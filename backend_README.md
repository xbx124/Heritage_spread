# Heritage Spread Backend

非遗文化传播系统后端服务，基于 Spring Boot + MyBatis-Plus + MySQL 实现，提供用户认证、非遗项目管理、分类管理、传承人管理、文化资讯管理、评论、传播渠道与传播数据统计等接口。

## 一、技术栈

- JDK 17
- Spring Boot
- MyBatis-Plus
- MySQL 8.x
- Redis（当前配置中已预留）
- JWT
- Knife4j / SpringDoc OpenAPI

## 二、项目结构

```text
backend/
├── pom.xml
└── src/
    └── main/
        ├── java/org/example/heritage/
        │   ├── common/              # 通用结果、异常、常量、拦截器、工具类
        │   ├── config/              # JWT、Knife4j、WebMVC 配置
        │   ├── controller/          # Controller 接口层
        │   ├── mapper/              # MyBatis Mapper 接口
        │   ├── pojo/
        │   │   ├── dto/             # 请求 DTO
        │   │   ├── entity/          # 数据库实体类
        │   │   └── vo/              # 响应 VO
        │   ├── service/             # Service 接口
        │   └── service/impl/        # Service 实现类
        └── resources/
            ├── application.yml      # 项目配置
            └── mapper/              # MyBatis XML 文件
```

## 三、本地运行环境

请先确认本地已安装：

```bash
java -version
mvn -version
mysql --version
```

推荐环境：

```text
JDK: 17+
MySQL: 8.x
Maven: 3.8+
```

## 四、数据库配置

默认配置文件位置：

```text
backend/src/main/resources/application.yml
```

当前数据库连接配置示例：

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/heritage_spread_db?serverTimezone=Asia/Shanghai&characterEncoding=utf-8&useSSL=false&allowPublicKeyRetrieval=true
    username: root
    password: your_password
    driver-class-name: com.mysql.cj.jdbc.Driver
```

运行前请先创建数据库：

```sql
CREATE DATABASE IF NOT EXISTS heritage_spread_db
DEFAULT CHARACTER SET utf8mb4
COLLATE utf8mb4_general_ci;
```

Maven依赖请见
```text
backend/pom.xml
```

如团队仓库中存在数据库脚本，请优先执行：

```text
database/create.sql
database/sample.sql
```

如团队仓库数据库脚本还不存在/未完善，可先运行：
```text
backend\src\main\resources\heritage_spread_db
```

## 五、启动项目

在 `backend` 目录下执行：

```bash
mvn clean install
mvn spring-boot:run
```

启动成功后，默认访问地址【前端请求后端地址】：

```text
http://localhost:8080
```

Knife4j 接口文档地址通常为：

```text
http://localhost:8080/doc.html
```

OpenAPI JSON 地址通常为：

```text
http://localhost:8080/v3/api-docs
```

## 六、JWT 使用说明

登录接口成功后会返回 Token。

后续需要登录权限的接口，请在请求头中携带：

```http
Authorization: Bearer your_token
```

在 Knife4j 中测试时，也需要填写：

```text
Bearer your_token
```

## 七、注意事项

1. 不要把本地数据库密码、密钥、临时文件提交到仓库。
2. `application.yml` 中的数据库密码建议改成个人本地配置，或使用 `application-dev.yml` 单独维护。
3. 提交前建议执行：

```bash
mvn clean test
```

4. 如果新增 Mapper XML，请确认 `application.yml` 中的配置包含：

```yaml
mybatis-plus:
  mapper-locations: classpath*:mapper/**/*.xml
```

5. 如果接口需要登录，请确认前端请求头携带 JWT Token。
