# 非遗文化数字化传播系统

> 数据库原理与传播应用实验 · 实验六大作业

## 项目简介

基于 MySQL 数据库设计并实现的非遗文化数字化传播管理系统，涵盖非遗资源管理、传承人管理、文化资讯发布、传播渠道管理及传播数据统计分析等核心功能。

## 目录结构

```
heritage-spread-system/
├── database/          # 数据库脚本（成员A负责）
│   ├── create.sql     # 建库建表脚本
│   └── sample.sql     # 样例数据脚本
├── backend/           # 后端接口代码（成员B负责）
│   └── README.md      # 后端启动说明
├── frontend/          # 前端页面（成员C负责）
│   └── README.md      # 前端启动说明
├── data/              # 统计图表模块（成员D负责）
│   └── README.md
├── docs/              # 文档资料
│   ├── ER图.png        # 数据库ER图
│   ├── 接口文档.md     # B完成后填写
│   └── 实验报告.docx   # 最终提交报告
└── README.md
```

## 小组分工

| 成员 | 负责模块 | 对应目录 |
|------|----------|----------|
| 成员A（组长） | 数据库设计、SQL脚本、项目统筹 | `database/` |
| 成员B | 后端接口开发 | `backend/` |
| 成员C | 前端页面开发 | `frontend/` |
| 成员D | 传播数据统计、实验报告 | `data/` |
| 成员E | 系统测试、样例数据、演讲PPT | 全局 |

## 快速开始

### 1. 初始化数据库（所有人都要做）

```bash
# 在 MySQL Workbench 中依次执行：
database/create.sql   # 建库建表
database/sample.sql   # 导入样例数据
```

### 2. 启动后端

见 `backend/README.md`

### 3. 启动前端

见 `frontend/README.md`

## 技术栈

- 数据库：MySQL 8.0
- 后端：Python(Flask) / Java(Spring Boot)
- 前端：HTML + JavaScript + ECharts
- 版本管理：Git + GitHub
