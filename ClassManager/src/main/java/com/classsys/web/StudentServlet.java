package com.classsys.web;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.classsys.model.Student;
import com.classsys.util.DBUtil;

public class StudentServlet extends BaseServlet {

    // 学生列表
    public String studentList(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String cidStr = req.getParameter("classId");
        String pageStr = req.getParameter("page");
        String sort = req.getParameter("sort");
        
        int classId = (cidStr != null && !cidStr.isEmpty()) ? Integer.parseInt(cidStr) : 0;
        int page = (pageStr != null && !pageStr.isEmpty()) ? Integer.parseInt(pageStr) : 1;
        int pageSize = 5; 
        int offset = (page - 1) * pageSize;

        Connection conn = DBUtil.getConn();
        StringBuilder sql = new StringBuilder("SELECT s.*, c.class_name FROM t_student s LEFT JOIN t_class c ON s.class_id = c.id WHERE 1=1 ");
        if(classId > 0) sql.append(" AND s.class_id = " + classId);
        if("id_desc".equals(sort)) sql.append(" ORDER BY s.id DESC");
        else sql.append(" ORDER BY s.id ASC");
        sql.append(" LIMIT " + offset + "," + pageSize);

        PreparedStatement ps = conn.prepareStatement(sql.toString());
        ResultSet rs = ps.executeQuery();
        List<Student> list = new ArrayList<>();
        while(rs.next()){
            Student s = new Student();
            s.setId(rs.getInt("id"));
            s.setName(rs.getString("name"));
            s.setStudentNo(rs.getString("student_no"));
            s.setPhone(rs.getString("phone"));
            s.setAvatar(rs.getString("avatar"));
            s.setClassName(rs.getString("class_name"));
            list.add(s);
        }
        
        String countSql = "SELECT COUNT(*) FROM t_student WHERE 1=1 " + (classId > 0 ? " AND class_id="+classId : "");
        ResultSet rsCount = conn.createStatement().executeQuery(countSql);
        rsCount.next();
        int total = rsCount.getInt(1);
        int totalPage = (int) Math.ceil(total * 1.0 / pageSize);

        DBUtil.close(conn, ps, rs);

        req.setAttribute("stList", list);
        req.setAttribute("classList", getAllClasses()); 
        req.setAttribute("currClassId", classId);
        req.setAttribute("currPage", page);
        req.setAttribute("totalPage", totalPage);
        req.setAttribute("currSort", sort);

        return "student_list.jsp";
    }

    // 跳转新增
    public String toAddStudent(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        req.setAttribute("classList", getAllClasses());
        return "add_student.jsp";
    }

    // 执行新增
    public String addStudent(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String name = req.getParameter("name");
        String phone = req.getParameter("phone");
        int classId = Integer.parseInt(req.getParameter("classId"));
        String username = "stu_" + System.currentTimeMillis() % 10000;
        String studentNo = req.getParameter("studentNo");
        
        Connection conn = DBUtil.getConn();
        // 账号
        String sqlUser = "INSERT INTO t_user (username, password, role, nickname, avatar) VALUES (?, '123456', 'student', ?, 'default.jpg')";
        PreparedStatement psUser = conn.prepareStatement(sqlUser);
        psUser.setString(1, username);
        psUser.setString(2, name);
        psUser.executeUpdate();
        // 档案
        String sqlStu = "INSERT INTO t_student (name, student_no, phone, class_id, username, avatar) VALUES (?, ?, ?, ?, ?, 'default.jpg')";
        PreparedStatement psStu = conn.prepareStatement(sqlStu);
        psStu.setString(1, name);
        psStu.setString(2, studentNo);
        psStu.setString(3, phone);
        psStu.setInt(4, classId);
        psStu.setString(5, username);
        psStu.executeUpdate();
        
        DBUtil.close(conn, psStu, null);
        return "redirect:student?method=studentList";
    }

    // 跳转修改
    public String toEditStudent(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String id = req.getParameter("id");
        Connection conn = DBUtil.getConn();
        PreparedStatement ps = conn.prepareStatement("SELECT * FROM t_student WHERE id=?");
        ps.setString(1, id);
        ResultSet rs = ps.executeQuery();
        if(rs.next()){
            Student s = new Student();
            s.setId(rs.getInt("id"));
            s.setName(rs.getString("name"));
            s.setStudentNo(rs.getString("student_no"));
            s.setPhone(rs.getString("phone"));
            s.setClassId(rs.getInt("class_id"));
            s.setUsername(rs.getString("username"));
            req.setAttribute("stu", s);
        }
        DBUtil.close(conn, ps, rs);
        req.setAttribute("classList", getAllClasses());
        return "edit_student.jsp";
    }

    // 执行修改
    public String updateStudent(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        int id = Integer.parseInt(req.getParameter("id"));
        String name = req.getParameter("name");
        String studentNo = req.getParameter("studentNo");
        String phone = req.getParameter("phone");
        int classId = Integer.parseInt(req.getParameter("classId"));
        String username = req.getParameter("username");
        
        Connection conn = DBUtil.getConn();
        String sqlStu = "UPDATE t_student SET name=?, student_no=?, phone=?, class_id=? WHERE id=?";
        PreparedStatement ps = conn.prepareStatement(sqlStu);
        ps.setString(1, name);
        ps.setString(2, studentNo);
        ps.setString(3, phone);
        ps.setInt(4, classId);
        ps.setInt(5, id);
        ps.executeUpdate();
        
        if(username != null && !username.isEmpty()){
            String sqlUser = "UPDATE t_user SET nickname=? WHERE username=?";
            PreparedStatement psUser = conn.prepareStatement(sqlUser);
            psUser.setString(1, name);
            psUser.setString(2, username);
            psUser.executeUpdate();
        }
        DBUtil.close(conn, ps, null);
        return "redirect:student?method=studentList";
    }

    // 辅助获取班级
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