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

### 1. 克隆项目

先安装 Git，然后在本地选择一个目录，右键打开终端，执行：

```bash
git clone https://github.com/xbx124/Heritage_spread.git
```

进入项目目录：

```bash
cd Heritage_spread
```

切换到后端分支：

```bash
git checkout backend
```

### 2. 用 IDEA 打开后端项目

打开 IntelliJ IDEA，选择：

```text
File → Open
```

然后选择：

```text
Heritage_spread/backend
```

注意：不要打开整个 `Heritage_spread` 根目录，后端 Spring Boot 项目在 `backend` 文件夹中。

如果 IDEA 提示：

```text
Trust Project?
```

点击：

```text
Trust Project
```

### 3. 确认需要的插件

刚下载 IDEA 的同学，需要确认已安装以下插件：

```text
File → Settings → Plugins
```

建议检查：

* Maven
* Spring Boot
* Lombok

其中：

* Maven：用于加载项目依赖
* Spring Boot：用于识别和运行 Spring Boot 项目
* Lombok：用于识别 `@Data`、`@Builder` 等注解

如果插件未安装，搜索插件名称并安装，安装后重启 IDEA。

### 4. 加载 Maven 依赖

打开项目后，IDEA 会自动识别 `pom.xml` 并加载依赖。

如果没有自动加载，可以：

```text
右键 backend/pom.xml
→ Add as Maven Project
```

或者打开右侧 Maven 面板，点击：

```text
Reload All Maven Projects
```

等待依赖下载完成。

### 5. 常见启动问题

#### ① 端口被占用

如果提示：

```text
Port 8080 was already in use
```

可以关闭占用 8080 的程序，或者在 `application.yml` 中修改端口：

```yaml
server:
  port: 8081
```

#### ② 数据库连接失败

如果提示数据库连接失败，请检查：

* MySQL 是否已启动
* 数据库名是否为 `heritage_spread_db`
* 用户名和密码是否正确
* 是否已导入数据库 SQL 脚本

#### ③ Maven 依赖无法下载

如果依赖一直下载失败，请检查：

* 网络是否正常
* IDEA 是否正确识别 `backend/pom.xml`
* Maven 配置是否正确

重新加载 Maven：

```text
右侧 Maven 面板 → Reload All Maven Projects
```

### 六、访问地址

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

## 七、JWT 使用说明

登录接口成功后会返回 Token。

后续需要登录权限的接口，请在请求头中携带：

```http
Authorization: Bearer your_token
```

在 Knife4j 中测试时，也需要填写：

```text
Bearer your_token
```

## 八、注意事项

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
