# network-charts-repackage

## step generate chart

case 1. 如果直接使用开源chart，不需要父chart wrapper，那么 请编辑  /charts/${PROJECT}/config ， 确保 USE_OPENSOURCE_CHART=true

    最终，执行`make -e PROJECT=${PROJECT}` ， chart 放置于 /charts/${PROJECT}/${PROJECT}

case 2. 如果需要制作 父chart ，dependency 依赖 开源的chart ， 那么 请编辑  /charts/${PROJECT}/config，确保 USE_OPENSOURCE_CHART=false
且把 父chart 的添加内容 ， 放置在 /charts/${PROJECT}/parent 目录中 ，最终，执行`make -e PROJECT=${PROJECT}`， 执行如下流程 来 生成 chart

    （1）准备好 父chart 目录，把依赖的 dependency开源 chart 中的 README.md values.yaml Chart.yaml values.schema.json ，放置在 父chart 目录中

    （2）chart.yaml 中 主动注入 config 中的依赖内容 ，把 dependency chart 放置在 父chart 的 /charts 目录下

    （3）如果存在 /charts/${PROJECT}/appendValues.yaml  ， 则 其中内容 被 追加到 父chart 的 values.yaml

    （4）如果存在 /charts/${PROJECT}/parent，则把其中的所有内容  覆盖拷贝到 父chart （在此目录中，你可以定义自己的README.md values.yaml Chart.yaml values.schema.json， 从而 覆盖以上3步的效果 ）

    （5）如果 父chart  缺失 values.schema.json 文件，则自动生成 values.schema.json

    （6）如果存在 /src/PROJECT/custom.sh， 则执行它，脚本的 入参是 父chart 的目录 。 再次脚本中，你可以自定义代码，实现 复杂的 自定义修改

    （7）最终 ， chart 就绪于 /charts/${PROJECT}/${PROJECT}

    注：如上流程看似复杂，其实为了满足 不同人的 制作 需求，您可以依赖 其中的几个步骤 来 完成 你的chart 制作

case 3. 如果你自己 已经编辑好 chart，不需要自动化帮助生成chart，那么可直接把 chart 放在 /charts/${PROJECT}/${PROJECT} 下，删除 /charts/${PROJECT}/config 文件

> 对于如上case1 和 case2 ， 如果你本地网络不能拉取开源chart，可提交 pr 后，在 github action 中手动触发"Call Generate Chart"，它会帮助执行 make，且生成 PR

## step  全量 chart 发布到 github pages 和 daocloud 仓库

给项目推送任意 tag，github action 自动会制作所有的chart，并提交到github pages 和 daocloud 仓库

提交到 github pages，可方便你测试
helm repo add daocloud https://daocloud.github.io/network-charts-repackage/
helm pull daocloud/${PROJECT} 

## step  个别 chart 发布到 github pages 和 daocloud 仓库

在 github action 中手动触发 "Release Chart" ， 触发推送指定chart
