package com.classsys.web;

import java.io.IOException;
import java.lang.reflect.Method;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * 核心控制器：利用反射机制分发请求
 * 满足选题要求2：利用反射机制，实现将字符串作为函数名调用
 */
public class BaseServlet extends HttpServlet {
    @Override
    protected void service(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("text/html;charset=UTF-8");
        resp.setCharacterEncoding("UTF-8");
        // 获取请求参数中的方法名，例如：userServlet?method=login
        String methodName = req.getParameter("method");

        if (methodName == null || methodName.trim().isEmpty()) {
            methodName = "index"; // 默认方法
        }

     // ... 前面的代码不变 ...
        try {
            Method method = this.getClass().getMethod(methodName, HttpServletRequest.class, HttpServletResponse.class);
            String path = (String) method.invoke(this, req, resp);
            
            if (path != null) {
                // 如果是以 redirect: 开头的，则重定向（优化体验）
                if (path.startsWith("redirect:")) {
                    resp.sendRedirect(path.substring(9));
                } else {
                    req.getRequestDispatcher(path).forward(req, resp);
                }
            }
        } catch (Exception e) {
            e.printStackTrace(); // 务必在 Eclipse 控制台看详细报错！！！
            
            // 获取原始的报错原因（剥离反射包装）
            Throwable cause = e.getCause();
            String errorMsg = (cause == null) ? e.toString() : cause.toString();
            
            // 在网页上显示具体错误
            resp.getWriter().write("<h2>系统运行出错</h2>");
            resp.getWriter().write("<p>错误详情: " + errorMsg + "</p>");
            resp.getWriter().write("<p>请检查 Eclipse 控制台(Console)获取完整堆栈信息。</p>");
        }
        // ...
    }
    
    public String index(HttpServletRequest req, HttpServletResponse resp) {
        return null;
    }
}