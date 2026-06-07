package org.example.heritage.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class Knife4jConfig {

    @Bean
    public OpenAPI heritageOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("非遗文化数字化传播系统")
                        .description("基于 Spring Boot 的非遗文化数字化传播系统后端接口文档")
                        .version("1.0.0"));
    }
}
