package org.example.heritage;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan("org.example.heritage.mapper")
public class HeritageApplication {

    public static void main(String[] args) {
        SpringApplication.run(HeritageApplication.class, args);
    }

}
