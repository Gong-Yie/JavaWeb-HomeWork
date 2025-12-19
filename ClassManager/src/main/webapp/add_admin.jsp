<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>添加管理员</title>
<link rel="stylesheet" href="background.css"/>
</head>
<body>
    <!-- 侧边栏保持不变 -->
    <div id="mySidenav" class="sidenav">
        <a href="javascript:void(0)" class="closebtn" onclick="closeNav()">&times;</a>
        <a href="index.jsp">系统首页</a>
        <a href="student?method=studentList">班级人员管理</a>
        <a href="duty?method=dutyList">值日安排查询</a>
        <a href="activity?method=activityList">班级活动记录</a>
        <a href="message?method=messageList">班级留言簿</a>
        <a href="message?method=toChat">Socket 在线聊天</a>
        
        <% if("admin".equals(session.getAttribute("role"))) { %>
            <a href="add_admin.jsp" style="color:#ffd700;">+ 添加管理员</a>
        <% } %>
    </div>

    <div id="main-content">
        <jsp:include page="header_inc.jsp" />

        <!-- 居中卡片样式 -->
        <div class="content-box" style="margin: 50px auto; width: 400px;">
            <h2>添加新的管理员账号</h2>
            
            <p style="color:green; text-align:center; font-size:14px;">${msg}</p>
            

            <form action="user?method=addAdmin" method="post">
                
                <div style="margin-bottom:15px;">
                    <label>管理员账号：</label>
                    <input type="text" name="username" placeholder="建议使用 admin_xxx" required style="width:100%; padding:8px;">
                </div>
                
                <div style="margin-bottom:15px;">
                    <label>设置密码：</label>
                    <input type="password" name="password" required style="width:100%; padding:8px;">
                </div>
                
                <div style="margin-bottom:15px;">
                    <label>显示昵称：</label>
                    <input type="text" name="nickname" placeholder="例如：教务处李老师" required style="width:100%; padding:8px;">
                </div>
                
                <button type="submit" class="btn btn-edit" style="width:100%; padding:10px;">立即添加</button>
                
                <div style="margin-top:10px; text-align:center;">
                    <a href="index.jsp" style="color:#666; text-decoration:none;">返回首页</a>
                </div>
            </form>
        </div>
    </div>

    <script>
        function openNav() { document.getElementById("mySidenav").style.width = "250px"; document.getElementById("main-content").style.marginLeft = "250px"; }
        function closeNav() { document.getElementById("mySidenav").style.width = "0"; document.getElementById("main-content").style.marginLeft = "0"; }
    </script>
</body>
</html>