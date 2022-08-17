# network-charts-repackage

## generate chart

## step1
1 如果直接需要同步 开源chart，不需要做 父chart 进行 wrapper，那么 请编辑  /charts/${PROJECT}/config ， 确保 USE_OPENSOURCE_CHART=true
最终，工程生成 chart 于 /charts/${PROJECT}/${PROJECT}

2 如果需要制作 父chart ，dependency 依赖 开源的chart ， 那么 请编辑  /charts/${PROJECT}/config，确保 USE_OPENSOURCE_CHART=false
且把 父chart 的内容 ， 放置在 /charts/${PROJECT}/parent 目录中
最终，工程依据如下流程 来 生成 chart
（1）准备好 父chart，把依赖的 dependency开源 chart 中的 README.md values.yaml Chart.yaml values.schema.json ，放置在 父chart 目录中
（2）主动注入 config 中的依赖内容 到 chart.yaml ，把 dependency chart 放置在 父chart 的 /charts 目录下
（3）如果存在 /charts/${PROJECT}/appendValues.yaml  ， 则 其中内容 追加到 values.yaml
（4）如果存在 /charts/${PROJECT}/parent，则把其中的所有内容  覆盖拷贝到 父chart
（5）如果 父chart  缺失values.schema.json 文件，则自动生成 values.schema.json
（6）如果存在 /src/PROJECT/custom.sh， 则执行它，脚本的 入参是 父chart 的目录 。 再次脚本中，你可以自定义代码，实现 自定义修改
（7）最终 ， chart 就绪于 /charts/${PROJECT}/${PROJECT}
注：如上流程看似复杂，其实为了不同人的 制作 需求，您可以依赖 其中的几个步骤 来 完成 你的chart 制作

3 如果你自己已经编辑好chart，不需要自动化帮助生成chart，那么 可 直接 把 chart 放在 /charts/${PROJECT}/${PROJECT}，且删除 /charts/${PROJECT}/config 文件

## step2

手动 make ，
或者 如果你本地网络不好，没有代理，可 提交 pr 后，在 action 中手动触发，其会生成 PR

## step3  发布到 github pages 和 daocloud 仓库



