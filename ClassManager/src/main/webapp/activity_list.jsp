<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>班级活动记录</title>
    <link rel="stylesheet" href="background.css"/>
    <style>
        .search-bar { background: rgba(255,255,255,0.8); padding: 15px; border-radius: 8px; margin-bottom: 20px; display: flex; align-items: center; justify-content: space-between; border: 1px solid #eee; flex-wrap: wrap; gap:10px; }
        .search-group { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }
        .stat-badge { background: #e3f2fd; color: #1976d2; padding: 5px 12px; border-radius: 20px; font-size: 14px; font-weight: bold; border: 1px solid #bbdefb; white-space: nowrap; }
        input[type="date"], input[type="text"] { padding: 5px; border: 1px solid #ddd; border-radius: 4px; }
    </style>
</head>
<body>
    <div id="mySidenav" class="sidenav">
        <a href="javascript:void(0)" class="closebtn" onclick="closeNav()">&times;</a>
        <a href="index.jsp">系统首页</a>
        <a href="student?method=studentList">班级人员管理</a>
        <a href="duty?method=dutyList">值日安排查询</a>
        <a href="activity?method=activityList" style="color:white;">班级活动记录</a>
        <a href="message?method=messageList">班级留言簿</a>
        <a href="message?method=toChat">Socket 在线聊天</a>
        <% if("admin".equals(session.getAttribute("role"))) { %><a href="user?method=addAdmin" style="color:#ffd700;">+ 添加管理员</a><% } %>
    </div>

    <div id="main-content">
        <jsp:include page="header_inc.jsp" />

        <div class="content-box">
            <h2>班级精彩活动记录</h2>
            
            <!-- 1. 查询与统计栏 -->
            <div class="search-bar">
                <form action="activity" method="get" class="search-group">
                    <input type="hidden" name="method" value="activityList">
                    
                    <input type="text" name="keyword" value="${keyword}" placeholder="搜主题/内容..." style="width:120px;">
                    
                    <label>日期：</label>
                    <input type="date" name="startDate" value="${startDate}">
                    <span>-</span>
                    <input type="date" name="endDate" value="${endDate}">
                    
                    <button type="submit" class="btn btn-edit" style="padding:6px 15px;">查询</button>
                    <a href="activity?method=activityList" class="btn" style="background:#eee; color:#333;">重置</a>
                </form>
                
                <!-- 统计结果 -->
                <span class="stat-badge">
                    共找到：${totalCount} 场
                </span>
            </div>

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
                    <c:if test="${role == 'admin'}"><th>操作</th></c:if>
                </tr>
                <c:forEach items="${actList}" var="a">
                    <tr>
                        <td><strong>${a.title}</strong></td>
                        <td style="text-align:left; max-width:300px;">${a.content}</td>
                        <td>${a.organizer}</td>
                        <td><span style="background:#fff3cd; padding:2px 6px; border-radius:4px; font-size:13px;">${a.act_date}</span></td>
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