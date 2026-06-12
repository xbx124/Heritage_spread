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
  h. 新增触发器 trg_spread_data_check_time
     插入 spread_data 前校验 stat_time 不能晚于当前时间，
     防止误填未来日期的统计数据
  i. 文件末尾新增"数据完整性自检"小结，汇总各表外键
     级联策略，便于答辩时整体说明设计意图

 ================================================================
  v1.2 修订内容：

  【v1.2 新增修正】
  a. spread_data.project_id / channel_id 改为 NOT NULL
     （统计记录必须归属具体项目与渠道，且为保证唯一索引
      uk_spread_data 生效，两列不可为 NULL —— MySQL 中 NULL
      不参与唯一性比较，为空会导致唯一约束失效）
  b. heritage_news.status 的 ENUM 增补 'pending'
     （后端 NewsPublishDTO 校验规则允许 published/draft/pending
      三种取值，原 ENUM 缺少 pending，会导致该状态写入失败）
  c. spread_channel.status 由 TINYINT(1) 统一改为 TINYINT
     （与 sys_user / heritage_project 等其他表的 status 字段
      写法保持一致，避免风格不统一）
  d. heritage_project ID=5 的 update_time 早于 create_time，
     已修正为合理的更新时间
  e. heritage_inheritor ID=5、7 的 avatar 由空字符串 '' 统一
     改为 NULL（与字段默认值及"无头像"语义保持一致）
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
  `status`      TINYINT      NULL DEFAULT 1                  COMMENT '账号状态：1-正常，0-禁用',
  `create_time` DATETIME     NULL DEFAULT CURRENT_TIMESTAMP  COMMENT '账号创建时间',
  `update_time` DATETIME     NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后更新时间',
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
INSERT INTO `sys_user` VALUES (1, 'admin',   '$2a$10$hashedpwd1', 'admin',  1, '2026-06-06 16:19:15', '2026-06-07 17:02:41');
INSERT INTO `sys_user` VALUES (2, 'editor1', '$2a$10$hashedpwd2', 'editor', 1, '2026-06-06 16:19:15', '2026-06-07 17:02:41');
INSERT INTO `sys_user` VALUES (3, 'user1',   '$2a$10$hashedpwd3', 'user',   1, '2026-06-06 16:19:15', '2026-06-07 17:02:41');
INSERT INTO `sys_user` VALUES (4, '张三',   '$2a$10$PLACEHOLDER_HASH_REPLACE_BEFORE_DEPLOY', 'admin', 1, '2026-06-07 11:55:16', '2026-06-07 17:02:41');
INSERT INTO `sys_user` VALUES (5, '张凉',   '$2a$10$VlCxDUEhUQCQzcg3ta4yhu/wSdI.I8/JReqOxPr1/yK9oEbdHFz/y', 'admin', 1, '2026-06-07 17:38:09', '2026-06-07 17:38:09');


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
  `create_time`   DATETIME     NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time`   DATETIME     NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_id`     INT          NULL DEFAULT NULL              COMMENT '创建人用户ID',
  `update_id`     INT          NULL DEFAULT NULL              COMMENT '最后修改人用户ID',
  PRIMARY KEY (`category_id`) USING BTREE,
  UNIQUE INDEX `uk_category_name` (`category_name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7    -- ⚡ 已修正：原值为5，但存在 ID=6 的记录，会导致下次插入主键冲突
  CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci
  COMMENT = '非遗分类表'
  ROW_FORMAT = Dynamic;

INSERT INTO `heritage_category` VALUES (1, '传统技艺', '包含陶瓷、刺绣、雕刻、织锦等手工技艺',         '2026-06-07 17:02:34', '2026-06-07 17:31:34', 1, 1);
INSERT INTO `heritage_category` VALUES (2, '传统戏剧', '包含京剧、越剧、昆曲、黄梅戏等戏剧形式',       '2026-06-07 17:02:34', '2026-06-07 17:31:35', 1, 1);
INSERT INTO `heritage_category` VALUES (3, '民间文学', '包含神话、传说、歌谣、民间故事等',             '2026-06-07 17:02:34', '2026-06-07 17:31:37', 1, 1);
INSERT INTO `heritage_category` VALUES (4, '传统音乐', '包含古琴、二胡、笛子等传统乐器及音乐形式',     '2026-06-07 17:02:34', '2026-06-07 17:31:39', 1, 1);
INSERT INTO `heritage_category` VALUES (6, '技艺',     '陶瓷和骨器',                                  '2026-06-07 17:02:34', '2026-06-07 17:40:33', NULL, 5);


-- ================================================================
-- 表3：非遗项目表 (heritage_project)
-- 系统核心传播素材主体，存储各类非遗项目基本信息
-- category_id 外键关联 heritage_category，DELETE SET NULL（分类删除后项目保留）
-- ================================================================
DROP TABLE IF EXISTS `heritage_project`;
CREATE TABLE `heritage_project` (
  `project_id`    INT          NOT NULL AUTO_INCREMENT        COMMENT '项目ID（主键）',
  `project_name`  VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '非遗项目名称',
  `category_id`   INT          NULL DEFAULT NULL              COMMENT '所属分类ID（外键 → heritage_category）',
  `project_intro` TEXT         CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '项目详细介绍',
  `area`          VARCHAR(50)  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '项目所属地区，填写具体地名，如：北京、江苏苏州',
  `status`        TINYINT      NOT NULL DEFAULT 1             COMMENT '状态：1-正常上架，0-已下架',
  `create_time`   DATETIME     NULL DEFAULT CURRENT_TIMESTAMP COMMENT '录入时间',
  `update_time`   DATETIME     NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后更新时间',
  -- ⚡ 已修正：原脚本此字段为 NULL DEFAULT NULL，缺少 ON UPDATE CURRENT_TIMESTAMP
  `create_id`     INT          NULL DEFAULT NULL              COMMENT '创建人用户ID',
  `update_id`     INT          NULL DEFAULT NULL              COMMENT '最后修改人用户ID',
  -- ⚡ 已修正：原字段类型为 bigint，统一改为 int（与 sys_user.user_id 保持一致）
  PRIMARY KEY (`project_id`) USING BTREE,
  INDEX `idx_category_id` (`category_id` ASC) USING BTREE,
  CONSTRAINT `fk_project_category` FOREIGN KEY (`category_id`)
    REFERENCES `heritage_category` (`category_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 7    -- ⚡ 已修正：原值为6，max(id)=6，下次插入需从7开始
  CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci
  COMMENT = '非遗项目表'
  ROW_FORMAT = Dynamic;

-- ⚡ 数据修正：ID=1 的 area 原值为 '传统技艺'（误填分类名），已改为正确地区名 '江西景德镇'
INSERT INTO `heritage_project` VALUES (1, '景德镇瓷器烧制技艺', 1, '是历史悠久的陶瓷烧制工艺，被誉为"瓷都"核心技艺。', '江西景德镇', 1, '2026-06-06 16:19:16', '2026-06-07 17:32:34', 1, NULL);
INSERT INTO `heritage_project` VALUES (2, '苏绣',               1, '以针法细腻、图案精美著称的传统刺绣技艺。',           '江苏苏州',   1, '2026-06-06 16:19:16', '2026-06-07 17:32:38', 1, 1);
INSERT INTO `heritage_project` VALUES (3, '京剧',               2, '中国国粹，融合唱念做打，表演体系完整。',             '北京',       1, '2026-06-06 16:19:16', '2026-06-03 17:32:40', 1, 1);
INSERT INTO `heritage_project` VALUES (4, '昆曲',               2, '百戏之祖，旋律婉转，被列入世界非遗名录。',           '江苏苏州',   1, '2026-06-06 16:19:16', '2026-06-15 17:32:43', 1, 1);
-- ⚡ v1.2修正：update_time原为'2026-05-26'，早于create_time('2026-06-06')，逻辑矛盾，已改为合理更新时间
INSERT INTO `heritage_project` VALUES (5, '牛郎织女传说',       3, '中国四大民间传说之一，传播范围广泛。',               '山东沂源',   1, '2026-06-06 16:19:16', '2026-06-08 17:32:46', 1, 1);
-- ⚡ v1.2修正：area原值为'苗疆'（非规范地名，按地区筛选/统计时无法匹配），改为'湖南湘西'
INSERT INTO `heritage_project` VALUES (6, '赶尸',               1, '历史悠久的苗疆技艺',                               '湖南湘西',   1, '2026-06-07 13:51:29', '2026-06-10 17:32:50', 1, 1);


-- ================================================================
-- 表4：非遗传承人表 (heritage_inheritor)
-- 记录传承人基本信息、从业年限及个人简介
-- project_id 外键关联 heritage_project，DELETE SET NULL（项目下架后传承人记录保留）
-- ================================================================
DROP TABLE IF EXISTS `heritage_inheritor`;
CREATE TABLE `heritage_inheritor` (
  `inheritor_id` INT          NOT NULL AUTO_INCREMENT        COMMENT '传承人ID（主键）',
  `name`         VARCHAR(30)  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '传承人姓名',
  `project_id`   INT          NULL DEFAULT NULL              COMMENT '关联的非遗项目ID（外键 → heritage_project）',
  `years`        INT          NULL DEFAULT NULL              COMMENT '从业年限（单位：年，CHECK years >= 0）',
  `intro`        TEXT         CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '传承人个人简介及代表成就',
  `avatar`       VARCHAR(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '头像图片路径或访问 URL',
  `status`       TINYINT      NOT NULL DEFAULT 1             COMMENT '状态：1-正常，0-已删除（软删除）',
  `create_time`  DATETIME     NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time`  DATETIME     NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_id`    INT          NULL DEFAULT NULL              COMMENT '创建人用户ID',
  `update_id`    INT          NULL DEFAULT NULL              COMMENT '最后修改人用户ID',
  -- ⚡ 已修正：原字段类型为 bigint，统一改为 int（与 sys_user.user_id 保持一致）
  PRIMARY KEY (`inheritor_id`) USING BTREE,
  INDEX `idx_project_id` (`project_id` ASC) USING BTREE,
  CONSTRAINT `fk_inheritor_project` FOREIGN KEY (`project_id`)
    REFERENCES `heritage_project` (`project_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `chk_inheritor_years` CHECK (`years` >= 0)
) ENGINE = InnoDB AUTO_INCREMENT = 8    -- ⚡ 已修正：原值为4，但最大 ID=7，已改为8
  CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci
  COMMENT = '非遗传承人表'
  ROW_FORMAT = Dynamic;

INSERT INTO `heritage_inheritor` VALUES (1, '王大师', 1, 35, '国家级非遗传承人，从事景德镇制瓷工艺三十余年。',     NULL, 1, '2026-06-07 17:02:03', '2026-06-07 17:31:48', 1, 1);
INSERT INTO `heritage_inheritor` VALUES (2, '李绣娘', 2, 28, '苏绣省级传承人，代表作《百鸟朝凤》多次获国家奖项。', NULL, 1, '2026-06-07 17:02:03', '2026-06-07 17:31:49', 1, 1);
INSERT INTO `heritage_inheritor` VALUES (3, '张梅',   3, 42, '京剧梅派表演艺术家，国家一级演员。',               NULL, 1, '2026-06-07 17:02:03', '2026-06-07 17:31:51', 1, 1);
-- ⚡ v1.2修正：以下两条 avatar 原为空字符串 ''，统一改为 NULL（与字段默认值及"无头像"语义一致）
INSERT INTO `heritage_inheritor` VALUES (5, '刘曼',   6, 56, '绳匠',                                             NULL, 1, '2026-06-07 17:02:03', '2026-06-07 17:31:54', 1, 1);
INSERT INTO `heritage_inheritor` VALUES (7, '刘曼怡', 1, 66, '木白凤雕',                                         NULL, 0, '2026-06-07 17:42:36', '2026-06-07 17:43:11', 5, 5);


-- ================================================================
-- 表5：文化资讯传播表 (heritage_news)
-- 存储由编辑用户发布的非遗科普文章、文化动态和展览活动预告
-- user_id 外键关联 sys_user，DELETE SET NULL（用户删除后文章保留）
-- status 使用 ENUM：draft=草稿，published=已发布，deleted=已删除
-- ================================================================
DROP TABLE IF EXISTS `heritage_news`;
CREATE TABLE `heritage_news` (
  `news_id`      INT          NOT NULL AUTO_INCREMENT        COMMENT '资讯ID（主键）',
  `title`        VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '资讯标题',
  `content`      TEXT         CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '资讯正文内容（传播主体）',
  `user_id`      INT          NULL DEFAULT NULL              COMMENT '发布者用户ID（外键 → sys_user）',
  `status`       ENUM('draft','published','pending','deleted')  NOT NULL DEFAULT 'published' COMMENT '发布状态：draft-草稿，published-已发布，pending-待审核，deleted-已删除',
  -- ⚡ 已修正(v1.1)：原字段类型为 varchar(20)，改为 ENUM，语义更严格，杜绝脏数据
  -- ⚡ v1.2修正：增补 'pending'（待审核），与后端 NewsPublishDTO 的
  --   @Pattern(regexp = "^(published|draft|pending)$") 校验规则对齐，
  --   否则前端提交 status=pending 时会因 ENUM 不支持而插入失败
  `summary`      TEXT         CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '内容摘要，用于列表页卡片展示',
  `publish_time` DATETIME     NULL DEFAULT CURRENT_TIMESTAMP COMMENT '对外发布时间（可手动指定）',
  `create_time`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
  `update_time`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后更新时间',
  `create_id`    INT          NULL DEFAULT NULL              COMMENT '创建人用户ID',
  `update_id`    INT          NULL DEFAULT NULL              COMMENT '最后修改人用户ID',
  PRIMARY KEY (`news_id`) USING BTREE,
  INDEX `idx_user_id`     (`user_id` ASC) USING BTREE,
  INDEX `idx_status_time` (`status` ASC, `publish_time` DESC) USING BTREE,  -- 优化按状态+时间查询（列表页常用）
  CONSTRAINT `fk_news_user` FOREIGN KEY (`user_id`)
    REFERENCES `sys_user` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 6    -- ⚡ 已修正：原值为4，但最大 ID=5，已改为6
  CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci
  COMMENT = '文化资讯传播表'
  ROW_FORMAT = Dynamic;

INSERT INTO `heritage_news` VALUES (1, '景德镇制瓷：千年火与土的对话', '景德镇制瓷技艺迄今已有1700余年历史……（正文内容）', 2, 'published', '景德镇制瓷技艺迄今已有1700余年历史……',                                                    '2026-06-06 16:19:16', '2026-06-07 17:00:48', '2026-06-07 17:32:26', 1, 1);
INSERT INTO `heritage_news` VALUES (2, '苏绣的前世今生',               '苏绣以其精湛技艺驰名中外，历代皇室御用……（正文内容）', 2, 'published', '苏绣以其精湛技艺驰名中外，历代皇室御用……',                                                    '2026-06-06 16:19:16', '2026-06-07 17:00:48', '2026-06-07 17:43:59', 1, 5);
INSERT INTO `heritage_news` VALUES (3, '2025年非遗文化节活动预告',     '定于2025年6月12日举办非遗文化展览……（正文内容）',     2, 'published', '定于2025年6月12日举办非遗文化展……',                                                        '2026-06-06 16:19:16', '2026-06-07 17:00:48', '2026-06-07 17:32:29', 1, 1);
INSERT INTO `heritage_news` VALUES (4, '新潮国年秀',                   '好样的',                                              4, 'published', '新潮国年秀：共赏非遗新气华',                                                               '2026-06-07 13:41:59', '2026-06-07 17:00:48', '2026-06-07 17:44:19', NULL, 5);
INSERT INTO `heritage_news` VALUES (5, '新潮国年秀：共赏非遗新气华',   '好玩~',                                               5, 'deleted',   '本次市集活动中，湘西苗绣、蜀锦织造等43项非遗技艺同台展演，更有10位国家级非遗代表性传承人现场展示匠心工艺。', '2026-06-07 17:43:48', '2026-06-07 17:43:48', '2026-06-07 17:44:14', 5, 5);


-- ================================================================
-- 表6：传播渠道表 (spread_channel)
-- 维护各类传播投放平台，支持线上和线下多种渠道类型
-- ================================================================
DROP TABLE IF EXISTS `spread_channel`;
CREATE TABLE `spread_channel` (
  `channel_id`   INT         NOT NULL AUTO_INCREMENT         COMMENT '渠道ID（主键）',
  `channel_name` VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '渠道名称，如：官方网站、微信公众号、抖音短视频',
  `channel_type` VARCHAR(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '渠道类型，如：线上-网站、线上-短视频、线下-实体',
  `status`       TINYINT     NULL DEFAULT 1                  COMMENT '状态：1-启用，0-禁用',
  -- ⚡ v1.2修正：原类型为 TINYINT(1)，统一改为 TINYINT，与其他表 status 字段写法保持一致
  `create_time`  DATETIME    NULL DEFAULT CURRENT_TIMESTAMP  COMMENT '创建时间',
  `update_time`  DATETIME    NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_id`    INT         NULL DEFAULT NULL               COMMENT '创建人用户ID',
  `update_id`    INT         NULL DEFAULT NULL               COMMENT '最后修改人用户ID',
  -- ⚡ 已修正：原字段类型为 bigint，统一改为 int（与 sys_user.user_id 保持一致）
  PRIMARY KEY (`channel_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10   -- ⚡ 已修正：原值为5，但最大 ID=9，已改为10
  CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci
  COMMENT = '传播渠道表'
  ROW_FORMAT = Dynamic;

INSERT INTO `spread_channel` VALUES (1, '官方网站',    '线上-网站',    1, '2026-06-07 17:02:22', '2026-06-07 17:33:14', 1, 1);
INSERT INTO `spread_channel` VALUES (2, '微信公众号',  '线上-社交媒体', 1, '2026-06-07 17:02:22', '2026-06-07 17:33:16', 1, 1);
INSERT INTO `spread_channel` VALUES (3, '抖音短视频',  '线上-短视频',  1, '2026-06-07 17:02:22', '2026-06-07 17:33:17', 1, 1);
INSERT INTO `spread_channel` VALUES (4, '线下文化展馆','线下-实体',    1, '2026-06-07 17:02:22', '2026-06-07 17:33:55', 1, 1);
INSERT INTO `spread_channel` VALUES (7, 'B站',         '线上-视频',    0, '2026-06-07 17:02:22', '2026-06-07 17:41:00', 1, 5);
-- ⚠️ 以下两条为测试过程中产生的重复脏数据，正式上线前建议 DELETE 清除
INSERT INTO `spread_channel` VALUES (8, 'B站1',        '线上-视频',    0, '2026-06-07 17:41:09', '2026-06-07 17:46:49', 5, 5);
INSERT INTO `spread_channel` VALUES (9, 'B站1886',     '线上-视频',    0, '2026-06-07 17:46:25', '2026-06-07 17:46:54', 5, 5);


-- ================================================================
-- 表7：传播数据统计表 (spread_data)
-- 按「非遗项目 × 传播渠道 × 统计时间」三维度记录浏览量和曝光量
-- 唯一约束 uk_spread_data 防止同一组合在同一时间点重复录入
-- stat_time 建议统一精确到天（格式：YYYY-MM-DD 00:00:00），便于按日聚合分析
-- ================================================================
DROP TABLE IF EXISTS `spread_data`;
CREATE TABLE `spread_data` (
  `data_id`      INT      NOT NULL AUTO_INCREMENT          COMMENT '数据记录ID（主键）',
  `project_id`   INT      NOT NULL                         COMMENT '非遗项目ID（外键 → heritage_project，不可为空）',
  `channel_id`   INT      NOT NULL                         COMMENT '传播渠道ID（外键 → spread_channel，不可为空）',
  -- ⚡ v1.2修正：原均为 NULL DEFAULT NULL。统计记录必须归属具体项目与渠道；
  --   另外唯一索引 uk_spread_data(project_id, channel_id, stat_time) 在
  --   MySQL 中若列允许为 NULL，NULL 值互不相等，唯一约束会失效，
  --   可能插入多条"重复"脏数据，故改为 NOT NULL。
  `view_num`     INT      NULL DEFAULT 0                   COMMENT '浏览量，需 >= 0',
  `exposure_num` INT      NULL DEFAULT 0                   COMMENT '曝光量，需 >= 0',
  `stat_time`    DATETIME NULL DEFAULT CURRENT_TIMESTAMP   COMMENT '数据统计时间，建议精确到天（YYYY-MM-DD 00:00:00）',
  `create_time`  DATETIME NULL DEFAULT CURRENT_TIMESTAMP   COMMENT '记录创建时间',
  `update_time`  DATETIME NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '记录更新时间',
  `create_id`    INT      NULL DEFAULT NULL                COMMENT '创建人用户ID',
  `update_id`    INT      NULL DEFAULT NULL                COMMENT '最后修改人用户ID',
  -- ⚡ 已修正：原字段类型为 bigint，统一改为 int（与 sys_user.user_id 保持一致）
  PRIMARY KEY (`data_id`) USING BTREE,
  INDEX `idx_channel_id` (`channel_id` ASC) USING BTREE,
  UNIQUE INDEX `uk_spread_data` (`project_id` ASC, `channel_id` ASC, `stat_time` ASC) USING BTREE,
  CONSTRAINT `fk_spread_data_project` FOREIGN KEY (`project_id`)
    REFERENCES `heritage_project`  (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_spread_data_channel` FOREIGN KEY (`channel_id`)
    REFERENCES `spread_channel`    (`channel_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_spread_view_num`     CHECK (`view_num`     >= 0),
  CONSTRAINT `chk_spread_exposure_num` CHECK (`exposure_num` >= 0)
) ENGINE = InnoDB AUTO_INCREMENT = 11   -- ⚡ 已修正：原值为6，但最大 ID=10，已改为11
  CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci
  COMMENT = '传播数据统计表'
  ROW_FORMAT = Dynamic;

INSERT INTO `spread_data` VALUES (2,  1, 2, 35200, 120000, '2025-05-01 00:00:00', '2026-06-07 17:02:11', '2026-06-07 17:33:31', 1, 1);
INSERT INTO `spread_data` VALUES (3,  2, 3, 28900,  95000, '2025-05-02 00:00:00', '2026-06-07 17:02:11', '2026-06-07 17:33:32', 1, 1);
INSERT INTO `spread_data` VALUES (4,  3, 2, 41000, 180000, '2025-05-03 00:00:00', '2026-06-07 17:02:11', '2026-06-07 17:33:33', 1, 1);
INSERT INTO `spread_data` VALUES (7,  1, 1, 12560,  48000, '2025-05-04 00:00:00', '2026-06-07 17:02:11', '2026-06-07 17:33:33', 1, 1);
INSERT INTO `spread_data` VALUES (10, 6, 1, 50000,  75560, '2025-05-10 00:00:00', '2026-06-07 17:02:11', '2026-06-07 17:40:14', 1, 5);


-- ================================================================
-- 表8：资讯评论表 (news_comment)
-- 记录用户对文化资讯文章的评论，支持互动点评
-- ⚡ 本次修正内容：
--   1. news_id / user_id 由 bigint 改为 int（与主表一致，确保 FK 可建立）
--   2. 补充 FK 约束：news_id → heritage_news，user_id → sys_user
--   3. 字符集统一为 utf8mb4_unicode_ci（原为 utf8mb4_0900_ai_ci）
--   4. 新增 status 软删除字段（与其他业务表保持一致）
-- ================================================================
DROP TABLE IF EXISTS `news_comment`;
CREATE TABLE `news_comment` (
  `comment_id`  INT      NOT NULL AUTO_INCREMENT         COMMENT '评论ID（主键）',
  `news_id`     INT      NOT NULL                        COMMENT '所属资讯ID（外键 → heritage_news）',
  `user_id`     INT      NOT NULL                        COMMENT '评论用户ID（外键 → sys_user）',
  `content`     TEXT     CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '评论正文内容',
  `status`      TINYINT  NOT NULL DEFAULT 1              COMMENT '状态：1-正常显示，0-已删除（软删除）',
  `create_time` DATETIME NULL DEFAULT CURRENT_TIMESTAMP COMMENT '评论发布时间',
  `update_time` DATETIME NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`comment_id`) USING BTREE,
  INDEX `idx_news_id` (`news_id` ASC) USING BTREE,
  INDEX `idx_user_id` (`user_id` ASC) USING BTREE,
  CONSTRAINT `fk_comment_news` FOREIGN KEY (`news_id`)
    REFERENCES `heritage_news` (`news_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_comment_user` FOREIGN KEY (`user_id`)
    REFERENCES `sys_user`      (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 6    -- ⚡ 已修正：原值为5，max(id)=5，已改为6
  CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci  -- ⚡ 已修正：原为 utf8mb4_0900_ai_ci
  COMMENT = '资讯评论表'
  ROW_FORMAT = Dynamic;

-- ⚡ 新增 status 字段，INSERT 语句相应补充默认值 1（正常）
INSERT INTO `news_comment` VALUES (1, 1, 1, '这篇文章写得太好了，受益匪浅！', 1, '2026-06-07 13:30:44', '2026-06-07 13:30:44');
INSERT INTO `news_comment` VALUES (2, 1, 2, '感谢分享，很有帮助的内容。',     1, '2026-06-07 13:30:44', '2026-06-07 13:30:44');
INSERT INTO `news_comment` VALUES (3, 2, 1, '非常实用的资讯，收藏了！',       1, '2026-06-07 13:30:44', '2026-06-07 13:30:44');
INSERT INTO `news_comment` VALUES (4, 2, 3, '期待更多这样的优质内容。',       1, '2026-06-07 13:30:44', '2026-06-07 13:30:44');
INSERT INTO `news_comment` VALUES (5, 1, 5, '好意思',                         1, '2026-06-07 17:43:28', '2026-06-07 17:43:28');


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
-- 触发器：传播数据统计时间校验 (trg_spread_data_check_time)
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
-- 恢复外键约束检查
-- ================================================================
SET FOREIGN_KEY_CHECKS = 1;


/*
 ================================================================
  数据完整性自检小结（v1.3 新增）
  —— 各表外键级联策略一览，便于答辩时整体说明设计意图 ——
 ================================================================

  外键 (子表.列 → 父表.列)                          | ON DELETE   | ON UPDATE | 设计说明
  --------------------------------------------------|-------------|-----------|----------------------------------
  heritage_project.category_id → heritage_category  | SET NULL    | CASCADE   | 分类删除后，项目保留但分类置空，
                                                      |             |           | 不因维护分类体系而误删核心素材
  heritage_inheritor.project_id → heritage_project   | SET NULL    | CASCADE   | 项目下架/删除后，传承人记录保留，
                                                      |             |           | 人物档案不随项目变动而丢失
  heritage_news.user_id → sys_user                   | SET NULL    | CASCADE   | 编辑账号删除后，已发布资讯保留，
                                                      |             |           | 仅作者信息置空，不影响内容传播
  spread_data.project_id → heritage_project          | CASCADE     | CASCADE   | 项目删除则其全部传播统计数据
                                                      |             |           | 一并删除，避免产生孤儿统计记录
  spread_data.channel_id → spread_channel            | CASCADE     | CASCADE   | 渠道删除则该渠道下的统计数据
                                                      |             |           | 一并删除，逻辑同上
  news_comment.news_id → heritage_news               | CASCADE     | CASCADE   | 资讯删除则其下评论一并删除，
                                                      |             |           | 避免出现指向不存在资讯的评论
  news_comment.user_id → sys_user                    | CASCADE     | CASCADE   | 用户删除则其发表的评论一并删除

  设计原则归纳：
    - "核心业务数据"（项目、传承人、资讯）采用 SET NULL，
      保证其不因关联记录的维护操作而被动丢失；
    - "从属/统计型数据"（传播数据、评论）采用 CASCADE，
      保证不会残留无意义的孤儿记录。
 ================================================================
*/

