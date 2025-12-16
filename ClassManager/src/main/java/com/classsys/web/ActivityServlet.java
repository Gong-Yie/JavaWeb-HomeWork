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

import com.classsys.util.DBUtil;

public class ActivityServlet extends BaseServlet {

    // 活动列表
    public String activityList(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        List<Map<String, String>> list = new ArrayList<>();
        Connection conn = DBUtil.getConn();
        PreparedStatement ps = conn.prepareStatement("SELECT * FROM t_activity");
        ResultSet rs = ps.executeQuery();
        while(rs.next()){
            Map<String, String> m = new HashMap<>();
            m.put("id", rs.getString("id"));
            m.put("title", rs.getString("title"));
            m.put("content", rs.getString("content"));
            m.put("organizer", rs.getString("organizer"));
            m.put("act_date", rs.getString("act_date"));
            list.add(m);
        }
        DBUtil.close(conn, ps, rs);
        req.setAttribute("actList", list);
        return "activity_list.jsp";
    }

    // 跳转表单
    public String toActivityForm(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String id = req.getParameter("id");
        if(id != null && !id.isEmpty()){
            Connection conn = DBUtil.getConn();
            PreparedStatement ps = conn.prepareStatement("SELECT * FROM t_activity WHERE id=?");
            ps.setString(1, id);
            ResultSet rs = ps.executeQuery();
            if(rs.next()){
                Map<String, String> act = new HashMap<>();
                act.put("id", rs.getString("id"));
                act.put("title", rs.getString("title"));
                act.put("content", rs.getString("content"));
                act.put("organizer", rs.getString("organizer"));
                act.put("act_date", rs.getString("act_date"));
                req.setAttribute("act", act);
            }
            DBUtil.close(conn, ps, rs);
        }
        return "activity_form.jsp";
    }

    // 保存
    public String saveActivity(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String id = req.getParameter("id");
        String title = req.getParameter("title");
        String content = req.getParameter("content");
        String organizer = req.getParameter("organizer");
        String actDate = req.getParameter("act_date");
        
        Connection conn = DBUtil.getConn();
        PreparedStatement ps = null;
        
        if(id == null || id.isEmpty()){
            String sql = "INSERT INTO t_activity (title, content, organizer, act_date) VALUES (?, ?, ?, ?)";
            ps = conn.prepareStatement(sql);
            ps.setString(1, title);
            ps.setString(2, content);
            ps.setString(3, organizer);
            ps.setString(4, actDate);
        } else {
            String sql = "UPDATE t_activity SET title=?, content=?, organizer=?, act_date=? WHERE id=?";
            ps = conn.prepareStatement(sql);
            ps.setString(1, title);
            ps.setString(2, content);
            ps.setString(3, organizer);
            ps.setString(4, actDate);
            ps.setString(5, id);
        }
        ps.executeUpdate();
        DBUtil.close(conn, ps, null);
        return "redirect:activity?method=activityList";
    }

    // 删除
    public String deleteActivity(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String id = req.getParameter("id");
        Connection conn = DBUtil.getConn();
        PreparedStatement ps = conn.prepareStatement("DELETE FROM t_activity WHERE id=?");
        ps.setString(1, id);
        ps.executeUpdate();
        DBUtil.close(conn, ps, null);
        return "redirect:activity?method=activityList";
    }
}