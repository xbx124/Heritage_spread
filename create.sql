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
