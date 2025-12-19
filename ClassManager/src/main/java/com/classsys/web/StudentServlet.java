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

    // 1. 学生列表 (支持：分页 + 班级筛选 + 性别筛选 + 关键词搜索 + 排序)
    public String studentList(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String cidStr = req.getParameter("classId");
        String pageStr = req.getParameter("page");
        String sort = req.getParameter("sort");
        String keyword = req.getParameter("keyword"); // 搜学号/姓名/电话
        String gender = req.getParameter("gender");   // 搜性别
        
        int classId = (cidStr != null && !cidStr.isEmpty()) ? Integer.parseInt(cidStr) : 0;
        int page = (pageStr != null && !pageStr.isEmpty()) ? Integer.parseInt(pageStr) : 1;
        int pageSize = 5; 
        int offset = (page - 1) * pageSize;

        Connection conn = DBUtil.getConn();
        
        // 构造动态 SQL
        StringBuilder sqlBuilder = new StringBuilder(" FROM t_student s LEFT JOIN t_class c ON s.class_id = c.id WHERE 1=1 ");
        
        if(classId > 0) {
            sqlBuilder.append(" AND s.class_id = ").append(classId);
        }
        
        if(gender != null && !gender.isEmpty() && !"all".equals(gender)) {
            sqlBuilder.append(" AND s.gender = '").append(gender).append("'");
        }
        
        if(keyword != null && !keyword.trim().isEmpty()) {
            // 简单的防注入处理，实际建议用 PreparedStatement 参数化
            String k = keyword.replace("'", ""); 
            sqlBuilder.append(" AND (s.name LIKE '%").append(k).append("%'")
                      .append(" OR s.student_no LIKE '%").append(k).append("%'")
                      .append(" OR s.phone LIKE '%").append(k).append("%')");
        }

        // --- 查询列表 ---
        StringBuilder listSql = new StringBuilder("SELECT s.*, c.class_name ").append(sqlBuilder);
        
        if("id_desc".equals(sort)) listSql.append(" ORDER BY s.id DESC");
        else listSql.append(" ORDER BY s.id ASC");
        
        listSql.append(" LIMIT ").append(offset).append(",").append(pageSize);

        PreparedStatement ps = conn.prepareStatement(listSql.toString());
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
            s.setGender(rs.getString("gender")); // 读取性别
            list.add(s);
        }
        
        // --- 统计总数 ---
        String countSql = "SELECT COUNT(*) " + sqlBuilder.toString();
        ResultSet rsCount = conn.createStatement().executeQuery(countSql);
        rsCount.next();
        int total = rsCount.getInt(1);
        int totalPage = (int) Math.ceil(total * 1.0 / pageSize);

        DBUtil.close(conn, ps, rs);

        // 回传数据
        req.setAttribute("stList", list);
        req.setAttribute("classList", getAllClasses()); 
        req.setAttribute("currClassId", classId);
        req.setAttribute("currPage", page);
        req.setAttribute("totalPage", totalPage);
        req.setAttribute("currSort", sort);
        req.setAttribute("keyword", keyword);
        req.setAttribute("gender", gender);

        return "student_list.jsp";
    }

    // 2. 跳转新增
    public String toAddStudent(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        req.setAttribute("classList", getAllClasses());
        return "add_student.jsp";
    }

    // 3. 执行新增 (加入性别)
    public String addStudent(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String name = req.getParameter("name");
        String phone = req.getParameter("phone");
        String gender = req.getParameter("gender"); // 获取性别
        int classId = Integer.parseInt(req.getParameter("classId"));
        String username = "stu_" + System.currentTimeMillis() % 10000;
        String studentNo = req.getParameter("studentNo");
        
        // 默认性别
        if(gender == null || gender.isEmpty()) gender = "男";
        
        Connection conn = DBUtil.getConn();
        
        // 创建账号
        String sqlUser = "INSERT INTO t_user (username, password, role, nickname, avatar, gender) VALUES (?, '123456', 'student', ?, 'default.jpg', ?)";
        PreparedStatement psUser = conn.prepareStatement(sqlUser);
        psUser.setString(1, username);
        psUser.setString(2, name);
        psUser.setString(3, gender);
        psUser.executeUpdate();
        
        // 创建档案
        String sqlStu = "INSERT INTO t_student (name, student_no, phone, class_id, username, avatar, gender) VALUES (?, ?, ?, ?, ?, 'default.jpg', ?)";
        PreparedStatement psStu = conn.prepareStatement(sqlStu);
        psStu.setString(1, name);
        psStu.setString(2, studentNo);
        psStu.setString(3, phone);
        psStu.setInt(4, classId);
        psStu.setString(5, username);
        psStu.setString(6, gender);
        psStu.executeUpdate();
        
        DBUtil.close(conn, psStu, null);
        return "redirect:student?method=studentList";
    }

    // 4. 跳转修改
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
            s.setGender(rs.getString("gender")); // 读取性别
            req.setAttribute("stu", s);
        }
        DBUtil.close(conn, ps, rs);
        req.setAttribute("classList", getAllClasses());
        return "edit_student.jsp";
    }

    // 5. 执行修改 (加入性别)
    public String updateStudent(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        int id = Integer.parseInt(req.getParameter("id"));
        String name = req.getParameter("name");
        String studentNo = req.getParameter("studentNo");
        String phone = req.getParameter("phone");
        String gender = req.getParameter("gender"); // 获取性别
        int classId = Integer.parseInt(req.getParameter("classId"));
        String username = req.getParameter("username");
        
        Connection conn = DBUtil.getConn();
        
        // 更新学生表
        String sqlStu = "UPDATE t_student SET name=?, student_no=?, phone=?, class_id=?, gender=? WHERE id=?";
        PreparedStatement ps = conn.prepareStatement(sqlStu);
        ps.setString(1, name);
        ps.setString(2, studentNo);
        ps.setString(3, phone);
        ps.setInt(4, classId);
        ps.setString(5, gender);
        ps.setInt(6, id);
        ps.executeUpdate();
        
        // 同步更新用户表
        if(username != null && !username.isEmpty()){
            String sqlUser = "UPDATE t_user SET nickname=?, gender=? WHERE username=?";
            PreparedStatement psUser = conn.prepareStatement(sqlUser);
            psUser.setString(1, name);
            psUser.setString(2, gender);
            psUser.setString(3, username);
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