package com.classsys.socket;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import javax.websocket.OnClose;
import javax.websocket.OnError;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.PathParam;
import javax.websocket.server.ServerEndpoint;

import com.classsys.util.DBUtil;
import com.fasterxml.jackson.databind.ObjectMapper;

/**
 * WebSocket 服务端
 * 访问地址: ws://localhost:8080/ClassManager/chat/{username}
 */
@ServerEndpoint("/chat/{username}")
public class WebSocketServer {

    // 静态变量，用来记录当前在线连接数。Map存 <用户名, Session>
    private static Map<String, Session> clients = new ConcurrentHashMap<>();
    
    private String username;
    private Session session;
    private static ObjectMapper mapper = new ObjectMapper();

    @OnOpen
    public void onOpen(@PathParam("username") String username, Session session) {
        this.username = username;
        this.session = session;
        clients.put(username, session);
        System.out.println("用户上线: " + username);
    }

    @OnClose
    public void onClose() {
        clients.remove(username);
        System.out.println("用户下线: " + username);
    }

    @OnError
    public void onError(Session session, Throwable error) {
        System.out.println("WebSocket发生错误");
        error.printStackTrace();
    }

    /**
     * 收到客户端发来的消息
     * 消息格式 JSON: {"receiver": "admin", "content": "你好"}
     */
    @OnMessage
    public void onMessage(String message, Session session) {
        try {
            // 1. 解析消息
            Map<String, String> msgMap = mapper.readValue(message, Map.class);
            String receiver = msgMap.get("receiver");
            String content = msgMap.get("content");
            String time = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date());

            // 2. 存入数据库
            saveToDb(this.username, receiver, content, time);

            // 3. 构建转发消息 JSON
            // 格式: {"sender": "张三", "content": "你好", "time": "..."}
            msgMap.put("sender", this.username);
            msgMap.put("time", time);
            String jsonMsg = mapper.writeValueAsString(msgMap);

            // 4. 发送给接收者 (如果在线)
            Session receiverSession = clients.get(receiver);
            if (receiverSession != null && receiverSession.isOpen()) {
                receiverSession.getBasicRemote().sendText(jsonMsg);
            }
            
            // 5. 发送给自己 (用于前端回显，确认发送成功)
            this.session.getBasicRemote().sendText(jsonMsg);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void saveToDb(String sender, String receiver, String content, String time) {
        try {
            Connection conn = DBUtil.getConn();
            String sql = "INSERT INTO t_chat_msg (sender, receiver, content, create_time) VALUES (?, ?, ?, ?)";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, sender);
            ps.setString(2, receiver);
            ps.setString(3, content);
            ps.setString(4, time);
            ps.executeUpdate();
            DBUtil.close(conn, ps, null);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}