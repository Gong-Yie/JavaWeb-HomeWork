<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"><title>值日安排</title><link rel="stylesheet" href="background.css"/></head>
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
            <h2>本周值日安排表</h2>
            <table>
                <tr><th>姓名</th><th>学号</th><th>值日时间</th><th>状态</th></tr>
                <c:forEach items="${stList}" var="s">
                    <tr>
                        <td><strong>${s.name}</strong></td>
                        <td>${s.studentNo}</td>
                        <td><span style="color:#2575fc; font-weight:bold;">${dutyMap[s.dutyDay]}</span></td>
                        <td>
                            <c:if test="${role == 'admin'}">
                                <a href="duty?method=toEditDuty&id=${s.id}" class="btn btn-edit" style="background:#f0ad4e;">调整值日</a>
                            </c:if>
                            <span style="color:green;">正常</span>
                        </td>
                    </tr>
                </c:forEach>
            </table>
        </div>
    </div>
    <script>function openNav(){document.getElementById("mySidenav").style.width="250px";document.getElementById("main-content").style.marginLeft="250px";}function closeNav(){document.getElementById("mySidenav").style.width="0";document.getElementById("main-content").style.marginLeft="0";}</script>
</body>
</html>