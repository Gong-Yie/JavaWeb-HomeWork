<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>值日安排</title>
    <link rel="stylesheet" href="background.css"/>
    <style>
        .stat-container { display: flex; justify-content: space-between; margin-bottom: 20px; gap: 10px; flex-wrap: wrap; }
        .stat-box { flex: 1; min-width: 80px; text-align: center; padding: 10px; border-radius: 8px; background: rgba(255,255,255,0.8); border: 1px solid #eee; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
        .stat-box .day { font-size: 12px; color: #888; margin-bottom: 5px; }
        .stat-box .count { font-size: 20px; font-weight: bold; color: #2575fc; }
        .filter-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; flex-wrap: wrap; gap:10px; }
        .search-group { display: flex; gap: 8px; align-items: center; }
    </style>
</head>
<body>
    <div id="mySidenav" class="sidenav">
        <a href="javascript:void(0)" class="closebtn" onclick="closeNav()">&times;</a>
        <a href="index.jsp">系统首页</a>
        <a href="student?method=studentList">班级人员管理</a>
        <a href="duty?method=dutyList" style="color:white;">值日安排查询</a>
        <a href="activity?method=activityList">班级活动记录</a>
        <a href="message?method=messageList">班级留言簿</a>
        <a href="message?method=toChat">Socket 在线聊天</a>
        <% if("admin".equals(session.getAttribute("role"))) { %><a href="user?method=addAdmin" style="color:#ffd700;">+ 添加管理员</a><% } %>
    </div>

    <div id="main-content">
        <jsp:include page="header_inc.jsp" />

        <div class="content-box">
            <h2>值日安排与统计</h2>
            
            <div class="stat-container">
                <c:forEach items="${dutyMap}" var="entry">
                    <div class="stat-box">
                        <div class="day">${entry.value}</div>
                        <div class="count">${dutyStats[entry.key]}人</div>
                    </div>
                </c:forEach>
            </div>

            <div class="filter-header">
                <form action="duty" method="get" id="dutyFilter" class="search-group">
                    <input type="hidden" name="method" value="dutyList">
                    
                    <input type="text" name="keyword" value="${keyword}" placeholder="搜姓名/学号..." style="padding:6px; width:140px; border:1px solid #ddd; border-radius:4px;">
                    
                    <select name="gender" style="padding:6px; border-radius:4px; border:1px solid #ddd;">
                        <option value="all">所有性别</option>
                        <option value="男" ${gender == '男' ? 'selected' : ''}>男</option>
                        <option value="女" ${gender == '女' ? 'selected' : ''}>女</option>
                    </select>

                    <select name="queryDay" style="padding:6px; border-radius:4px; border:1px solid #ddd;">
                        <option value="0">--- 所有日期 ---</option>
                        <c:forEach items="${dutyMap}" var="entry">
                            <option value="${entry.key}" ${queryDay == entry.key ? 'selected' : ''}>${entry.value}</option>
                        </c:forEach>
                    </select>
                    
                    <button type="submit" class="btn btn-edit" style="padding:6px 12px;">筛选</button>
                    <a href="duty?method=dutyList" class="btn" style="background:#eee; color:#333;">重置</a>
                </form>
            </div>

            <table>
                <tr>
                    <th>姓名</th>
                    <th>性别</th>
                    <th>学号</th>
                    <th>值日时间</th>
                    <th>状态</th>
                </tr>
                <c:forEach items="${stList}" var="s">
                    <tr>
                        <td><strong>${s.name}</strong></td>
                        <td>${s.gender}</td>
                        <td>${s.studentNo}</td>
                        <td><span style="color:#2575fc; font-weight:bold;">${dutyMap[s.dutyDay]}</span></td>
                        <td>
                            <c:if test="${role == 'admin'}">
                                <a href="duty?method=toEditDuty&id=${s.id}" class="btn btn-edit" style="background:#f0ad4e;">调整</a>
                            </c:if>
                            <span style="color:green; margin-left:5px;">正常</span>
                        </td>
                    </tr>
                </c:forEach>
            </table>
        </div>
    </div>
    <script>function openNav(){document.getElementById("mySidenav").style.width="250px";document.getElementById("main-content").style.marginLeft="250px";}function closeNav(){document.getElementById("mySidenav").style.width="0";document.getElementById("main-content").style.marginLeft="0";}</script>
</body>
</html>