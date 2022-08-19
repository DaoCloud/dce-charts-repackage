# network-charts-repackage

***

## requirement

install：
* helm (localy buidl chart)
* helm-schema-gen if needed (https://github.com/karuppiah7890/helm-schema-gen.git)
* docker(e2e)
* kind(e2e)
* kubectl(e2e)

***

## 生成chart

### case：不需要父chart，自动化同步开源 chart

果直接使用开源chart，不需要父chart wrapper，那么 请编辑  /charts/${PROJECT}/config ， 确保 USE_OPENSOURCE_CHART=true

    最终，执行`make -e PROJECT=${PROJECT}` ， 开源 chart 最终生成到 /charts/${PROJECT}/${PROJECT}

> 如果你本地网络不能拉取开源chart，编辑请编辑  /charts/${PROJECT}/config 后，可提交 pr 后，在 github action 中手动触发"Call Generate Chart"，它会帮助执行 make，且生成 PR

### case: 自动化制作做父chart，

如果需要制作 父chart ，dependency 依赖 开源的chart ， 那么 请编辑  /charts/${PROJECT}/config，确保 USE_OPENSOURCE_CHART=false
且把 父chart 的添加内容 ， 放置在 /charts/${PROJECT}/parent 目录中 ，最终，执行`make -e PROJECT=${PROJECT}`， 执行如下流程 来 生成 chart

    （1）准备好 父chart 目录，把依赖的 dependency开源 chart 中的 README.md values.yaml Chart.yaml values.schema.json ，放置在 父chart 目录中

    （2）chart.yaml 中 主动注入 config 中的依赖内容 ，把 dependency chart 放置在 父chart 的 /charts 目录下

    （3）如果存在 /charts/${PROJECT}/appendValues.yaml  ， 则 其中内容 被 追加到 父chart 的 values.yaml

    （4）如果存在 /charts/${PROJECT}/parent，则把其中的所有内容  覆盖拷贝到 父chart （在此目录中，你可以定义自己的README.md values.yaml Chart.yaml values.schema.json， 从而 覆盖以上3步的效果 ）

    （5）如果 父chart  缺失 values.schema.json 文件，则自动生成 values.schema.json

    （6）如果存在 /src/PROJECT/custom.sh， 则执行它，脚本的 入参是 父chart 的目录 。 再次脚本中，你可以自定义代码，实现 复杂的 自定义修改

    （7）最终 ， chart 就绪于 /charts/${PROJECT}/${PROJECT}

    注：如上流程看似复杂，其实为了满足 不同人的 制作 需求，您可以依赖 其中的几个步骤 来 完成 你的chart 制作

> 如果你本地网络不能拉取开源chart，编辑请编辑  /charts/${PROJECT}/config 后，可提交 pr 后，在 github action 中手动触发"Call Generate Chart"，它会帮助执行 make，且生成 PR

### case: 自己 准备好  chart

如果你自己 已经编辑好 chart，不需要自动化帮助生成chart，那么可直接把 chart 放在 /charts/${PROJECT}/${PROJECT} 下 ( 不需要  /charts/${PROJECT}/config 文件 ）

***

## e2e测试代码

### 本地测试
请书写你的项目的  /test/${PROJECT}/install.sh  文件，其中的代码是 helm 安装软件的 代码
默认，在一个共享 kind 汇总 运行 所有项目的 安装测试，如果你的项目需要一个定制、独立的 kind 集群，则可生成一份 /test/${PROJECT}/kind.yaml ，那么只会在你的独立 kind 中跑你的安装

工程执行 `make e2e` 运行所有 chart 安装测试，或者 运行 `make e2e -e PRORJECT=${PROJECT}` 只测试某个项目

> e2e 流程
> 1 安装 全局 kind 集群，会安装好 promethues 的 CRD 。 （如果存在 /test/${PROJECT}/kind.yaml ， 则安装你的定制 kind）
> 2 运行 你的 /test/${PROJECT}/install.sh ， 在kind集群中 进行安装。 如果安装成功，则测试通过

### github action

按照 .github/workflows/ci-spiderpool.yml ， 创建一份copy，编辑下其中的项目名字， 提交 PR

***

## chart 发布到 github pages 和 daocloud 仓库

给项目推送任意 tag，github action 自动会制作所有的 chart tgz，并提交PR 到 github pages (需要 approve 下 PR) ，并发送一份到 daocloud 仓库

提交到 github pages，可方便你测试
```shell
helm repo add daocloud https://daocloud.github.io/network-charts-repackage/
helm pull daocloud/${PROJECT} 
```

> 如果指需要 个别 chart 发布到 github pages 和 daocloud 仓库 ，可 在 github action 中手动触发 "Release Chart" action， 触发推送指定chart


