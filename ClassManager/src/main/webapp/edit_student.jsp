<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>编辑学生信息</title>
<link rel="stylesheet" href="background.css"/>
</head>
<body>
    <div class="content-box" style="margin: 50px auto; width: 400px;">
        <h2>编辑学生信息</h2>
        <form action="student" method="post">
            <input type="hidden" name="method" value="updateStudent">
            <input type="hidden" name="id" value="${stu.id}">
            <input type="hidden" name="username" value="${stu.username}">
            
            <div style="margin-bottom:15px;">
                <label>姓名：</label>
                <input type="text" name="name" value="${stu.name}" required style="width:100%; padding:8px;">
            </div>
            <div style="margin-bottom:15px;">
                <label>学号：</label>
                <input type="text" name="studentNo" value="${stu.studentNo}" required style="width:100%; padding:8px;">
            </div>
            <div style="margin-bottom:15px;">
                <label>电话：</label>
                <input type="text" name="phone" value="${stu.phone}" style="width:100%; padding:8px;">
            </div>
            <div style="margin-bottom:15px;">
                <label>所属班级：</label>
                <select name="classId" style="width:100%; padding:8px;">
                    <c:forEach items="${classList}" var="c">
                        <option value="${c.id}" ${stu.classId == c.id ? 'selected' : ''}>${c.name}</option>
                    </c:forEach>
                </select>
            </div>
            
            <button type="submit" class="btn btn-edit" style="width:100%; padding:10px;">保存修改</button>
            <div style="margin-top:10px; text-align:center;">
                <a href="student?method=studentList">取消返回</a>
            </div>
        </form>
    </div>
</body>
</html>