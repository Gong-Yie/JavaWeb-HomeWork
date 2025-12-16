package com.classsys.web;

import java.io.File;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

import com.classsys.util.DBUtil;
import com.classsys.util.JwtUtil;

@MultipartConfig(maxFileSize = 1024 * 1024 * 10)
public class UserServlet extends BaseServlet {

    // 登录
    public String login(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String inputCode = req.getParameter("captcha");
        String sessionCode = (String) req.getSession().getAttribute("CHECK_CODE");
        req.getSession().removeAttribute("CHECK_CODE");

        if (inputCode == null || !inputCode.equalsIgnoreCase(sessionCode)) {
            req.setAttribute("msg", "验证码错误");
            return "login.jsp";
        }

        String u = req.getParameter("username");
        String p = req.getParameter("password");
        String role = req.getParameter("role");

        Connection conn = DBUtil.getConn();
        String sql = "SELECT * FROM t_user WHERE username=? AND password=? AND role=?";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, u);
        ps.setString(2, p);
        ps.setString(3, role);
        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
            String token = JwtUtil.createToken(u, role);
            Cookie cookie = new Cookie("access_token", token);
            cookie.setPath("/");
            cookie.setMaxAge(60 * 60);
            cookie.setHttpOnly(true);
            resp.addCookie(cookie);

            req.getSession().setAttribute("user", u);
            req.getSession().setAttribute("role", role);
            req.getSession().setAttribute("nickname", rs.getString("nickname"));
            req.getSession().setAttribute("avatar", rs.getString("avatar"));

            DBUtil.close(conn, ps, rs);
            // 注意：跳转到 student 模块
            return "redirect:index.jsp";
        } else {
            req.setAttribute("msg", "账号密码错误");
            DBUtil.close(conn, ps, rs);
            return "login.jsp";
        }
    }

    // 退出
    public String logout(HttpServletRequest req, HttpServletResponse resp) {
        req.getSession().invalidate();
        Cookie cookie = new javax.servlet.http.Cookie("access_token", "");
        cookie.setPath("/");
        cookie.setMaxAge(0);
        resp.addCookie(cookie);
        return "redirect:login.jsp";
    }

    // 注册预加载
    public String toRegister(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        req.setAttribute("classList", getAllClasses());
        return "register.jsp";
    }

    // 注册执行
    public String register(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String u = req.getParameter("username");
        String p = req.getParameter("password");
        String classIdStr = req.getParameter("classId");
        String name = req.getParameter("name");
        if(name == null) name = u; 
        
        int classId = 1; 
        if (classIdStr != null && !classIdStr.trim().isEmpty()) {
            try { classId = Integer.parseInt(classIdStr); } catch (Exception e) { classId = 1; }
        }

        Connection conn = DBUtil.getConn();
        // 查重
        PreparedStatement ps = conn.prepareStatement("SELECT * FROM t_user WHERE username=?");
        ps.setString(1, u);
        if(ps.executeQuery().next()) {
            req.setAttribute("msg", "用户名已存在");
            DBUtil.close(conn, ps, null);
            return "register.jsp";
        }
        
        // 插入用户
        String insertUser = "INSERT INTO t_user (username, password, role, nickname, avatar) VALUES (?, ?, 'student', ?, 'default.jpg')";
        PreparedStatement psUser = conn.prepareStatement(insertUser);
        psUser.setString(1, u);
        psUser.setString(2, p);
        psUser.setString(3, name);
        psUser.executeUpdate();
        
        // 插入学生
        String insertStu = "INSERT INTO t_student (name, username, class_id, avatar, student_no) VALUES (?, ?, ?, 'default.jpg', ?)";
        PreparedStatement psStu = conn.prepareStatement(insertStu);
        psStu.setString(1, name);
        psStu.setString(2, u);
        psStu.setInt(3, classId);
        psStu.setString(4, "S" + System.currentTimeMillis() % 100000); 
        psStu.executeUpdate();

        DBUtil.close(conn, psStu, null);
        req.setAttribute("msg", "注册成功，请登录");
        return "login.jsp";
    }

    // 个人信息
    public String myInfo(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String username = (String) req.getSession().getAttribute("user");
        if(username == null) return "redirect:login.jsp";
        
        Connection conn = DBUtil.getConn();
        PreparedStatement ps = conn.prepareStatement("SELECT * FROM t_user WHERE username=?");
        ps.setString(1, username);
        ResultSet rs = ps.executeQuery();
        if(rs.next()){
            req.setAttribute("currUser_id", rs.getInt("id"));
            req.setAttribute("currUser_nick", rs.getString("nickname"));
            req.setAttribute("currUser_email", rs.getString("email"));
            req.setAttribute("currUser_avatar", rs.getString("avatar"));
        }
        DBUtil.close(conn, ps, rs);
        return "profile.jsp";
    }

    // 修改个人信息
    public String updateInfo(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String username = (String) req.getSession().getAttribute("user");
        String nickname = req.getParameter("nickname");
        String avatarFilename = (String) req.getSession().getAttribute("avatar");
        
        Part part = req.getPart("avatarFile");
        if(part != null && part.getSize() > 0) {
            String cd = part.getHeader("content-disposition");
            String originalName = cd.substring(cd.lastIndexOf("filename=\"") + 10, cd.lastIndexOf("\""));
            String suffix = originalName.contains(".") ? originalName.substring(originalName.lastIndexOf(".")) : "";
            String newName = username + "_" + System.currentTimeMillis() + suffix;
            
            String savePath = "E:/class_photos"; 
            File fileDir = new File(savePath);
            if (!fileDir.exists()) fileDir.mkdirs();
            part.write(savePath + File.separator + newName);
            avatarFilename = newName; 
        }
        
        Connection conn = DBUtil.getConn();
        String sqlUser = "UPDATE t_user SET nickname=?, avatar=? WHERE username=?";
        PreparedStatement ps = conn.prepareStatement(sqlUser);
        ps.setString(1, nickname);
        ps.setString(2, avatarFilename);
        ps.setString(3, username);
        ps.executeUpdate();
        
        String sqlStu = "UPDATE t_student SET name=?, avatar=? WHERE username=?";
        PreparedStatement psStu = conn.prepareStatement(sqlStu);
        psStu.setString(1, nickname);
        psStu.setString(2, avatarFilename);
        psStu.setString(3, username);
        psStu.executeUpdate();
        
        DBUtil.close(conn, ps, null);
        req.getSession().setAttribute("nickname", nickname);
        req.getSession().setAttribute("avatar", avatarFilename);
        
        // 注意：跳转回 user 模块
        return "redirect:user?method=myInfo";
    }

 // 添加管理员
    public String addAdmin(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String u = req.getParameter("username");
        String p = req.getParameter("password");
        String nick = req.getParameter("nickname");
        
        // --- 调试打印 ---
        System.out.println("--- 执行添加管理员 ---");
        System.out.println("Username: " + u);
        System.out.println("Password: " + p);
        
        // --- 增加防空判断 ---
        if (u == null || u.trim().isEmpty()) {
            req.setAttribute("msg", "错误：用户名不能为空");
            return "add_admin.jsp";
        }
        
        Connection conn = DBUtil.getConn();
        PreparedStatement check = conn.prepareStatement("SELECT * FROM t_user WHERE username=?");
        check.setString(1, u);
        if(check.executeQuery().next()){
            req.setAttribute("msg", "错误：管理员账号已存在");
            DBUtil.close(conn, check, null);
            return "add_admin.jsp";
        }
        
        String sql = "INSERT INTO t_user (username, password, role, nickname, avatar) VALUES (?, ?, 'admin', ?, 'default.jpg')";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, u);
        ps.setString(2, p);
        ps.setString(3, nick);
        ps.executeUpdate();
        
        DBUtil.close(conn, ps, null);
        req.setAttribute("msg", "管理员 " + u + " 添加成功！");
        return "add_admin.jsp";
    }
    // 辅助：获取班级
    private List<Map<String, Object>> getAllClasses() throws Exception {
        List<Map<String, Object>> classes = new ArrayList<>();
        Connection conn = DBUtil.getConn();
        ResultSet rs = conn.createStatement().executeQuery("SELECT * FROM t_class");
        while(rs.next()){
            Map<String, Object> m = new HashMap<>();
            m.put("id", rs.getInt("id"));
            m.put("name", rs.getString("class_name"));
            classes.add(m);
        }
        DBUtil.close(conn, null, rs);
        return classes;
    }
}