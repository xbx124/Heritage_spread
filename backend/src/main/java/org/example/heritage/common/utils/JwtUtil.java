package org.example.heritage.common.utils;

import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;
import com.auth0.jwt.interfaces.DecodedJWT;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import org.example.heritage.config.JwtConfig;
import org.springframework.stereotype.Component;

import java.util.Date;

@Component
@RequiredArgsConstructor
public class JwtUtil {

    private final JwtConfig jwtConfig;

    private static String secretKey;
    private static Long ttl;

    @PostConstruct
    public void init() {
        secretKey = jwtConfig.getSecretKey();
        ttl = jwtConfig.getTtl();
    }

    public static String createToken(Long userId, String username, String role) {
        return JWT.create()
                .withClaim("userId", userId)
                .withClaim("username", username)
                .withClaim("role", role)
                .withExpiresAt(new Date(System.currentTimeMillis() + ttl))
                .sign(Algorithm.HMAC256(secretKey));
    }

    public static DecodedJWT verify(String token) {
        return JWT.require(Algorithm.HMAC256(secretKey))
                .build()
                .verify(token);
    }

    public static Long getUserId(String token) {
        return verify(token).getClaim("userId").asLong();
    }

    public static String getUsername(String token) {
        return verify(token).getClaim("username").asString();
    }

    public static String getRole(String token) {
        return verify(token).getClaim("role").asString();
    }
}