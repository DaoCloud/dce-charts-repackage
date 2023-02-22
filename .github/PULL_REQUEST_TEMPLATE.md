<!-- * chart 适配注意

1. 修改 values.yaml 文件，其中的仓库指向 m.daocloud 仓库的镜像。

    并且，设置开源镜像的自动化同步

2. values.yaml 调优各种配置值，使得安装最简单，例如 一些功能开关、CPU 和 memory 满足 kubecost 最小要求

3. Chart.yaml 文件中如果缺失 keywords，可进行添加分类，使得应用商店中能按照组件来寻找

4. 如果 chart 中 有 serviceMonitor、prometheusRules 等对象，请设置上 label “operator.insight.io/managed-by: insight”

-->
#### What this PR does / why we need it:

#### Which issue(s) this PR fixes:
<!--
*Automatically closes linked issue when PR is merged.
Usage: `Fixes #<issue number>`, or `Fixes (paste link of issue)`.
-->
Fixes #