<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>系统登录</title>
    <link rel="stylesheet" href="login-style.css">
</head>
<body>
<!-- 动态背景 -->
	<ul class="circles">
	    <li></li><li></li><li></li><li></li><li></li>
	    <li></li><li></li><li></li><li></li><li></li>
	</ul>
    <div class="container">
        <h2>用户登录</h2>
        <div id="errorBox" class="error-msg" 
             style="display: ${not empty msg or param.msg == 'expired' ? 'block' : 'none'}">
            ${msg}
            ${param.msg == 'expired' ? '登录状态已过期，请重新登录' : ''}
        </div>

        <form action="user" method="post" onsubmit="return validateForm()">
            <input type="hidden" name="method" value="login">
            
            <div class="input-group">
                <label>账号</label>
                <input type="text" name="username" placeholder="请输入用户名" required>
            </div>
            <div class="input-group">
                <label>密码</label>
                <input type="password" name="password" placeholder="请输入密码" required>
            </div>
            
            <div class="input-group" style="display:flex; justify-content: space-between; align-items: center;">
                <div style="width: 60%;">
                    <label>验证码</label>
                    <input type="text" name="captcha" placeholder="输入右侧字符" required>
                </div>
                <div style="width: 35%; text-align:right;">
                    <img src="captcha" onclick="this.src='captcha?'+Math.random()" 
                         style="cursor:pointer; border-radius:5px; height:45px; margin-top:22px;" title="点击刷新">
                </div>
            </div>
            
            <label style="text-align:left; font-size:12px; color:#888;">请选择登录身份：</label>
            <div class="role-group">
                <label class="role-option"><input type="radio" name="role" value="student"> 普通用户</label>
                <label class="role-option"><input type="radio" name="role" value="admin"> 系统管理员</label>
            </div>
            
            <button type="submit">立即登录</button>
        </form>
        
        <div class="footer-link">
            <!-- 指向 UserServlet -->
            还没有账号？ <a href="user?method=toRegister">去注册 (仅限学生)</a>
        </div>
        <div class="footer-link">
             <a href="index.jsp" style="color:#999; font-weight:normal;">← 返回首页</a>
        </div>
    </div>

    <script>
        function validateForm() {
            var roles = document.getElementsByName("role");
            var isChecked = false;
            for (var i = 0; i < roles.length; i++) {
                if (roles[i].checked) { isChecked = true; break; }
            }
            if (!isChecked) {
                document.getElementById("errorBox").style.display = "block";
                document.getElementById("errorBox").innerText = "请选择登录身份";
                return false;
            }
            return true;
        }
    </script>
</body>
</html>