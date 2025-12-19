<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>班级人员管理</title>
    <link rel="stylesheet" href="background.css"/>
    <style>
        .filter-bar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; flex-wrap: wrap; gap: 10px; }
        .search-group { display: flex; align-items: center; gap: 8px; }
        .page-bar { margin-top: 20px; text-align: center; }
        .page-bar a { padding: 5px 10px; border: 1px solid #ddd; margin: 0 2px; text-decoration: none; color: #333; background:white; border-radius:4px;}
        .page-bar a:hover { background: #f0f0f0; }
        .avatar-small { width: 40px; height: 40px; border-radius: 50%; vertical-align: middle; margin-right: 10px; object-fit: cover; border: 1px solid #eee;}
    </style>
</head>
<body>
    <div id="mySidenav" class="sidenav">
        <a href="javascript:void(0)" class="closebtn" onclick="closeNav()">&times;</a>
        <a href="index.jsp">系统首页</a>
        <a href="student?method=studentList" style="color:white;">班级人员管理</a>
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
                <form action="student" method="get" id="searchForm" class="search-group">
                    <input type="hidden" name="method" value="studentList">
                    
                    <!-- 关键词搜索 -->
                    <input type="text" name="keyword" value="${keyword}" placeholder="搜姓名/学号/电话" style="padding:6px; width:140px; border:1px solid #ddd; border-radius:4px;">
                    
                    <!-- 性别筛选 -->
                    <select name="gender" style="padding:6px; border-radius:4px; border:1px solid #ddd;">
                        <option value="all">所有性别</option>
                        <option value="男" ${gender == '男' ? 'selected' : ''}>男</option>
                        <option value="女" ${gender == '女' ? 'selected' : ''}>女</option>
                    </select>

                    <!-- 班级筛选 -->
                    <select name="classId" style="padding:6px; border-radius:4px; border:1px solid #ddd;">
                        <option value="0">所有班级</option>
                        <c:forEach items="${classList}" var="c">
                            <option value="${c.id}" ${currClassId == c.id ? 'selected' : ''}>${c.name}</option>
                        </c:forEach>
                    </select>
                    
                    <button type="submit" class="btn btn-edit" style="padding:6px 12px;">搜索</button>
                    <a href="student?method=studentList" class="btn" style="background:#eee; color:#666;">重置</a>
                </form>

                <c:if test="${role == 'admin'}">
                    <button class="btn btn-edit" onclick="location.href='student?method=toAddStudent'">+ 新增学生</button>
                </c:if>
            </div>

            <table>
                <tr>
                    <th>ID</th>
                    <th>学生信息</th>
                    <th>性别</th>
                    <th>班级</th>
                    <th>学号</th>
                    <th>电话</th>
                    <c:if test="${role == 'admin'}"><th>操作</th></c:if>
                </tr>
                <c:forEach items="${stList}" var="s">
                    <tr>
                        <td>${s.id}</td>
                        <td style="text-align:left; padding-left:20px;">
                            <img src="photos/${s.avatar}" class="avatar-small">
                            <strong>${s.name}</strong>
                        </td>
                        <td>${s.gender}</td>
                        <td>${s.className}</td>
                        <td>${s.studentNo}</td>
                        <td>${s.phone}</td>
                        <c:if test="${role == 'admin'}">
                            <td>
                                <a href="student?method=toEditStudent&id=${s.id}" class="btn btn-edit">修改</a>
                            </td>
                        </c:if>
                    </tr>
                </c:forEach>
            </table>
            
            <div class="page-bar">
                <c:if test="${currPage > 1}">
                    <a href="student?method=studentList&page=${currPage-1}&classId=${currClassId}&keyword=${keyword}&gender=${gender}">上一页</a>
                </c:if>
                <span> 第 ${currPage} / ${totalPage} 页 </span>
                <c:if test="${currPage < totalPage}">
                    <a href="student?method=studentList&page=${currPage+1}&classId=${currClassId}&keyword=${keyword}&gender=${gender}">下一页</a>
                </c:if>
            </div>
        </div>
    </div>
    <script>function openNav() { document.getElementById("mySidenav").style.width = "250px"; document.getElementById("main-content").style.marginLeft = "250px"; } function closeNav() { document.getElementById("mySidenav").style.width = "0"; document.getElementById("main-content").style.marginLeft = "0"; }</script>
</body>
</html>