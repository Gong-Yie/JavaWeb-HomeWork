package com.classsys.util;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

/**
 * JWT 工具类：基于时间戳的验证
 */
public class JwtUtil {
    // 密钥 (保持不变)
    private static final String SECRET_STRING = "MySuperSecretKeyForClassSystemproject2023!!";
    private static final SecretKey KEY = Keys.hmacShaKeyFor(SECRET_STRING.getBytes(StandardCharsets.UTF_8));
    
    // 设置过期时间：这里为了测试方便，设为 30分钟 (30 * 60 * 1000)
    // 如果你想立刻测试过期效果，可以改成 10 * 1000 (10秒)
    private static final long EXPIRATION_TIME = 1000 * 60 * 60 * 3; 

    /**
     * 生成带时间戳的 Token
     */
    public static String createToken(String username, String role) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("role", role); 

        long nowMillis = System.currentTimeMillis();
        Date now = new Date(nowMillis);
        Date exp = new Date(nowMillis + EXPIRATION_TIME); // 计算过期时间点

        return Jwts.builder()
                .setClaims(claims)
                .setSubject(username)
                .setIssuedAt(now)      // 签发时间 (iat)
                .setExpiration(exp)    // 过期时间 (exp) -> 核心验证字段
                .signWith(KEY, SignatureAlgorithm.HS256)
                .compact();
    }

    /**
     * 验证 Token (包含时间戳验证)
     */
    public static String verifyToken(String token) {
        try {
            Claims claims = Jwts.parserBuilder()
                    .setSigningKey(KEY)
                    .build()
                    .parseClaimsJws(token) // 这一步会自动校验 exp 时间戳
                    .getBody();
            
            return claims.getSubject(); // 返回用户名
            
        } catch (ExpiredJwtException e) {
            // 专门捕获过期异常
            System.out.println("Token 已过期 (Timestamp Validation Failed): " + e.getMessage());
            return null; 
        } catch (Exception e) {
            System.out.println("Token 验证无效: " + e.getMessage());
            return null;
        }
    }
    
    /**
     * 获取角色
     */
    public static String getRole(String token) {
        try {
            Claims claims = Jwts.parserBuilder()
                    .setSigningKey(KEY)
                    .build()
                    .parseClaimsJws(token)
                    .getBody();
            return (String) claims.get("role");
        } catch (Exception e) {
            return null;
        }
    }
}