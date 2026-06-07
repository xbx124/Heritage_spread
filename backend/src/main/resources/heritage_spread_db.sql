/*
 Navicat Premium Data Transfer

 Source Server         : root
 Source Server Type    : MySQL
 Source Server Version : 80023
 Source Host           : localhost:3306
 Source Schema         : heritage_spread_db

 Target Server Type    : MySQL
 Target Server Version : 80023
 File Encoding         : 65001

 Date: 07/06/2026 17:51:45
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for heritage_category
-- ----------------------------
DROP TABLE IF EXISTS `heritage_category`;
CREATE TABLE `heritage_category`  (
  `category_id` int NOT NULL AUTO_INCREMENT,
  `category_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `category_desc` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_id` int NULL DEFAULT NULL COMMENT '创建人ID',
  `update_id` int NULL DEFAULT NULL COMMENT '更新人ID',
  PRIMARY KEY (`category_id`) USING BTREE,
  UNIQUE INDEX `category_name`(`category_name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of heritage_category
-- ----------------------------
INSERT INTO `heritage_category` VALUES (1, '传统技艺', '包含陶瓷、刺绣、雕刻、织锦等手工技艺', '2026-06-07 17:02:34', '2026-06-07 17:31:34', 1, 1);
INSERT INTO `heritage_category` VALUES (2, '传统戏剧', '包含京剧、越剧、昆曲、黄梅戏等戏剧形式', '2026-06-07 17:02:34', '2026-06-07 17:31:35', 1, 1);
INSERT INTO `heritage_category` VALUES (3, '民间文学', '包含神话、传说、歌谣、民间故事等', '2026-06-07 17:02:34', '2026-06-07 17:31:37', 1, 1);
INSERT INTO `heritage_category` VALUES (4, '传统音乐', '包含古琴、二胡、笛子等传统乐器及音乐形式', '2026-06-07 17:02:34', '2026-06-07 17:31:39', 1, 1);
INSERT INTO `heritage_category` VALUES (6, '技艺', '陶瓷和骨器', '2026-06-07 17:02:34', '2026-06-07 17:40:33', NULL, 5);

-- ----------------------------
-- Table structure for heritage_inheritor
-- ----------------------------
DROP TABLE IF EXISTS `heritage_inheritor`;
CREATE TABLE `heritage_inheritor`  (
  `inheritor_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `project_id` int NULL DEFAULT NULL,
  `years` int NULL DEFAULT NULL,
  `intro` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `avatar` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1正常，0删除',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_id` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `update_id` bigint NULL DEFAULT NULL COMMENT '修改人ID',
  PRIMARY KEY (`inheritor_id`) USING BTREE,
  INDEX `project_id`(`project_id` ASC) USING BTREE,
  CONSTRAINT `heritage_inheritor_ibfk_1` FOREIGN KEY (`project_id`) REFERENCES `heritage_project` (`project_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `heritage_inheritor_chk_1` CHECK (`years` >= 0)
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of heritage_inheritor
-- ----------------------------
INSERT INTO `heritage_inheritor` VALUES (1, '王大师', 1, 35, '国家级非遗传承人，从事景德镇制瓷工艺三十余年。', NULL, 1, '2026-06-07 17:02:03', '2026-06-07 17:31:48', 1, 1);
INSERT INTO `heritage_inheritor` VALUES (2, '李绣娘', 2, 28, '苏绣省级传承人，代表作《百鸟朝凤》多次获国家奖项。', NULL, 1, '2026-06-07 17:02:03', '2026-06-07 17:31:49', 1, 1);
INSERT INTO `heritage_inheritor` VALUES (3, '张梅', 3, 42, '京剧梅派表演艺术家，国家一级演员。', NULL, 1, '2026-06-07 17:02:03', '2026-06-07 17:31:51', 1, 1);
INSERT INTO `heritage_inheritor` VALUES (5, '刘曼', 6, 56, '绳匠', '', 1, '2026-06-07 17:02:03', '2026-06-07 17:31:54', 1, 1);
INSERT INTO `heritage_inheritor` VALUES (7, '刘曼怡', 1, 66, '木白凤雕', '', 0, '2026-06-07 17:42:36', '2026-06-07 17:43:11', 5, 5);

-- ----------------------------
-- Table structure for heritage_news
-- ----------------------------
DROP TABLE IF EXISTS `heritage_news`;
CREATE TABLE `heritage_news`  (
  `news_id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` int NULL DEFAULT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'published',
  `summary` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `publish_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_id` int NULL DEFAULT NULL COMMENT '创建人ID',
  `update_id` int NULL DEFAULT NULL COMMENT '更新人ID',
  PRIMARY KEY (`news_id`) USING BTREE,
  INDEX `user_id`(`user_id` ASC) USING BTREE,
  CONSTRAINT `heritage_news_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of heritage_news
-- ----------------------------
INSERT INTO `heritage_news` VALUES (1, '景德镇制瓷：千年火与土的对话', '景德镇制瓷技艺迄今已有1700余年历史……（正文内容）', 2, 'published', '景德镇制瓷技艺迄今已有1700余年历史……', '2026-06-06 16:19:16', '2026-06-07 17:00:48', '2026-06-07 17:32:26', 1, 1);
INSERT INTO `heritage_news` VALUES (2, '苏绣的前世今生', '苏绣以其精湛技艺驰名中外，历代皇室御用……（正文内容）', 2, 'published', '苏绣以其精湛技艺驰名中外，历代皇室御用……', '2026-06-06 16:19:16', '2026-06-07 17:00:48', '2026-06-07 17:43:59', 1, 5);
INSERT INTO `heritage_news` VALUES (3, '2025年非遗文化节活动预告', '定于2025年6月12日举办非遗文化展览……（正文内容）', 2, 'published', '定于2025年6月12日举办非遗文化展……', '2026-06-06 16:19:16', '2026-06-07 17:00:48', '2026-06-07 17:32:29', 1, 1);
INSERT INTO `heritage_news` VALUES (4, '新潮国年秀', '好样的', 4, 'published', '新潮国年秀：共赏非遗新气华', '2026-06-07 13:41:59', '2026-06-07 17:00:48', '2026-06-07 17:44:19', NULL, 5);
INSERT INTO `heritage_news` VALUES (5, '新潮国年秀：共赏非遗新气华', '好玩~', 5, 'deleted', '本次市集活动中，湘西苗绣、蜀锦织造等43项非遗技艺同台展演，更有10位国家级非遗代表性传承人现场展示马尾绣、花丝镶嵌制作等匠心工艺。 游客还可参与篆刻、扎染、泥塑等体验项目，近距离感受传统技艺的精湛与厚重。 舌尖上的非遗同样动人。 “京城非遗美食荟”同步开席，潮州牛肉丸弹牙爽脆、泉州面线糊细如发丝、淮安平桥豆腐切片薄如刀锋，传承人现场展示捶打、拼配技艺，让游客在味蕾间读懂非遗之美。', '2026-06-07 17:43:48', '2026-06-07 17:43:48', '2026-06-07 17:44:14', 5, 5);

-- ----------------------------
-- Table structure for heritage_project
-- ----------------------------
DROP TABLE IF EXISTS `heritage_project`;
CREATE TABLE `heritage_project`  (
  `project_id` int NOT NULL AUTO_INCREMENT,
  `project_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `category_id` int NULL DEFAULT NULL,
  `project_intro` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `area` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1正常 0下架',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `create_id` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `update_id` bigint NULL DEFAULT NULL COMMENT '修改人ID',
  PRIMARY KEY (`project_id`) USING BTREE,
  INDEX `category_id`(`category_id` ASC) USING BTREE,
  CONSTRAINT `heritage_project_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `heritage_category` (`category_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of heritage_project
-- ----------------------------
INSERT INTO `heritage_project` VALUES (1, '景德镇瓷器烧制技艺', 1, '是历史悠久的陶瓷烧制工艺，被誉为\"瓷都\"核心技艺。', '传统技艺', 1, '2026-06-06 16:19:16', '2026-06-07 17:32:34', 1, NULL);
INSERT INTO `heritage_project` VALUES (2, '苏绣', 1, '以针法细腻、图案精美著称的传统刺绣技艺。', '江苏苏州', 1, '2026-06-06 16:19:16', '2026-06-07 17:32:38', 1, 1);
INSERT INTO `heritage_project` VALUES (3, '京剧', 2, '中国国粹，融合唱念做打，表演体系完整。', '北京', 1, '2026-06-06 16:19:16', '2026-06-03 17:32:40', 1, 1);
INSERT INTO `heritage_project` VALUES (4, '昆曲', 2, '百戏之祖，旋律婉转，被列入世界非遗名录。', '江苏苏州', 1, '2026-06-06 16:19:16', '2026-06-15 17:32:43', 1, 1);
INSERT INTO `heritage_project` VALUES (5, '牛郎织女传说', 3, '中国四大民间传说之一，传播范围广泛。', '山东沂源', 1, '2026-06-06 16:19:16', '2026-05-26 17:32:46', 1, 1);
INSERT INTO `heritage_project` VALUES (6, '赶尸', 1, '历史悠久的苗疆技艺', '苗疆', 1, '2026-06-07 13:51:29', '2026-06-10 17:32:50', 1, 1);

-- ----------------------------
-- Table structure for news_comment
-- ----------------------------
DROP TABLE IF EXISTS `news_comment`;
CREATE TABLE `news_comment`  (
  `comment_id` bigint NOT NULL AUTO_INCREMENT COMMENT '评论ID',
  `news_id` bigint NOT NULL COMMENT '新闻ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '评论内容',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`comment_id`) USING BTREE,
  INDEX `idx_news_id`(`news_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '新闻评论表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of news_comment
-- ----------------------------
INSERT INTO `news_comment` VALUES (1, 1, 1, '这篇文章写得太好了，受益匪浅！', '2026-06-07 13:30:44', '2026-06-07 13:30:44');
INSERT INTO `news_comment` VALUES (2, 1, 2, '感谢分享，很有帮助的内容。', '2026-06-07 13:30:44', '2026-06-07 13:30:44');
INSERT INTO `news_comment` VALUES (3, 2, 1, '非常实用的资讯，收藏了！', '2026-06-07 13:30:44', '2026-06-07 13:30:44');
INSERT INTO `news_comment` VALUES (4, 2, 3, '期待更多这样的优质内容。', '2026-06-07 13:30:44', '2026-06-07 13:30:44');
INSERT INTO `news_comment` VALUES (5, 1, 5, '好意思', '2026-06-07 17:43:28', '2026-06-07 17:43:28');

-- ----------------------------
-- Table structure for spread_channel
-- ----------------------------
DROP TABLE IF EXISTS `spread_channel`;
CREATE TABLE `spread_channel`  (
  `channel_id` int NOT NULL AUTO_INCREMENT,
  `channel_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `channel_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` tinyint(1) NULL DEFAULT 1 COMMENT '状态：1-启用，0-禁用',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_id` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `update_id` bigint NULL DEFAULT NULL COMMENT '修改人ID',
  PRIMARY KEY (`channel_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of spread_channel
-- ----------------------------
INSERT INTO `spread_channel` VALUES (1, '官方网站', '线上-网站', 1, '2026-06-07 17:02:22', '2026-06-07 17:33:14', 1, 1);
INSERT INTO `spread_channel` VALUES (2, '微信公众号', '线上-社交媒体', 1, '2026-06-07 17:02:22', '2026-06-07 17:33:16', 1, 1);
INSERT INTO `spread_channel` VALUES (3, '抖音短视频', '线上-短视频', 1, '2026-06-07 17:02:22', '2026-06-07 17:33:17', 1, 1);
INSERT INTO `spread_channel` VALUES (4, '线下文化展馆', '线下-实体', 1, '2026-06-07 17:02:22', '2026-06-07 17:33:55', 1, 1);
INSERT INTO `spread_channel` VALUES (7, 'B站', '线上-视频', 0, '2026-06-07 17:02:22', '2026-06-07 17:41:00', 1, 5);
INSERT INTO `spread_channel` VALUES (8, 'B站1', '线上-视频', 0, '2026-06-07 17:41:09', '2026-06-07 17:46:49', 5, 5);
INSERT INTO `spread_channel` VALUES (9, 'B站1886', '线上-视频', 0, '2026-06-07 17:46:25', '2026-06-07 17:46:54', 5, 5);

-- ----------------------------
-- Table structure for spread_data
-- ----------------------------
DROP TABLE IF EXISTS `spread_data`;
CREATE TABLE `spread_data`  (
  `data_id` int NOT NULL AUTO_INCREMENT,
  `project_id` int NULL DEFAULT NULL,
  `channel_id` int NULL DEFAULT NULL,
  `view_num` int NULL DEFAULT 0,
  `exposure_num` int NULL DEFAULT 0,
  `stat_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_id` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `update_id` bigint NULL DEFAULT NULL COMMENT '修改人ID',
  PRIMARY KEY (`data_id`) USING BTREE,
  INDEX `channel_id`(`channel_id` ASC) USING BTREE,
  UNIQUE INDEX `uk_spread_data_project_channel_stat_time`(`project_id` ASC, `channel_id` ASC, `stat_time` ASC) USING BTREE,
  CONSTRAINT `spread_data_ibfk_1` FOREIGN KEY (`project_id`) REFERENCES `heritage_project` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `spread_data_ibfk_2` FOREIGN KEY (`channel_id`) REFERENCES `spread_channel` (`channel_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `spread_data_chk_1` CHECK (`view_num` >= 0),
  CONSTRAINT `spread_data_chk_2` CHECK (`exposure_num` >= 0)
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of spread_data
-- ----------------------------
INSERT INTO `spread_data` VALUES (2, 1, 2, 35200, 120000, '2025-05-01 00:00:00', '2026-06-07 17:02:11', '2026-06-07 17:33:31', 1, 1);
INSERT INTO `spread_data` VALUES (3, 2, 3, 28900, 95000, '2025-05-02 00:00:00', '2026-06-07 17:02:11', '2026-06-07 17:33:32', 1, 1);
INSERT INTO `spread_data` VALUES (4, 3, 2, 41000, 180000, '2025-05-03 00:00:00', '2026-06-07 17:02:11', '2026-06-07 17:33:33', 1, 1);
INSERT INTO `spread_data` VALUES (7, 1, 1, 12560, 48000, '2025-05-04 00:00:00', '2026-06-07 17:02:11', '2026-06-07 17:33:33', 1, 1);
INSERT INTO `spread_data` VALUES (10, 6, 1, 50000, 75560, '2025-05-10 00:00:00', '2026-06-07 17:02:11', '2026-06-07 17:40:14', 1, 5);

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user`  (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'user',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `status` tinyint NULL DEFAULT 1 COMMENT '账号状态：1正常，0禁用',
  PRIMARY KEY (`user_id`) USING BTREE,
  UNIQUE INDEX `username`(`username` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO `sys_user` VALUES (1, 'admin', '$2a$10$hashedpwd1', 'admin', '2026-06-06 16:19:15', '2026-06-07 17:02:41', 1);
INSERT INTO `sys_user` VALUES (2, 'editor1', '$2a$10$hashedpwd2', 'editor', '2026-06-06 16:19:15', '2026-06-07 17:02:41', 1);
INSERT INTO `sys_user` VALUES (3, 'user1', '$2a$10$hashedpwd3', 'user', '2026-06-06 16:19:15', '2026-06-07 17:02:41', 1);
INSERT INTO `sys_user` VALUES (4, '张三', 'zhangsan', 'admin', '2026-06-07 11:55:16', '2026-06-07 17:02:41', 1);
INSERT INTO `sys_user` VALUES (5, '张凉', '$2a$10$VlCxDUEhUQCQzcg3ta4yhu/wSdI.I8/JReqOxPr1/yK9oEbdHFz/y', 'admin', '2026-06-07 17:38:09', '2026-06-07 17:38:09', 1);

SET FOREIGN_KEY_CHECKS = 1;
