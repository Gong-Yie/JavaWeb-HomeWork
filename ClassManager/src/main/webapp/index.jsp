<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>班级管理系统-首页</title>
    <link rel="stylesheet" href="background.css"/>
</head>
<body>
	<!-- 动态背景 -->
	<ul class="circles">
	    <li></li><li></li><li></li><li></li><li></li>
	    <li></li><li></li><li></li><li></li><li></li>
	</ul>
    <!-- 1. 侧边栏 (公共部分) -->
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

    <!-- 2. 主容器 -->
    <div id="main-content">
        <jsp:include page="header_inc.jsp" />
        
        <!-- 使用新的 content-box 居中显示 -->
        <div class="content-box" style="text-align: center; margin-top: 15vh; padding: 60px; width: 60%; max-width: 800px;">
            <h1 style="font-size: 3em; color: #333; margin-bottom: 20px; text-shadow: 2px 2px 4px rgba(0,0,0,0.1);">
                <span id="typed-text"></span><span class="typing-cursor" style="color:#2575fc;">|</span>
            </h1>
            
            <div id="welcome-container" style="font-size: 1.5em; color: #666; margin-top: 20px;">
                <span id="welcome"></span><span class="over"></span>
            </div>
            
            <div style="margin-top: 50px;">
                <a href="student?method=studentList" class="btn btn-edit" style="padding: 15px 40px; font-size: 18px; border-radius: 50px;">进入系统</a>
            </div>
        </div>
    </div>

    <!-- 3. JS脚本 (公共逻辑) -->
    <script>
        // 侧边栏开关逻辑
        function openNav() {
            document.getElementById("mySidenav").style.width = "250px";
            document.getElementById("main-content").style.marginLeft = "250px";
        }
        function closeNav() {
            document.getElementById("mySidenav").style.width = "0";
            document.getElementById("main-content").style.marginLeft = "0";
        }

        // 首页特有的打字动画 (仅在index.jsp保留)
        document.addEventListener('DOMContentLoaded', function() {
            const typedTextElement = document.getElementById('typed-text');
            const cursorElement = document.querySelector('.typing-cursor');
            const text = "高校班级管理系统";
            let index = 0;
            function typeWriter() {
                if (index < text.length) {
                    typedTextElement.textContent += text.charAt(index);
                    index++;
                    setTimeout(typeWriter, 200);
                } else {
                    setTimeout(() => { cursorElement.style.display = 'none'; startWelcomeAnimation(); }, 1000);
                }
            }
            setTimeout(typeWriter, 300);
        });
        function startWelcomeAnimation() {
            const welcomeElement = document.getElementById('welcome');
            const overElement = document.querySelector('.over');
            const text = "Welcome to Class System!";
            let index = 0;
            overElement.style.display = 'inline-block';
            function typeWriter() {
                if (index < text.length) { welcomeElement.textContent += text.charAt(index); index++; setTimeout(typeWriter, 100); }
                else { setTimeout(typeDelete, 1500); }
            }
            function typeDelete() {
                if (index > 0) { welcomeElement.textContent = text.substring(0, index - 1); index--; setTimeout(typeDelete, 50); }
                else { setTimeout(() => { overElement.style.display = 'none'; }, 500); }
            }
            typeWriter();
        }
        
     	// 切换下拉菜单
        function toggleDropdown() {
            var drop = document.getElementById("userDrop");
            if (drop.style.display === "block") {
                drop.style.display = "none";
            } else {
                drop.style.display = "block";
            }
        }

        // 点击页面其他地方关闭下拉菜单
        window.onclick = function(event) {
            if (!event.target.matches('.user-dropdown') && !event.target.matches('.user-dropdown *')) {
                var drop = document.getElementById("userDrop");
                if (drop && drop.style.display === "block") {
                    drop.style.display = "none";
                }
            }
        }
    </script>
</body>
<!-- ==================================================================== -->
<!-- Sakana 摇摇乐组件 (开始) -->
<!-- ==================================================================== -->
<style>
    /* 1. 容器定位：左下角固定 */
    #sakana-widget-container {
        position: fixed;
        left: 20px;
        bottom: 0;
        z-index: 9999; /* 确保层级最高，浮在所有内容上面 */
        width: 200px;
        /* 初始状态向下隐藏内容，只露出把手 */
        transform: translateY(calc(100% - 40px)); 
        transition: transform 0.4s cubic-bezier(0.34, 1.56, 0.64, 1);
        background: rgba(255, 255, 255, 0.95);
        border-radius: 15px 15px 0 0;
        box-shadow: 0 -2px 10px rgba(0,0,0,0.15);
        font-family: sans-serif;
    }

    /* 激活状态：向上弹出 */
    #sakana-widget-container.active {
        transform: translateY(0);
    }

    /* 2. 上拉把手 */
    .sakana-handle {
        height: 40px;
        width: 100%;
        cursor: pointer;
        display: flex;
        justify-content: center;
        align-items: center;
        color: #666;
        font-size: 20px;
        user-select: none;
        border-bottom: 1px solid #eee;
        font-weight: bold;
    }
    .sakana-handle:hover {
        background-color: rgba(0,0,0,0.05);
        border-radius: 15px 15px 0 0;
        color: #2575fc;
    }

    /* 3. 物理效果区域 */
    .sakana-box {
        width: 100%;
        height: 260px;
        position: relative;
        overflow: hidden;
    }

    .sakana-box canvas {
        position: absolute;
        left: 0;
        right: 0;
        bottom: 0;
        width: 100%;
        height: 100%;
        pointer-events: none;
    }

    /* 4. 头像样式 (这里修改图片路径) */
    .sakana-character {
        width: 120px;
        height: 120px;
        position: absolute;
        left: 50%;
        bottom: 80px;
        margin-left: -60px;
        cursor: grab;
        background-size: cover; /* 确保图片填满 */
        background-repeat: no-repeat;
        background-position: center;
        border-radius: 50%; /* 如果你想让头像是圆形的，保留这行；方形则删掉 */
        
        /* ↓↓↓↓↓ 关键修改：直接写文件名即可 ↓↓↓↓↓ */
        background-image: url('photos/gongyizhen.jpg'); 
    }
    .sakana-character:active {
        cursor: grabbing;
    }

    /* 5. 底部文字介绍 */
    .sakana-footer {
        text-align: center;
        font-size: 12px;
        color: #666;
        padding: 10px;
        background: #f9f9f9;
        border-top: 1px solid #eee;
        line-height: 1.6;
    }
</style>

<div id="sakana-widget-container">
    <!-- 上拉点击区域 -->
    <div class="sakana-handle" onclick="toggleSakana()">
        <span id="handle-icon">↑ 展开</span>
    </div>
    
    <!-- 摇晃动画区域 -->
    <div id="sakana-app" class="sakana-box"></div>

    <!-- 底部介绍 -->
    <div class="sakana-footer">
        <b>作者：工一阵</b><br>
        <b>qq：3750387410</b>
    </div>
</div>

<script>
    // 切换显示/隐藏逻辑
    function toggleSakana() {
        var container = document.getElementById('sakana-widget-container');
        var icon = document.getElementById('handle-icon');
        
        // 兼容旧浏览器的 classList 切换
        if (container.className.indexOf('active') === -1) {
            container.className += " active";
            icon.innerText = '↓ 收起';
        } else {
            container.className = container.className.replace(" active", "");
            icon.innerText = '↑ 展开';
        }
    }

    // 物理引擎逻辑 (为了避免变量污染，使用立即执行函数)
    (function() {
        var SakanaSimple = {
            init: function(elSelector) {
                var inertia = 0.08; 
                var sticky = 0.1;   
                var maxR = 60;      
                var maxY = 110;     
                var decay = 0.99;   

                var v = { r: 0, y: 0, t: 0, w: 0 };
                var running = false;
                var isDragging = false;

                function rotatePoint(cx, cy, x, y, angle) {
                    var radians = (Math.PI / 180) * angle;
                    var cos = Math.cos(radians);
                    var sin = Math.sin(radians);
                    return {
                        x: (cos * (x - cx)) + (sin * (y - cy)) + cx,
                        y: (cos * (y - cy)) - (sin * (x - cx)) + cy
                    };
                }

                var el = document.querySelector(elSelector);
                if (!el) return;

                el.innerHTML = '<canvas></canvas><div class="sakana-character"></div>';
                var canvas = el.querySelector('canvas');
                var characterEl = el.querySelector('.sakana-character');
                var ctx = canvas.getContext('2d');

                var width = el.clientWidth;
                var height = el.clientHeight;
                var dpr = window.devicePixelRatio || 1;
                canvas.width = width * dpr;
                canvas.height = height * dpr;
                ctx.scale(dpr, dpr);

                function draw() {
                    var r = v.r;
                    var y = v.y;
                    var x = r * 1;
                    
                    characterEl.style.transform = 'rotate(' + r + 'deg) translateX(' + x + 'px) translateY(' + y + 'px)';

                    ctx.clearRect(0, 0, width, height);
                    ctx.save();
                    ctx.strokeStyle = '#333';
                    ctx.lineWidth = 6;
                    ctx.lineCap = 'round';

                    ctx.beginPath();
                    var basePathX = width / 2;
                    var basePathY = height; 

                    ctx.translate(basePathX, basePathY);
                    ctx.moveTo(0, 0); 

                    var rodHeight = 80; 
                    var n = rotatePoint(0, 0, x, -y - rodHeight, r);
                    
                    ctx.quadraticCurveTo(0, -rodHeight / 2, n.x, n.y);
                    ctx.stroke();
                    ctx.restore();
                }

                function run() {
                    if (!running && !isDragging && Math.abs(v.w) < 0.1 && Math.abs(v.r) < 0.1 && Math.abs(v.t) < 0.1 && Math.abs(v.y) < 0.1) {
                        running = false;
                        return;
                    }

                    var r = v.r; var y = v.y; var t = v.t; var w = v.w;

                    w = w - r * 2;
                    r = r + w * inertia * 1.2;
                    v.w = w * decay;
                    v.r = r;

                    t = t - y * 2;
                    y = y + t * inertia * 2;
                    v.t = t * decay;
                    v.y = y;

                    draw();
                    requestAnimationFrame(run);
                }

                function startLoop() {
                    if (!running) {
                        running = true;
                        run();
                    }
                }

                function move(x, y) {
                    var r = x * sticky;
                    r = Math.max(-maxR, Math.min(maxR, r));
                    var ny = y * sticky * 2;
                    ny = Math.max(-maxY, Math.min(maxY, ny));

                    v.r = r;
                    v.y = ny;
                    v.w = 0;
                    v.t = 0;
                    draw();
                }

                function onMouseDown(e) {
                    if(e.cancelable) e.preventDefault();
                    isDragging = true;
                    running = false;
                    
                    // 兼容触摸和鼠标
                    var clientY = e.pageY || (e.touches ? e.touches[0].pageY : 0);
                    var rect = el.getBoundingClientRect();
                    var centerX = rect.left + rect.width / 2;
                    var startY = clientY;

                    function onMouseMove(event) {
                        var pageX = event.pageX || (event.touches ? event.touches[0].pageX : 0);
                        var pageY = event.pageY || (event.touches ? event.touches[0].pageY : 0);
                        move(pageX - centerX, pageY - startY);
                    }

                    function onMouseUp() {
                        document.removeEventListener('mousemove', onMouseMove);
                        document.removeEventListener('mouseup', onMouseUp);
                        document.removeEventListener('touchmove', onMouseMove);
                        document.removeEventListener('touchend', onMouseUp);
                        isDragging = false;
                        startLoop();
                    }

                    document.addEventListener('mousemove', onMouseMove);
                    document.addEventListener('mouseup', onMouseUp);
                    document.addEventListener('touchmove', onMouseMove, {passive: false});
                    document.addEventListener('touchend', onMouseUp);
                }

                characterEl.addEventListener('mousedown', onMouseDown);
                characterEl.addEventListener('touchstart', onMouseDown, {passive: false});

                // 初始给一点力
                v.r = 10; 
                startLoop();
            }
        };

        // 初始化
        SakanaSimple.init('#sakana-app');
    })();
</script>
<!-- ==================================================================== -->
<!-- Sakana 摇摇乐组件 (结束) -->
<!-- ==================================================================== -->
</html>