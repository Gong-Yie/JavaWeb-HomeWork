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

    // 1. 值日列表 (含关键词和性别搜索)
    public String dutyList(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String dayStr = req.getParameter("queryDay");
        String keyword = req.getParameter("keyword"); 
        String gender = req.getParameter("gender");
        
        int queryDay = (dayStr != null && !dayStr.isEmpty()) ? Integer.parseInt(dayStr) : 0; 

        List<Student> list = new ArrayList<>();
        Map<Integer, Integer> stats = new HashMap<>();
        for(int i=1; i<=7; i++) stats.put(i, 0);

        Connection conn = DBUtil.getConn();
        
        // 统计
        String statSql = "SELECT duty_day, COUNT(*) as cnt FROM t_student GROUP BY duty_day";
        ResultSet rsStat = conn.createStatement().executeQuery(statSql);
        while(rsStat.next()){
            stats.put(rsStat.getInt("duty_day"), rsStat.getInt("cnt"));
        }
        
        // 查询
        StringBuilder sql = new StringBuilder("SELECT * FROM t_student WHERE 1=1 ");
        
        if(queryDay > 0) sql.append(" AND duty_day = ").append(queryDay);
        
        if(gender != null && !gender.isEmpty() && !"all".equals(gender)) {
            sql.append(" AND gender = '").append(gender).append("'");
        }
        
        if(keyword != null && !keyword.trim().isEmpty()) {
            String k = keyword.replace("'", "");
            sql.append(" AND (name LIKE '%").append(k).append("%'")
               .append(" OR student_no LIKE '%").append(k).append("%')");
        }
        
        sql.append(" ORDER BY duty_day ASC");
        
        PreparedStatement ps = conn.prepareStatement(sql.toString());
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Student s = new Student();
            s.setId(rs.getInt("id"));
            s.setName(rs.getString("name"));
            s.setStudentNo(rs.getString("student_no"));
            s.setGender(rs.getString("gender"));
            s.setDutyDay(rs.getInt("duty_day"));
            list.add(s);
        }
        DBUtil.close(conn, ps, rs);
        
        req.setAttribute("stList", list);
        req.setAttribute("dutyMap", dutyMap); 
        req.setAttribute("dutyStats", stats); 
        req.setAttribute("queryDay", queryDay);
        req.setAttribute("keyword", keyword);
        req.setAttribute("gender", gender);
        
        return "duty_roster.jsp"; 
    }

    // 2. 跳转调整
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

    // 3. 执行调整
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