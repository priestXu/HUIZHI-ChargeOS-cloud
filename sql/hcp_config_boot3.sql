-- ----------------------------
-- HUIZHI-ChargeOS Nacos 配置库（Spring Boot 3 / CHG-001 v1.1）
--
-- 由 sql/hcp_config.sql 生成，相对原脚本的差异：
--   1. 只保留 namespace = 'hcp' 的配置；删除 yu / hcp_lwh 测试命名空间
--   2. 删除 hcp-demo-dev.yml（demo 模块已移出构建）与孤儿配置 ruoyi-gateway.yml
--   3. spring.redis.*            -> spring.data.redis.*
--   4. feign.*                   -> spring.cloud.openfeign.*
--   5. spring.datasource.dynamic/druid -> 单数据源 HikariCP
--   6. 删除 seata.* 全部配置（模块已移除）
--   7. 网关白名单 /v2/api-docs   -> /v3/api-docs
--   8. 清除 his_config_info 历史与非 nacos 内置账号
--
-- 生成命令：python3 tools/gen_nacos_config_boot3.py
-- ----------------------------

/*
 Navicat Premium Data Transfer

 Source Server         : 127.0.0.1
 Source Server Type    : MySQL
 Source Server Version : 80042
 Source Host           : 127.0.0.1:3306
 Source Schema         : hcp_config

 Target Server Type    : MySQL
 Target Server Version : 80042
 File Encoding         : 65001

 Date: 25/05/2025 21:44:17
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for config_info
-- ----------------------------
DROP TABLE IF EXISTS `config_info`;
CREATE TABLE `config_info`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `data_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT 'data_id',
  `group_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `content` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT 'content',
  `md5` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT 'md5',
  `gmt_create` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `gmt_modified` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '修改时间',
  `src_user` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL COMMENT 'source user',
  `src_ip` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT 'source ip',
  `app_name` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `tenant_id` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT '' COMMENT '租户字段',
  `c_desc` varchar(256) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `c_use` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `effect` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `type` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `c_schema` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL,
  `encrypted_data_key` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT '秘钥',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_configinfo_datagrouptenant`(`data_id`, `group_id`, `tenant_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 109 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = 'config_info' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of config_info
-- ----------------------------

-- ----------------------------
-- Table structure for config_info_aggr
-- ----------------------------
DROP TABLE IF EXISTS `config_info_aggr`;
CREATE TABLE `config_info_aggr`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `data_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT 'data_id',
  `group_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT 'group_id',
  `datum_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT 'datum_id',
  `content` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT '内容',
  `gmt_modified` datetime(0) NOT NULL COMMENT '修改时间',
  `app_name` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `tenant_id` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT '' COMMENT '租户字段',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_configinfoaggr_datagrouptenantdatum`(`data_id`, `group_id`, `tenant_id`, `datum_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '增加租户字段' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of config_info_aggr
-- ----------------------------

-- ----------------------------
-- Table structure for config_info_beta
-- ----------------------------
DROP TABLE IF EXISTS `config_info_beta`;
CREATE TABLE `config_info_beta`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `data_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT 'data_id',
  `group_id` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT 'group_id',
  `app_name` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT 'app_name',
  `content` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT 'content',
  `beta_ips` varchar(1024) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT 'betaIps',
  `md5` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT 'md5',
  `gmt_create` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `gmt_modified` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '修改时间',
  `src_user` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL COMMENT 'source user',
  `src_ip` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT 'source ip',
  `tenant_id` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT '' COMMENT '租户字段',
  `encrypted_data_key` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT '秘钥',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_configinfobeta_datagrouptenant`(`data_id`, `group_id`, `tenant_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = 'config_info_beta' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of config_info_beta
-- ----------------------------

-- ----------------------------
-- Table structure for config_info_tag
-- ----------------------------
DROP TABLE IF EXISTS `config_info_tag`;
CREATE TABLE `config_info_tag`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `data_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT 'data_id',
  `group_id` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT 'group_id',
  `tenant_id` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT '' COMMENT 'tenant_id',
  `tag_id` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT 'tag_id',
  `app_name` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT 'app_name',
  `content` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT 'content',
  `md5` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT 'md5',
  `gmt_create` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `gmt_modified` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '修改时间',
  `src_user` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL COMMENT 'source user',
  `src_ip` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT 'source ip',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_configinfotag_datagrouptenanttag`(`data_id`, `group_id`, `tenant_id`, `tag_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = 'config_info_tag' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of config_info_tag
-- ----------------------------

-- ----------------------------
-- Table structure for config_tags_relation
-- ----------------------------
DROP TABLE IF EXISTS `config_tags_relation`;
CREATE TABLE `config_tags_relation`  (
  `id` bigint(0) NOT NULL COMMENT 'id',
  `tag_name` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT 'tag_name',
  `tag_type` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT 'tag_type',
  `data_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT 'data_id',
  `group_id` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT 'group_id',
  `tenant_id` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT '' COMMENT 'tenant_id',
  `nid` bigint(0) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`nid`) USING BTREE,
  UNIQUE INDEX `uk_configtagrelation_configidtag`(`id`, `tag_name`, `tag_type`) USING BTREE,
  INDEX `idx_tenant_id`(`tenant_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = 'config_tag_relation' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of config_tags_relation
-- ----------------------------

-- ----------------------------
-- Table structure for group_capacity
-- ----------------------------
DROP TABLE IF EXISTS `group_capacity`;
CREATE TABLE `group_capacity`  (
  `id` bigint(0) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `group_id` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT '' COMMENT 'Group ID，空字符表示整个集群',
  `quota` int(0) UNSIGNED NOT NULL DEFAULT 0 COMMENT '配额，0表示使用默认值',
  `usage` int(0) UNSIGNED NOT NULL DEFAULT 0 COMMENT '使用量',
  `max_size` int(0) UNSIGNED NOT NULL DEFAULT 0 COMMENT '单个配置大小上限，单位为字节，0表示使用默认值',
  `max_aggr_count` int(0) UNSIGNED NOT NULL DEFAULT 0 COMMENT '聚合子配置最大个数，，0表示使用默认值',
  `max_aggr_size` int(0) UNSIGNED NOT NULL DEFAULT 0 COMMENT '单个聚合数据的子配置大小上限，单位为字节，0表示使用默认值',
  `max_history_count` int(0) UNSIGNED NOT NULL DEFAULT 0 COMMENT '最大变更历史数量',
  `gmt_create` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `gmt_modified` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '修改时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_group_id`(`group_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '集群、各Group容量信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of group_capacity
-- ----------------------------

-- ----------------------------
-- Table structure for his_config_info
-- ----------------------------
DROP TABLE IF EXISTS `his_config_info`;
CREATE TABLE `his_config_info`  (
  `id` bigint(0) UNSIGNED NOT NULL,
  `nid` bigint(0) UNSIGNED NOT NULL AUTO_INCREMENT,
  `data_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `group_id` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `app_name` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT 'app_name',
  `content` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `md5` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `gmt_create` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0),
  `gmt_modified` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0),
  `src_user` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL,
  `src_ip` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `op_type` char(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `tenant_id` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT '' COMMENT '租户字段',
  `encrypted_data_key` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT '秘钥',
  PRIMARY KEY (`nid`) USING BTREE,
  INDEX `idx_gmt_create`(`gmt_create`) USING BTREE,
  INDEX `idx_gmt_modified`(`gmt_modified`) USING BTREE,
  INDEX `idx_did`(`data_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 113 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '多租户改造' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of his_config_info
-- ----------------------------

-- ----------------------------
-- Table structure for permissions
-- ----------------------------
DROP TABLE IF EXISTS `permissions`;
CREATE TABLE `permissions`  (
  `role` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `resource` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `action` varchar(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  UNIQUE INDEX `uk_role_permission`(`role`, `resource`, `action`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of permissions
-- ----------------------------

-- ----------------------------
-- Table structure for roles
-- ----------------------------
DROP TABLE IF EXISTS `roles`;
CREATE TABLE `roles`  (
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `role` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  UNIQUE INDEX `idx_user_role`(`username`, `role`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of roles
-- ----------------------------
INSERT INTO `roles` VALUES ('nacos', 'ROLE_ADMIN');

-- ----------------------------
-- Table structure for tenant_capacity
-- ----------------------------
DROP TABLE IF EXISTS `tenant_capacity`;
CREATE TABLE `tenant_capacity`  (
  `id` bigint(0) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `tenant_id` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT '' COMMENT 'Tenant ID',
  `quota` int(0) UNSIGNED NOT NULL DEFAULT 0 COMMENT '配额，0表示使用默认值',
  `usage` int(0) UNSIGNED NOT NULL DEFAULT 0 COMMENT '使用量',
  `max_size` int(0) UNSIGNED NOT NULL DEFAULT 0 COMMENT '单个配置大小上限，单位为字节，0表示使用默认值',
  `max_aggr_count` int(0) UNSIGNED NOT NULL DEFAULT 0 COMMENT '聚合子配置最大个数',
  `max_aggr_size` int(0) UNSIGNED NOT NULL DEFAULT 0 COMMENT '单个聚合数据的子配置大小上限，单位为字节，0表示使用默认值',
  `max_history_count` int(0) UNSIGNED NOT NULL DEFAULT 0 COMMENT '最大变更历史数量',
  `gmt_create` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `gmt_modified` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '修改时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_tenant_id`(`tenant_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '租户容量信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of tenant_capacity
-- ----------------------------

-- ----------------------------
-- Table structure for tenant_info
-- ----------------------------
DROP TABLE IF EXISTS `tenant_info`;
CREATE TABLE `tenant_info`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `kp` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT 'kp',
  `tenant_id` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT '' COMMENT 'tenant_id',
  `tenant_name` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT '' COMMENT 'tenant_name',
  `tenant_desc` varchar(256) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT 'tenant_desc',
  `create_source` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT 'create_source',
  `gmt_create` bigint(0) NOT NULL COMMENT '创建时间',
  `gmt_modified` bigint(0) NOT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_tenant_info_kptenantid`(`kp`, `tenant_id`) USING BTREE,
  INDEX `idx_tenant_id`(`tenant_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = 'tenant_info' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of tenant_info
-- ----------------------------

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users`  (
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `password` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `enabled` tinyint(1) NOT NULL,
  PRIMARY KEY (`username`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users` VALUES ('nacos', '$2a$10$FWfbhzGP9HsPYCYhG7gigetQyZqkzS8Uce8/mWzG.U9eWH1JphOAe', 1);

SET FOREIGN_KEY_CHECKS = 1;

-- Nacos 命名空间（仅保留 hcp）
INSERT INTO `tenant_info` VALUES (1, '1', 'hcp', 'hcp', 'hcp', 'nacos', 1723651120141, 1723651120141);

-- 配置内容（namespace = hcp）
INSERT INTO `config_info` VALUES (NULL, 'application-dev.yml', 'DEFAULT_GROUP', 'spring:\n  mail:\n    host: smtp.qq.com\n    username: 544023561884@qq.com\n    password: csgzzhyuoxtxbega\n    port: 465\n    default-encoding: UTF-8\n    properties:\n      mail:\n        smtp:\n          ssl:\n            enable: true\n          socketFactoryClass: javax.net.ssl.SSLSocketFactory\n        debug: true\n  cloud:\n    openfeign:\n      sentinel:\n        enabled: true\n      okhttp:\n        enabled: true\n      httpclient:\n        enabled: false\n      client:\n        config:\n          default:\n            connectTimeout: 10000\n            readTimeout: 10000\n          vctgo-job:\n            connectTimeout: 100000\n            readTimeout: 100000\n      compression:\n        request:\n          enabled: true\n        response:\n          enabled: true\nmanagement:\n  endpoints:\n    web:\n      exposure:\n        include: \'*\'\nlogging:\n  level:\n    org.springframework: info\n    com.hcp: debug\n  file_basePath: ./logs\n  file_prefix: ${spring.application.name}\nmybatis-plus:\n  mapper-locations: classpath*:mapper/**/*.xml\n  global-config:\n    banner: false\n    refresh-mapper: true\n    db-config:\n      id-type: auto\n      table-underline: true\n      logic-delete-value: 1\n      logic-not-delete-value: 0\n  configuration:\n    map-underscore-to-camel-case: true\n  type-handlers-package: com.hcp.common.mybatisplus\nhcp:\n  tenant:\n    ignore-tables:\n    - sys_config\n    - gen_table\n    - gen_table_column\n    - sys_dict_data\n    - sys_dict_type\n    - sys_menu\n    - sys_tenant\n    - sys_tenant_package\n    - sys_oper_log\n    - sys_logininfor\n    - branch_table\n    - global_table\n    - lock_table\n    - undo_log\n    - xxl_job_group\n    - xxl_job_info\n    - xxl_job_lock\n    - xxl_job_log\n    - xxl_job_log_report\n    - xxl_job_logglue\n    - xxl_job_registry\n    - xxl_job_user\n    - c_city\naliyun:\n  endpoint: cn-shanghai\n  accessKeyId: null\n  accessKeySecret: null\n  signName: null\n  templateCode: null\nfile:\n  domain: http://127.0.0.1:39300\n  path: /home/upload\n  prefix: /documents\n', 'ee2c874ff6a90037895534169913a7cb', now(), now(), 'nacos', '43.134.162.37', '', 'hcp', NULL, '', NULL, 'yaml', NULL, '');
INSERT INTO `config_info` VALUES (NULL, 'hcp-auth-dev.yml', 'DEFAULT_GROUP', 'spring:\n  data:\n    redis:\n      host: 127.0.0.1\n      port: 6379\n      database: 5\n      password: root\n      timeout: 1000\n      lettuce:\n        pool:\n          max-active: 10\n          max-wait: -1ms\n          max-idle: 8\n          min-idle: 0\n  cloud:\n    openfeign:\n      sentinel:\n        enabled: true\n      okhttp:\n        enabled: true\n      httpclient:\n        enabled: false\n      client:\n        config:\n          default:\n            connectTimeout: 10000\n            readTimeout: 10000\n            requestInterceptors: com.hcp.common.security.feign.FeignRequestInterceptor\n', '7c0f426a065c93ef0d06e9626a28c3bd', now(), now(), 'nacos', '49.118.86.41', '', 'hcp', NULL, '', NULL, 'yaml', NULL, '');
INSERT INTO `config_info` VALUES (NULL, 'hcp-file-dev.yml', 'DEFAULT_GROUP', 'spring:\n  datasource:\n    driver-class-name: com.mysql.cj.jdbc.Driver\n    url: jdbc:mysql://127.0.0.1:3306/hcp_cloud?useUnicode=true&characterEncoding=utf8&zeroDateTimeBehavior=convertToNull&useSSL=true&serverTimezone=GMT%2B8\n    username: root\n    password: root\n    hikari:\n      maximum-pool-size: 100\n      minimum-idle: 50\n      connection-timeout: 60000\n      connection-test-query: SELECT 1\n  data:\n    redis:\n      host: 127.0.0.1\n      port: 6379\n      database: 5\n      password: root\n      timeout: 1000\n      lettuce:\n        pool:\n          max-active: 10\n          max-wait: -1ms\n          max-idle: 8\n          min-idle: 0\n', '41e0bce33d9e537cba5c92c54fae28d2', now(), now(), 'nacos', '49.118.86.41', '', 'hcp', NULL, '', NULL, 'yaml', NULL, '');
INSERT INTO `config_info` VALUES (NULL, 'hcp-gateway-dev.yml', 'DEFAULT_GROUP', 'spring:\n  cloud:\n    gateway:\n      discovery:\n        locator:\n          lowerCaseServiceId: true\n          enabled: true\n      routes:\n      - id: hcp-auth\n        uri: lb://hcp-auth\n        predicates:\n        - Path=/auth/**\n        filters:\n        - CacheRequestFilter\n        - ValidateCodeFilter\n        - StripPrefix=1\n      - id: hcp-gen\n        uri: lb://hcp-gen\n        predicates:\n        - Path=/code/**\n        filters:\n        - StripPrefix=1\n      - id: hcp-system\n        uri: lb://hcp-system\n        predicates:\n        - Path=/system/**\n        filters:\n        - StripPrefix=1\n      - id: hcp-file\n        uri: lb://hcp-file\n        predicates:\n        - Path=/file/**\n        filters:\n        - StripPrefix=1\n      - id: hcp-monitor\n        uri: lb://hcp-monitor\n        predicates:\n        - Path=/monitor/**\n        filters:\n        - StripPrefix=1\n      - id: hcp-job\n        uri: lb://hcp-job\n        predicates:\n        - Path=/job/**\n        filters:\n        - StripPrefix=1\n      - id: hcp-operator\n        uri: lb://hcp-operator\n        predicates:\n        - Path=/operator/**\n        filters:\n        - StripPrefix=1\n      - id: hcp-mp\n        uri: lb://hcp-mp\n        predicates:\n        - Path=/mp/**\n        filters:\n        - StripPrefix=1\n      - id: hcp-simulator\n        uri: lb://hcp-simulator\n        predicates:\n        - Path=/simulator/**\n        filters:\n        - StripPrefix=1\n  data:\n    redis:\n      host: 127.0.0.1\n      port: 6379\n      database: 5\n      password: root\n      timeout: 1000\n      lettuce:\n        pool:\n          max-active: 10\n          max-wait: -1ms\n          max-idle: 8\n          min-idle: 0\nsecurity:\n  captcha:\n    enabled: true\n    type: math\n  xss:\n    enabled: true\n    excludeUrls:\n    - /system/notice\n  ignore:\n    whites:\n    - /auth/logout\n    - /auth/login\n    - /auth/register\n    - /*/v3/api-docs\n    - /csrf\n    - /job/api/callback\n    - /job/api/registry\n    - /job/api/registryRemove\n    - /file/documents/**\n    - /hcp-mp/**\n    - /hcp-operator/websocket/charge/**\n', '327598e21ce951d6fc8a53435f99158a', now(), now(), 'nacos', '127.0.0.1', '', 'hcp', NULL, '', NULL, 'yaml', NULL, '');
INSERT INTO `config_info` VALUES (NULL, 'hcp-gen-dev.yml', 'DEFAULT_GROUP', 'spring:\n  datasource:\n    driver-class-name: com.mysql.cj.jdbc.Driver\n    url: jdbc:mysql://127.0.0.1:3306/hcp_cloud?useUnicode=true&characterEncoding=utf8&zeroDateTimeBehavior=convertToNull&useSSL=true&serverTimezone=GMT%2B8\n    username: root\n    password: root\n  data:\n    redis:\n      host: 127.0.0.1\n      port: 6379\n      database: 5\n      password: root\n      timeout: 1000\n      lettuce:\n        pool:\n          max-active: 10\n          max-wait: -1ms\n          max-idle: 8\n          min-idle: 0\nswagger:\n  title: 代码生成接口文档\n  license: Powered By hcp\n  licenseUrl: https://hcp.cn\ngen:\n  author: hcp\n  packageName: com.hcp.system\n  autoRemovePre: false\n  tablePrefix: sys_\n', '3acc934d2bf8f4481a5abdfdd0bb009d', now(), now(), 'nacos', '49.118.86.41', '', 'hcp', NULL, '', NULL, 'yaml', NULL, '');
INSERT INTO `config_info` VALUES (NULL, 'hcp-job-dev.yml', 'DEFAULT_GROUP', 'spring:\n  datasource:\n    driver-class-name: com.mysql.cj.jdbc.Driver\n    url: jdbc:mysql://127.0.0.1:3306/hcp_cloud?useUnicode=true&characterEncoding=utf8&zeroDateTimeBehavior=convertToNull&useSSL=true&serverTimezone=GMT%2B8\n    username: root\n    password: root\n  mail:\n    host: www.163.com\n    port: 25\n    username: xxxxxx@163.com\n    from: xxxxxx@163.com\n    password: xxxxxx\n    properties:\n      mail:\n        smtp:\n          auth: false\n          starttls:\n            enable: false\n            required: false\n          socketFactory:\n            class: javax.net.ssl.SSLSocketFactory\n  data:\n    redis:\n      host: 127.0.0.1\n      port: 6379\n      database: 5\n      password: root\n      timeout: 1000\n      lettuce:\n        pool:\n          max-active: 10\n          max-wait: -1ms\n          max-idle: 8\n          min-idle: 0\nswagger:\n  title: 定时任务接口文档\n  license: Powered By hcp\n  licenseUrl: https://hcp.cn\nxxl:\n  job:\n    accessToken: default_token\n    i18n: zh_CN\n    logretentiondays: 30\n    triggerpool:\n      fast:\n        max: 200\n      slow:\n        max: 100\ncustom:\n  log:\n    list:\n    - scheduleJobQuery-error\n    - findFailJobLogIds-error\n    - findByAddressType-error\n', 'b6cdd55859675a9899eb5fa474d37b5e', now(), now(), 'nacos', '49.118.86.41', '', 'hcp', NULL, '', NULL, 'yaml', NULL, '');
INSERT INTO `config_info` VALUES (NULL, 'hcp-monitor-dev.yml', 'DEFAULT_GROUP', 'spring:\n  datasource:\n    driver-class-name: com.mysql.cj.jdbc.Driver\n    url: jdbc:mysql://127.0.0.1:3306/hcp_cloud?useUnicode=true&characterEncoding=utf8&zeroDateTimeBehavior=convertToNull&useSSL=true&serverTimezone=GMT%2B8\n    username: root\n    password: root\n  data:\n    redis:\n      host: 127.0.0.1\n      port: 6379\n      password: root\n      timeout: 1000\n      lettuce:\n        pool:\n          max-active: 20\n          max-wait: 500ms\n          max-idle: 10\n          min-idle: 2\nswagger:\n  title: 代码生成接口文档\n  license: Powered By hcp\n  licenseUrl: https://hcp.cn\n', '55c911db38fd7539b8e7e5a62af46471', now(), now(), 'nacos', '49.118.86.41', '', 'hcp', NULL, '', NULL, 'yaml', NULL, '');
INSERT INTO `config_info` VALUES (NULL, 'hcp-mp-dev.yml', 'DEFAULT_GROUP', 'spring:\n  datasource:\n    driver-class-name: com.mysql.cj.jdbc.Driver\n    url: jdbc:mysql://127.0.0.1:3306/hcp_cloud?useUnicode=true&characterEncoding=utf8&zeroDateTimeBehavior=convertToNull&useSSL=true&serverTimezone=GMT%2B8\n    username: root\n    password: root\n    hikari:\n      maximum-pool-size: 100\n      minimum-idle: 50\n      connection-timeout: 60000\n      connection-test-query: SELECT 1\n  data:\n    redis:\n      host: 127.0.0.1\n      port: 6379\n      database: 5\n      password: root\n      timeout: 1000\n      lettuce:\n        pool:\n          max-active: 10\n          max-wait: -1ms\n          max-idle: 8\n          min-idle: 0\n  cloud:\n    openfeign:\n      sentinel:\n        enabled: true\n      okhttp:\n        enabled: true\n      httpclient:\n        enabled: false\n      client:\n        config:\n          default:\n            connectTimeout: 10000\n            readTimeout: 10000\n            loggerLevel: full\n            requestInterceptors: com.hcp.common.security.feign.FeignRequestInterceptor\nswagger:\n  title: 系统模块接口文档\n  license: Powered By hcp\n  licenseUrl: https://hcp.vip\n', '1ac8f6ceae28d2a37b923d39cee4eb73', now(), now(), 'nacos', '49.118.86.41', '', 'hcp', NULL, '', NULL, 'yaml', NULL, '');
INSERT INTO `config_info` VALUES (NULL, 'hcp-operator-dev.yml', 'DEFAULT_GROUP', 'spring:\n  datasource:\n    driver-class-name: com.mysql.cj.jdbc.Driver\n    url: jdbc:mysql://127.0.0.1:3306/hcp_cloud?useUnicode=true&characterEncoding=utf8&zeroDateTimeBehavior=convertToNull&useSSL=true&serverTimezone=GMT%2B8\n    username: root\n    password: root\n    hikari:\n      maximum-pool-size: 100\n      minimum-idle: 50\n      connection-timeout: 60000\n      connection-test-query: SELECT 1\n  data:\n    redis:\n      host: 127.0.0.1\n      port: 6379\n      database: 5\n      password: root\n      timeout: 1000\n      lettuce:\n        pool:\n          max-active: 10\n          max-wait: -1ms\n          max-idle: 8\n          min-idle: 0\n  cloud:\n    openfeign:\n      sentinel:\n        enabled: true\n      okhttp:\n        enabled: true\n      httpclient:\n        enabled: false\n      client:\n        config:\n          default:\n            connectTimeout: 10000\n            readTimeout: 10000\n            loggerLevel: full\n            requestInterceptors: com.hcp.common.security.feign.FeignRequestInterceptor\nswagger:\n  title: 系统模块接口文档\n  license: Powered By hcp\n  licenseUrl: https://hcp.vip\n', '1ac8f6ceae28d2a37b923d39cee4eb73', now(), now(), 'nacos', '49.118.86.41', '', 'hcp', NULL, '', NULL, 'yaml', NULL, '');
INSERT INTO `config_info` VALUES (NULL, 'hcp-simulator-dev.yml', 'DEFAULT_GROUP', 'spring:\n  datasource:\n    driver-class-name: com.mysql.cj.jdbc.Driver\n    url: jdbc:mysql://127.0.0.1:3306/hcp_cloud?useUnicode=true&characterEncoding=utf8&zeroDateTimeBehavior=convertToNull&useSSL=true&serverTimezone=GMT%2B8\n    username: root\n    password: root\n    hikari:\n      maximum-pool-size: 100\n      minimum-idle: 50\n      connection-timeout: 60000\n      connection-test-query: SELECT 1\n  data:\n    redis:\n      host: 127.0.0.1\n      port: 6379\n      database: 5\n      password: root\n      timeout: 1000\n      lettuce:\n        pool:\n          max-active: 10\n          max-wait: -1ms\n          max-idle: 8\n          min-idle: 0\n  cloud:\n    openfeign:\n      sentinel:\n        enabled: true\n      okhttp:\n        enabled: true\n      httpclient:\n        enabled: false\n      client:\n        config:\n          default:\n            connectTimeout: 10000\n            readTimeout: 10000\n            loggerLevel: full\n            requestInterceptors: com.hcp.common.security.feign.FeignRequestInterceptor\nswagger:\n  title: 系统模块接口文档\n  license: Powered By hcp\n  licenseUrl: https://hcp.vip\nchargeServer:\n  address: http://wrt.fengzb.pp.ua:9250\n', 'f6a9fedb5eaf89795442b3374298f107', now(), now(), 'nacos', '49.118.86.41', '', 'hcp', NULL, '', NULL, 'yaml', NULL, '');
INSERT INTO `config_info` VALUES (NULL, 'hcp-system-dev.yml', 'DEFAULT_GROUP', 'spring:\n  datasource:\n    driver-class-name: com.mysql.cj.jdbc.Driver\n    url: jdbc:mysql://127.0.0.1:3306/hcp_cloud?useUnicode=true&characterEncoding=utf8&zeroDateTimeBehavior=convertToNull&useSSL=true&serverTimezone=GMT%2B8\n    username: root\n    password: root\n    hikari:\n      maximum-pool-size: 100\n      minimum-idle: 50\n      connection-timeout: 60000\n      connection-test-query: SELECT 1\n  data:\n    redis:\n      host: 127.0.0.1\n      port: 6379\n      database: 5\n      password: root\n      timeout: 1000\n      lettuce:\n        pool:\n          max-active: 10\n          max-wait: -1ms\n          max-idle: 8\n          min-idle: 0\n  cloud:\n    openfeign:\n      sentinel:\n        enabled: true\n      okhttp:\n        enabled: true\n      httpclient:\n        enabled: false\n      client:\n        config:\n          default:\n            connectTimeout: 10000\n            readTimeout: 10000\n            loggerLevel: full\n            requestInterceptors: com.hcp.common.security.feign.FeignRequestInterceptor\nswagger:\n  title: 系统模块接口文档\n  license: Powered By hcp\n  licenseUrl: https://hcp.vip\n', '1ac8f6ceae28d2a37b923d39cee4eb73', now(), now(), 'nacos', '49.118.86.41', '', 'hcp', NULL, '', NULL, 'yaml', NULL, '');
INSERT INTO `config_info` VALUES (NULL, 'sentinel-hcp-gateway', 'DEFAULT_GROUP', '[\n  {\n    \"resource\": \"hcp-auth\",\n    \"count\": 500,\n    \"grade\": 1,\n    \"limitApp\": \"default\",\n    \"strategy\": 0,\n    \"controlBehavior\": 0\n  },\n  {\n    \"resource\": \"hcp-system\",\n    \"count\": 1000,\n    \"grade\": 1,\n    \"limitApp\": \"default\",\n    \"strategy\": 0,\n    \"controlBehavior\": 0\n  },\n  {\n    \"resource\": \"hcp-gen\",\n    \"count\": 200,\n    \"grade\": 1,\n    \"limitApp\": \"default\",\n    \"strategy\": 0,\n    \"controlBehavior\": 0\n  }\n]', '48c7b91d9204c012905c5132a70d4e73', now(), now(), 'nacos', '49.118.86.41', '', 'hcp', NULL, '', NULL, 'json', NULL, '');
