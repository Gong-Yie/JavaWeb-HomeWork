<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>新增学生</title>
<link rel="stylesheet" href="background.css"/>
</head>
<body>
    <div class="content-box" style="margin: 50px auto; width: 400px;">
        <h2>录入新学生</h2>
        <form action="student" method="post">
            <input type="hidden" name="method" value="addStudent">
            
            <div style="margin-bottom:15px;">
                <label>姓名：</label>
                <input type="text" name="name" required style="width:100%; padding:8px;">
            </div>
            <div style="margin-bottom:15px;">
                <label>学号：</label>
                <input type="text" name="studentNo" required style="width:100%; padding:8px;">
            </div>
            <div style="margin-bottom:15px;">
                <label>电话：</label>
                <input type="text" name="phone" style="width:100%; padding:8px;">
            </div>
            <div style="margin-bottom:15px;">
                <label>所属班级：</label>
                <select name="classId" style="width:100%; padding:8px;">
                    <c:forEach items="${classList}" var="c">
                        <option value="${c.id}">${c.name}</option>
                    </c:forEach>
                </select>
            </div>
            
            <button type="submit" class="btn btn-edit" style="width:100%; padding:10px;">确认添加</button>
            <div style="margin-top:10px; text-align:center;">
                <span style="color:#888; font-size:12px;">(系统将自动生成登录账号，默认密码123456)</span><br>
                <a href="student?method=studentList">返回列表</a>
            </div>
        </form>
    </div>
</body>
</html>