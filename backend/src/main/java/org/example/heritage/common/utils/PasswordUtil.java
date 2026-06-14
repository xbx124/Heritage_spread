package org.example.heritage.common.utils;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public class PasswordUtil {

    private static final BCryptPasswordEncoder ENCODER =
            new BCryptPasswordEncoder();

    /**
     * 加密密码
     */
    public static String encode(String rawPassword) {
        return ENCODER.encode(rawPassword);
    }

    /**
     * 校验密码
     */
    public static boolean matches(String rawPassword,
                                  String encodedPassword) {
        return ENCODER.matches(rawPassword, encodedPassword);
    }

    private PasswordUtil() {
    }
}