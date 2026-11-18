#!/usr/bin/env python3
"""
从 sql/hcp_config.sql 生成 Boot 3 可用的 Nacos 配置库脚本 sql/hcp_config_boot3.sql。

CHG-001 T04-8 / D7：只保留 namespace=hcp 的配置，删除 hcp-demo 与孤儿配置，
并把内容迁移到 Spring Boot 3 的配置键。

用法： python3 tools/gen_nacos_config_boot3.py
"""
import hashlib
import re
import sys
from pathlib import Path

import yaml

BASE = Path(__file__).resolve().parent.parent
SRC = BASE / "sql" / "hcp_config.sql"
DST = BASE / "sql" / "hcp_config_boot3.sql"

# 保留的 dataId（namespace=hcp）；demo 已移出构建，ruoyi-gateway 为孤儿配置
DROP_DATA_IDS = {"hcp-demo-dev.yml", "ruoyi-gateway.yml"}
KEEP_NS = "hcp"


def split_sql_tuple(body):
    parts, buf, in_str, i = [], "", False, 0
    while i < len(body):
        c = body[i]
        if in_str:
            if c == "\\":
                buf += body[i : i + 2]
                i += 2
                continue
            if c == "'":
                in_str = False
            buf += c
        elif c == "'":
            in_str = True
            buf += c
        elif c == ",":
            parts.append(buf.strip())
            buf = ""
        else:
            buf += c
        i += 1
    if buf.strip():
        parts.append(buf.strip())
    return parts


def unescape_sql(text: str) -> str:
    out, i = [], 0
    while i < len(text):
        if text[i] == "\\" and i + 1 < len(text):
            nxt = text[i + 1]
            out.append({"n": "\n", "r": "\r", "t": "\t", "0": "\0",
                        "'": "'", '"': '"', "\\": "\\"}.get(nxt, nxt))
            i += 2
        else:
            out.append(text[i])
            i += 1
    return "".join(out)


def escape_sql(text: str) -> str:
    return (text.replace("\\", "\\\\").replace("'", "\\'")
                .replace("\n", "\\n").replace("\r", "\\r").replace('"', '\\"'))


def migrate(cfg: dict) -> dict:
    """把 Boot 2.7 的配置结构迁移到 Boot 3。"""
    cfg.pop("seata", None)                       # D5：seata 已彻底移除
    spring = cfg.get("spring") or {}

    # spring.redis -> spring.data.redis
    if "redis" in spring:
        data = spring.setdefault("data", {})
        redis = spring.pop("redis")
        # 项目未引入 Jedis，Boot 3 默认客户端为 Lettuce，池参数需挂到 lettuce 下否则静默失效
        if isinstance(redis, dict) and "jedis" in redis:
            redis.setdefault("lettuce", redis.pop("jedis"))
        data["redis"] = redis

    # 数据源归一：druid/dynamic -> 单数据源 HikariCP
    ds = spring.get("datasource")
    if isinstance(ds, dict):
        new_ds = {}
        for key in ("driver-class-name", "url", "username", "password"):
            if key in ds:
                new_ds[key] = ds[key]
        dyn = ds.get("dynamic") or {}
        master = (dyn.get("datasource") or {}).get("master") or {}
        for key in ("driver-class-name", "url", "username", "password"):
            if key in master:
                new_ds[key] = master[key]
        pool = dyn.get("druid") or {}
        hikari = {}
        if "maxActive" in pool:
            hikari["maximum-pool-size"] = pool["maxActive"]
        if "min-idle" in pool:
            hikari["minimum-idle"] = pool["min-idle"]
        if "maxWait" in pool:
            hikari["connection-timeout"] = pool["maxWait"]
        if "validationQuery" in pool:
            hikari["connection-test-query"] = "SELECT 1"
        if hikari:
            new_ds["hikari"] = hikari
        spring["datasource"] = new_ds

    # Spring Boot 3 默认 PathPatternParser，不再需要 ant_path_matcher
    mvc = spring.get("mvc")
    if isinstance(mvc, dict) and "pathmatch" in mvc:
        mvc.pop("pathmatch")
        if not mvc:
            spring.pop("mvc")

    # feign.* -> spring.cloud.openfeign.*
    if "feign" in cfg:
        spring.setdefault("cloud", {})["openfeign"] = cfg.pop("feign")

    if spring:
        cfg["spring"] = spring
    return cfg


def strip_autoconfigure_exclude(cfg: dict) -> dict:
    """Druid 已移除，spring.autoconfigure.exclude 中的 Druid 类必须一并清除。

    保留 exclude 键本身（可能还有其他条目），只过滤 druid 相关项；过滤后为空则删键。
    """
    spring = cfg.get("spring")
    if not isinstance(spring, dict):
        return cfg
    auto = spring.get("autoconfigure")
    if not isinstance(auto, dict):
        return cfg
    exclude = auto.get("exclude")
    if exclude is None:
        return cfg
    items = exclude if isinstance(exclude, list) else str(exclude).split(",")
    kept = [x for x in items if "druid" not in str(x).lower() and str(x).strip()]
    if kept:
        auto["exclude"] = kept
    else:
        auto.pop("exclude", None)
    if not auto:
        spring.pop("autoconfigure", None)
    return cfg


def replace_v2_api_docs(node):
    """网关白名单等处的 Swagger2 路径改成 OpenAPI3。"""
    if isinstance(node, dict):
        return {k: replace_v2_api_docs(v) for k, v in node.items()}
    if isinstance(node, list):
        return [replace_v2_api_docs(v) for v in node]
    if isinstance(node, str):
        return node.replace("/v2/api-docs", "/v3/api-docs")
    return node


def migrate_content(data_id: str, content: str) -> str:
    """YAML 配置走结构化迁移；Sentinel 流控规则是 JSON，单独规范化。"""
    if data_id.startswith("sentinel-"):
        # 原内容为 JSON（混用 tab 缩进，YAML 1.1 无法解析），统一格式化为 2 空格缩进 JSON
        import json
        return json.dumps(json.loads(content), ensure_ascii=False, indent=2)
    try:
        cfg = yaml.safe_load(content)
    except yaml.YAMLError:
        print(f"  [跳过结构化迁移] {data_id}: 非标准 YAML，仅做路径替换", file=sys.stderr)
        return content.replace("/v2/api-docs", "/v3/api-docs")
    if not isinstance(cfg, dict):
        return content
    cfg = replace_v2_api_docs(drop_demo_route(strip_autoconfigure_exclude(migrate(cfg))))
    return yaml.safe_dump(cfg, allow_unicode=True, sort_keys=False,
                          default_flow_style=False)


def drop_demo_route(cfg: dict) -> dict:
    """网关路由中删除已下线的 hcp-demo。"""
    routes = (((cfg.get("spring") or {}).get("cloud") or {})
              .get("gateway") or {}).get("routes")
    if isinstance(routes, list):
        kept = [r for r in routes if not (isinstance(r, dict) and r.get("id") == "hcp-demo")]
        inner = cfg["spring"]["cloud"]["gateway"]
        inner["routes"] = kept
    return cfg


def main():
    raw = SRC.read_text(encoding="utf-8", errors="strict")
    lines = raw.split("\n")

    config_rows, tenant_rows, kept_lines = [], [], []
    for line in lines:
        m = re.match(r"^INSERT INTO `config_info` VALUES \((.*)\);$", line)
        if m:
            parts = split_sql_tuple(m.group(1))
            ns = parts[10].strip("'")
            data_id = parts[1].strip("'")
            if ns == KEEP_NS and data_id not in DROP_DATA_IDS:
                config_rows.append((data_id, parts[2], unescape_sql(parts[3].strip("'")),
                                    parts[7], parts[8]))
            continue
        m = re.match(r"^INSERT INTO `tenant_info` VALUES \((.*)\);$", line)
        if m:
            parts = split_sql_tuple(m.group(1))
            # tenant_info 列顺序：kp, tenant_id, tenant_name, tenant_desc, ...
            # 命名空间标识存在 tenant_name，config_info.tenant_id 与之对应
            if parts[2].strip("'") == KEEP_NS:
                tenant_rows.append(m.group(1))
            continue
        # 清掉历史表噪音与非 nacos 内置账号
        if line.startswith("INSERT INTO `his_config_info`"):
            continue
        if re.match(r"^INSERT INTO `users` VALUES \('nacos'", line) is None \
                and line.startswith("INSERT INTO `users`"):
            continue
        kept_lines.append(line)

    out = []
    out.append("-- ----------------------------")
    out.append("-- HUIZHI-ChargeOS Nacos 配置库（Spring Boot 3 / CHG-001 v1.1）")
    out.append("--")
    out.append("-- 由 sql/hcp_config.sql 生成，相对原脚本的差异：")
    out.append("--   1. 只保留 namespace = 'hcp' 的配置；删除 yu / hcp_lwh 测试命名空间")
    out.append("--   2. 删除 hcp-demo-dev.yml（demo 模块已移出构建）与孤儿配置 ruoyi-gateway.yml")
    out.append("--   3. spring.redis.*            -> spring.data.redis.*")
    out.append("--   4. feign.*                   -> spring.cloud.openfeign.*")
    out.append("--   5. spring.datasource.dynamic/druid -> 单数据源 HikariCP")
    out.append("--   6. 删除 seata.* 全部配置（模块已移除）")
    out.append("--   7. 网关白名单 /v2/api-docs   -> /v3/api-docs")
    out.append("--   8. 清除 his_config_info 历史与非 nacos 内置账号")
    out.append("--")
    out.append("-- 生成命令：python3 tools/gen_nacos_config_boot3.py")
    out.append("-- ----------------------------")
    out.append("")

    for line in kept_lines:
        out.append(line)
        if line.startswith("CREATE TABLE `config_info`"):
            pass
    text = "\n".join(out)

    # 注入 config_info / tenant_info / users 的 INSERT
    inject = []
    inject.append("-- Nacos 命名空间（仅保留 hcp）")
    for row in tenant_rows:
        inject.append(f"INSERT INTO `tenant_info` VALUES ({row});")
    inject.append("")
    inject.append("-- 配置内容（namespace = hcp）")
    for data_id, group, content, src_user, src_ip in sorted(config_rows):
        new_content = migrate_content(data_id, content)
        md5 = hashlib.md5(new_content.encode("utf-8")).hexdigest()
        cfg_type = "json" if data_id.startswith("sentinel-") else "yaml"
        inject.append(
            "INSERT INTO `config_info` VALUES (NULL, '{}', {}, '{}', '{}', now(), now(), {}, {}, '', "
            "'{}', NULL, '', NULL, '{}', NULL, '');".format(
                data_id, group, escape_sql(new_content), md5,
                src_user, src_ip, KEEP_NS, cfg_type))

    marker = "\n\n-- ----------------------------\n-- Records of users\n-- ----------------------------"
    if marker not in text:
        print("WARN: 未找到 users 记录插入锚点", file=sys.stderr)
    # 统一在文件末尾前插入（schema 已含所有表）
    text = text.rstrip() + "\n\n" + "\n".join(inject) + "\n"

    DST.write_text(text, encoding="utf-8")
    print(f"生成 {DST}")
    print(f"config_info 条数: {len(config_rows)}")
    for data_id, *_ in sorted(config_rows):
        print(f"  - {data_id}")


if __name__ == "__main__":
    main()
