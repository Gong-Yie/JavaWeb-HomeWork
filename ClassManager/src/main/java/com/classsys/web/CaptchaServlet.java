package com.classsys.web;

import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.util.Random;
import javax.imageio.ImageIO;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/captcha")
public class CaptchaServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int width = 100, height = 40;
        BufferedImage image = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);
        Graphics g = image.getGraphics();
        
        // 背景
        g.setColor(Color.LIGHT_GRAY);
        g.fillRect(0, 0, width, height);
        
        // 随机字符
        String str = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
        Random ran = new Random();
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < 4; i++) {
            int index = ran.nextInt(str.length());
            char ch = str.charAt(index);
            sb.append(ch);
            g.setColor(new Color(ran.nextInt(100), ran.nextInt(100), ran.nextInt(100)));
            g.setFont(new Font("Arial", Font.BOLD, 24));
            g.drawString(ch + "", 20 * i + 10, 28);
        }
        
        // 将验证码存入 Session (用于验证)
        req.getSession().setAttribute("CHECK_CODE", sb.toString());
        
        // 干扰线
        for(int i=0; i<5; i++){
            g.setColor(Color.GRAY);
            g.drawLine(ran.nextInt(width), ran.nextInt(height), ran.nextInt(width), ran.nextInt(height));
        }
        
        resp.setContentType("image/jpeg");
        ImageIO.write(image, "jpeg", resp.getOutputStream());
    }
}