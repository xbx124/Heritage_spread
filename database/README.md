# 非遗文化传播数据库 - 导入指南

本指南帮助团队成员快速搭建本地开发环境，完成数据库的导入。

## 📋 前置要求

- MySQL 8.0+
- Git（用于克隆仓库）
- 基本的命令行操作能力

## 📁 文件说明
your-repo/
├── database/
│ └── heritagespread_db.sql # 建表脚本 + 用户数据
├── data/
│ ├── heritage_category.csv # 分类数据（52条）
│ ├── heritage_project.csv # 项目数据（55条）
│ ├── heritage_inheritor.csv # 传承人数据（52条）
│ ├── heritage_news.csv # 资讯数据（54条）
│ ├── spread_channel.csv # 渠道数据（20条）
│ ├── news_comment.csv # 评论数据（20条）
│ └── spread_data.csv # 传播数据（10条）
└── README.md

text

## 🚀 快速开始

### 第一步：创建数据库并建表

打开终端（Windows 用 CMD，Mac/Linux 用 Terminal），执行：

```bash
# 进入项目目录
cd your-repo

# 创建数据库并建表（需要输入 MySQL 密码）
mysql -u root -p < database/heritagespread_db.sql
如果提示 mysql 命令不存在，说明 MySQL 没有加入系统 PATH，请先安装或配置环境变量。

第二步：登录 MySQL 并开启本地导入
bash
mysql -u root -p --local-infile=1
输入密码后进入 mysql> 命令行环境。

第三步：选择数据库
sql
USE heritage_spread_db;
第四步：按顺序导入 CSV 文件
⚠️ 注意：必须严格按照以下顺序执行，否则会因为外键约束报错。

请逐条复制粘贴下面的命令，每执行完一条再复制下一条。

1. 导入分类数据（52条）
sql
LOAD DATA LOCAL INFILE 'data/heritage_category.csv'
INTO TABLE heritage_category
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
2. 导入项目数据（55条）
sql
LOAD DATA LOCAL INFILE 'data/heritage_project.csv'
INTO TABLE heritage_project
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
3. 导入传承人数据（52条）
sql
LOAD DATA LOCAL INFILE 'data/heritage_inheritor.csv'
INTO TABLE heritage_inheritor
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
4. 导入渠道数据（20条）
sql
LOAD DATA LOCAL INFILE 'data/spread_channel.csv'
INTO TABLE spread_channel
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
5. 导入资讯数据（54条）
sql
LOAD DATA LOCAL INFILE 'data/heritage_news.csv'
INTO TABLE heritage_news
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
6. 导入评论数据（20条）
sql
LOAD DATA LOCAL INFILE 'data/news_comment.csv'
INTO TABLE news_comment
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
7. 导入传播数据（10条）
sql
LOAD DATA LOCAL INFILE 'data/spread_data.csv'
INTO TABLE spread_data
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
第五步：验证导入结果
执行以下命令，检查各表数据量是否正确：

sql
SELECT 'heritage_category' AS 表名, COUNT(*) AS 记录数 FROM heritage_category
UNION ALL
SELECT 'heritage_project', COUNT(*) FROM heritage_project
UNION ALL
SELECT 'heritage_inheritor', COUNT(*) FROM heritage_inheritor
UNION ALL
SELECT 'spread_channel', COUNT(*) FROM spread_channel
UNION ALL
SELECT 'heritage_news', COUNT(*) FROM heritage_news
UNION ALL
SELECT 'news_comment', COUNT(*) FROM news_comment
UNION ALL
SELECT 'spread_data', COUNT(*) FROM spread_data;
预期结果：

表名	记录数
heritage_category	52
heritage_project	55
heritage_inheritor	52
spread_channel	20
heritage_news	54
news_comment	20
spread_data	10
第六步：退出 MySQL
sql
EXIT;
❗ 常见问题排查
Q1: 报错 The used command is not allowed
原因： 没有开启本地文件导入权限。

解决： 退出 MySQL 重新登录，加上 --local-infile=1 参数：

bash
mysql -u root -p --local-infile=1
Q2: 报错 File not found
原因： CSV 文件路径不对。

解决：

确认你在项目根目录下执行 MySQL 命令

使用绝对路径：LOAD DATA LOCAL INFILE 'C:/完整路径/data/xxx.csv'

注意 Windows 路径用正斜杠 /，不要用反斜杠 \

Q3: 报错 Duplicate entry for primary key
原因： 表中已有数据，主键冲突。

解决： 清空对应表后重新导入：

sql
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE 表名;
SET FOREIGN_KEY_CHECKS = 1;
Q4: 中文显示为乱码
原因： 编码设置不对。

解决： 确保所有 LOAD DATA 命令中包含 CHARACTER SET utf8mb4，且 CSV 文件保存为 UTF-8 编码。

Q5: 提示外键约束错误
原因： 导入顺序不对，子表先于父表导入。

解决： 严格按照第四步的顺序执行：分类 → 项目 → 传承人 → 渠道 → 资讯 → 评论 → 传播数据。

📞 需要帮助？
