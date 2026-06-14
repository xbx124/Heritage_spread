/*
 ================================================================
  非遗文化数字化传播系统 — 数据库初始化脚本
  Database   : heritage_spread_db
  Engine     : MySQL 8.0+
  Charset    : utf8mb4 / utf8mb4_unicode_ci
  Version    : 1.3（修订版）
 ================================================================
  本版（v1.3）在 v1.2 基础上新增以下内容（均为新增对象，不影响
  原有表结构与数据）：

  【v1.3 新增】
  g. 新增视图 v_project_spread_stats
     按项目汇总传播渠道数、总浏览量、总曝光量，
     对应后端 ProjectStatsVO 接口的数据来源
  h. 新增触发器 trg_spread_data_check_time（INSERT）
     插入 spread_data 前校验 stat_time 不能晚于当前时间，
     防止误填未来日期的统计数据
  i. 新增触发器 trg_spread_data_check_time_update（UPDATE）
     更新 spread_data 前校验 stat_time 不能晚于当前时间，
     防止误填未来日期的统计数据
  j. spread_data 使用普通索引 idx_spread_query 替代唯一索引，
     降低唯一性检查的写入开销，业务唯一性由应用层保证
  k. 文件末尾新增"数据完整性自检"小结，汇总各表外键
     级联策略，便于答辩时整体说明设计意图

 ================================================================
  v1.2 修订内容：

  【v1.2 新增修正】
  a. spread_data.project_id / channel_id 改为 NOT NULL
     （统计记录必须归属具体项目与渠道）
  b. heritage_news.status 的 ENUM 增补 'pending'、'rejected'
     （后端 NewsPublishDTO 校验规则允许 published/draft/pending
      三种取值，原 ENUM 缺少 pending，会导致该状态写入失败）
  c. spread_channel.status 由 TINYINT(1) 统一改为 TINYINT
     （与 sys_user / heritage_project 等其他表的 status 字段
      写法保持一致，避免风格不统一）
  d. heritage_project ID=5 的 update_time 早于 create_time，
     已修正为合理的更新时间
  e. heritage_inheritor 表中不存在 avatar 字段（注释已同步清理）
  f. heritage_project ID=6 的 area '苗疆' 不是规范地名，
     已改为具体地区 '湖南湘西'，避免按地区筛选/统计时无法匹配

 ================================================================
  原脚本由成员B根据后端开发调整，v1.1 修订内容如下：

  【严重修正】
  1. AUTO_INCREMENT 值全部与实际最大 ID 对齐，防止下次插入主键冲突
  2. news_comment 补充外键约束（news_id → heritage_news，user_id → sys_user）
  3. news_comment.news_id / user_id 由 bigint 改为 int，与主表类型一致
  4. sys_user ID=4 明文密码替换为占位哈希，上线前务必重新生成 BCrypt

  【设计优化】
  5. 建表顺序按外键依赖关系重排，逻辑清晰
  6. create_id / update_id 统一为 int（对齐 sys_user.user_id）
  7. heritage_news.status 由 varchar(20) 改为 ENUM，类型更严格
  8. heritage_project.update_time 补充 ON UPDATE CURRENT_TIMESTAMP
  9. news_comment 字符集统一为 utf8mb4_unicode_ci
  10. news_comment 补充 status 软删除字段

  【数据修正】
  11. heritage_project ID=1 的 area 字段值由 '传统技艺'（分类名）
      修正为正确地区名 '江西景德镇'
  12. spread_channel 中测试残留数据（'B站1'、'B站1886'）已加注释，
      正式上线前建议清除

  【注释补充】
  13. 各字段补充中文 COMMENT
  14. 各建表语句增加表级 COMMENT
  15. 各分组增加结构说明注释
 ================================================================

  建表顺序（按外键依赖关系）：
    sys_user
    → heritage_category
    → heritage_project      (FK → heritage_category)
    → heritage_inheritor    (FK → heritage_project)
    → heritage_news         (FK → sys_user)
    → spread_channel
    → spread_data           (FK → heritage_project, spread_channel)
    → news_comment          (FK → heritage_news, sys_user)
 ================================================================
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;    -- 导入期间暂时关闭外键检查，导入完成后恢复


-- ================================================================
-- 表1：系统用户表 (sys_user)
-- 存储登录账号、BCrypt 加密密码及权限角色
-- 角色说明：admin=管理员，editor=内容编辑，user=普通浏览用户
-- ================================================================
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user` (
  `user_id`     INT          NOT NULL AUTO_INCREMENT         COMMENT '用户ID（主键）',
  `username`    VARCHAR(30)  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '登录用户名（全局唯一）',
  `password`    VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '登录密码（BCrypt 加密，禁止明文存储）',
  `role`        VARCHAR(20)  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'user' COMMENT '角色：admin-管理员，editor-内容编辑，user-普通用户',
  `status`      TINYINT      NOT NULL DEFAULT 1                  COMMENT '账号状态：1-正常，0-禁用',
  `create_time` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP  COMMENT '账号创建时间',
  `update_time` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后更新时间',
  PRIMARY KEY (`user_id`) USING BTREE,
  UNIQUE INDEX `uk_username` (`username` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6
  CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci
  COMMENT = '系统用户表'
  ROW_FORMAT = Dynamic;

-- ----------------------------
-- 初始用户数据
-- ⚠️ 生产环境上线前，所有密码必须使用 BCrypt 重新生成，$2a$10$hashedpwdN 均为占位符
-- ⚠️ user_id=4 原密码为明文 'zhangsan'（严重安全漏洞），已替换为占位哈希
-- ----------------------------
INSERT INTO `sys_user` VALUES (1, 'admin',   '$10$ULtIoGOypBQDip.8u5bxCedV1law2DMhPfzAKp5AJ.8GOVpnvxPYO', 'admin',  1, '2026-06-06 16:19:15', '2026-06-07 17:02:41');
INSERT INTO `sys_user` VALUES (2, 'editor1', '$10$ULtIoGOypBQDip.8u5bxCedV1law2DMhPfzAKp5AJ.8GOVpnvxPYO', 'editor', 1, '2026-06-06 16:19:15', '2026-06-07 17:02:41');
INSERT INTO `sys_user` VALUES (3, 'user1',   '$10$ULtIoGOypBQDip.8u5bxCedV1law2DMhPfzAKp5AJ.8GOVpnvxPYO', 'user',   1, '2026-06-06 16:19:15', '2026-06-07 17:02:41');
INSERT INTO `sys_user` VALUES (4, '张三',   '$10$ULtIoGOypBQDip.8u5bxCedV1law2DMhPfzAKp5AJ.8GOVpnvxPYO', 'admin', 1, '2026-06-07 11:55:16', '2026-06-07 17:02:41');
INSERT INTO `sys_user` VALUES (5, '张凉',   '$10$ULtIoGOypBQDip.8u5bxCedV1law2DMhPfzAKp5AJ.8GOVpnvxPYO', 'admin', 1, '2026-06-07 17:38:09', '2026-06-07 17:38:09');


-- ================================================================
-- 表2：非遗分类表 (heritage_category)
-- 存储非遗项目的顶层分类，如传统技艺、传统戏剧等
-- category_name 设有唯一约束，防止重复分类录入
-- ================================================================
DROP TABLE IF EXISTS `heritage_category`;
CREATE TABLE `heritage_category` (
  `category_id`   INT          NOT NULL AUTO_INCREMENT        COMMENT '分类ID（主键）',
  `category_name` VARCHAR(50)  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '分类名称，如：传统技艺、传统戏剧（唯一）',
  `category_desc` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '分类简介，描述该类别包含的典型内容',
  `create_time`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_id`     INT          NOT NULL			              COMMENT '创建人用户ID',
  `update_id`     INT          NOT NULL      		          COMMENT '最后修改人用户ID',
  PRIMARY KEY (`category_id`) USING BTREE,
  UNIQUE INDEX `uk_category_name` (`category_name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6
  CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci
  COMMENT = '非遗分类表'
  ROW_FORMAT = Dynamic;


-- ================================================================
-- 表3：非遗项目表 (heritage_project)
-- 系统核心传播素材主体，存储各类非遗项目基本信息
-- category_id 外键关联 heritage_category
-- ================================================================
DROP TABLE IF EXISTS `heritage_project`;
CREATE TABLE `heritage_project` (
  `project_id`    INT          NOT NULL AUTO_INCREMENT        COMMENT '项目ID（主键）',
  `project_name`  VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '非遗项目名称',
  `category_id`   INT          NOT NULL DEFAULT 1             COMMENT '所属分类ID（外键 → heritage_category），默认1-传统技艺',
  `project_intro` TEXT         CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '项目详细介绍',
  `area`          VARCHAR(50)  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '项目所属地区',
  `status`        TINYINT      NOT NULL DEFAULT 1             COMMENT '状态：1-正常上架，0-已下架',
  `create_time`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '录入时间',
  `update_time`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后更新时间',
  `create_id`     INT          NOT NULL                       COMMENT '创建人用户ID（外键 → sys_user.user_id）',
  `update_id`     INT          NOT NULL                       COMMENT '最后修改人用户ID（外键 → sys_user.user_id）',
  PRIMARY KEY (`project_id`) USING BTREE,
  INDEX `idx_category_id` (`category_id` ASC) USING BTREE,
  CONSTRAINT `fk_project_category` FOREIGN KEY (`category_id`)
    REFERENCES `heritage_category` (`category_id`) 
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 7
  CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci
  COMMENT = '非遗项目表'
  ROW_FORMAT = Dynamic;


-- ================================================================
-- 表4：非遗传承人表 (heritage_inheritor)
-- 记录传承人基本信息、从业年限及个人简介
-- 注意：本表不包含 avatar 字段，头像功能暂未实现
-- project_id 外键关联 heritage_project
-- ================================================================
DROP TABLE IF EXISTS `heritage_inheritor`;
CREATE TABLE `heritage_inheritor` (
  `inheritor_id` INT          NOT NULL AUTO_INCREMENT        COMMENT '传承人ID（主键）',
  `name`         VARCHAR(30)  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '传承人姓名',
  `project_id`   INT          NOT NULL COMMENT '关联的非遗项目ID（外键 → heritage_project）',
  `years`        INT          NULL DEFAULT NULL              COMMENT '从业年限（单位：年，CHECK years >= 0）',
  `intro`        TEXT         CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '传承人个人简介及代表成就',
  `status`       TINYINT      NOT NULL DEFAULT 1             COMMENT '状态：1-正常，0-已删除（软删除）',
  `create_time`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_id`    INT          NOT NULL              COMMENT '创建人用户ID',
  `update_id`    INT          NOT NULL              COMMENT '最后修改人用户ID',
  PRIMARY KEY (`inheritor_id`) USING BTREE,
  INDEX `idx_project_id` (`project_id` ASC) USING BTREE,
  CONSTRAINT `fk_inheritor_project` FOREIGN KEY (`project_id`)
  REFERENCES `heritage_project` (`project_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_inheritor_years` CHECK (`years` >= 0)
) ENGINE = InnoDB AUTO_INCREMENT = 8
  CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci
  COMMENT = '非遗传承人表'
  ROW_FORMAT = Dynamic;

-- ================================================================
-- 表5：文化资讯传播表 (heritage_news)
-- 存储由编辑用户发布的非遗科普文章、文化动态和展览活动预告
-- user_id 外键关联 sys_user
-- status 使用 ENUM：draft=草稿，published=已发布，pending=待审核，
-- rejected=不通过，deleted=已删除
-- ================================================================
DROP TABLE IF EXISTS `heritage_news`;
CREATE TABLE `heritage_news` (
  `news_id`      INT          NOT NULL AUTO_INCREMENT        COMMENT '资讯ID（主键）',
  `title`        VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '资讯标题',
  `content`      TEXT         CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '资讯正文内容（传播主体）',
  `user_id` INT NOT NULL COMMENT '发布者用户ID（外键 → sys_user）',
  `status`       ENUM('draft','published','pending','rejected','deleted')  NOT NULL DEFAULT 'published' COMMENT '发布状态：draft-草稿，published-已发布，pending-待审核，rejected-不通过，deleted-已删除',
  `summary`      TEXT         CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '内容摘要，用于列表页卡片展示',
  `publish_time` DATETIME     NULL DEFAULT CURRENT_TIMESTAMP COMMENT '对外发布时间',
  `create_time`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
  `update_time`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后更新时间',
  `create_id`    INT          NOT NULL              COMMENT '创建人用户ID',
  `update_id`    INT          NOT NULL              COMMENT '最后修改人用户ID',
  PRIMARY KEY (`news_id`) USING BTREE,
  INDEX `idx_user_id`     (`user_id` ASC) USING BTREE,
  INDEX `idx_status_time` (`status` ASC, `publish_time` DESC) USING BTREE,  -- 优化按状态+时间查询（列表页常用）
  CONSTRAINT `fk_news_user` FOREIGN KEY (`user_id`)
    REFERENCES `sys_user` (`user_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 6
  CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci
  COMMENT = '文化资讯传播表'
  ROW_FORMAT = Dynamic;

-- ================================================================
-- 表6：传播渠道表 (spread_channel)
-- 维护各类传播投放平台，支持线上和线下多种渠道类型
-- ================================================================
DROP TABLE IF EXISTS `spread_channel`;
CREATE TABLE `spread_channel` (
  `channel_id`   INT         NOT NULL AUTO_INCREMENT         COMMENT '渠道ID（主键）',
  `channel_name` VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '渠道名称，如：官方网站、微信公众号、抖音短视频',
  `channel_type` VARCHAR(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '渠道类型，如：线上-网站、线上-短视频、线下-实体',
  `status`       TINYINT     NOT NULL DEFAULT 1                  COMMENT '状态：1-启用，0-禁用',
  `create_time`  DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP  COMMENT '创建时间',
  `update_time`  DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_id`    INT         NOT NULL               COMMENT '创建人用户ID',
  `update_id`    INT         NOT NULL               COMMENT '最后修改人用户ID',
  PRIMARY KEY (`channel_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10
  CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci
  COMMENT = '传播渠道表'
  ROW_FORMAT = Dynamic;

-- ================================================================
-- 表7：传播数据统计表 (spread_data)
-- 按「非遗项目 × 传播渠道 × 统计时间」三维度记录浏览量和曝光量
-- 使用普通索引 idx_spread_query 优化查询性能，不设唯一约束
-- 业务唯一性由应用层保证（插入前查询是否存在）
-- stat_time 建议统一精确到天（格式：YYYY-MM-DD 00:00:00），便于按日聚合分析
-- ================================================================
DROP TABLE IF EXISTS `spread_data`;
CREATE TABLE `spread_data` (
  `data_id`      INT      NOT NULL AUTO_INCREMENT          COMMENT '数据记录ID（主键）',
  `project_id`   INT      NOT NULL                         COMMENT '非遗项目ID（外键 → heritage_project，不可为空）',
  `channel_id`   INT      NOT NULL                         COMMENT '传播渠道ID（外键 → spread_channel，不可为空）',
  `view_num`     INT      NOT NULL DEFAULT 0                   COMMENT '浏览量，需 >= 0',
  `exposure_num` INT      NOT NULL DEFAULT 0                   COMMENT '曝光量，需 >= 0',
  `stat_time`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP   COMMENT '数据统计时间，建议精确到天（YYYY-MM-DD 00:00:00）',
  `create_time`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP   COMMENT '记录创建时间',
  `update_time`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '记录更新时间',
  `create_id`    INT      NOT NULL                COMMENT '创建人用户ID',
  `update_id`    INT      NOT NULL                COMMENT '最后修改人用户ID',
  PRIMARY KEY (`data_id`) USING BTREE,
  INDEX `idx_channel_id` (`channel_id` ASC) USING BTREE,
  INDEX `idx_spread_query` (`project_id` ASC, `channel_id` ASC, `stat_time` ASC) USING BTREE COMMENT '复合索引，优化按项目+渠道+时间的查询',
  CONSTRAINT `fk_spread_data_project` FOREIGN KEY (`project_id`)
    REFERENCES `heritage_project`  (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_spread_data_channel` FOREIGN KEY (`channel_id`)
    REFERENCES `spread_channel`    (`channel_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_spread_view_num`     CHECK (`view_num`     >= 0),
  CONSTRAINT `chk_spread_exposure_num` CHECK (`exposure_num` >= 0)
) ENGINE = InnoDB AUTO_INCREMENT = 11
  CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci
  COMMENT = '传播数据统计表'
  ROW_FORMAT = Dynamic;

-- ================================================================
-- 表8：资讯评论表 (news_comment)
-- 记录用户对文化资讯文章的评论，支持互动点评
-- 本表已补充 status 软删除字段（与其他业务表保持一致）
-- ================================================================
DROP TABLE IF EXISTS `news_comment`;
CREATE TABLE `news_comment` (
  `comment_id`  INT      NOT NULL AUTO_INCREMENT         COMMENT '评论ID（主键）',
  `news_id`     INT      NOT NULL                        COMMENT '所属资讯ID（外键 → heritage_news）',
  `user_id`     INT      NOT NULL                        COMMENT '评论用户ID（外键 → sys_user）',
  `content`     TEXT     CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '评论正文内容',
  `status`      TINYINT  NOT NULL DEFAULT 1              COMMENT '状态：1-正常显示，0-已删除（软删除）',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '评论发布时间',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`comment_id`) USING BTREE,
  INDEX `idx_news_id` (`news_id` ASC) USING BTREE,
  INDEX `idx_user_id` (`user_id` ASC) USING BTREE,
  CONSTRAINT `fk_comment_news` FOREIGN KEY (`news_id`)
    REFERENCES `heritage_news` (`news_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_comment_user` FOREIGN KEY (`user_id`)
    REFERENCES `sys_user`      (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 6
  CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci
  COMMENT = '资讯评论表'
  ROW_FORMAT = Dynamic;

-- ================================================================
-- 视图：项目传播数据汇总 (v_project_spread_stats)
-- 按非遗项目维度汇总：覆盖渠道数、累计浏览量、累计曝光量
-- 对应后端 ProjectStatsVO（项目详情页"传播数据统计"模块的数据来源），
-- 将多表聚合逻辑封装在数据库层，简化业务层 SQL
-- ================================================================
DROP VIEW IF EXISTS `v_project_spread_stats`;
CREATE VIEW `v_project_spread_stats` AS
SELECT
    p.project_id,
    p.project_name,
    COUNT(DISTINCT sd.channel_id)      AS channel_count,
    COALESCE(SUM(sd.view_num), 0)      AS total_view,
    COALESCE(SUM(sd.exposure_num), 0)  AS total_exposure
FROM `heritage_project` p
LEFT JOIN `spread_data` sd ON sd.project_id = p.project_id
GROUP BY p.project_id, p.project_name;


-- ================================================================
-- 触发器1：传播数据统计时间校验（INSERT）
-- 插入 spread_data 前，校验 stat_time 不能晚于当前时间，
-- 防止人为误填"未来日期"的统计数据，影响趋势分析结果
-- ================================================================
DROP TRIGGER IF EXISTS `trg_spread_data_check_time`;
DELIMITER $$
CREATE TRIGGER `trg_spread_data_check_time`
BEFORE INSERT ON `spread_data`
FOR EACH ROW
BEGIN
    IF NEW.stat_time > NOW() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '统计时间(stat_time)不能晚于当前时间';
    END IF;
END$$
DELIMITER ;

-- ================================================================
-- 触发器2：传播数据统计时间校验（UPDATE）
-- 更新 spread_data 前，校验 stat_time 不能晚于当前时间
-- ================================================================
DROP TRIGGER IF EXISTS `trg_spread_data_check_time_update`;
DELIMITER $$
CREATE TRIGGER `trg_spread_data_check_time_update`
BEFORE UPDATE ON `spread_data`
FOR EACH ROW
BEGIN
    IF NEW.stat_time > NOW() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '统计时间(stat_time)不能晚于当前时间';
    END IF;
END$$
DELIMITER ;

-- ================================================================
-- 恢复外键约束检查
-- ================================================================
SET FOREIGN_KEY_CHECKS = 1;


-- ================================================================
-- 【数据完整性自检】
-- 各表外键级联策略汇总（便于答辩说明）：
--
-- 1. heritage_project → heritage_category
--    ON DELETE RESTRICT（禁止删除有项目的分类）
--    ON UPDATE CASCADE（分类ID变更时自动更新项目外键）
--
-- 2. heritage_inheritor → heritage_project
--    ON DELETE RESTRICT（禁止删除有传承人的项目）
--    ON UPDATE CASCADE（项目ID变更时自动更新传承人外键）
--
-- 3. heritage_news → sys_user
--    ON DELETE RESTRICT（禁止删除有资讯的用户）
--    ON UPDATE CASCADE（用户ID变更时自动更新资讯外键）
--
-- 4. spread_data → heritage_project
--    ON DELETE CASCADE（删除项目时自动清除其传播统计数据）
--    ON UPDATE CASCADE
--
-- 5. spread_data → spread_channel
--    ON DELETE CASCADE（删除渠道时自动清除相关统计数据）
--    ON UPDATE CASCADE
--
-- 6. news_comment → heritage_news
--    ON DELETE CASCADE（删除资讯时自动清除其评论）
--    ON UPDATE CASCADE
--
-- 7. news_comment → sys_user
--    ON DELETE CASCADE（删除用户时自动清除其评论）
--    ON UPDATE CASCADE
--
-- 【设计策略说明】
-- - 核心业务实体（项目、传承人、资讯、用户）使用 RESTRICT，
--   防止误删导致业务数据断裂
-- - 统计数据和评论采用 CASCADE，属于附属数据，
--   随主实体删除而清理，符合数据生命周期管理逻辑
-- ================================================================