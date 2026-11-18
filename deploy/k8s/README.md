# HUIZHI-ChargeOS 后端 k8s 部署（Spring Boot 3 / JDK 17）

## 目录内容

| 文件 | 说明 |
| :--- | :--- |
| `hcp-apps.yaml` | 7 个服务的 ConfigMap + Deployment + Service（生成的完整清单） |
| `gateway-configmap.yaml` | 网关单独覆盖用（例如临时关闭验证码） |
| `configs/<svc>.yaml` | 各服务的合并配置（共享 `application-dev.yml` + 服务专属配置，已替换 MySQL/Redis 为实际地址） |

## 部署前提

- 命名空间 `ows-fd-evcp`（`kubectl create ns ows-fd-evcp`）
- 镜像拉取凭据 `harbor-registry`（docker-registry 类型 Secret）
- 集群内可访问的 Nacos：`nacos.test-common-app.svc.cluster.local:8848`

## 镜像

```
harbor.yuanwangxianfeng.com/ows/hcp-gateway:boot3-20261118
harbor.yuanwangxianfeng.com/ows/hcp-auth:boot3-20261118
harbor.yuanwangxianfeng.com/ows/hcp-system:boot3-20261118
harbor.yuanwangxianfeng.com/ows/hcp-operator:boot3-20261118b
harbor.yuanwangxianfeng.com/ows/hcp-mp:boot3-20261118
harbor.yuanwangxianfeng.com/ows/hcp-file:boot3-20261118
harbor.yuanwangxianfeng.com/ows/hcp-job:boot3-20261118
```

## 当前的配置加载方式（临时）

Nacos 配置中心的管理端凭据尚未提供，因此清单使用 **ConfigMap 挂载 + 关闭 Nacos 配置中心**：
`SPRING_CLOUD_NACOS_CONFIG_ENABLED=false` + `SPRING_CONFIG_ADDITIONAL_LOCATION=file:/config/`。
Nacos 仅承担**服务发现**（namespace `hcp`）。

取得 Nacos 管理端账号后，应改为：
1. 用 `sql/hcp_config_boot3.sql` 的内容通过 Nacos OpenAPI 发布到 namespace `hcp`
2. 从 Deployment 中移除 `SPRING_CLOUD_NACOS_CONFIG_ENABLED` / `SPRING_CONFIG_ADDITIONAL_LOCATION` 与该 ConfigMap 挂载

## 副本数约束（重要）

- `hcp-operator`：**必须 `replicas: 1`**。充电进度 WebSocket 使用进程内静态表（`WebSocket.CLIENTS`），多副本会导致推送落到错误 Pod。
- `hcp-job`：**必须 `replicas: 1`**。内嵌 xxl-job 调度中心 + 执行器。
- 两者均使用 `strategy: Recreate` 避免滚动更新期间新旧 Pod 并存。

## 访问

- 网关 NodePort：`http://<任一节点IP>:30880`
- 默认管理员：`admin` / `admin123`（**上线前必须修改**）
