-- ============================================================
--  非遗文化数字化传播系统 — 数据库建库脚本
--  执行方式：在 MySQL Workbench 中打开此文件，点击执行
-- ============================================================

CREATE DATABASE IF NOT EXISTS heritage_spread_db
  DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE heritage_spread_db;

-- ------------------------------------------------------------
-- 表1：系统用户表
-- ------------------------------------------------------------
CREATE TABLE sys_user (
    user_id     INT          PRIMARY KEY AUTO_INCREMENT,
    username    VARCHAR(30)  NOT NULL UNIQUE COMMENT '登录账号',
    password    VARCHAR(100) NOT NULL COMMENT 'BCrypt加密密码',
    role        VARCHAR(20)  NOT NULL DEFAULT 'user' COMMENT 'admin/editor/user',
    create_time DATETIME     DEFAULT NOW()
) COMMENT='系统用户表';

-- ------------------------------------------------------------
-- 表2：非遗分类表
-- ------------------------------------------------------------
CREATE TABLE heritage_category (
    category_id   INT         PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(50) NOT NULL UNIQUE COMMENT '如：传统技艺、传统戏剧',
    category_desc VARCHAR(255) COMMENT '分类介绍'
) COMMENT='非遗分类表';

-- ------------------------------------------------------------
-- 表3：非遗项目表
-- ------------------------------------------------------------
CREATE TABLE heritage_project (
    project_id    INT          PRIMARY KEY AUTO_INCREMENT,
    project_name  VARCHAR(100) NOT NULL COMMENT '非遗项目名称',
    category_id   INT          NOT NULL COMMENT '所属分类',
    project_intro TEXT         COMMENT '项目详细介绍',
    area          VARCHAR(50)  COMMENT '所属地区',
    create_time   DATETIME     DEFAULT NOW(),
    CONSTRAINT fk_project_category FOREIGN KEY (category_id)
        REFERENCES heritage_category(category_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) COMMENT='非遗项目表';

-- ------------------------------------------------------------
-- 表4：非遗传承人表
-- ------------------------------------------------------------
CREATE TABLE heritage_inheritor (
    inheritor_id INT         PRIMARY KEY AUTO_INCREMENT,
    name         VARCHAR(30) NOT NULL COMMENT '传承人姓名',
    project_id   INT         NOT NULL COMMENT '关联非遗项目',
    years        INT         CHECK (years >= 0) COMMENT '从业年限',
    intro        TEXT        COMMENT '传承人简介',
    CONSTRAINT fk_inheritor_project FOREIGN KEY (project_id)
        REFERENCES heritage_project(project_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) COMMENT='非遗传承人表';

-- ------------------------------------------------------------
-- 表5：文化资讯表
-- ------------------------------------------------------------
CREATE TABLE heritage_news (
    news_id      INT          PRIMARY KEY AUTO_INCREMENT,
    title        VARCHAR(100) NOT NULL COMMENT '资讯标题',
    content      TEXT         NOT NULL COMMENT '资讯正文',
    user_id      INT          NOT NULL COMMENT '发布编辑ID',
    publish_time DATETIME     DEFAULT NOW(),
    CONSTRAINT fk_news_user FOREIGN KEY (user_id)
        REFERENCES sys_user(user_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) COMMENT='文化资讯表';

-- ------------------------------------------------------------
-- 表6：传播渠道表
-- ------------------------------------------------------------
CREATE TABLE spread_channel (
    channel_id   INT         PRIMARY KEY AUTO_INCREMENT,
    channel_name VARCHAR(50) NOT NULL COMMENT '如：官网、微信公众号',
    channel_type VARCHAR(30) NOT NULL COMMENT '线上 / 线下'
) COMMENT='传播渠道表';

-- ------------------------------------------------------------
-- 表7：传播数据表
-- ------------------------------------------------------------
CREATE TABLE spread_data (
    data_id      INT      PRIMARY KEY AUTO_INCREMENT,
    project_id   INT      NOT NULL COMMENT '关联非遗项目',
    channel_id   INT      NOT NULL COMMENT '关联传播渠道',
    view_num     INT      DEFAULT 0 CHECK (view_num >= 0)     COMMENT '浏览量',
    exposure_num INT      DEFAULT 0 CHECK (exposure_num >= 0) COMMENT '曝光量',
    stat_time    DATETIME DEFAULT NOW() COMMENT '统计时间',
    CONSTRAINT fk_data_project FOREIGN KEY (project_id)
        REFERENCES heritage_project(project_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_data_channel FOREIGN KEY (channel_id)
        REFERENCES spread_channel(channel_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) COMMENT='传播数据表';

-- ============================================================
--  样例数据（供成员E演示用，执行建表后再执行这部分）
-- ============================================================

-- 用户数据
INSERT INTO sys_user (username, password, role) VALUES
('admin',   '$2a$10$admin_hash_placeholder',  'admin'),
('editor1', '$2a$10$editor_hash_placeholder', 'editor'),
('user1',   '$2a$10$user_hash_placeholder',   'user');

-- 非遗分类
INSERT INTO heritage_category (category_name, category_desc) VALUES
('传统技艺', '包括各类手工技艺、制作工艺等'),
('传统戏剧', '包括地方戏曲、皮影戏等表演艺术'),
('传统民俗', '包括节庆习俗、礼仪风俗等'),
('民间文学', '包括神话、传说、史诗、故事等');

-- 非遗项目
INSERT INTO heritage_project (project_name, category_id, project_intro, area) VALUES
('景德镇手工制瓷技艺', 1, '千年瓷都景德镇独有的手工拉坯、绘瓷技艺，列入国家级非遗名录。', '江西景德镇'),
('昆曲',               2, '中国现存最古老的戏曲剧种之一，被誉为"百戏之祖"。',            '江苏苏州'),
('春节（春节习俗）',   3, '中华民族最重要的传统节日，包含守岁、放鞭炮、拜年等习俗。',    '全国'),
('格萨尔',             4, '藏族英雄史诗，世界最长史诗之一，口耳相传至今。',               '西藏、青海');

-- 传承人
INSERT INTO heritage_inheritor (name, project_id, years, intro) VALUES
('王龙根', 1, 40, '景德镇手工拉坯第四代传承人，师从其父，精通青花与粉彩。'),
('汪世瑜', 2, 50, '著名昆曲表演艺术家，国家级非遗传承人，工小生。'),
('才让旦周', 4, 35, '格萨尔说唱艺人，能完整演唱百余部史诗。');

-- 传播渠道
INSERT INTO spread_channel (channel_name, channel_type) VALUES
('官方网站',     '线上'),
('微信公众号',   '线上'),
('抖音短视频',   '线上'),
('线下博物馆展', '线下');

-- 传播数据
INSERT INTO spread_data (project_id, channel_id, view_num, exposure_num, stat_time) VALUES
(1, 1, 12400, 35000, '2025-05-01 00:00:00'),
(1, 2, 8800,  22000, '2025-05-01 00:00:00'),
(1, 3, 45000, 130000,'2025-05-01 00:00:00'),
(2, 1, 9600,  28000, '2025-05-01 00:00:00'),
(2, 2, 6200,  18000, '2025-05-01 00:00:00'),
(3, 3, 88000, 250000,'2025-05-01 00:00:00'),
(3, 4, 3200,  8000,  '2025-05-01 00:00:00'),
(4, 1, 4100,  11000, '2025-05-01 00:00:00');

