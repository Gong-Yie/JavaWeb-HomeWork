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
import com.fasterxml.jackson.databind.ObjectMapper;
import java.io.PrintWriter;

public class MessageServlet extends BaseServlet {

    // 留言列表
    public String messageList(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        List<Map<String, String>> list = new ArrayList<>();
        Connection conn = DBUtil.getConn();
        PreparedStatement ps = conn.prepareStatement("SELECT * FROM t_message ORDER BY create_time DESC");
        ResultSet rs = ps.executeQuery();
        while(rs.next()){
            Map<String, String> m = new HashMap<>();
            m.put("id", rs.getString("id")); 
            m.put("username", rs.getString("username"));
            m.put("content", rs.getString("content"));
            m.put("time", rs.getString("create_time"));
            list.add(m);
        }
        DBUtil.close(conn, ps, rs);
        req.setAttribute("msgList", list);
        return "message_board.jsp";
    }

    // 发布留言
    public String addMessage(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String content = req.getParameter("content");
        String user = (String) req.getSession().getAttribute("user");
        Connection conn = DBUtil.getConn();
        PreparedStatement ps = conn.prepareStatement("INSERT INTO t_message (username, content) VALUES (?, ?)");
        ps.setString(1, user);
        ps.setString(2, content);
        ps.executeUpdate();
        DBUtil.close(conn, ps, null);
        return "redirect:message?method=messageList";
    }

    // 删除留言
    public String deleteMessage(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String id = req.getParameter("id");
        Connection conn = DBUtil.getConn();
        PreparedStatement ps = conn.prepareStatement("DELETE FROM t_message WHERE id=?");
        ps.setString(1, id);
        ps.executeUpdate();
        DBUtil.close(conn, ps, null);
        return "redirect:message?method=messageList";
    }

    // 进入聊天室
 // 进入聊天室，加载联系人列表及未读数
    public String toChat(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String currentUser = (String) req.getSession().getAttribute("user");
        
        Connection conn = DBUtil.getConn();
        
        // 核心修改：使用子查询统计 unread_count
        // 统计条件：发送者是对方，接收者是我，且状态是 0 (未读)
        String sql = "SELECT u.username, u.nickname, u.avatar, " +
                     "(SELECT COUNT(*) FROM t_chat_msg m WHERE m.sender = u.username AND m.receiver = ? AND m.is_read = 0) AS unread_count " +
                     "FROM t_user u WHERE u.username != ?";
                     
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, currentUser);
        ps.setString(2, currentUser);
        ResultSet rs = ps.executeQuery();
        
        List<Map<String, Object>> contacts = new ArrayList<>();
        while(rs.next()){
            Map<String, Object> m = new HashMap<>();
            m.put("username", rs.getString("username"));
            m.put("nickname", rs.getString("nickname"));
            
            String ava = rs.getString("avatar");
            if(ava == null || ava.isEmpty()) ava = "default.jpg";
            m.put("avatar", ava);
            
            // 获取未读数
            m.put("unread", rs.getInt("unread_count"));
            
            contacts.add(m);
        }
        DBUtil.close(conn, ps, rs);
        
        req.setAttribute("contacts", contacts);
        return "chat.jsp";
    }
    /**
     * 获取历史聊天记录 (AJAX接口)
     * URL: message?method=getHistory&receiver=zhangsan
     */
    public void getHistory(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        // 1. 设置响应格式为 JSON
        resp.setContentType("application/json;charset=UTF-8");
        
        String me = (String) req.getSession().getAttribute("user");
        String he = req.getParameter("receiver");
        
        List<Map<String, String>> list = new ArrayList<>();
        Connection conn = DBUtil.getConn();
        
        // 2. 查询我和他，或者他和我发送的所有消息，按时间正序排列
        String sql = "SELECT * FROM t_chat_msg " +
                     "WHERE (sender=? AND receiver=?) OR (sender=? AND receiver=?) " +
                     "ORDER BY id ASC"; // 按ID或时间排序
        
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, me);
        ps.setString(2, he);
        ps.setString(3, he);
        ps.setString(4, me);
        
        ResultSet rs = ps.executeQuery();
        while(rs.next()){
            Map<String, String> m = new HashMap<>();
            m.put("sender", rs.getString("sender"));
            m.put("receiver", rs.getString("receiver"));
            m.put("content", rs.getString("content"));
            m.put("time", rs.getString("create_time")); // 确保数据库列名一致
            list.add(m);
        }
        DBUtil.close(conn, ps, rs);
        
        // 3. 将 List 转为 JSON 字符串输出
        ObjectMapper mapper = new ObjectMapper();
        PrintWriter out = resp.getWriter();
        out.print(mapper.writeValueAsString(list));
        out.flush();
        out.close();
    }
    /**
     * 将指定发送者发给我的消息标记为已读
     * URL: message?method=markRead&sender=zhangsan
     */
    public void markRead(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String sender = req.getParameter("sender");
        String me = (String) req.getSession().getAttribute("user");
        
        Connection conn = DBUtil.getConn();
        String sql = "UPDATE t_chat_msg SET is_read = 1 WHERE sender = ? AND receiver = ?";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, sender);
        ps.setString(2, me);
        ps.executeUpdate();
        
        DBUtil.close(conn, ps, null);
        
        // 不需要返回页面，只需返回状态码200即可
        resp.setStatus(200); 
    }
}