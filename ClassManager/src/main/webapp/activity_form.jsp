<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>活动编辑</title>
<link rel="stylesheet" href="background.css"/>
</head>
<body>
    <div class="content-box" style="width:500px; margin:50px auto;">
        <h2>${empty act ? '发布新活动' : '修改活动信息'}</h2>
        
        <form action="activity" method="post">
            <input type="hidden" name="method" value="saveActivity">
            <!-- 如果有id则是修改，没有则是新增 -->
            <input type="hidden" name="id" value="${act.id}">
            
            <div style="margin-bottom:15px;">
                <label>活动主题：</label>
                <input type="text" name="title" value="${act.title}" required style="width:100%; padding:8px;">
            </div>
            
            <div style="margin-bottom:15px;">
                <label>组织者：</label>
                <input type="text" name="organizer" value="${act.organizer}" required style="width:100%; padding:8px;">
            </div>
            
            <div style="margin-bottom:15px;">
                <label>活动日期：</label>
                <!-- type="date" 会显示日历选择器 -->
                <input type="date" name="act_date" value="${act.act_date}" required style="width:100%; padding:8px;">
            </div>
            
            <div style="margin-bottom:15px;">
                <label>活动详情：</label>
                <textarea name="content" required style="width:100%; height:100px; padding:8px;">${act.content}</textarea>
            </div>
            
            <button type="submit" class="btn btn-edit" style="width:100%; padding:10px;">提交保存</button>
            <div style="margin-top:10px; text-align:center;">
                <a href="activity?method=activityList">返回列表</a>
            </div>
        </form>
    </div>
</body>
</html>