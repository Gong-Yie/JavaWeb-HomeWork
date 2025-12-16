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

public class DutyServlet extends BaseServlet {

    private static Map<Integer, String> dutyMap = new HashMap<>();
    static {
        dutyMap.put(1, "星期一"); dutyMap.put(2, "星期二"); dutyMap.put(3, "星期三");
        dutyMap.put(4, "星期四"); dutyMap.put(5, "星期五"); dutyMap.put(6, "星期六"); dutyMap.put(7, "星期日");
    }

    // 值日列表
    public String dutyList(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        List<Student> list = new ArrayList<>();
        Connection conn = DBUtil.getConn();
        String sql = "SELECT * FROM t_student";
        PreparedStatement ps = conn.prepareStatement(sql);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Student s = new Student();
            s.setId(rs.getInt("id"));
            s.setName(rs.getString("name"));
            s.setStudentNo(rs.getString("student_no"));
            s.setDutyDay(rs.getInt("duty_day"));
            list.add(s);
        }
        DBUtil.close(conn, ps, rs);
        
        req.setAttribute("stList", list);
        req.setAttribute("dutyMap", dutyMap); 
        return "duty_roster.jsp"; 
    }

    // 跳转调整
    public String toEditDuty(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String id = req.getParameter("id");
        Connection conn = DBUtil.getConn();
        PreparedStatement ps = conn.prepareStatement("SELECT * FROM t_student WHERE id=?");
        ps.setString(1, id);
        ResultSet rs = ps.executeQuery();
        if(rs.next()){
            Student s = new Student();
            s.setId(rs.getInt("id"));
            s.setName(rs.getString("name"));
            s.setDutyDay(rs.getInt("duty_day"));
            req.setAttribute("stu", s);
        }
        DBUtil.close(conn, ps, rs);
        req.setAttribute("dutyMap", dutyMap); 
        return "edit_duty.jsp";
    }

    // 执行调整
    public String updateDuty(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String id = req.getParameter("id");
        String dutyDay = req.getParameter("dutyDay");
        Connection conn = DBUtil.getConn();
        PreparedStatement ps = conn.prepareStatement("UPDATE t_student SET duty_day=? WHERE id=?");
        ps.setString(1, dutyDay);
        ps.setString(2, id);
        ps.executeUpdate();
        DBUtil.close(conn, ps, null);
        return "redirect:duty?method=dutyList";
    }
}