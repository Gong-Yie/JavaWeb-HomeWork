<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>新用户注册</title>
    <link rel="stylesheet" href="login-style.css">
</head>
<body>
	<!-- 动态背景 -->
	<ul class="circles">
	    <li></li><li></li><li></li><li></li><li></li>
	    <li></li><li></li><li></li><li></li><li></li>
	</ul>
    <div class="container">
        <h2>学生注册</h2>
        <div class="error-msg" style="display: ${not empty msg ? 'block' : 'none'}; background: ${msg.startsWith('注册成功') ? '#e6ffe6' : '#ffe6e6'}; color: ${msg.startsWith('注册成功') ? 'green' : 'red'};">
            ${msg}
        </div>

        <form action="user" method="post" onsubmit="return checkPass()">
            <input type="hidden" name="method" value="register">
            
            <div class="input-group">
                <label>账号</label>
                <input type="text" name="username" placeholder="登录账号" required>
            </div>
            <div class="input-group">
                <label>真实姓名</label>
                <input type="text" name="name" placeholder="将显示在班级列表中" required>
            </div>
            <div class="input-group" style="margin:10px 0;">
			    <label>性别：</label>
			    <label style="margin-right:15px;"><input type="radio" name="gender" value="男" checked> 男</label>
			    <label><input type="radio" name="gender" value="女"> 女</label>
			</div>
            <div class="input-group">
                <label>选择班级</label>
                <select name="classId" style="width:100%; padding:10px; border:1px solid #ddd; border-radius:5px;">
                    <c:forEach items="${classList}" var="c">
                        <option value="${c.id}">${c.name}</option>
                    </c:forEach>
                </select>
            </div>
            <div class="input-group">
                <label>密码</label>
                <input type="password" id="p1" name="password" required>
            </div>
            
            <button type="submit">确认注册</button>
        </form>
        <div class="footer-link">已有账号？ <a href="login.jsp">返回登录</a></div>
    </div>
    <script>
        function checkPass() {
            if(document.getElementById("p1").value.length < 6) { alert("密码至少6位"); return false; }
            return true;
        }
    </script>
</body>
</html>