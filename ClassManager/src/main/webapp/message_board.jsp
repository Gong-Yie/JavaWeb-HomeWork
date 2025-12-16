<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"><title>班级留言簿</title><link rel="stylesheet" href="background.css"/>
<style>
    .msg-card { border-bottom: 1px solid #eee; padding: 15px 0; text-align: left;}
    .msg-meta { font-size: 12px; color: #888; margin-bottom: 5px; }
    .msg-content { font-size: 15px; color: #333; }
    textarea { width: 100%; height: 80px; padding: 10px; margin: 10px 0; border:1px solid #ddd; border-radius:5px;}
</style>
</head>
<body>
    <div id="mySidenav" class="sidenav">
        <a href="javascript:void(0)" class="closebtn" onclick="closeNav()">&times;</a>
        <a href="index.jsp">系统首页</a>
        <a href="student?method=studentList">班级人员管理</a>
        <a href="duty?method=dutyList">值日安排查询</a>
        <a href="activity?method=activityList">班级活动记录</a>
        <a href="message?method=messageList">班级留言簿</a>
        <a href="message?method=toChat">Socket 在线聊天</a>
        <% if("admin".equals(session.getAttribute("role"))) { %>
            <a href="user?method=addAdmin" style="color:#ffd700;">+ 添加管理员</a>
        <% } %>
    </div>

    <div id="main-content">
        <jsp:include page="header_inc.jsp" />
        <div class="content-box">
            <h2>班级留言簿</h2>
            <form action="message" method="post" style="background:#f9f9f9; padding:15px; border-radius:10px;">
                <input type="hidden" name="method" value="addMessage">
                <label>写下你想说的话：</label>
                <textarea name="content" required placeholder="畅所欲言..."></textarea>
                <button type="submit" class="btn btn-edit" style="width:100%; border:none;">发布留言</button>
            </form>
            <div style="margin-top: 20px;">
                <c:forEach items="${msgList}" var="m">
                    <div class="msg-card">
                        <div class="msg-meta">
                            <span style="color:#2575fc; font-weight:bold;">${m.username}</span> 于 ${m.time} 说：
                            <c:if test="${role == 'admin'}">
                                <a href="message?method=deleteMessage&id=${m.id}" style="color:red; float:right; font-size:12px;" onclick="return confirm('确认删除？')">[删除]</a>
                            </c:if>
                        </div>
                        <div class="msg-content">${m.content}</div>
                    </div>
                </c:forEach>
            </div>
        </div>
    </div>
    <script>function openNav(){document.getElementById("mySidenav").style.width="250px";document.getElementById("main-content").style.marginLeft="250px";}function closeNav(){document.getElementById("mySidenav").style.width="0";document.getElementById("main-content").style.marginLeft="0";}</script>
</body>
</html>