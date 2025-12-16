<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>个人中心</title>
    <link rel="stylesheet" href="background.css"/>
    <style>
        /* --- 个人中心专用样式 (嵌入式，确保不影响全局) --- */
        
        /* 布局容器：左侧菜单 + 右侧内容 */
        .profile-wrapper {
            display: flex;
            min-height: 450px;
        }

        /* 左侧菜单栏 */
        .profile-sidebar {
            width: 250px;
            background: rgba(0, 0, 0, 0.03); /* 轻微深色背景 */
            border-right: 1px solid rgba(0, 0, 0, 0.05);
            padding: 30px 0;
            display: flex;
            flex-direction: column;
        }

        .profile-sidebar ul {
            list-style: none;
            padding: 0;
            margin: 0;
        }

        .profile-sidebar li {
            padding: 15px 30px;
            cursor: pointer;
            color: #555;
            font-weight: 500;
            transition: all 0.3s;
            border-left: 4px solid transparent;
            font-size: 15px;
        }

        .profile-sidebar li:hover {
            background-color: rgba(255, 255, 255, 0.5);
            color: #2575fc;
        }

        /* 选中状态 */
        .profile-sidebar li.active {
            background-color: rgba(37, 117, 252, 0.1);
            color: #2575fc;
            border-left-color: #2575fc;
        }

        /* 右侧内容区 */
        .profile-content {
            flex: 1;
            padding: 40px 50px;
            text-align: left; /* 内容左对齐 */
        }

        /* 标题样式 */
        .section-title {
            font-size: 24px;
            color: #333;
            margin-bottom: 30px;
            padding-bottom: 10px;
            border-bottom: 2px solid #f0f0f0;
            font-weight: 600;
        }

        /* 头像区域 */
        .avatar-section {
            display: flex;
            align-items: center;
            margin-bottom: 30px;
        }

        .big-avatar {
            width: 100px;
            height: 100px;
            border-radius: 50%;
            border: 4px solid white;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            object-fit: cover;
            cursor: zoom-in;
            transition: transform 0.3s;
        }
        .big-avatar:hover { transform: scale(1.05); }

        .avatar-info {
            margin-left: 20px;
        }

        /* 信息行 */
        .info-row {
            margin-bottom: 15px;
            font-size: 15px;
            color: #555;
            display: flex;
            align-items: center;
        }
        .info-label {
            width: 100px;
            font-weight: bold;
            color: #888;
        }

        /* 表单样式微调 */
        .form-input {
            width: 100%;
            padding: 10px 15px;
            border: 1px solid #ddd;
            border-radius: 6px;
            margin-top: 5px;
            box-sizing: border-box;
            background: rgba(255,255,255,0.8);
        }
        .form-group { margin-bottom: 20px; }
        
        /* 模态框修正 */
        .modal { display: none; position: fixed; z-index: 9999; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0,0,0,0.8); backdrop-filter: blur(5px); }
        .modal-content { margin: auto; display: block; max-width: 80%; max-height: 80%; margin-top: 5%; border-radius: 10px; box-shadow: 0 0 20px rgba(0,0,0,0.5); }
        .close-modal { position: absolute; top: 30px; right: 50px; color: #fff; font-size: 40px; font-weight: bold; cursor: pointer; }
    </style>
</head>
<body>

    <!-- 1. 侧边栏 -->
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

    <!-- 2. 主内容 -->
    <div id="main-content">
        <jsp:include page="header_inc.jsp" /> 

        <!-- 使用 content-box 实现毛玻璃效果，padding设为0交给内部布局控制 -->
        <div class="content-box" style="padding: 0; overflow: hidden; margin-top: 100px; max-width: 900px;">
            
            <div class="profile-wrapper">
                <!-- 左侧：功能菜单 -->
                <div class="profile-sidebar">
                    <ul>
                        <li onclick="showTab('info')" id="tab-info" class="active">👤 我的信息</li>
                        <li onclick="showTab('edit')" id="tab-edit">✏️ 修改资料</li>
                        <li onclick="location.href='user?method=logout'" style="color:#ff4757; border-top:1px solid #eee; margin-top:20px;">🚪 退出登录</li>
                    </ul>
                </div>

                <!-- 右侧：详细内容 -->
                <div class="profile-content">
                    
                    <!-- 1. 展示信息面板 -->
                    <div id="view-info">
                        <div class="section-title">个人档案</div>
                        
                        <div class="avatar-section">
                            <img src="photos/${currUser_avatar}" class="big-avatar" onclick="openModal(this.src)" title="点击查看大图">
                            <div class="avatar-info">
                                <h3 style="margin: 0 0 5px 0;">${currUser_nick}</h3>
                                <span style="background: #e1f0ff; color: #2575fc; padding: 3px 8px; border-radius: 4px; font-size: 12px;">
                                    ${role == 'admin' ? '系统管理员' : '普通学生'}
                                </span>
                            </div>
                        </div>

                        <div class="info-row"><span class="info-label">登录账号:</span> <span>${user}</span></div>
                        <div class="info-row"><span class="info-label">电子邮箱:</span> <span>${currUser_email == null ? '未绑定' : currUser_email}</span></div>
                        <div class="info-row"><span class="info-label">系统ID:</span> <span>#${currUser_id}</span></div>
                        
                        <div style="margin-top: 30px;">
                            <button class="btn btn-edit" onclick="showTab('edit')">编辑资料</button>
                        </div>
                    </div>

                    <!-- 2. 修改资料面板 -->
                    <div id="view-edit" style="display:none;">
                        <div class="section-title">更新资料</div>
                        
                        <form action="user" method="post" enctype="multipart/form-data">
                            <input type="hidden" name="method" value="updateInfo">
                            
                            <div class="form-group">
                                <label style="font-size:14px; font-weight:bold; color:#555;">昵称 / 姓名</label>
                                <input type="text" name="nickname" value="${currUser_nick}" class="form-input">
                            </div>

                            <div class="form-group">
                                <label style="font-size:14px; font-weight:bold; color:#555;">更换头像</label>
                                <div style="margin-top:5px; border: 1px dashed #ccc; padding: 15px; border-radius: 6px; text-align: center; background: rgba(255,255,255,0.5);">
                                    <img src="photos/${currUser_avatar}" style="width:40px; height:40px; border-radius:50%; vertical-align:middle; margin-right:10px;">
                                    <input type="file" name="avatarFile" accept="image/*" style="font-size:13px;">
                                </div>
                            </div>
    
                            <div style="margin-top: 30px;">
                                <button type="submit" class="btn btn-edit" style="padding: 10px 25px;">保存修改</button>
                                <button type="button" class="btn" style="background:#eee; color:#666; margin-left:10px;" onclick="showTab('info')">取消</button>
                            </div>
                        </form>
                    </div>

                </div>
            </div>
        </div>
    </div>

    <!-- 图片放大模态框 -->
    <div id="imgModal" class="modal">
        <span class="close-modal" onclick="document.getElementById('imgModal').style.display='none'">&times;</span>
        <img class="modal-content" id="img01">
    </div>

    <!-- JS 逻辑 -->
    <script>
        function openNav() { document.getElementById("mySidenav").style.width = "250px"; document.getElementById("main-content").style.marginLeft = "250px"; }
        function closeNav() { document.getElementById("mySidenav").style.width = "0"; document.getElementById("main-content").style.marginLeft = "0"; }

        function showTab(tabName) {
            var infoView = document.getElementById('view-info');
            var editView = document.getElementById('view-edit');
            var tabInfo = document.getElementById('tab-info');
            var tabEdit = document.getElementById('tab-edit');

            if (tabName === 'info') {
                infoView.style.display = 'block';
                editView.style.display = 'none';
                tabInfo.classList.add('active');
                tabEdit.classList.remove('active');
            } else {
                infoView.style.display = 'none';
                editView.style.display = 'block';
                tabInfo.classList.remove('active');
                tabEdit.classList.add('active');
            }
        }

        function openModal(src) {
            document.getElementById("imgModal").style.display = "block";
            document.getElementById("img01").src = src;
        }
        
        // 自动跳转到编辑页 (如果URL包含 action=edit)
        window.onload = function() {
            const urlParams = new URLSearchParams(window.location.search);
            if(urlParams.get('action') === 'edit') {
                showTab('edit');
            }
        }
    </script>
</body>
</html>