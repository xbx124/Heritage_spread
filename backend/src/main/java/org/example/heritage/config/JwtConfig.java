package org.example.heritage.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Data
@Configuration
@ConfigurationProperties(prefix = "jwt")
public class JwtConfig {

    /**
     * jwt密钥
     */
    private String secretKey;

    /**
     * 过期时间(毫秒)
     */
    private Long ttl;
}