# LuCSI - Lustre CSI Driver

## 介绍

LuCSI (Lustre Container Storage Interface) 是一个用于 Kubernetes 的 Lustre 存储 CSI 驱动程序。

## 功能特性

- 支持 Lustre 存储系统集成
- 完整的 CSI 实现（创建、删除、挂载卷）
- 节点驱动程序支持
- Pod 卷管理

## 前置条件

- Kubernetes 1.14+
- Lustre 文件系统可访问

## 安装

### 使用 Helm 安装

```bash
helm repo add daocloud https://daocloud.github.io/dce-charts-repackage/
helm install luscsi daocloud/luscsi --namespace kube-system
```

### 配置选项

主要配置项可以在 `values.yaml` 中修改：

| 参数 | 描述 | 默认值 |
|------|------|--------|
| `global.k8sImageRegistry` | Kubernetes 镜像仓库 | `m.daocloud.io/registry.k8s.io` |
| `global.luscsiImageRegistry` | LuCSI 镜像仓库 | `m.daocloud.io/ghcr.io` |
| `global.kubeletRootDir` | Kubelet 根目录 | `/var/lib/kubelet` |
| `csiController.replicas` | 控制器副本数 | `1` |
| `luscsiNode.tolerations` | 节点容忍度 | `[]` |

## 卸载

```bash
helm uninstall luscsi --namespace kube-system
```

## 支持和反馈

更多信息，请访问 [LuCSI GitHub](https://github.com/luskits/luscsi)

