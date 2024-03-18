# 安装

## 前置条件
### 昇腾相关驱动与固件安装
请参考官方文档进行安装：https://www.hiascend.com/document/detail/zh/CANNCommunityEdition/80RC1alpha002/softwareinst/instg/instg_0001.html

### 创建用户
需要创建默认运行用户，不同系统参考下述命令创建：

**Centos**：
```
useradd -d /home/hwMindX -u 9000 -m -s /sbin/nologin hwMindX
usermod -a -G HwHiAiUser hwMindX
```
**ubuntu**
```
useradd -d /home/hwMindX -u 9000 -m -s /sbin/nologin hwMindX
usermod -a -G HwHiAiUser hwMindX
```

### 创建日志目录

**创建父目录**
```
mkdir -m 755 /var/log/mindx-dl
chown root:root /var/log/mindx-dl
```
**根据安装的组件自行选择**


1.Ascend Device Plugin
```
mkdir -m 750 /var/log/mindx-dl/devicePlugin
chown hwMindX:hwMindX /var/log/mindx-dl/devicePlugin
```
2.NPU-Exporter
```
mkdir -m 750 /var/log/mindx-dl/npu-exporter
chown hwMindX:hwMindX /var/log/mindx-dl/npu
```

### 创建节点标签
参考下述命令，在计算节点创建标签
```
// 在安装了驱动的计算节点创建此标签
kubectl label node {nodename} huawei.com.ascend/Driver=installed
kubectl label node {nodename} node-role.kubernetes.io/worker=worker
kubectl label node {nodename} workerselector=dls-worker-node
kubectl label node {nodename} host-arch=huawei-arm //或者host-arch=huawei-x86 ，根据实际情况选择
kubectl label node {nodename} accelerator=huawei-Ascend910 // 根据实际情况进行选择
// 在控制节点创建此标签
kubectl label node {nodename} masterselector=dls-master-node
```
