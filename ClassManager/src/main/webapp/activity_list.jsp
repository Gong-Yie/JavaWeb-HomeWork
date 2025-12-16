<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>班级活动记录</title>
    <link rel="stylesheet" href="background.css"/>
</head>
<body>
    <!-- 侧边栏 -->
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
            <h2>班级精彩活动记录</h2>
            <c:if test="${role == 'admin'}">
                <div style="margin-bottom:10px;">
                    <a href="activity?method=toActivityForm" class="btn btn-edit">+ 发布新活动</a>
                </div>
            </c:if>
            <table>
                <tr>
                    <th>活动主题</th>
                    <th>活动内容</th>
                    <th>组织者</th>
                    <th>日期</th>
                    <c:if test="${role == 'admin'}">
                        <th>操作</th>
                    </c:if>
                </tr>
                <c:forEach items="${actList}" var="a">
                    <tr>
                        <td><strong>${a.title}</strong></td>
                        <td style="text-align:left;">${a.content}</td>
                        <td>${a.organizer}</td>
                        <td>${a.act_date}</td>
                        <c:if test="${role == 'admin'}">
                            <td>

                                <a href="activity?method=toActivityForm&id=${a.id}" class="btn btn-edit" style="font-size:12px;">编辑</a>

                                <a href="activity?method=deleteActivity&id=${a.id}" class="btn btn-del" style="font-size:12px;" onclick="return confirm('确认删除？')">删除</a>
                            </td>
                        </c:if>
                    </tr>
                </c:forEach>
            </table>
        </div>
    </div>
    <script>function openNav(){document.getElementById("mySidenav").style.width="250px";document.getElementById("main-content").style.marginLeft="250px";}function closeNav(){document.getElementById("mySidenav").style.width="0";document.getElementById("main-content").style.marginLeft="0";}</script>
</body>
</html>