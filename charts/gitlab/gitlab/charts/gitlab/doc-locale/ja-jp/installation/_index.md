---
stage: Systems
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: Helmを使用したGitLabのインストール
---

{{< details >}}

- プラン:Free、Premium、Ultimate
- 製品:GitLab Self-Managed

{{< /details >}}

クラウドネイティブのGitLab Helmチャートを使用して、KubernetesにGitLabをインストールします。

[前提要件](tools.md)がインストール済み/設定済みなら、`helm`コマンドにより [GitLabをデプロイ](deployment.md)できます。

{{< alert type="warning" >}}

デフォルトのHelmチャート設定は、**本番環境を対象としたものではありません**。デフォルトのチャートで作成されるのは概念実証（PoC）の実装であり、そこではすべてのGitLabサービスがクラスターにデプロイされます。本番環境にデプロイする場合は、[クラウドネイティブハイブリッドリファレンスアーキテクチャー](#use-the-reference-architectures)に従う必要があります。

{{< /alert >}}

本番環境へのデプロイでは、Kubernetesに関する確かな実務知識が必要です。このデプロイ方法の管理、可観測性、および概念は、従来のデプロイとは異なります。

本番環境へのデプロイでは:

- PostgreSQLやGitaly（Gitリポジトリのストレージデータプレーン）などのステートフルコンポーネントは、PaaSまたはコンピューティングインスタンス上のクラスターの外部で実行する必要があります。この設定は、GitLab本番環境にあるさまざまなワークロードをスケールしたり、信頼性の高い仕方でサービスを提供したりするために必要です。
- PostgreSQL、Redis、およびGitリポジトリストレージ以外のすべてのストレージのオブジェクトストレージには、Cloud PaaSを使用する必要があります。

GitLabインスタンスにKubernetesが不要な場合は、よりシンプルな代替手段について[リファレンスアーキテクチャー](https://docs.gitlab.com/administration/reference_architectures/)を参照してください。

## 外部ステートフルデータを使用するように Helmチャートを設定する

PostgreSQL、Redis、Git リポジトリストレージ以外のすべてのストレージ、およびGitリポジトリストレージ（Gitaly）などの項目のために、外部ステートフルストレージを参照するよう、GitLab Helmチャートを設定することができます。

次のInfrastructure as Code（IaC）オプションでは、このアプローチを使用しています。

本番環境グレードの実装では、適切なチャートパラメーターを使用することにより、選択した[リファレンスアーキテクチャー](https://docs.gitlab.com/administration/reference_architectures/)に合わせて事前構築された外部ステートストアを参照する必要があります。

### リファレンスアーキテクチャーを使用する

KubernetesにGitLabインスタンスをデプロイするためのリファレンスアーキテクチャーが特に[クラウドネイティブハイブリッド](https://docs.gitlab.com/administration/reference_architectures/#cloud-native-hybrid)と呼ばれるのは、本番環境グレードの実装の場合、すべてのGitLabサービスをクラスター内で実行できるわけではないためです。ステートフルGitLabコンポーネントは、すべて、Kubernetesクラスターの外部にデプロイする必要があります。

使用可能なクラウドネイティブハイブリッドリファレンスアーキテクチャーのサイズのリストについては、[リファレンスアーキテクチャー](https://docs.gitlab.com/administration/reference_architectures/#cloud-native-hybrid)のページをご覧ください。たとえば、ユーザー数3,000に対する[クラウドネイティブハイブリッドリファレンスアーキテクチャー](https://docs.gitlab.com/administration/reference_architectures/3k_users/#cloud-native-hybrid-reference-architecture-with-helm-charts-alternative)は、次のとおりです。

### Infrastructure as Code（IaC）とビルダーリソースを使用する

GitLabでは、Helmチャートと補足的なクラウドインフラストラクチャの組み合わせを設定することのできるInfrastructure as Codeを開発しています。

- [GitLab Environment Toolkit IaC](https://gitlab.com/gitlab-org/gitlab-environment-toolkit)。
- [実装パターン:AWS EKSでGitLabクラウドネイティブハイブリッドをプロビジョニングする](https://docs.gitlab.com/solutions/cloud/aws/gitlab_instance_on_aws/):このリソースは、GitLab Performance Toolkitでテスト済みの部品表を提供し、予算編成にAWS料金計算ツールを使用しています。
