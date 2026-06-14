# 非遗文化数字化传播系统

> 数据库原理与传播应用实验 · 实验六大作业

## 项目简介

基于 MySQL 数据库设计并实现的非遗文化数字化传播管理系统，涵盖非遗资源管理、传承人管理、文化资讯发布、传播渠道管理及传播数据统计分析等核心功能。

## 目录结构

```
heritage-spread-system/
├── database/                # 数据库脚本（成员A负责）
│   └── heritagespread_db.sql    # 建库建表 + 样例数据
├── backend/                 # 后端接口代码 - Java Spring Boot（成员B负责）
│   ├── src/
│   ├── pom.xml
│   └── README.md
├── frontend/                # 前端页面（成员C负责）
│   ├── css/       style.css
│   ├── js/        app.js / landing.js
│   ├── images/    非遗主题图片
│   ├── login.html            # 首页（登录/注册 + 轮播图）
│   ├── index.html            # 管理后台
│   └── README.md
├── data/                    # 统计图表模块（成员D负责）
│   ├── js/        stats.js
│   └── README.md
├── docs/                    # 文档资料
│   ├── 接口文档.md
│   ├── ER图.png
│   └── 实验报告.docx
├── app.py                   # Flask 前端服务 + API 反向代理
├── requirements.txt         # Python 依赖
└── README.md
```

## 小组分工

| 成员          | 负责模块                         | 对应目录    |
| ------------- | -------------------------------- | ----------- |
| 成员A（组长） | 数据库设计、SQL脚本、项目统筹    | `database/` |
| 成员B         | 后端接口开发（Java Spring Boot） | `backend/`  |
| 成员C         | 前端页面开发                     | `frontend/` |
| 成员D         | 传播数据统计、实验报告           | `data/`     |
| 成员E         | 系统测试、样例数据、演讲PPT      | 全局        |

## 技术栈

- **数据库**：MySQL 8.0
- **后端**：Java Spring Boot + MyBatis-Plus + JWT
- **前端**：HTML + CSS + JavaScript + ECharts 5.5
- **代理**：Python Flask（静态文件 + API 反向代理）

## 系统架构

```
浏览器 ⟶ localhost:8080 (Flask)
              │
              ├─ 静态文件 (frontend/) → HTML/CSS/JS
              ├─ 统计模块 (data/)     → stats.js
              └─ /api/*  ──────────→ localhost:8081 (Java Spring Boot)
                                           │
                                           └─ MySQL (heritage_spread_db)
```

## 快速开始

### 前置条件

- Python 3.8+（已安装 pip）
- Java JDK 17+
- MySQL 8.0（已启动）
- Maven 3.6+

### 1. 安装 Python 依赖

```bash
pip install -r requirements.txt
```

### 2. 初始化数据库

在 MySQL 中执行 `database/heritagespread_db.sql`：

```bash
# 方式一：命令行
mysql -u root -p < database/heritagespread_db.sql

# 方式二：MySQL Workbench
# 打开 database/heritagespread_db.sql → 执行
```

### 3. 修改 Java 后端端口

编辑 `backend/src/main/resources/application.yml`，将 `server.port` 改为 **8081**：

```yaml
server:
  port: 8081    # 原来是 8080，改为 8081 避免与 Flask 冲突
```

同时确认数据库连接配置正确（用户名、密码）：

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/heritage_spread_db?...
    username: root          # 改成你的 MySQL 用户名
    password: your_password # 改成你的 MySQL 密码
```

### 4. 启动 Java 后端

```bash
cd backend
mvn spring-boot:run
```

启动成功后访问 `http://localhost:8081`，看到 Spring Boot 启动日志即表示成功。

### 5. 启动 Flask 前端服务

```bash
# 在项目根目录
python app.py
```

启动后输出：

```
==============================================================
  非遗文化数字化传播系统 - 前端服务
  静态文件: http://localhost:8080
  API 代理: /api/* → http://localhost:8081/api/*
==============================================================
  请确保 Java 后端已启动（端口 8081）
==============================================================
```

### 6. 访问系统

浏览器打开 **http://localhost:8080**

- 首页 → 非遗轮播图 + 登录/注册
- 登录后 → 管理后台（非遗分类、项目、传承人、资讯、渠道、数据统计）

## 注意事项

- 启动顺序：MySQL → Java 后端 → Flask 前端
- Java 后端端口必须为 8081（Flask 占用 8080 做静态文件服务）
- 前端代码无需任何修改，所有 API 请求为相对路径 `/api/...`，Flask 自动转发到 Java 后端
- 如果只运行 Flask 不运行 Java 后端，API 请求会返回 503 错误提示"后端服务未启动"
- 接口文档详见 `docs/接口文档.md`，前端说明详见 `frontend/README.md`
