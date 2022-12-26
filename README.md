# dce-charts-repackage

[![Auto Release Chart](https://github.com/DaoCloud/dce-charts-repackage/actions/workflows/auto-release.yaml/badge.svg)](https://github.com/DaoCloud/dce-charts-repackage/actions/workflows/auto-release.yaml)
[![Auto Upgrade Chart](https://github.com/DaoCloud/dce-charts-repackage/actions/workflows/auto-upgrade.yaml/badge.svg)](https://github.com/DaoCloud/dce-charts-repackage/actions/workflows/auto-upgrade.yaml)
[![Nightly E2E](https://github.com/DaoCloud/dce-charts-repackage/actions/workflows/night-ci.yml/badge.svg)](https://github.com/DaoCloud/dce-charts-repackage/actions/workflows/night-ci.yml)
[![Manually Release Chart](https://github.com/DaoCloud/dce-charts-repackage/actions/workflows/release-chart.yml/badge.svg)](https://github.com/DaoCloud/dce-charts-repackage/actions/workflows/release-chart.yml)

***

## 说明

本工程主要是提供了 制作 chart 的框架、 自动化测试 和 自动发版的能力。**您 书写的代码，关键在于如何自动化做 chart 包，这样工程才能 跟进开源版本自动化迭代升级**

开发一个新的 chart，主要开发如下2个目录，细节请看后续说明

* /charts/${PROJECT}

* /test/${PROJECT}/install.sh

***

## 开发 /charts/${PROJECT} 

开发该目录，主要是书写自动化生成chart的代码。 主要有3种做包方式：

**无论哪种做包方式，最终执行`make build_chart -e PROJECT=${PROJECT}` ， 要求开源chart 最终生成到 /charts/${PROJECT}/${PROJECT}**

### case: 复用工程做包框架，基于开源 chart 作为子 chart，wrapper了一层父chart

目前，基本所有项目 都遵循该制作方式，基于父子chart封装，保持开源子 chart 原汁原味，
而 父chart中可加入如下，使得产品安装更加简单：
* schema

* roleK8

* 调优开源values参数

* 下发CRD实例，如业务CRD，如 Prometheus 的监控 crd

开发流程：

1. 准备文件如下文件，每个文件的作用，在步骤2中提及
    
    * （必须）/charts/${PROJECT}/config，确保其中 USE_OPENSOURCE_CHART=false （可参考 spiderpool）。

    * （必须）父 chart 的添加内容放置在 /charts/${PROJECT}/parent 目录中

    * （可选）/charts/${PROJECT}/appendValues.yaml

    * （可选）/src/${PROJECT}/custom.sh

    * （可选）/src/${PROJECT}/skip-check.yaml : PR CI 会检查父子chart间的 values 映射关系，如果父chart中定制了一个 子chart中不存在的values，CI就会报错。对于必要的例外情况，你可以加入这种value到本文件，让 CI 忽略
    
2. 执行`make -e PROJECT=${PROJECT}`， 工程自动化 执行如下流程 来 生成 chart （ **实现代码参考脚本 scripts/generateChart.sh** ）

    1. 脚本流程会准备好一个 '父chart临时目录' ，基于/charts/${PROJECT}/config 中的配置，把依赖的 dependency开源 chart 中的 README.md values.yaml Chart.yaml values.schema.json ，放置在 '父chart临时目录' 中

    2. 对于'父chart临时目录' 中的chart.yaml ， 脚本流程会主动注入 /charts/${PROJECT}/config 中的依赖的开源项目内容 ，且把 dependency chart 自动放置在 '父chart临时目录/charts' 目录下

    3. 如果存在**您书写的 /charts/${PROJECT}/appendValues.yaml**  ， 脚本流程会把其中内容追加到 '父chart临时目录' 的 values.yaml 中

    4. 如果存在**您书写的 /charts/${PROJECT}/parent 目录**（在此目录中，你可以事先准备好 子定义的 README.md values.yaml Chart.yaml values.schema.json， 从而 覆盖以上3步的效果 ），脚本流程会则把其中的所有文件  覆盖拷贝到 '父chart临时目录' 中

    5. 如果 '父chart临时目录'  缺失 values.schema.json 文件，脚本流程会 则自动生成 values.schema.json

    6. 如果存在**您书写的 /src/${PROJECT}/custom.sh**， 脚本流程会执行它， 脚本的第一个入参是 '父chart临时目录'的路径 。 在此脚本中，你可以自定义代码，实现 复杂的 自定义修改 。 （可参考 spiderpool）

    7. 最终 ， '父chart临时目录'  拷贝于 /charts/${PROJECT}/${PROJECT}

> 如上流程看似复杂，其实为了满足 不同人的 制作 需求，您可以依赖 其中的几个步骤 来 完成 你的chart 制作


#### /charts/${PROJECT}/config 文件说明：

* USE_OPENSOURCE_CHART ： 自动化做包的方式

    * 值为 true，代表 'case：chart 直接同步开源 chart'

    * 值为 false，代表 'case: 基于开源 chart 作为子 chart，wrapper了一层父chart'

* BUILD_SELF：（可填）自己书写做chart包的脚本，不复用工程的做包框架

* DAOCLOUD_REPO_PROJECT ：（必填）chart发布时，推送到daocloud chart仓库的哪个项目下

* REPO_URL : 开源chart的 仓库URL ，用于获取开源chart

* REPO_NAME ：开源chart的 repo 名字，用于获取开源chart

* CHART_NAME : 开源chart 的名字，用于获取开源chart

* VERSION ：开源项目的 chart 版本号，用于获取开源chart

* UPGRADE_METHOD ：（必填）指定自动化升级的方式：

    * 值为 pr ：E2E 每晚会自动根据 config 中的配置，检查开源最新版本，基于 make build_chart 升级，并提交 PR 给 UPGRADE_REVIWER

    * 值为 issue ：E2E 每晚会自动根据 config 中的配置，检查开源最新版本，提交 issue 提醒给 UPGRADE_REVIWER

    * 值为 none ：(**没特殊情况，部门不允许使用这种**) 不会自动升级该组件

* UPGRADE_REVIWER ：github账号名（多个用逗号分割），当 UPGRADE_METHOD=pr 或者 UPGRADE_METHOD=issue 时必填，指定 issue 或者 pr 的assigne，

* TEST_ASSIGNER ： （可选）github账号名（多个用逗号分割），当升级 PR 被合入 main 后， chart 会被自动发布到 daocloud，若发布成功，会自动建立 issue 提醒该测试同事进行测试。如果本值不填写，会有默认的测试同事被 assign

* CUSTOM_SHELL : （可选）指定 custom.sh 脚本路径

* APPEND_VALUES_FILE ： （可选）指定 appendValues.yaml 路径 

### case: 自己写做包脚本

准备好 /charts/${PROJECT}/config ：

1. 设置其中 DAOCLOUD_REPO_PROJECT ， 推送到哪个 daocloud chart仓库项目中

2. 设置好其中的 BUILD_SELF 字段，指向做包的脚本名，你自己 在项目目录下写好做包的脚本。 **注意，该脚本 会被工程CI 调用，实现在升级场景下做包，所以，请考虑周全**

参考 f5networks 项目（其做包设计了好几个开源chart的整合，所以使用了自定义的做包脚本）

### case：复用工程做包框架，chart 直接同步开源 chart

如果直接使用开源chart，不需要父chart wrapper，那么 请编辑  /charts/${PROJECT}/config （可参考 spiderpool） ， 确保 USE_OPENSOURCE_CHART=true

***

## e2e测试代码

开发如下2个文件：

1. （必备）书写你的项目的  /test/${PROJECT}/install.sh  文件 （可参考 spiderpool），其中的代码是 helm 安装软件的 代码，主要用于跑 E2E，以闭环后续自动化升级的测试

2. （可选）/test/${PROJECT}/kind.yaml。

    默认，E2E 测试所有chart时，是在一个共享 kind 集群中 测试 安装 所有项目的 安装，如果你的项目需要一个定制、独立的 kind 集群，则可生成一份 /test/${PROJECT}/kind.yaml ，那么 E2E 只会在你的独立 kind 中跑 你的安装

工程目录下，执行 `make e2e` 运行所有 chart 安装测试，或者 运行 `make e2e -e PROJECT=${PROJECT}` 只测试某个项目

e2e 流程:

1. 安装 全局 kind 集群，会安装好 promethues 的 CRD 。 （ 如果存在 /test/${PROJECT}/kind.yaml ， 则安装你的定制 kind ）

2. 运行 你的 /test/${PROJECT}/install.sh ， 在kind集群中 进行安装。 如果安装成功，则测试通过

本地测试时，需要安装如下工具：

* helm

* [helm-schema-gen](https://github.com/karuppiah7890/helm-schema-gen.git) if needed

* docker (e2e)

* kind (e2e)

* kubectl (e2e)

***

## 自动升级

在项目的 config 配置文件中，变量 UPGRADE_METHOD 控制着自动chart包升级的方式

* 值为 pr ：E2E 每晚会自动根据 config 中的配置，检查开源最新版本，基于 make build_chart 升级，并提交 PR 给 UPGRADE_REVIWER

* 值为 issue ：E2E 每晚会自动根据 config 中的配置，检查开源最新版本，提交 issue 提醒给 UPGRADE_REVIWER

* 值为 none ：不会自动升级该组件

**对于自动升级的 PR 或者 ISSUE ，如果不想发布，只要不合入PR即可。不需要 close，因为每晚还是会提交新 PR 或者 ISSUE 上来，并且，自动提交的 PR 和 ISSUE 是比较智能的，会删除历史 未合入的 升级PR，覆盖最新版本的 升级 PR**

## chart 发布到 github pages 和 daocloud 仓库

触发 发布流程到 daocloud 仓库 ，主要有3种渠道：

1. 如果 PR 中修改了某个chart， 被合入 main 分支，则会自动 触发 release CI, 其 发布 变更 chart 到 daocloud 仓库。

    如果该 CI 成功，会自动创建 issue 提醒测试同事 测试新chart ；如果该 CI 失败，会自动创建 ISSUE 提醒 PR 作者
    
    注意：如果是直接以 commit 提交给 main ，而不是 PR 形式，是不会触发的

2. 手动点击 action 中的 “Manually Release Chart” 

3. 打tag 方式。

    给工程 推送 任意 tag，github action 自动会制作所有项目的 chart tgz，并提交 PR 到 github pages (需要 approve 下 PR) (go-pages branch)，作为调试 chart 仓库使用

    CI 还会并发送一份到 daocloud 仓库 ( 推送到哪个项目下？依据  charts/${PROJECT}/config 文件中的 DAOCLOUD_REPO_PROJECT 设置 )

在 触发完成 发布到 daocloud 仓库 CI 后，也会自动提交 PR，其合入变更 chart 到本项目的 github pages 。 如果 PR 合入后 ，你可使用 本工程的 chart repo 来测试

    helm repo add daocloud https://daocloud.github.io/dce-charts-repackage/
    helm pull daocloud/${PROJECT}

