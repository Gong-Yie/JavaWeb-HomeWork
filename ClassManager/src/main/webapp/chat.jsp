<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>班级微聊</title>
<link rel="stylesheet" href="background.css"/>
<style>
    .chat-container { display: flex; width: 1000px; height: 600px; background: #fff; margin: 80px auto; border-radius: 5px; box-shadow: 0 5px 15px rgba(0,0,0,0.2); overflow: hidden; }
    .chat-sidebar { width: 250px; background: #2e3238; color: #fff; overflow-y: auto; }
    .user-item { display: flex; align-items: center; padding: 12px; cursor: pointer; border-bottom: 1px solid #292c33; transition: 0.2s; position: relative; /* 为了定位红点 */ }
    .user-item:hover { background: #383c43; }
    .user-item.active { background: #3a3f45; }
    .user-avatar { width: 40px; height: 40px; border-radius: 3px; margin-right: 10px; }
    .user-name { font-size: 14px; }
    .chat-main { flex: 1; display: flex; flex-direction: column; background: #f5f5f5; }
    .chat-header { height: 50px; line-height: 50px; padding: 0 20px; border-bottom: 1px solid #e7e7e7; font-size: 16px; font-weight: bold; }
    .chat-history { flex: 1; padding: 20px; overflow-y: auto; }
    .message { margin-bottom: 15px; display: flex; }
    .message.self { flex-direction: row-reverse; }
    .msg-avatar { width: 35px; height: 35px; border-radius: 3px; }
    .msg-content { max-width: 60%; padding: 8px 12px; margin: 0 10px; border-radius: 4px; font-size: 14px; line-height: 1.5; position: relative; word-wrap: break-word; }
    .message.other .msg-content { background: #fff; border: 1px solid #ededed; }
    .message.self .msg-content { background: #9eea6a; border: 1px solid #9eea6a; }
    .chat-input-area { height: 150px; border-top: 1px solid #e7e7e7; background: #fff; display: flex; flex-direction: column; }
    textarea { flex: 1; border: none; padding: 10px; resize: none; outline: none; font-size: 14px; }
    .btn-bar { text-align: right; padding: 5px 20px 10px; }
    .btn-send { background: #f5f5f5; color: #666; border: 1px solid #e7e7e7; padding: 5px 20px; cursor: pointer; transition: 0.2s; }
    .btn-send:hover { background: #129611; color: white; border-color: #129611; }
    .empty-state { display: flex; justify-content: center; align-items: center; height: 100%; color: #ccc; }

    /* 【新增】红点样式 */
    .red-dot {
        position: absolute;
        right: 15px;
        top: 15px;
        background-color: #f43530;
        color: white;
        font-size: 10px;
        height: 16px;
        min-width: 16px;
        border-radius: 8px;
        text-align: center;
        line-height: 16px;
        padding: 0 4px;
        box-sizing: border-box;
    }
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
        <a href="message?method=toChat" style="color:white;">Socket 在线聊天</a>
        <% if("admin".equals(session.getAttribute("role"))) { %><a href="user?method=addAdmin" style="color:#ffd700;">+ 添加管理员</a><% } %>
    </div>

    <div id="main-content">
        <jsp:include page="header_inc.jsp" />

        <div class="chat-container">
            <!-- 左侧：联系人列表 -->
            <div class="chat-sidebar">
                <div style="padding:15px; color:#999; font-size:12px;">联系人列表</div>
                <c:forEach items="${contacts}" var="c">
                    <!-- 
                       【修改】：给 div 加一个 id="user-row-用户名"，方便 JS 查找
                    -->
                    <div class="user-item" id="user-row-${c.username}" onclick="selectUser('${c.username}', '${c.nickname}', '${c.avatar}')">
                        <img src="photos/${c.avatar}" class="user-avatar">
                        <span class="user-name">${c.nickname}</span>
                        
                        <!-- 【新增】：如果有未读消息，显示红点 -->
                        <c:if test="${c.unread > 0}">
                            <span class="red-dot" id="dot-${c.username}">${c.unread}</span>
                        </c:if>
                        <!-- 预留一个隐藏的红点结构，方便JS操作 -->
                        <span class="red-dot" id="dot-${c.username}" style="display:none;">0</span>
                    </div>
                </c:forEach>
            </div>

            <!-- 右侧 -->
            <div class="chat-main">
                <div class="chat-header" id="chatTitle">未选择联系人</div>
                <div class="chat-history" id="chatHistory">
                    <div class="empty-state">请在左侧选择一位同学开始聊天</div>
                </div>
                <div class="chat-input-area" id="inputArea" style="visibility:hidden;">
                    <textarea id="msgInput" placeholder="输入消息..."></textarea>
                    <div class="btn-bar">
                        <button class="btn-send" onclick="sendMsg()">发送 (S)</button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        function openNav() { document.getElementById("mySidenav").style.width = "250px"; document.getElementById("main-content").style.marginLeft = "250px"; }
        function closeNav() { document.getElementById("mySidenav").style.width = "0"; document.getElementById("main-content").style.marginLeft = "0"; }

        var websocket = null;
        var currentUser = "${sessionScope.user}"; 
        var currentReceiver = null; 
        var myAvatar = "${sessionScope.avatar}"; if(myAvatar == "") myAvatar = "default.jpg";

        if ('WebSocket' in window) {
            websocket = new WebSocket("ws://localhost:8080/ClassManager/chat/" + currentUser);
        } else {
            alert('不支持 WebSocket');
        }

        websocket.onopen = function() { console.log("连接成功"); }
        
        // 【关键修改】：接收消息时的红点逻辑
        websocket.onmessage = function(event) {
            var data = JSON.parse(event.data);
            
            // 1. 如果正在和这个人聊天，直接显示消息
            if ( (data.sender === currentReceiver) || (data.sender === currentUser && data.receiver === currentReceiver) ) {
                appendMessage(data);
                // 顺便告诉后台已读
                if(data.sender === currentReceiver) {
                    markAsRead(currentReceiver);
                }
            } 
            // 2. 如果收到了别人的消息（且不是自己发的），并且没在和他聊，显示红点
            else if (data.sender !== currentUser) {
                showRedDot(data.sender);
            }
        }

        function selectUser(username, nickname, avatar) {
            currentReceiver = username;
            document.getElementById("chatTitle").innerText = "正在与 " + nickname + " 聊天中...";
            document.getElementById("inputArea").style.visibility = "visible";
            document.getElementById("chatHistory").innerHTML = ""; 
            
            var items = document.querySelectorAll(".user-item");
            items.forEach(i => i.classList.remove("active"));
            
            // 选中高亮
            var row = document.getElementById("user-row-" + username);
            if(row) row.classList.add("active");
            
            // 【关键】：点击后消除红点
            hideRedDot(username);
            
            // 【关键】：发送请求给后台，标记已读
            markAsRead(username);
            
            loadHistory(username);
        }
        
        // 显示红点函数
        function showRedDot(username) {
            var dot = document.getElementById("dot-" + username);
            if(dot) {
                var count = parseInt(dot.innerText);
                if(isNaN(count)) count = 0;
                count++;
                dot.innerText = count;
                dot.style.display = "block";
            }
        }
        
        // 隐藏红点函数
        function hideRedDot(username) {
            var dot = document.getElementById("dot-" + username);
            if(dot) {
                dot.innerText = "0"; // 重置计数
                dot.style.display = "none";
            }
        }
        
        // 后台标记已读
        function markAsRead(senderUser) {
            fetch("message?method=markRead&sender=" + senderUser);
        }

        function loadHistory(receiver) {
            fetch("message?method=getHistory&receiver=" + receiver)
                .then(response => response.json())
                .then(data => {
                    data.forEach(function(msg) { appendMessage(msg); });
                });
        }

        function sendMsg() {
            var input = document.getElementById("msgInput");
            var content = input.value;
            if(content.trim() === "") return;
            if(websocket && currentReceiver) {
                var json = { "receiver": currentReceiver, "content": content };
                websocket.send(JSON.stringify(json));
                input.value = ""; 
            }
        }

        function appendMessage(data) {
            var history = document.getElementById("chatHistory");
            var isSelf = (data.sender === currentUser);
            var avatarUrl = isSelf ? "photos/" + myAvatar : "photos/default.jpg"; 
            var html = '<div class="message ' + (isSelf ? 'self' : 'other') + '">' +
                    '<img src="' + avatarUrl + '" class="msg-avatar">' +
                    '<div class="msg-content">' + data.content + '</div></div>';
            history.innerHTML += html;
            history.scrollTop = history.scrollHeight;
        }
    </script>
</body>
</html>