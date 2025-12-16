package com.classsys.web;

import java.io.IOException;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import com.classsys.util.JwtUtil;

@WebFilter("/*")
public class LoginFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        String uri = req.getRequestURI();
        
        // 获取 method 参数
        String method = req.getParameter("method");

        // 1. 【白名单放行】不需要登录就能访问的资源
        if (uri.contains("login.jsp") || uri.contains("register.jsp") || 
            uri.contains(".css") || uri.contains(".js") || uri.contains(".jpg") || uri.contains(".png") ||
            uri.contains("captcha") || 
            // 放行 WebSocket 握手请求 (ws://...)
            uri.contains("/chat/") ||
            // 放行 UserServlet 中的登录、注册、跳转注册页
            (uri.contains("user") && "login".equals(method)) ||
            (uri.contains("user") && "register".equals(method)) ||
            (uri.contains("user") && "toRegister".equals(method))) {
            
            chain.doFilter(req, resp);
            return;
        }

        // 2. 获取 Token Cookie
        String token = null;
        Cookie[] cookies = req.getCookies();
        if (cookies != null) {
            for (Cookie c : cookies) {
                if ("access_token".equals(c.getName())) {
                    token = c.getValue();
                    break;
                }
            }
        }

        // 3. 校验 Token (时间戳验证在 JwtUtil 内部自动完成)
        String user = null;
        if (token != null) {
            user = JwtUtil.verifyToken(token);
        }

        if (user != null) {
            // 验证通过！
            // 关键步骤：如果你 Session 掉了（比如重启了服务器），这里会根据 Token 帮你把 User 塞回去
            // 这样 markRead, toChat 等方法就能从 Session 里取到数据了
            if (req.getSession().getAttribute("user") == null) {
                req.getSession().setAttribute("user", user);
                req.getSession().setAttribute("role", JwtUtil.getRole(token));
            }
            chain.doFilter(req, resp);
        } else {
            // 4. 验证失败或过期 -> 重定向到登录页
            resp.sendRedirect("login.jsp?msg=expired");
        }
    }

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}
    @Override
    public void destroy() {}
}