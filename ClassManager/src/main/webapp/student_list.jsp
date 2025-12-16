<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>班级人员管理</title>
    <link rel="stylesheet" href="background.css"/>
    <style>
        .filter-bar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; }
        .page-bar { margin-top: 20px; text-align: center; }
        .page-bar a { padding: 5px 10px; border: 1px solid #ddd; margin: 0 2px; text-decoration: none; color: #333;}
        .page-bar a.active { background: #2575fc; color: white; border-color: #2575fc; }
        .avatar-small { width: 40px; height: 40px; border-radius: 50%; vertical-align: middle; margin-right: 10px; object-fit: cover; border: 1px solid #eee;}
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
            <h2>班级人员通讯录</h2>
            <div class="filter-bar">
                <form action="student" method="get" id="searchForm">
                    <input type="hidden" name="method" value="studentList">
                    <label>切换班级：</label>
                    <select name="classId" onchange="document.getElementById('searchForm').submit()" style="padding:5px;">
                        <option value="0">--- 所有班级 ---</option>
                        <c:forEach items="${classList}" var="c">
                            <option value="${c.id}" ${currClassId == c.id ? 'selected' : ''}>${c.name}</option>
                        </c:forEach>
                    </select>
                    <select name="sort" onchange="document.getElementById('searchForm').submit()" style="padding:5px; margin-left:10px;">
                        <option value="id_asc" ${currSort == 'id_asc' ? 'selected' : ''}>ID 正序</option>
                        <option value="id_desc" ${currSort == 'id_desc' ? 'selected' : ''}>ID 倒序</option>
                    </select>
                </form>
                <c:if test="${role == 'admin'}">
                    <button class="btn btn-edit" onclick="location.href='student?method=toAddStudent'">+ 新增学生</button>
                </c:if>
            </div>

            <table>
                <tr><th>ID</th><th>学生信息</th><th>班级</th><th>学号</th><th>电话</th><c:if test="${role == 'admin'}"><th>操作</th></c:if></tr>
                <c:forEach items="${stList}" var="s">
                    <tr>
                        <td>${s.id}</td>
                        <td style="text-align:left; padding-left:20px;">
                            <img src="photos/${s.avatar}" class="avatar-small">
                            <strong>${s.name}</strong>
                        </td>
                        <td>${s.className}</td>
                        <td>${s.studentNo}</td>
                        <td>${s.phone}</td>
                        <c:if test="${role == 'admin'}">
                            <td><a href="student?method=toEditStudent&id=${s.id}" class="btn btn-edit">修改</a></td>
                        </c:if>
                    </tr>
                </c:forEach>
            </table>
            
            <div class="page-bar">
                <c:if test="${currPage > 1}"><a href="student?method=studentList&page=${currPage-1}&classId=${currClassId}&sort=${currSort}">上一页</a></c:if>
                <span> 第 ${currPage} / ${totalPage} 页 </span>
                <c:if test="${currPage < totalPage}"><a href="student?method=studentList&page=${currPage+1}&classId=${currClassId}&sort=${currSort}">下一页</a></c:if>
            </div>
        </div>
    </div>
    <script>function openNav() { document.getElementById("mySidenav").style.width = "250px"; document.getElementById("main-content").style.marginLeft = "250px"; } function closeNav() { document.getElementById("mySidenav").style.width = "0"; document.getElementById("main-content").style.marginLeft = "0"; }</script>
</body>
</html>