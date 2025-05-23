---
stage: Systems
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: GitLab Helmチャート
---

{{< details >}}

- プラン：Free、Premium、Ultimate
- 製品：GitLab Self-Managed

{{< /details >}}

クラウドネイティブ版のGitLabをインストールするには、GitLab Helmチャートを使用します。このチャートには、開始するのに必要なすべてのコンポーネントが含まれており、大規模なデプロイに併せたスケールも可能です。

OpenShiftベースのインストールでは、[GitLab Operator](https://docs.gitlab.com/operator/)を使用します。それ以外の場合は、[セキュリティコンテキストの制約](https://docs.gitlab.com/operator/security_context_constraints.html)を自分で更新する必要があります。

{{< alert type="warning" >}}

デフォルトのHelmチャート設定は、**本番環境を対象としたものではありません**。デフォルト値では、_すべての_GitLabサービスがクラスターにデプロイされるという実装が作成されますが、これは**本番環境のワークロードには適していません**。本番環境デプロイでは、[クラウドネイティブハイブリッドリファレンスアーキテクチャー](installation/_index.md#use-the-reference-architectures)に従う**必要があります**。

{{< /alert >}}

本番環境デプロイには、Kubernetesについてのしっかりした実務知識が必要です。このデプロイ方法の管理、可観測性、および概念は、従来のデプロイとは異なります。

GitLab Helmチャートは複数の[サブチャート](charts/gitlab/_index.md)で構成されており、それぞれ個別にインストールできます。

## 詳しく見る

- [GKEまたはEKSでGitLabチャートをテスト](quickstart/_index.md)
- [Linuxパッケージの使用からGitLabチャートに移行](installation/migration/_index.md)
- [デプロイの準備](installation/_index.md)
- [デプロイ](installation/deployment.md)
- [デプロイのオプションを表示する](installation/command-line-options.md)
- [グローバル変数を設定する](charts/globals.md)
- [サブチャートを表示する](charts/gitlab/_index.md)
- [高度な設定オプションを表示する](advanced/_index.md)
- [アーキテクチャーに関する決定事項を表示する](architecture/_index.md)
- 開発にコントリビュート([デベロッパー向けドキュメント](development/_index.md)と[コントリビューションガイドライン](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/CONTRIBUTING.md)を参照)
- [イシュー](https://gitlab.com/gitlab-org/charts/gitlab/-/issues)を作成する
- [マージリクエスト](https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests)を作成する
- [トラブルシューティング](troubleshooting/_index.md)情報を表示する
