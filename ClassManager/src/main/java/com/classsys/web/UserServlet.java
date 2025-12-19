package com.classsys.web;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
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

// 【修改点1】增大限制到 50MB，防止上传稍大的图片就报错
@MultipartConfig(maxFileSize = 1024 * 1024 * 50, maxRequestSize = 1024 * 1024 * 100)
public class UserServlet extends BaseServlet {

    // 1. 登录
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
            req.getSession().setAttribute("gender", rs.getString("gender"));

            DBUtil.close(conn, ps, rs);
            return "redirect:student?method=studentList";
        } else {
            req.setAttribute("msg", "账号密码错误");
            DBUtil.close(conn, ps, rs);
            return "login.jsp";
        }
    }

    // 2. 退出
    public String logout(HttpServletRequest req, HttpServletResponse resp) {
        req.getSession().invalidate();
        Cookie cookie = new javax.servlet.http.Cookie("access_token", "");
        cookie.setPath("/");
        cookie.setMaxAge(0);
        resp.addCookie(cookie);
        return "redirect:login.jsp";
    }

    // 3. 注册预加载
    public String toRegister(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        req.setAttribute("classList", getAllClasses());
        return "register.jsp";
    }

    // 4. 注册执行
    public String register(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String u = req.getParameter("username");
        String p = req.getParameter("password");
        String classIdStr = req.getParameter("classId");
        String name = req.getParameter("name");
        String gender = req.getParameter("gender");
        if(name == null) name = u; 
        if(gender == null) gender = "男";
        
        int classId = 1; 
        if (classIdStr != null && !classIdStr.trim().isEmpty()) {
            try { classId = Integer.parseInt(classIdStr); } catch (Exception e) { classId = 1; }
        }

        Connection conn = DBUtil.getConn();
        PreparedStatement ps = conn.prepareStatement("SELECT * FROM t_user WHERE username=?");
        ps.setString(1, u);
        if(ps.executeQuery().next()) {
            req.setAttribute("msg", "用户名已存在");
            DBUtil.close(conn, ps, null);
            return "register.jsp";
        }
        
        String insertUser = "INSERT INTO t_user (username, password, role, nickname, avatar, gender) VALUES (?, ?, 'student', ?, 'default.jpg', ?)";
        PreparedStatement psUser = conn.prepareStatement(insertUser);
        psUser.setString(1, u);
        psUser.setString(2, p);
        psUser.setString(3, name);
        psUser.setString(4, gender);
        psUser.executeUpdate();
        
        String insertStu = "INSERT INTO t_student (name, username, class_id, avatar, student_no, gender) VALUES (?, ?, ?, 'default.jpg', ?, ?)";
        PreparedStatement psStu = conn.prepareStatement(insertStu);
        psStu.setString(1, name);
        psStu.setString(2, u);
        psStu.setInt(3, classId);
        psStu.setString(4, "S" + System.currentTimeMillis() % 100000); 
        psStu.setString(5, gender);
        psStu.executeUpdate();

        DBUtil.close(conn, psStu, null);
        req.setAttribute("msg", "注册成功，请登录");
        return "login.jsp";
    }

    // 5. 个人信息展示
    public String myInfo(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String username = (String) req.getSession().getAttribute("user");
        if(username == null) return "redirect:login.jsp";
        
        Connection conn = DBUtil.getConn();
        String sql = "SELECT u.id, u.nickname, u.email, u.avatar, u.gender, " +
                     "s.student_no, s.phone, c.class_name " +
                     "FROM t_user u " +
                     "LEFT JOIN t_student s ON u.username = s.username " +
                     "LEFT JOIN t_class c ON s.class_id = c.id " +
                     "WHERE u.username = ?";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, username);
        ResultSet rs = ps.executeQuery();
        
        if(rs.next()){
            req.setAttribute("currUser_id", rs.getInt("id"));
            req.setAttribute("currUser_nick", rs.getString("nickname"));
            req.setAttribute("currUser_email", rs.getString("email"));
            req.setAttribute("currUser_avatar", rs.getString("avatar"));
            req.setAttribute("currUser_gender", rs.getString("gender"));
            req.setAttribute("currUser_no", rs.getString("student_no"));
            req.setAttribute("currUser_phone", rs.getString("phone"));
            req.setAttribute("currUser_class", rs.getString("class_name"));
        }
        DBUtil.close(conn, ps, rs);
        return "profile.jsp";
    }

    // 6. 修改个人信息 (保存到 webapp/photos)
    public String updateInfo(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        // 设置请求编码，防止表单普通字段乱码
        req.setCharacterEncoding("UTF-8");
        
        String username = (String) req.getSession().getAttribute("user");
        String nickname = req.getParameter("nickname");
        String gender = req.getParameter("gender");
        String email = req.getParameter("email"); 
        String phone = req.getParameter("phone"); 
        
        // 默认使用旧头像
        String avatarFilename = (String) req.getSession().getAttribute("avatar");
        if(avatarFilename == null) avatarFilename = "default.jpg";
        
        // --- 文件上传逻辑 (改用流写入，更稳定) ---
        Part part = req.getPart("avatarFile");
        
        if(part != null && part.getSize() > 0) {
            String cd = part.getHeader("content-disposition");
            String originalName = cd.substring(cd.lastIndexOf("filename=\"") + 10, cd.lastIndexOf("\""));
            String suffix = originalName.contains(".") ? originalName.substring(originalName.lastIndexOf(".")) : ".jpg";
            String newName = username + "_" + System.currentTimeMillis() + suffix;
            
            // 获取项目发布路径
            String savePath = req.getServletContext().getRealPath("/photos");
            
            // 调试信息：请在 Console 查看这个路径是否存在
            System.out.println("====== 头像上传调试 ======");
            System.out.println("目标文件夹: " + savePath);
            System.out.println("文件名: " + newName);
            System.out.println("文件大小: " + part.getSize());
            
            File fileDir = new File(savePath);
            if (!fileDir.exists()) {
                fileDir.mkdirs(); // 自动创建目录
                System.out.println("文件夹不存在，已自动创建");
            }
            
            // 【关键修改】使用流写入，解决 part.write 的路径兼容问题
            try (InputStream in = part.getInputStream();
                 FileOutputStream out = new FileOutputStream(savePath + File.separator + newName)) {
                byte[] buffer = new byte[1024];
                int length;
                while ((length = in.read(buffer)) > 0) {
                    out.write(buffer, 0, length);
                }
                System.out.println("写入成功！");
                avatarFilename = newName; // 更新文件名
            } catch (Exception e) {
                e.printStackTrace();
                System.out.println("写入失败: " + e.getMessage());
            }
        }
        
        Connection conn = DBUtil.getConn();
        
        // 更新用户表
        String sqlUser = "UPDATE t_user SET nickname=?, gender=?, avatar=?, email=? WHERE username=?";
        PreparedStatement ps = conn.prepareStatement(sqlUser);
        ps.setString(1, nickname);
        ps.setString(2, gender);
        ps.setString(3, avatarFilename);
        ps.setString(4, email);
        ps.setString(5, username);
        ps.executeUpdate();
        
        // 更新学生表
        String sqlStu = "UPDATE t_student SET name=?, gender=?, avatar=?, phone=? WHERE username=?";
        PreparedStatement psStu = conn.prepareStatement(sqlStu);
        psStu.setString(1, nickname);
        psStu.setString(2, gender);
        psStu.setString(3, avatarFilename);
        psStu.setString(4, phone);
        psStu.setString(5, username);
        psStu.executeUpdate();
        
        DBUtil.close(conn, ps, null);
        
        // 更新 Session
        req.getSession().setAttribute("nickname", nickname);
        req.getSession().setAttribute("avatar", avatarFilename);
        req.getSession().setAttribute("gender", gender);
        
        return "redirect:user?method=myInfo";
    }

    // 7. 添加管理员
    public String addAdmin(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String u = req.getParameter("username");
        String p = req.getParameter("password");
        String nick = req.getParameter("nickname");
        String gender = req.getParameter("gender"); // 获取性别
        
        
        if (u == null || u.trim().isEmpty()) { req.setAttribute("msg", "用户名不能为空"); return "add_admin.jsp"; }
        
        Connection conn = DBUtil.getConn();
        PreparedStatement check = conn.prepareStatement("SELECT * FROM t_user WHERE username=?");
        check.setString(1, u);
        if(check.executeQuery().next()){
            req.setAttribute("msg", "管理员账号已存在");
            DBUtil.close(conn, check, null);
            return "add_admin.jsp";
        }
        
        String sql = "INSERT INTO t_user (username, password, role, nickname, avatar, gender) VALUES (?, ?, 'admin', ?, 'default.jpg', ?)";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, u);
        ps.setString(2, p);
        ps.setString(3, nick);
        ps.setString(4, gender != null ? gender : "男");
        ps.executeUpdate();
        
        DBUtil.close(conn, ps, null);
        req.setAttribute("msg", "管理员 " + u + " 添加成功！");
        return "add_admin.jsp";
    }

    // 辅助
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