<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>调整值日安排</title>
<link rel="stylesheet" href="background.css"/>
</head>
<body>
    <div class="content-box" style="width:400px; margin:50px auto;">
        <h2>调整值日时间</h2>
        <form action="duty" method="post">
            <input type="hidden" name="method" value="updateDuty">
            <input type="hidden" name="id" value="${stu.id}">
            
            <div style="margin-bottom:20px;">
                <p>正在调整学生：<strong>${stu.name}</strong></p>
            </div>
            
            <div style="margin-bottom:20px;">
                <label>选择新的值日时间：</label>
                <select name="dutyDay" style="width:100%; padding:8px;">
                    <c:forEach items="${dutyMap}" var="entry">
                        <option value="${entry.key}" ${stu.dutyDay == entry.key ? 'selected' : ''}>
                            ${entry.value}
                        </option>
                    </c:forEach>
                </select>
            </div>
            
            <button type="submit" class="btn btn-edit" style="width:100%; padding:10px;">保存设置</button>
            <div style="margin-top:10px; text-align:center;">
                <a href="duty?method=dutyList">取消</a>
            </div>
        </form>
    </div>
</body>
</html>