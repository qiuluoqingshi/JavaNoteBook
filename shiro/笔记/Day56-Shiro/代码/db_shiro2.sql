/*
 Navicat Premium Data Transfer

 Source Server         : localhost_3306
 Source Server Type    : MySQL
 Source Server Version : 50626
 Source Host           : localhost:3306
 Source Schema         : db_shiro2

 Target Server Type    : MySQL
 Target Server Version : 50626
 File Encoding         : 65001

 Date: 26/04/2020 17:03:02
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for tb_permissions
-- ----------------------------
DROP TABLE IF EXISTS `tb_permissions`;
CREATE TABLE `tb_permissions`  (
  `permission_id` int(11) NOT NULL AUTO_INCREMENT,
  `permission_code` varchar(60) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `permission_name` varchar(60) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`permission_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of tb_permissions
-- ----------------------------
INSERT INTO `tb_permissions` VALUES (1, 'sys:c:save', '入库');
INSERT INTO `tb_permissions` VALUES (2, 'sys:c:delete', '出库');
INSERT INTO `tb_permissions` VALUES (3, 'sys:c:update', '修改');
INSERT INTO `tb_permissions` VALUES (4, 'sys:c:find', '查询');
INSERT INTO `tb_permissions` VALUES (5, 'sys:x:save', '新增订单');
INSERT INTO `tb_permissions` VALUES (6, 'sys:x:delete', '删除订单');
INSERT INTO `tb_permissions` VALUES (7, 'sys:x:update', '修改订单');
INSERT INTO `tb_permissions` VALUES (8, 'sys:x:find', '查询订单');
INSERT INTO `tb_permissions` VALUES (9, 'sys:k:save', '新增客户');
INSERT INTO `tb_permissions` VALUES (10, 'sys:k:delete', '删除客户');
INSERT INTO `tb_permissions` VALUES (11, 'sys:k:update', '修改客户');
INSERT INTO `tb_permissions` VALUES (12, 'sys:k:find', '查询客户');

-- ----------------------------
-- Table structure for tb_roles
-- ----------------------------
DROP TABLE IF EXISTS `tb_roles`;
CREATE TABLE `tb_roles`  (
  `role_id` int(11) NOT NULL AUTO_INCREMENT,
  `role_name` varchar(60) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  PRIMARY KEY (`role_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of tb_roles
-- ----------------------------
INSERT INTO `tb_roles` VALUES (1, 'admin');
INSERT INTO `tb_roles` VALUES (2, 'cmanager');
INSERT INTO `tb_roles` VALUES (3, 'xmanager');
INSERT INTO `tb_roles` VALUES (4, 'kmanager');
INSERT INTO `tb_roles` VALUES (5, 'zmanager');

-- ----------------------------
-- Table structure for tb_rps
-- ----------------------------
DROP TABLE IF EXISTS `tb_rps`;
CREATE TABLE `tb_rps`  (
  `rid` int(11) NOT NULL,
  `pid` int(11) NOT NULL
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of tb_rps
-- ----------------------------
INSERT INTO `tb_rps` VALUES (2, 1);
INSERT INTO `tb_rps` VALUES (2, 2);
INSERT INTO `tb_rps` VALUES (2, 3);
INSERT INTO `tb_rps` VALUES (2, 4);
INSERT INTO `tb_rps` VALUES (3, 5);
INSERT INTO `tb_rps` VALUES (3, 6);
INSERT INTO `tb_rps` VALUES (3, 7);
INSERT INTO `tb_rps` VALUES (3, 8);
INSERT INTO `tb_rps` VALUES (3, 9);
INSERT INTO `tb_rps` VALUES (3, 10);
INSERT INTO `tb_rps` VALUES (3, 11);
INSERT INTO `tb_rps` VALUES (3, 12);
INSERT INTO `tb_rps` VALUES (3, 4);
INSERT INTO `tb_rps` VALUES (4, 11);
INSERT INTO `tb_rps` VALUES (4, 12);
INSERT INTO `tb_rps` VALUES (5, 4);
INSERT INTO `tb_rps` VALUES (5, 8);
INSERT INTO `tb_rps` VALUES (5, 12);

-- ----------------------------
-- Table structure for tb_urs
-- ----------------------------
DROP TABLE IF EXISTS `tb_urs`;
CREATE TABLE `tb_urs`  (
  `uid` int(11) NOT NULL,
  `rid` int(11) NOT NULL
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of tb_urs
-- ----------------------------
INSERT INTO `tb_urs` VALUES (1, 1);
INSERT INTO `tb_urs` VALUES (2, 2);
INSERT INTO `tb_urs` VALUES (3, 3);
INSERT INTO `tb_urs` VALUES (4, 4);
INSERT INTO `tb_urs` VALUES (5, 5);
INSERT INTO `tb_urs` VALUES (6, 4);
INSERT INTO `tb_urs` VALUES (6, 5);
INSERT INTO `tb_urs` VALUES (1, 2);
INSERT INTO `tb_urs` VALUES (1, 3);

-- ----------------------------
-- Table structure for tb_users
-- ----------------------------
DROP TABLE IF EXISTS `tb_users`;
CREATE TABLE `tb_users`  (
  `user_id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(60) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `password` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `password_salt` varchar(60) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`user_id`) USING BTREE,
  UNIQUE INDEX `username`(`username`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of tb_users
-- ----------------------------
INSERT INTO `tb_users` VALUES (1, 'zhangsan', '123456', NULL);
INSERT INTO `tb_users` VALUES (2, 'lisi', '123456', NULL);
INSERT INTO `tb_users` VALUES (3, 'wangwu', '123456', NULL);
INSERT INTO `tb_users` VALUES (4, 'zhaoliu', '123456', NULL);
INSERT INTO `tb_users` VALUES (5, 'chenqi', '123456', NULL);
INSERT INTO `tb_users` VALUES (6, 'ergou', '123456', NULL);

SET FOREIGN_KEY_CHECKS = 1;
