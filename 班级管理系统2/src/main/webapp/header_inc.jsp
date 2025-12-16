<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!-- === 动态背景粒子 (添加到所有页面) === -->
<ul class="circles">
    <li></li><li></li><li></li><li></li><li></li>
    <li></li><li></li><li></li><li></li><li></li>
</ul>

<!-- 顶部导航栏开始 -->
<div class="navigation">
    <ul>
        <li>
            <div id="menu-btn">
                <span class="hamburger" onclick="openNav()">&#9776; 菜单</span>
            </div>
        </li>
        <li>
            <% 
                String u_inc = (String)session.getAttribute("user");
                String nick_inc = (String)session.getAttribute("nickname");
                String ava_inc = (String)session.getAttribute("avatar");
                if(nick_inc == null) nick_inc = (u_inc != null) ? u_inc : "";
                if(ava_inc == null || ava_inc.trim().isEmpty()) ava_inc = "default.jpg";
                String finalAvatarPath = "photos/" + ava_inc;
            %>

            <% if(u_inc == null) { %>
                <a href="login.jsp" style="color:#333; font-weight:bold;">登录 / 注册</a>
            <% } else { %>
                <div class="user-dropdown" style="position:relative; display:inline-block;">
                    <a href="javascript:void(0)" onclick="toggleDropdown()" style="display:flex; align-items:center; color:#333; text-decoration:none; font-weight:600;">
                        <img src="<%=finalAvatarPath%>" style="width:35px; height:35px; border-radius:50%; margin-right:10px; border:2px solid #fff; box-shadow:0 2px 5px rgba(0,0,0,0.1); object-fit:cover;">
                        欢迎, <%=nick_inc%> ▾
                    </a>
                    
                    <div id="userDrop" class="dropdown-content">
                        <div style="text-align:center; padding:20px;">
                            <img src="<%=finalAvatarPath%>" class="dropdown-avatar" style="width:70px; height:70px; border-radius:50%; border:3px solid #f0f0f0; object-fit:cover;">
                            <div style="margin-top:10px; font-weight:bold; color:#333; font-size:16px;"><%=nick_inc%></div>
                            <div style="font-size:12px; color:#888;">@<%=u_inc%></div>
                        </div>
                        <hr style="border:0; border-top:1px solid #f0f0f0; margin:0;">
                        <a href="user?method=myInfo" style="color:#555;">👤 个人信息</a>
                        <a href="user?method=logout" style="color:#ff6b6b;">🚪 退出登录</a>
                    </div>
                </div>
            <% } %>
        </li>
    </ul>
</div>

<script>
    function toggleDropdown() {
        var d = document.getElementById("userDrop");
        if (d.style.display === "block") { d.style.display = "none"; } else { d.style.display = "block"; }
    }
    window.addEventListener('click', function(e) {
        if (!e.target.matches('.user-dropdown') && !e.target.matches('.user-dropdown *')) {
            var d = document.getElementById("userDrop");
            if (d && d.style.display === "block") { d.style.display = "none"; }
        }
    });
</script>