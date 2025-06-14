---
stage: Systems
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: グローバル変数を使用してチャートを設定する
---

{{< details >}}

- プラン：Free、Premium、Ultimate
- 製品：GitLab Self-Managed

{{< /details >}}

ラッパーHelmチャートのインストール時に同じ設定を何度も重複してすることを軽減するため、いくつかの設定は`global`の`values.yaml`セクションで設定できます。これらのグローバル設定は複数のチャートを通じて使用されますが、他のすべての設定はそのチャート内がスコープとなります。グローバル変数の仕組みの詳細については、[グローバル変数に関するHelmドキュメント](https://helm.sh/docs/chart_template_guide/subcharts_and_globals/#global-chart-values)を参照してください。

- [ホスト](#configure-host-settings)
- [Ingress](#configure-ingress-settings)
- [GitLabバージョン](#gitlab-version)
- [PostgreSQL](#configure-postgresql-settings)
- [Redis](#configure-redis-settings)
- [レジストリ](#configure-registry-settings)
- [Gitaly](#configure-gitaly-settings)
- [Praefect](#configure-praefect-settings)
- [MinIO](#configure-minio-settings)
- [appConfig](#configure-appconfig-settings)
- [Rails](#configure-rails-settings)
- [Workhorse](#configure-workhorse-settings)
- [GitLab Shell](#configure-gitlab-shell)
- [Pages](#configure-gitlab-pages)
- [Webservice](#configure-webservice)
- [カスタム公開認証局（CA）](#custom-certificate-authorities)
- [アプリケーションリソース](#application-resource)
- [GitLabベースイメージ](#gitlab-base-image)
- [サービスアカウント](#service-accounts)
- [アノテーション](#annotations)
- [トレーシング](#tracing)
- [extraEnv](#extraenv)
- [extraEnvFrom](#extraenvfrom)
- [OAuth](#configure-oauth-settings)
- [Kerberos](#kerberos)
- [送信メール](#outgoing-email)
- [プラットフォーム](#platform)
- [アフィニティ](#affinity)
- [ポッドの優先度とプリエンプション](#pod-priority-and-preemption)
- [ログローテーション](#log-rotation)
- [ジョブ](#jobs)
- [Traefik](#traefik)

## ホストの設定

GitLabグローバルホストの設定は、`global.hosts`キーの下にあります。

```yaml
global:
  hosts:
    domain: example.com
    hostSuffix: staging
    https: false
    externalIP:
    gitlab:
      name: gitlab.example.com
      https: false
    registry:
      name: registry.example.com
      https: false
    minio:
      name: minio.example.com
      https: false
    smartcard:
      name: smartcard.example.com
    kas:
      name: kas.example.com
    pages:
      name: pages.example.com
      https: false
    ssh: gitlab.example.com
```

| 名前                      | 型      | デフォルト        | 説明                                                                                                                                                                                                                                                                                                               |
| :------------------------ | :-------: | :------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `domain`                  | 文字列    | `example.com`  | ベースドメイン。GitLabとレジストリは、この設定のサブドメインで公開されます。そのデフォルトは`example.com`ですが、`name`プロパティが設定されているホストには使用されません。下記の`gitlab.name`、`minio.name`、および`registry.name`のセクションを参照してください。                                                     |
| `externalIP`              |           | `nil`          | プロバイダーから要求される外部IPアドレスを設定します。これは、より複雑な`nginx.service.loadBalancerIP`の代わりに、テンプレートとして[NGINXチャート](nginx/_index.md#configuring-nginx)に設定されます。                                                                                                         |
| `externalGeoIP`           |           | `nil`          | `externalIP`と同じですが、[NGINX Geoチャート](nginx/_index.md#gitlab-geo)用です。統合URLを使用して[GitLab Geo](../advanced/geo/_index.md)サイトの静的IPを設定するために必要です。`externalIP`とは異なっている必要があります。                                                                                                 |
| `https`                   | ブール値   | `true`         | trueに設定されている場合は、NGINXチャートが証明書にアクセスできることを確認する必要があります。Ingressの前にTLSターミネーションがある場合は、[`global.ingress.tls.enabled`](#configure-ingress-settings)を調べるとよいでしょう。外部URLでは、`https`の代わりに`http://`を使用するため、falseに設定します。 |
| `hostSuffix`              | 文字列    |                | [下記を参照](#hostsuffix)。                                                                                                                                                                                                                                                                                                 |
| `gitlab.https`            | ブール値   | `false`        | `hosts.https`または`gitlab.https`が`true`の場合、GitLab外部URLでは`http://`ではなく`https://`を使用します。                                                                                                                                                                                                          |
| `gitlab.name`             | 文字列    |                | GitLabのホスト名。設定されている場合、`global.hosts.domain`と`global.hosts.hostSuffix`の設定に関係なくこのホスト名が使用されます。                                                                                                                                                                                   |
| `gitlab.hostnameOverride` | 文字列    |                | WebserviceのIngress設定で使用されているホスト名をオーバーライドします。ホスト名を内部ホスト名に書き換えるWAFの背後からGitLabに到達可能でなければならないという場合に役立ちます（例：`gitlab.example.com`→`gitlab.cluster.local`)。                                                                                      |
| `gitlab.serviceName`      | 文字列    | `webservice`   | GitLabサーバーを操作している`service`の名前。チャートにより、サービス（および現在の`.Release.Name`）のホスト名がテンプレート化され、適切な内部サービス名が作成されます。                                                                                                                              |
| `gitlab.servicePort`      | 文字列    | `workhorse`    | GitLabサーバーに到達できる`service`の名前付きポート。                                                                                                                                                                                                                                                   |
| `keda.enabled`            | ブール値   | `false`        | `HorizontalPodAutoscalers`の代わりに[KEDA](https://keda.sh/) `ScaledObjects`を使用します                                                                                                                                                                                                                                        |
| `minio.https`             | ブール値   | `false`        | `hosts.https`または`minio.https`が`true`の場合、MinIO外部URLでは`http://`ではなく`https://`を使用します。                                                                                                                                                                                                            |
| `minio.name`              | 文字列    | `minio`        | MinIOのホスト名。設定されている場合、`global.hosts.domain`と`global.hosts.hostSuffix`の設定に関係なくこのホスト名が使用されます。                                                                                                                                                                                    |
| `minio.serviceName`       | 文字列    | `minio`        | MinIOサーバーを操作している`service`の名前。チャートにより、サービス（および現在の`.Release.Name`）のホスト名がテンプレート化され、適切な内部サービス名が作成されます。                                                                                                                               |
| `minio.servicePort`       | 文字列    | `minio`        | MinIOサーバーに到達できる`service`の名前付きポート。                                                                                                                                                                                                                                                    |
| `registry.https`          | ブール値   | `false`        | `hosts.https`または`registry.https`が`true`の場合、レジストリの外部URLでは`http://`ではなく`https://`を使用します。                                                                                                                                                                                                      |
| `registry.name`           | 文字列    | `registry`     | レジストリのホスト名。設定されている場合、`global.hosts.domain`と`global.hosts.hostSuffix`の設定に関係なくこのホスト名が使用されます。                                                                                                                                                                                 |
| `registry.serviceName`    | 文字列    | `registry`     | レジストリサーバーを操作している`service`の名前。チャートにより、サービス（および現在の`.Release.Name`）のホスト名がテンプレート化され、適切な内部サービス名が作成されます。                                                                                                                            |
| `registry.servicePort`    | 文字列    | `registry`     | レジストリサーバーに到達できる`service`の名前付きポート。                                                                                                                                                                                                                                                 |
| `smartcard.name`          | 文字列    | `smartcard`    | スマートカード認証のホスト名。設定されている場合、`global.hosts.domain`と`global.hosts.hostSuffix`の設定に関係なくこのホスト名が使用されます。                                                                                                                                                                 |
| `kas.name`                | 文字列    | `kas`          | KASのホスト名。設定されている場合、`global.hosts.domain`と`global.hosts.hostSuffix`の設定に関係なくこのホスト名が使用されます。                                                                                                                                                                                  |
| `kas.https`               | ブール値   | `false`        | `hosts.https`または`kas.https`が`true`の場合、KAS外部URLでは`ws://`ではなく`wss://`を使用します。                                                                                                                                                                                                                    |
| `pages.name`              | 文字列    | `pages`        | GitLab Pagesのホスト名。設定されている場合、`global.hosts.domain`と`global.hosts.hostSuffix`の設定に関係なくこのホスト名が使用されます。                                                                                                                                                                             |
| `pages.https`             | 文字列    |                | `global.pages.https`、`global.hosts.pages.https`、または`global.hosts.https`が`true`の場合、プロジェクト設定UIにおいて、GitLab PagesのURLには`http://`ではなく`https://`を使用します。                                                                                                                                  |
| `ssh`                     | 文字列    |                | SSH経由でリポジトリを複製するためのホスト名。設定されている場合、`global.hosts.domain`と`global.hosts.hostSuffix`の設定に関係なくこのホスト名が使用されます。 |

### hostSuffix

ベース`domain`を使用してホスト名を構成する際には`hostSuffix`がサブドメインに付加されますが、独自の`name`が設定されているホストには使用されません。

デフォルトでは未設定です。設定されている場合、サブドメインにハイフンとこのサフィックスが付加されます。以下の例では、`gitlab-staging.example.com`や`registry-staging.example.com` のような外部ホスト名が使用されることになります:

```yaml
global:
  hosts:
    domain: example.com
    hostSuffix: staging
```

## Horizontal Pod Autoscalerの設定

HPAのGitLabグローバルホストの設定は、`global.hpa`キーの下にあります:

| 名前         | 型      | デフォルト | 説明                                                           |
| :----------- | :-------: | :------ | :-------------------------------------------------------------------- |
| `apiVersion` | 文字列    |         | HorizontalPodAutoscalerオブジェクトの定義で使用するAPIバージョン。 |

## PodDisruptionBudgetの設定

PDBのGitLabグローバルホストの設定は、`global.pdb`キーの下にあります:

| 名前         | 型      | デフォルト | 説明                                                           |
| :----------- | :-------: | :------ | :-------------------------------------------------------------------- |
| `apiVersion` | 文字列    |         | PodDisruptionBudgetオブジェクトの定義で使用するAPIバージョン。 |

## CronJobの設定

CronJobのGitLabグローバルホストの設定は、`global.batch.cronJob`キーの下にあります:

| 名前         | 型      | デフォルト | 説明                                                           |
| :----------- | :-------: | :------ | :-------------------------------------------------------------------- |
| `apiVersion` | 文字列    |         | CronJobオブジェクトの定義で使用するAPIバージョン。 |

## モニタリングの設定

ServiceMonitorとPodMonitorのGitLabのグローバル設定は、`global.monitoring`キーの下にあります:

| 名前         | 型      | デフォルト | 説明                                                           |
| :----------- | :-------: | :------ | :-------------------------------------------------------------------- |
| `enabled`    | ブール値   | `false` | `monitoring.coreos.com/v1`APIの可用性に関係なく、モニタリングリソースを有効にします。 |

## Ingressの設定

IngressのGitLabグローバルホストの設定は、`global.ingress`キーの下にあります:

| 名前                           | 型    | デフォルト        | 説明 |
|:------------------------------ |:-------:|:-------        |:----------- |
| `apiVersion`                   | 文字列  |                | Ingressオブジェクトの定義で使用するAPIバージョン。 |
| `annotations.*annotation-key*` | 文字列  |                | `annotation-key`は、あらゆるIngressでアノテーションとして値とともに使用される文字列です。例：`global.ingress.annotations."nginx\.ingress\.kubernetes\.io/enable-access-log"=true`。デフォルトの場合、グローバルアノテーションは提供されません。 |
| `configureCertmanager`         | ブール値 | `true`         | [下記を参照](#globalingressconfigurecertmanager)。 |
| `useNewIngressForCerts`        | ブール値 | `false`        | [下記を参照](#globalingressusenewingressforcerts)。 |
| `class`                        | 文字列  | `gitlab-nginx` | `Ingress`リソースの`kubernetes.io/ingress.class`アノテーションまたは`spec.IngressClassName`を制御するグローバル設定。無効にする場合は`none`、空にする場合は`""`に設定します。注：`none`または`""`の場合、不要なIngressリソースがチャートによってデプロイされないようにするため、`nginx-ingress.enabled=false`に設定してください。 |
| `enabled`                      | ブール値 | `true`         | サービスでサポートするIngressオブジェクトを作成するかどうかを制御するためのグローバル設定。 |
| `tls.enabled`                  | ブール値 | `true`         | `false`に設定すると、GitLabのTLSが無効になります。これは、IngressのTLSターミネーションを使用できない場合（TLSターミネーションプロキシがIngressコントローラーの前にある場合など）に役立ちます。httpsを完全に無効にする場合は、[`global.hosts.https`](#configure-host-settings)とともに`false`に設定する必要があります。 |
| `tls.secretName`               | 文字列  |                | `global.hosts.domain`で使用されるドメインの**ワイルドカード**証明書とキーが含まれる[Kubernetes TLSシークレット](https://kubernetes.io/docs/concepts/services-networking/ingress/#tls)の名前。 |
| `path`                         | 文字列  | `/`            | [Ingressオブジェクト](https://kubernetes.io/docs/concepts/services-networking/ingress/)の`path`エントリのデフォルト |
| `pathType`                     | 文字列  | `Prefix`       | [パスタイプ](https://kubernetes.io/docs/concepts/services-networking/ingress/#path-types)を使用すると、パスのマッチング方法を指定できます。現在のデフォルトは`Prefix`ですが、ユースケースに応じて`ImplementationSpecific`や`Exact`も使用できます。 |
| `provider`                     | 文字列  | `nginx`       | 使用するIngressプロバイダーを定義するグローバル設定。`nginx`がデフォルトのプロバイダーとして使用されます。  |

[さまざまなクラウドプロバイダーの設定](https://gitlab.com/gitlab-org/charts/gitlab/-/tree/master/examples)のサンプルが、examplesフォルダーにあります。

- [`AWS`](https://gitlab.com/gitlab-org/charts/gitlab/-/blob/master/examples/aws/ingress.yaml)
- [`GKE`](https://gitlab.com/gitlab-org/charts/gitlab/-/blob/master/examples/gke/ingress.yaml)

### Ingressパス

このチャートでは、Ingressオブジェクトの`path`エントリの定義を変更する必要があるユーザーを支援する手段として、`global.ingress.path`を採用しています。多くのユーザーはこの設定を必要としないため、_設定しないでください_。

GCPで`ingress.class: gce`、AWSで`ingress.class: alb`を利用する場合など、プロバイダーの必要に応じてロードバランサー/プロキシの動作に一致するように、`path`の定義を`/*`で終了させる必要があるユーザー向けです。

この設定により、このチャート全体としてIngressリソースのすべての`path`エントリのレンダリングでこれが使用されるようになります。唯一の例外として、[`gitlab/webservice`デプロイの設定](gitlab/webservice/_index.md#deployments-settings)にデータを入力する場合には`path`を指定する必要があります。

### クラウドプロバイダーロードバランサー

さまざまなクラウドプロバイダーのロードバランサーの実装は、このチャートの一部としてデプロイされるIngressリソースとNGINXコントローラーの設定に影響を与えます。次の表に例を示します。

| プロバイダー | レイヤ | サンプルスニペット |
| :-- | --: | :-- |
| AWS | 4 | [`aws/elb-layer4-loadbalancer`](https://gitlab.com/gitlab-org/charts/gitlab/-/blob/master/examples/aws/elb-layer4-loadbalancer.yaml) |
| AWS | 7 | [`aws/elb-layer7-loadbalancer`](https://gitlab.com/gitlab-org/charts/gitlab/-/blob/master/examples/aws/elb-layer7-loadbalancer.yaml) |
| AWS | 7 | [`aws/alb-full`](https://gitlab.com/gitlab-org/charts/gitlab/-/blob/master/examples/aws/alb-full.yaml) |

### `global.ingress.configureCertmanager`

Ingressオブジェクトの[cert-manager](https://cert-manager.io/docs/installation/helm/)の自動設定を制御するグローバル設定。`true`の場合は、`certmanager-issuer.email`が設定されている必要があります。

`false`の場合、かつ`global.ingress.tls.secretName`が未設定で、`global.ingress.tls.enabled`がtrueまたは未設定の場合は、自動自己署名証明書生成がアクティブになり、すべてのIngressオブジェクトに対して**ワイルドカード**証明書が作成されます。

外部`cert-manager`を使用する場合は、以下を指定する必要があります:

- `gitlab.webservice.ingress.tls.secretName`
- `registry.ingress.tls.secretName`
- `minio.ingress.tls.secretName`
- `global.ingress.annotations`

### `global.ingress.useNewIngressForCerts`

`cert-manager`の動作を変更して、毎回動的に作成される新しいIngressを使用してACMEチャレンジ検証を実行するようにするためのグローバル設定。

デフォルトのロジック（`global.ingress.useNewIngressForCerts`が`false`の場合）は、検証のために既存のIngressを再利用します。このデフォルトは、状況によっては適切ではありません。フラグを`true`に設定すると、検証のたびに新しいIngressオブジェクトが作成されます。

GKE Ingressコントローラーで使用する場合、`global.ingress.useNewIngressForCerts`を`true`に設定することはできません。これを有効にすることについて詳しくは、[リリースノート](../releases/7_0.md#bundled-certmanager)を参照してください。

## GitLabバージョン

{{< alert type="note" >}}

この値は、開発目的か、またはGitLabサポートからの明示的なリクエストがあった場合のみに使用してください。本番環境ではこの値を使用しないようにし、[Helmを使用したデプロイ](../installation/deployment.md#deploy-using-helm)の説明に従ってバージョンを設定してください

{{< /alert >}}

チャートのデフォルトイメージタグで使用されているGitLabのバージョンは、`global.gitlabVersion`キーを使用して変更できます:

```shell
--set global.gitlabVersion=11.0.1
```

これは、`webservice`、`sidekiq`、および`migration`のチャートで使用されるデフォルトのイメージタグに影響します。`gitaly`、`gitlab-shell`、および`gitlab-runner`のイメージタグは、個別に更新して、GitLabバージョンと互換性のあるバージョンにする必要があります。

## すべてのイメージタグへのサフィックスの追加

Helmチャートで使用されるすべてのイメージの名前にサフィックスを追加する場合は、`global.image.tagSuffix`キーを使用することができます。このユースケースの例としては、GitLabからfips準拠のコンテナイメージを使用する場合があり、それらはすべてイメージタグに拡張子`-fips`を付けて構成されます。

```shell
--set global.image.tagSuffix="-fips"
```

## すべてのコンテナのカスタムタイムゾーン

すべてのGitLabコンテナに対してカスタムタイムゾーンを設定する場合は、`global.time_zone`キーを使用することができます。使用可能な値については、[tzデータベースのタイムゾーンのリスト](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)の`TZ identifier`を参照してください。デフォルトは`UTC`です。

```shell
--set global.time_zone="America/Chicago"
```

## PostgreSQLの設定

GitLabのグローバルPostgreSQLの設定は、`global.psql`キーの下にあります。GitLabでは、`main`データベース用と`ci`用の2つのデータベース接続を使用しています。デフォルトの場合、これらの指すPostgreSQLデータベースは同じです。

`global.psql`の下の値はデフォルトであり、両方のデータベース設定に適用されます。[2つのデータベース](https://docs.gitlab.com/administration/postgresql/multiple_databases/)を使用する場合は、`global.psql.main`と`global.psql.ci`に接続の詳細を指定できます。

```yaml
global:
  psql:
    host: psql.example.com
    # serviceName: pgbouncer
    port: 5432
    database: gitlabhq_production
    username: gitlab
    applicationName:
    preparedStatements: false
    databaseTasks: true
    connectTimeout:
    keepalives:
    keepalivesIdle:
    keepalivesInterval:
    keepalivesCount:
    tcpUserTimeout:
    password:
      useSecret: true
      secret: gitlab-postgres
      key: psql-password
      file:
    main: {}
      # host: postgresql-main.hostedsomewhere.else
      # ...
    ci: {}
      # host: postgresql-ci.hostedsomewhere.else
      # ...
```

| 名前                 | 型      | デフォルト                | 説明                                                                                                                                                                                    |
| :-----------------   | :-------: | :--------------------- | :-----------                                                                                                                                                                                   |
| `host`               | 文字列    |                        | 使用するデータベースが格納されているPostgreSQLサーバーのホスト名。このチャートによってデプロイされるPostgreSQLを使用している場合は省略可能。                                                                |
| `serviceName`        | 文字列    |                        | PostgreSQLデータベースを操作している`service`の名前。これが存在して、`host`が存在しない場合、チャートでは、`host`値ではなくサービスのホスト名をテンプレートとして設定します。 |
| `database`           | 文字列    | `gitlabhq_production`  | PostgreSQLサーバーで使用するデータベースの名前。                                                                                                                                      |
| `password.useSecret` | ブール値   | `true`                 | PostgreSQLのパスワードをシークレットまたはファイルから読み取るかどうかを制御します。                                                                                                                    |
| `password.file`      | 文字列    |                        | PostgreSQLのパスワードを含むファイルのパスを定義します。`password.useSecret`がtrueなら無視されます                                                                                |
| `password.key`       | 文字列    |                        | PostgreSQLの`password.key`属性は、パスワードを含むシークレット（下記）内のキーの名前を定義します。`password.useSecret`がfalseなら無視されます。                            |
| `password.secret`    | 文字列    |                        | PostgreSQLの`password.secret`属性は、プル元となるKubernetesの`Secret`の名前を定義します。`password.useSecret`がfalseなら無視されます。                                             |
| `port`               | 整数   | `5432`                 | PostgreSQLサーバーへの接続に使用するポート。                                                                                                                                         |
| `username`           | 文字列    | `gitlab`               | データベースへの認証に使用するユーザー名。                                                                                                                                       |
| `preparedStatements` | ブール値   | `false`                | PostgreSQLサーバーとの通信時にプリペアドステートメントを使用するかどうか。                                                                                                           |
| `databaseTasks`      | ブール値   | `true`                 | GitLabが特定のデータベースに対してデータベースタスクを実行するかどうか。共有ホスト/ポート/データベースが`main`と一致する場合、自動的に無効になります。                                                   |
| `connectTimeout`     | 整数   |                        | データベース接続を待機する秒数。                                                                                                                                       |
| `keepalives`         | 整数   |                        | クライアント側のTCPキープアライブを使用するかどうかを制御します（1はオン、0はオフ）。                                                                                                          |
| `keepalivesIdle`     | 整数   |                        | TCPがキープアライブメッセージをサーバーに送信するまでの非アクティブ状態の秒数。値がゼロの場合は、システムのデフォルトを使用します。                                                    |
| `keepalivesInterval` | 整数   |                        | TCPキープアライブメッセージがサーバーによって確認応答されない場合に、それを再送信するまでの秒数。値がゼロの場合は、システムのデフォルトを使用します。                             |
| `keepalivesCount`    | 整数   |                        | クライアントからサーバーへの接続が切断されたと見なされることになるTCPキープアライブ損失数。値がゼロの場合は、システムのデフォルトを使用します。                                        |
| `tcpUserTimeout`     | 整数   |                        | 送信データへの確認応答がない場合に、接続を強制クローズするまでのミリ秒数。値がゼロの場合は、システムのデフォルトを使用します。                                    |
| `applicationName`    | 文字列    |                        | データベースに接続しているアプリケーションの名前。空文字列（`""`）に設定すると、これを無効にすることができます。デフォルトの場合、実行中のプロセスの名前（`sidekiq`、`puma`など）に設定されます。  |
| `ci.enabled`         | ブール値   | `true`                 | [2つのデータベース接続](#configure-multiple-database-connections)を有効にします。                                                                                                                  |

### チャートごとのPostgreSQL

一部の複雑なデプロイでは、このチャートの複数の部分についてPostgreSQLの設定を異なるものにすることが望ましい場合があります。`v4.2.0`の時点では、`gitlab.sidekiq.psql`など、`global.psql`内で使用可能なすべてのプロパティをチャートごとに設定できます。ローカル設定を指定した場合、それによってグローバル値がオーバーライドされます。_存在しないもの_については、`global.psql`から継承されます（`psql.load_balancing`を除く）。

設計上、[PostgreSQLのロードバランシング](#postgresql-load-balancing)がグローバルから継承_されることはありません_。

### PostgreSQL SSL

{{< alert type="note" >}}

SSLサポートは相互TLSのみです。[イシュー#2034](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/2034)と[イシュー#1817](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/1817)を参照してください。

{{< /alert >}}

相互TLS経由でGitLabをPostgreSQLデータベースに接続する場合は、クライアントキー、クライアント証明書、およびサーバー公開認証局（CA）を異なるシークレットキーとして含むシークレットを作成します。次に、`global.psql.ssl`マッピングを使用してシークレットの構造を記述します。

```yaml
global:
  psql:
    ssl:
      secret: db-example-ssl-secrets # Name of the secret
      clientCertificate: cert.pem    # Secret key storing the certificate
      clientKey: key.pem             # Secret key of the certificate's key
      serverCA: server-ca.pem        # Secret key containing the CA for the database server
```

| 名前                | 型    | デフォルト | 説明 |
|:-----------------   |:-------:|:------- |:----------- |
| `secret`            | 文字列  |         | 次のキーを含むKubernetes `Secret`の名前 |
| `clientCertificate` | 文字列  |         | `Secret`内で、クライアント証明書を含むキーの名前。 |
| `clientKey`         | 文字列  |         | `Secret`内で、クライアント証明書のキーファイルを含むキーの名前。 |
| `serverCA`          | 文字列  |         | `Secret`内で、サーバーの公開認証局（CA）を含むキーの名前。 |

正しいキーを指すように環境変数をエクスポートするために、```extraEnv```値を設定することが必要な場合もあります。

```yaml
global:
  extraEnv:
      PGSSLCERT: '/etc/gitlab/postgres/ssl/client-certificate.pem'
      PGSSLKEY: '/etc/gitlab/postgres/ssl/client-key.pem'
      PGSSLROOTCERT: '/etc/gitlab/postgres/ssl/server-ca.pem'
```

### PostgreSQLのロードバランシング

このチャートでは、HA方式でPostgreSQLをデプロイしないため、この機能を使用するには、[外部PostgreSQL](../advanced/external-db/_index.md)を使用する必要があります。

GitLabのRailsコンポーネントには、[PostgreSQLクラスターを利用して読み取り専用クエリの負荷を分散する](https://docs.gitlab.com/administration/postgresql/database_load_balancing/)機能があります。

この機能は、次の2つの方法で設定できます。

- セカンダリの_ホスト名_の静的リストを使用する。
- DNSベースのサービスディスカバリメカニズムを使用する。

分かりやすいのは静的リストによる設定です。

```yaml
global:
  psql:
    host: primary.database
    load_balancing:
       hosts:
       - secondary-1.database
       - secondary-2.database
```

サービスディスカバリの設定はもっと複雑になることがあります。この設定、パラメーター、関連する動作について詳しくは、[GitLab管理ドキュメント](https://docs.gitlab.com/administration/)の[サービスディスカバリ](https://docs.gitlab.com/administration/postgresql/database_load_balancing/#service-discovery)を参照してください。

```yaml
global:
  psql:
    host: primary.database
    load_balancing:
      discover:
        record:  secondary.postgresql.service.consul
        # record_type: A
        # nameserver: localhost
        # port: 8600
        # interval: 60
        # disconnect_timeout: 120
        # use_tcp: false
        # max_replica_pools: 30
```

さらに、[ステイル読み取りの処理](https://docs.gitlab.com/administration/postgresql/database_load_balancing/#handling-stale-reads)に関しても、追加の調整が可能です。これらの項目についてはGitLab管理ドキュメントで詳しく説明されており、これらのプロパティは`load_balancing`の下に直接追加できます。

```yaml
global:
  psql:
    load_balancing:
      max_replication_difference: # See documentation
      max_replication_lag_time:   # See documentation
      replica_check_interval:     # See documentation
```

### 複数のデータベース接続を設定する

{{< history >}}

- Rakeタスク`gitlab:db:decomposition:connection_status`は、GitLab 15.11で[導入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/111927)されました。

{{< /history >}}

GitLab 16.0におけるGitLabのデフォルトでは、同じPostgreSQLデータベースを指す2つのデータベース接続を使用します。

## Redisの設定

GitLabグローバルRedisの設定は、`global.redis`キーの下にあります。

デフォルトでは、単一の非レプリケートRedisインスタンスを使用します。高可用性Redisが必要な場合は、外部Redisインスタンスを使用することをお勧めします。

外部Redisインスタンスは、`redis.install=false`を設定し、設定に関する[詳細ドキュメント](../advanced/external-redis/_index.md)に従うことによって導入できます。

```yaml
global:
  redis:
    host: redis.example.com
    serviceName: redis
    database: 7
    port: 6379
    auth:
      enabled: true
      secret: gitlab-redis
      key: redis-password
    scheme:
```

| 名前               | 型    | デフォルト | 説明 |
|:------------------ |:-------:|:------- |:----------- |
| `connectTimeout`   | 整数 |         | Redis接続を待機する秒数。値を指定しない場合、クライアントのデフォルトは1秒です。 |
| `readTimeout`      | 整数 |         | Redisの読み取りを待機する秒数。値が指定されていない場合、クライアントのデフォルトは1秒です。 |
| `writeTimeout`     | 整数 |         | Redisの書き込みを待機する秒数。値が指定されていない場合、クライアントのデフォルトは1秒です。 |
| `host`             | 文字列  |         | 使用するデータベースが格納されているRedisサーバーのホスト名。`serviceName`の代わりとして省略できます。 |
| `serviceName`      | 文字列  | `redis` | Redisデータベースを操作している`service`の名前。これが存在して、`host`が存在しない場合、チャートでは、`host`値ではなくサービスのホスト名（および現在の`.Release.Name`）をテンプレートとして設定します。これは、RedisをGitLabチャート全体の一部として使用する場合に便利です。 |
| `port`             | 整数 | `6379`  | Redisサーバーへの接続に使用するポート。 |
| `database`         | 整数 | `0`     | Redisサーバー上の接続先データベース。 |
| `user`             | 文字列  |         | Redisに対する認証に使用するユーザー（Redis 6.0以降）。 |
| `auth.enabled`     | ブール値    | true    | `auth.enabled`は、Redisインスタンスでパスワードを使用するかどうかの切替機能を提供します。 |
| `auth.key`         | 文字列  |         | Redisの`auth.key`属性は、パスワードを含むシークレット（下記）内のキーの名前を定義します。 |
| `auth.secret`      | 文字列  |         | Redisの`auth.secret`属性は、プル元となるKubernetesの`Secret`の名前を定義します。 |
| `scheme`           | 文字列  | `redis` | Redis URLの生成に使用するURIスキーム。有効な値は、`redis`、`rediss`、および`tcp`です。`rediss`（SSL暗号化接続）スキームを使用する場合、サーバーで使用される証明書は、システムで信頼するチェーンの一部でなければなりません。そのためには、[カスタム公開認証局（CA）](#custom-certificate-authorities)のリストに追加することができます。 |

### Redisチャート固有の設定

[Redisチャート](https://github.com/bitnami/charts/tree/main/bitnami/redis)を直接設定するための設定は、`redis`キーの下にあります。

```yaml
redis:
  install: true
  image:
    registry: registry.example.com
    repository: example/redis
    tag: x.y.z
```

詳細については、[全設定のリスト](https://artifacthub.io/packages/helm/bitnami/redis/11.3.4#parameters)を参照してください。

### Redis Sentinelのサポート

現在のRedis Sentinelサポートでサポートされるのは、GitLabチャートはと別個にデプロイされたSentinelだけです。その結果として、GitLabチャートによる Redisデプロイを`redis.install=false`により無効にする必要があります。Redisパスワードを含むKubernetes Secretを、GitLabチャートをデプロイする前に手動で作成する必要があります。

GitLabチャートからHA Redisクラスターをインストールする場合、Sentinelの使用はサポートされません。Sentinelサポートが必要な場合は、GitLabチャートのインストールとは別にRedisクラスターを作成する必要があります。これは、Kubernetesクラスターの内外で実行できます。

[GitLabでデプロイされたRedisクラスターでのSentinelのサポート](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/1810)を追跡するイシューが、追跡目的で作成されています。

```yaml
redis:
  install: false
global:
  redis:
    host: redis.example.com
    serviceName: redis
    port: 6379
    sentinels:
      - host: sentinel1.example.com
        port: 26379
      - host: sentinel2.exeample.com
        port: 26379
    auth:
      enabled: true
      secret: gitlab-redis
      key: redis-password
```

| 名前               | 型    | デフォルト | 説明 |
|:------------------ |:-------:|:------- |:----------- |
| `host`             | 文字列  |         | `host`属性は、`sentinel.conf`で指定されているクラスター名に設定する必要があります。|
| `sentinels.[].host`| 文字列  |         | Redis HAセットアップ用のRedis Sentinelサーバーのホスト名。 |
| `sentinels.[].port`| 整数 | `26379` | Redis Sentinelサーバーへの接続に使用するポート。 |

上記の表でも指定されているのでない限り、一般的な[Redis設定](#configure-redis-settings)に含まれる先行するすべてのRedis属性は、Sentinelサポートに引き続き適用されます。

#### Redis Sentinelのパスワードサポート

{{< history >}}

- GitLab 17.1で[導入されました](https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests/3792)。

{{< /history >}}

```yaml
redis:
  install: false
global:
  redis:
    host: redis.example.com
    serviceName: redis
    port: 6379
    sentinels:
      - host: sentinel1.example.com
        port: 26379
      - host: sentinel2.example.com
        port: 26379
    auth:
      enabled: true
      secret: gitlab-redis
      key: redis-password
    sentinelAuth:
      enabled: false
      secret: gitlab-redis-sentinel
      key: sentinel-password
```

| 名前                       | 型       | デフォルト | 説明 |
|:-------------------------- |:----------:|:------- |:----------- |
| `sentinelAuth.enabled`     | ブール値    | false   | `sentinelAuth.enabled`は、Redis Sentinelインスタンスでパスワードを使用するかどうかの切替機能を提供します。 |
| `sentinelAuth.key`         | 文字列     |         | Redisの`sentinelAuth.key`属性は、パスワードを含むシークレット（下記）内のキーの名前を定義します。 |
| `sentinelAuth.secret`      | 文字列     |         | Redisの`sentinelAuth.secret`属性は、プル元となるKubernetesの`Secret`の名前を定義します。 |

`global.redis.sentinelAuth`は、すべてのSentinelインスタンスのためのSentinelパスワードを設定するために使用できます。

`sentinelAuth`は、[Redisインスタンス固有の設定](#multiple-redis-support)または[`global.redis.redisYmlOverride`](../advanced/external-redis/_index.md#redisyml-override)でオーバーライドできないことに注意してください。

### 複数のRedisのサポート

GitLabチャートには、さまざまな永続クラス用に別個のRedisインスタンスで実行するためのサポートが含まれています。現在のところ、次のとおりです。

| インスタンス          | 目的                                                         |
|:------------------|:----------------------------------------------------------------|
| `actioncable`     | ActionCableのPub/Subキューバックエンド                           |
| `cache`           | キャッシュされたデータを保存する                                               |
| `kas`             | kas固有のデータを保存する                                         |
| `queues`          | Sidekiqバックグラウンドジョブを保存する                                   |
| `rateLimiting`    | RackAttackおよびアプリケーション制限のレート制限の使用状況を保存する |
| `repositoryCache` | リポジトリ関連データを保存する                                   |
| `sessions`        | ユーザーセッションデータを保存する                                         |
| `sharedState`     | 分散ロックなど、さまざまな永続データを保存する         |
| `traceChunks`     | ジョブトレースを一時的に保存する                                    |
| `workhorse`       | WorkhorseのPub/subキューバックエンド                             |

インスタンスの数に制限はありません。指定されていないインスタンスは、`global.redis.host`で指定されるプライマリRedisインスタンスによって処理されるか、またはチャートからデプロイされたRedisインスタンスを使用します。唯一の例外は[GitLabエージェントサーバー（KAS）](gitlab/kas/_index.md)であり、それは次の順序でRedis設定を検索します。

1. `global.redis.kas`
1. `global.redis.sharedState`
1. `global.redis.host`

次に例を示します。

```yaml
redis:
  install: false
global:
  redis:
    host: redis.example
    port: 6379
    auth:
      enabled: true
      secret: redis-secret
      key: redis-password
    actioncable:
      host: cable.redis.example
      port: 6379
      password:
        enabled: true
        secret: cable-secret
        key: cable-password
    cache:
      host: cache.redis.example
      port: 6379
      password:
        enabled: true
        secret: cache-secret
        key: cache-password
    kas:
      host: kas.redis.example
      port: 6379
      password:
        enabled: true
        secret: kas-secret
        key: kas-password
    queues:
      host: queues.redis.example
      port: 6379
      password:
        enabled: true
        secret: queues-secret
        key: queues-password
    rateLimiting:
      host: rateLimiting.redis.example
      port: 6379
      password:
        enabled: true
        secret: rateLimiting-secret
        key: rateLimiting-password
    repositoryCache:
      host: repositoryCache.redis.example
      port: 6379
      password:
        enabled: true
        secret: repositoryCache-secret
        key: repositoryCache-password
    sessions:
      host: sessions.redis.example
      port: 6379
      password:
        enabled: true
        secret: sessions-secret
        key: sessions-password
    sharedState:
      host: shared.redis.example
      port: 6379
      password:
        enabled: true
        secret: shared-secret
        key: shared-password
    traceChunks:
      host: traceChunks.redis.example
      port: 6379
      password:
        enabled: true
        secret: traceChunks-secret
        key: traceChunks-password
    workhorse:
      host: workhorse.redis.example
      port: 6379
      password:
        enabled: true
        secret: workhorse-secret
        key: workhorse-password
```

次の表に、Redisインスタンスの各ディクショナリの属性を示します。

| 名前               | 型    | デフォルト | 説明 |
|:------------------ |:-------:|:------- |:----------- |
| `.host`            | 文字列  |         | 使用するデータベースが格納されているRedisサーバーのホスト名。 |
| `.port`            | 整数 | `6379`  | Redisサーバーへの接続に使用するポート。 |
| `.password.enabled`| ブール値 | true    | `password.enabled`は、Redisインスタンスでパスワードを使用するかどうかの切替機能を提供します。 |
| `.password.key`    | 文字列  |         | Redisの`password.key`属性は、パスワードを含むシークレット（下記）内のキーの名前を定義します。 |
| `.password.secret` | 文字列  |         | Redisの`password.secret`属性は、プル元となるKubernetesの`Secret`の名前を定義します。 |

分離されていない追加の永続クラスがあるため、プライマリRedisの定義が必要です。

インスタンス定義ごとに、Redis Sentinelのサポートも使用できます。Sentinelの設定は**共有されません**。Sentinelを使用するインスタンスごとに指定する必要があります。Sentinelサーバーの設定に使用する属性については、[Sentinelの設定](#redis-sentinel-support)を参照してください。

### セキュアなRedisスキーム（SSL）を指定する

SSLでRedisに接続するには、次のようにします。

1. `rediss`（`s`は2個）スキームパラメーターを使用するように設定を更新します。
1. `authClients`を`false`に設定します。

   ```yaml
   global:
     redis:
       scheme: rediss
   redis:
     tls:
       enabled: true
       authClients: false
   ```

   [Redisのデフォルトは相互TLS](https://redis.io/docs/latest/operate/oss_and_stack/management/security/encryption/)であり、それはすべてのチャートコンポーネントでサポートしているわけではないため、この設定は必須です。

1. Bitnamiの[TLSを有効にする手順](https://github.com/bitnami/charts/tree/main/bitnami/redis#securing-traffic-using-tls)に従います。チャートコンポーネントが、Redis証明書の作成に使用する公開認証局（CA）を信頼していることを確認します。
1. 任意。カスタム公開認証局を使用する場合については、[カスタム公開認証局（CA）](#custom-certificate-authorities)のグローバル設定を参照してください。

### パスワードレスRedisサーバー

Google Cloud Memorystoreなどの一部のRedisサービスでは、パスワードとそれに関連する`AUTH`コマンドを使用しません。パスワードの使用と要件は、次の設定により無効にできます。

```yaml
global:
  redis:
    auth:
      enabled: false
    host: ${REDIS_PRIVATE_IP}
redis:
  enabled: false
```

## レジストリの設定

レジストリのグローバル設定は、`global.registry`キーの下にあります。

```yaml
global:
  registry:
    bucket: registry
    certificate:
    httpSecret:
    notificationSecret:
    notifications: {}
    ## Settings used by other services, referencing registry:
    enabled: true
    host:
    api:
      protocol: http
      serviceName: registry
      port: 5000
    tokenIssuer: gitlab-issuer

```

`bucket`、`certificate`、`httpSecret`、`notificationSecret`の設定の詳細については、[レジストリチャート](registry/_index.md)内のドキュメントを参照してください。

`enabled`、`host`、`api`、`tokenIssuer`の詳細については、[コマンドラインオプション](../installation/command-line-options.md)および[webcervice](gitlab/webservice/_index.md)のドキュメントを参照してください。

`host`は、自動生成された外部レジストリホスト名参照をオーバーライドするために使用されます。

### notifications（通知）

この設定は、[レジストリ通知](https://distribution.github.io/distribution/about/notifications/)を設定するために使用されます。これは、（アップストリームの指定に従って）マップを取り込みますが、Kubernetes Secretsとして機密ヘッダーを提供するという機能が追加されています。たとえば、認証ヘッダーには機密データが含まれ、他のヘッダーには標準のデータが含まれている次のスニペットについて考えてみましょう。

```yaml
global:
  registry:
    notifications:
      events:
        includereferences: true
      endpoints:
        - name: CustomListener
          url: https://mycustomlistener.com
          timeout: 500mx
          # DEPRECATED: use `maxretries` instead https://gitlab.com/gitlab-org/container-registry/-/issues/1243.
          # When using `maxretries`, `threshold` is ignored: https://gitlab.com/gitlab-org/container-registry/-/blob/master/docs/configuration.md?ref_type=heads#endpoints
          threshold: 5
          maxretries: 5
          backoff: 1s
          headers:
            X-Random-Config: [plain direct]
            Authorization:
              secret: registry-authorization-header
              key: password
```

この例の場合、ヘッダー`X-Random-Config`は標準のヘッダーであり、その値は`values.yaml`ファイル内に、または`--set`フラグを介してプレーンテキストで指定できます。ただし、ヘッダー`Authorization`は機密ヘッダーであるため、Kubernetes secretからマウントすることをお勧めします。シークレットの構造の詳細については、[シークレットに関するドキュメント](../installation/secrets.md#registry-sensitive-notification-headers)を参照してください

## Gitalyの設定

Gitalyのグローバル設定は、`global.gitaly`キーの下にあります。

```yaml
global:
  gitaly:
    internal:
      names:
        - default
        - default2
    external:
      - name: node1
        hostname: node1.example.com
        port: 8075
    authToken:
      secret: gitaly-secret
      key: token
    tls:
      enabled: true
      secretName: gitlab-gitaly-tls
```

### Gitalyホスト

[Gitaly](https://gitlab.com/gitlab-org/gitaly)は、Gitリポジトリへの高レベルRPCアクセスを提供するサービスであり、GitLabによってなされるすべてのGit呼び出しを処理します。

管理者は、次の方法でGitalyノードを使用することもできます。

- [チャート内部](#internal)（[Gitalyチャート](gitlab/gitaly/_index.md)を介して`StatefulSet`の一部として）。
- [チャートの外部](#external)（外部ペットとして）。
- 内部ノードと外部ノードの両方を使用する[混合環境](#mixed)。

新規プロジェクト用に使用されるノードの管理の詳細については、[リポジトリストレージパス](https://docs.gitlab.com/administration/repository_storage_paths/)のドキュメントを参照してください。

`gitaly.host`が指定されている場合、`gitaly.internal`プロパティと`gitaly.external`プロパティは*無視されます*。[非推奨のGitaly設定](#deprecated-gitaly-settings) を参照してください。

現時点で、Gitaly認証トークンは、内部または外部のすべてのGitalyサービスで同一であることが期待されています。これらが揃っていることを確認してください。詳細については、[イシュー#1992](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/1992)を参照してください。

#### internal（内部）

現在のところ、`internal`キーは1つのキー`names`だけで構成されており、これはチャートによって管理される[ストレージ名](https://docs.gitlab.com/administration/repository_storage_paths/)のリストです。リスト内の名前ごとに（*論理的な順序*で）1つのポッドが生成されます。その名前は`${releaseName}-gitaly-${ordinal}`です（`ordinal`は`names`リスト内のインデックス）。動的なプロビジョニングが有効になっている場合、`PersistentVolumeClaim`は一致します。

このリストのデフォルトは`['default']`であり、1つの[ストレージパス](https://docs.gitlab.com/administration/repository_storage_paths/)に対して関連する1つのポッドを提供します。

このアイテムは手動スケーリングが必要です。そのためには、`gitaly.internal.names`の中のエントリを追加または削除します。スケールダウンすると、別のノードに移動されていないリポジトリは使用できなくなります。Gitalyチャートは`StatefulSet`であるため、動的にプロビジョニングされたディスクは*再利用されません*。つまり、データディスクは存続しており、`names`リストにノードを再度追加してセットを再びスケールアップすると、データディスク上のデータにアクセスできます。

[複数の内部ノードの設定](https://gitlab.com/gitlab-org/charts/gitlab/blob/master/examples/gitaly/values-multiple-internal.yaml)のサンプルがexamplesフォルダーにあります。

#### external（外部）

`external`キーは、クラスターの外部にあるGitalyノードの設定を提供します。このリストの各項目には、次の3つのキーがあります。

- `name`：[ストレージ](https://docs.gitlab.com/administration/repository_storage_paths/)の名前。[`name: default`のエントリが必要です](https://docs.gitlab.com/administration/gitaly/configure_gitaly/#gitlab-requires-a-default-repository-storage)。
- `hostname`：Gitalyサービスのホスト。
- `port`：（オプション）ホストに到達するためのポート番号。デフォルトは`8075`です。
- `tlsEnabled`：（オプション）この特定のエントリの`global.gitaly.tls.enabled` をオーバーライドします。

GitLabでは、[外部Gitalyサービスの使用](../advanced/external-gitaly/_index.md)に関する[高度な設定](../advanced/_index.md)ガイドを提供しています。examplesフォルダーには、複数の外部サービスの[設定](https://gitlab.com/gitlab-org/charts/gitlab/blob/master/examples/gitaly/values-multiple-external.yaml)の例もあります。

可用性の高いGitalyサービスを提供するために、外部[Praefect](https://docs.gitlab.com/administration/gitaly/praefect/)を使用することもできます。クライアントにとっては違いがないため、2つの設定は交換可能です。

#### 混合

内部Gitalyノードと外部Gitalyノードの両方を使用することは可能ですが、次の点に注意してください。

- [`default`というノードが常に存在する必要があります](https://docs.gitlab.com/administration/gitaly/configure_gitaly/#gitlab-requires-a-default-repository-storage)。内部ではこれがデフォルトで提供されます。
- 外部ノードが最初に設定され、次に内部ノードが設定されます。

examplesフォルダーに、[内部ノードと外部ノードの混合設定](https://gitlab.com/gitlab-org/charts/gitlab/blob/master/examples/gitaly/values-multiple-mixed.yaml)の例があります。

### authToken

Gitalyの`authToken`属性には、次の2つのサブキーがあります。

- `secret`は、プル元のとなるKubernetes`Secret`の名前を定義します。
- `key`は、上記のシークレットのうちauthTokenを含むキーの名前を定義します。

すべてのGitalyノードで同じ認証トークンを**共有する**必要があります。

### 非推奨のGitaly設定

| 名前                         | 型    | デフォルト | 説明 |
|:---------------------------- |:-------:|:------- |:----------- |
| `host`*（非推奨）*        | 文字列  |         | 使用するGitalyサーバーのホスト名。`serviceName`の代わりとして省略できます。この設定を使用すると、`internal`または`external`の値がオーバーライドされます。 |
| `port`*（非推奨）*        | 整数 | `8075`  | Gitalyサーバーへの接続に使用するポート。 |
| `serviceName`*（非推奨）* | 文字列  |         | Gitalyサーバーを操作している`service`の名前。これが存在して、`host`が存在しない場合、チャートでは、`host`値ではなくサービスのホスト名（および現在の`.Release.Name`）をテンプレートとして設定します。これは、GitalyをGitLabチャート全体の一部として使用する場合に便利です。 |

### TLSの設定

TLS経由で動作するようにGitalyを設定する方法について詳しくは、[Gitalyチャートのドキュメント](gitlab/gitaly#running-gitaly-over-tls)をご覧ください。

## Praefectの設定

Praefectのグローバル設定は、`global.praefect`キーの下にあります。

Praefectはデフォルトで無効になっています。追加の設定なしで有効にした場合、Gitalyレプリカが3つ作成され、デフォルトのPostgreSQLインスタンス上にPraefectデータベースを手動で作成する必要があります。

### Praefectを有効にする

デフォルト設定でPraefectを有効にするには、`global.praefect.enabled=true`を設定します。

Praefectを使用してGitalyクラスターを操作する方法の詳細については、[Praefectのドキュメント](https://docs.gitlab.com/administration/gitaly/praefect/)を参照してください。

### Praefectのグローバル設定

```yaml
global:
  praefect:
    enabled: false
    virtualStorages:
    - name: default
      gitalyReplicas: 3
      maxUnavailable: 1
    dbSecret: {}
    psql: {}
```

| 名前            | 型    | デフォルト     | 説明                                                        |
| ----            | ----    | -------     | -----------                                                        |
| 有効         | ブール値    | false       | Praefectを有効にするかどうか                                  |
| virtualStorages | リスト    | 上記の[複数の仮想ストレージ](https://docs.gitlab.com/administration/gitaly/praefect/#multiple-virtual-storages)を参照。  | 必要な仮想ストレージのリスト（それぞれをGitaly StatefulSetで処理） |
| dbSecret.secret | 文字列  |             | データベースの認証に使用するシークレットの名前 |
| dbSecret.key    | 文字列  |             | 使用する`dbSecret.secret`の中のキーの名前                    |
| psql.host       | 文字列  |             | 使用するデータベースサーバーのホスト名（外部データベースを使用する場合） |
| psql.port       | 文字列  |             | データベースサーバーのポート番号（外部データベースを使用する場合） |
| psql.user       | 文字列  | `praefect` | 使用するデータベースユーザー                                           |
| psql.dbName | 文字列 | `praefect` | 使用するデータベースの名前 |

## MinIOの設定

GitLabのグローバルMinIO設定は、`global.minio`キーの下にあります。これらの設定の詳細については、[MinIOチャート](minio/_index.md)内のドキュメントを参照してください。

```yaml
global:
  minio:
    enabled: true
    credentials: {}
```

## appConfigの設定

[Webservice](gitlab/webservice/_index.md)、[Sidekiq](gitlab/sidekiq/_index.md)、および [Gitaly](gitlab/gitaly/_index.md)のチャートでは複数の設定が共有されており、それらは`global.appConfig`キーで設定されます。

```yaml
global:
  appConfig:
    # cdnHost:
    contentSecurityPolicy:
      enabled: false
      report_only: true
      # directives: {}
    enableUsagePing: true
    enableSeatLink: true
    enableImpersonation: true
    applicationSettingsCacheSeconds: 60
    usernameChangingEnabled: true
    issueClosingPattern:
    defaultTheme:
    defaultColorMode:
    defaultSyntaxHighlightingTheme:
    defaultProjectsFeatures:
      issues: true
      mergeRequests: true
      wiki: true
      snippets: true
      builds: true
      containerRegistry: true
    webhookTimeout:
    gravatar:
      plainUrl:
      sslUrl:
    extra:
      googleAnalyticsId:
      matomoUrl:
      matomoSiteId:
      matomoDisableCookies:
      oneTrustId:
      googleTagManagerNonceId:
      bizible:
    object_store:
      enabled: false
      proxy_download: true
      storage_options: {}
      connection: {}
    lfs:
      enabled: true
      proxy_download: true
      bucket: git-lfs
      connection: {}
    artifacts:
      enabled: true
      proxy_download: true
      bucket: gitlab-artifacts
      connection: {}
    uploads:
      enabled: true
      proxy_download: true
      bucket: gitlab-uploads
      connection: {}
    packages:
      enabled: true
      proxy_download: true
      bucket: gitlab-packages
      connection: {}
    externalDiffs:
      enabled:
      when:
      proxy_download: true
      bucket: gitlab-mr-diffs
      connection: {}
    terraformState:
      enabled: false
      bucket: gitlab-terraform-state
      connection: {}
    ciSecureFiles:
      enabled: false
      bucket: gitlab-ci-secure-files
      connection: {}
    dependencyProxy:
      enabled: false
      bucket: gitlab-dependency-proxy
      connection: {}
    backups:
      bucket: gitlab-backups
    microsoft_graph_mailer:
      enabled: false
      user_id: "YOUR-USER-ID"
      tenant: "YOUR-TENANT-ID"
      client_id: "YOUR-CLIENT-ID"
      client_secret:
        secret:
        key: secret
      azure_ad_endpoint: "https://login.microsoftonline.com"
      graph_endpoint: "https://graph.microsoft.com"
    incomingEmail:
      enabled: false
      address: ""
      host: "imap.gmail.com"
      port: 993
      ssl: true
      startTls: false
      user: ""
      password:
        secret:
        key: password
      mailbox: inbox
      idleTimeout: 60
      inboxMethod: "imap"
      clientSecret:
        key: secret
      pollInterval: 60
      deliveryMethod: webhook
      authToken: {}

    serviceDeskEmail:
      enabled: false
      address: ""
      host: "imap.gmail.com"
      port: 993
      ssl: true
      startTls: false
      user: ""
      password:
        secret:
        key: password
      mailbox: inbox
      idleTimeout: 60
      inboxMethod: "imap"
      clientSecret:
        key: secret
      pollInterval: 60
      deliveryMethod: webhook
      authToken: {}

    cron_jobs: {}
    sentry:
      enabled: false
      dsn:
      clientside_dsn:
      environment:
    gitlab_docs:
      enabled: false
      host: ""
    smartcard:
      enabled: false
      CASecret:
      clientCertificateRequiredHost:
    sidekiq:
      routingRules: []
```

### 一般的なアプリケーション設定

Railsアプリケーションの一般的なプロパティを微調整するために使用できる`appConfig`設定について、以下に説明します。

| 名前                                | 型    | デフォルト | 説明 |
|:----------------------------------- |:-------:|:------- |:----------- |
| `cdnHost`                           | 文字列  | （空） | 静的資産を処理するための、CDNのベースURLを設定します（`https://mycdnsubdomain.fictional-cdn.com`など）。 |
| `contentSecurityPolicy`             | 構造体  |         | [下記を参照](#content-security-policy)。 |
| `enableUsagePing`                   | ブール値 | `true`  | [pingの使用のサポート](https://docs.gitlab.com/administration/settings/usage_statistics/)を無効にするフラグ。 |
| `enableSeatLink`                    | ブール値 | `true`  | [シートリンクのサポート](https://docs.gitlab.com/subscriptions/#seat-link)を無効にするフラグ。 |
| `enableImpersonation`               |         | `nil`   | [管理者によるユーザーの代理](https://docs.gitlab.com/api/#disable-impersonation)を無効にするフラグ。 |
| `applicationSettingsCacheSeconds`   | 整数 | 60      | [アプリケーション設定キャッシュ](https://docs.gitlab.com/administration/application_settings_cache/)を無効にする間隔の値（秒単位）。 |
| `usernameChangingEnabled`           | ブール値 | `true`  | ユーザーがユーザー名を変更できるかどうかを決定するフラグ。 |
| `issueClosingPattern`               | 文字列  | （空） | [イシューを自動的にクローズするパターン](https://docs.gitlab.com/administration/issue_closing_pattern/)。 |
| `defaultTheme`                      | 整数 |         | [GitLabインスタンスのデフォルトテーマの数値ID](https://gitlab.com/gitlab-org/gitlab-foss/blob/master/lib/gitlab/themes.rb#L17-27)。テーマのIDを示す数値を指定します。 |
| `defaultColorMode`                  | 整数 |         | [GitLabインスタンスのデフォルトのカラーモード](https://gitlab.com/gitlab-org/gitlab/-/blob/66788a1de8c3dd3c5566d0f30fe1c2a1bae64bf9/lib/gitlab/color_modes.rb#L17-19)。カラーモードのIDを示す数値を指定します。 |
| `defaultSyntaxHighlightingTheme`    | 整数 |         | [GitLabインスタンスのデフォルトの構文ハイライトテーマ](https://gitlab.com/gitlab-org/gitlab/-/blob/66788a1de8c3dd3c5566d0f30fe1c2a1bae64bf9/lib/gitlab/color_schemes.rb#L12-17)。構文ハイライトテーマのIDを示す数値を指定します。 |
| `defaultProjectsFeatures.*feature*` | ブール値 | `true`  | [下記を参照](#defaultprojectsfeatures)。 |
| `webhookTimeout`                    | 整数 | （空） | [フックが失敗したと見なされる](https://docs.gitlab.com/user/project/integrations/webhooks/#webhook-fails-or-multiple-webhook-requests-are-triggered)までの待機時間（秒単位）。 |
| `graphQlTimeout`                    | 整数 | （空） | Railsが[GraphQLリクエストを完了](https://docs.gitlab.com/api/graphql/#limits)するまでの時間（秒単位）。 |

#### コンテンツセキュリティポリシー

コンテンツセキュリティポリシー（CSP）を設定することは、JavaScriptクロスサイトスクリプティング（XSS）攻撃を阻止するのに役立ちます。設定の詳細については、GitLabドキュメントを参照してください。[コンテンツセキュリティポリシーのドキュメント](https://docs.gitlab.com/omnibus/settings/configuration/#set-a-content-security-policy)

CSPの安全なデフォルト値は、GitLabにより自動的に提供されます。

```yaml
global:
  appConfig:
    contentSecurityPolicy:
      enabled: true
      report_only: false
```

カスタムCSPを追加するには、次のようにします。

```yaml
global:
  appConfig:
    contentSecurityPolicy:
      enabled: true
      report_only: false
      directives:
        default_src: "'self'"
        script_src: "'self' 'unsafe-inline' 'unsafe-eval' https://www.recaptcha.net https://apis.google.com"
        frame_ancestors: "'self'"
        frame_src: "'self' https://www.recaptcha.net/ https://content.googleapis.com https://content-compute.googleapis.com https://content-cloudbilling.googleapis.com https://content-cloudresourcemanager.googleapis.com"
        img_src: "* data: blob:"
        style_src: "'self' 'unsafe-inline'"
```

CSPルールを不適切に設定すると、GitLabが正常に動作しなくなる可能性があります。ポリシーを実際に展開していく前に、`report_only`を`true`に変更して設定をテストするとよいかもしれません。

#### defaultProjectsFeatures

新規プロジェクト作成時に、対応する各機能をデフォルトで有効にするかどうかを決定するフラグ。どのフラグもデフォルトは`true`です。

```yaml
defaultProjectsFeatures:
  issues: true
  mergeRequests: true
  wiki: true
  snippets: true
  builds: true
  containerRegistry: true
```

### Gravatar/Libravatarの設定

デフォルトの場合、チャートはgravatar.comで利用可能なGravatarアバターサービスと連携します。とはいえ、必要に応じてカスタムLibravatarサービスも使用できます:

| 名前                | 型   | デフォルト | 説明 |
|:------------------- |:------:|:------- |:----------- |
| `gravatar.plainURL` | 文字列 | （空） | [LibravatarインスタンスのHTTP URL（gravatar.comの使用に代わるもの）](https://docs.gitlab.com/administration/libravatar/)。 |
| `gravatar.sslUrl`   | 文字列 | （空） | [LibravatarインスタンスのHTTPS URL（gravatar.comの使用に代わるもの）](https://docs.gitlab.com/administration/libravatar/)。 |

### GitLabインスタンスに対するAnalyticsサービスのフック

Google AnalyticsやMatomoなどのAnalyticsサービス設定は、`appConfig`の下の`extra`キーで定義されています。

| 名前                      | 型   | デフォルト | 説明 |
|:------------------------- |:------:|:------- |:----------- |
| `extra.googleAnalyticsId` | 文字列 | （空） | Google AnalyticsのトラッキングID。 |
| `extra.matomoSiteId`       | 文字列 | （空） | MatomoサイトID。 |
| `extra.matomoUrl`          | 文字列 | （空） | Matomo URL。 |
| `extra.matomoDisableCookies`| ブール値 | （空） | Matomoクッキーを無効にする（Matomoスクリプトの`disableCookies`に対応） |
| `extra.oneTrustId`         | 文字列 | （空） | OneTrust ID。 |
| `extra.googleTagManagerNonceId` | 文字列 | （空） | GoogleタグマネージャーID。 |
| `extra.bizible`            | ブール値 | `false` | Bizibleスクリプトを有効にする場合はtrueに設定 |

### 統合されたオブジェクトストレージ

オブジェクトストレージの個々の設定方法について説明する以下のセクションに加えて、これらの項目の共有設定を使いやすくするため、統合されたオブジェクトストレージ設定が追加されました。`object_store`を利用すると、`connection`を1回設定するだけで、オブジェクトストレージでサポートされる機能のうち、`connection`プロパティでは個別に設定されないものすべてに対してそれが使用されるようになります。

```yaml
  enabled: true
  proxy_download: true
  storage_options:
  connection:
    secret:
    key:
```

| 名前             | 型    | デフォルト | 説明 |
|:---------------- |:-------:|:------- |:----------- |
| `enabled`        | ブール値 | `false`  | 統合されたオブジェクトストレージの使用を有効にします。 |
| `proxy_download` | ブール値 | `true`  | GitLab経由のすべてのダウンロードについて、`bucket`から直接ダウンロードする代わりにプロキシを有効にします。 |
| `storage_options`| 文字列  | `{}`    | [下記を参照](#storage_options)。 |
| `connection`     | 文字列  | `{}`    | [下記を参照](#connection)。 |

プロパティの構造は共有されており、ここに示されているすべてのプロパティは、以下の個々の項目によってオーバーライドできます。`connection`プロパティの構造は同じです。

**注意：**デフォルト以外の値を使用する場合に、項目ごとに（`global.appConfig.artifacts.bucket`など）設定する必要があるのは、`bucket`、`enabled`、`proxy_download`のプロパティだけです。

[接続](#connection)に`AWS`プロバイダー（内蔵MinIOなどのS3互換プロバイダー）を使用する場合、GitLab Workhorseにより、ストレージ関連のすべてのアップロードをオフロードできます。この統合設定を使用する場合、これは自動的に有効になります。

### バケットを指定する

オブジェクトは、タイプごとに異なるバケットに格納する必要があります。デフォルトの場合、GitLabがタイプごとに使用するバケット名は次のとおりです。

| オブジェクトタイプ                  | バケット名               |
| ---------------------------- | ------------------------- |
| CIアーティファクト                 | `gitlab-artifacts`        |
| Git LFS                      | `git-lfs`                 |
| パッケージ                     | `gitlab-packages`         |
| アップロード                      | `gitlab-uploads`          |
| 外部マージリクエストの差分 | `gitlab-mr-diffs`         |
| Terraform状態              | `gitlab-terraform-state`  |
| CIセキュアファイル              | `gitlab-ci-secure-files`  |
| 依存プロキシ             | `gitlab-dependency-proxy` |
| Pages                        | `gitlab-pages`            |

これらのデフォルトを使用するか、またはバケット名を設定することができます。

```shell
--set global.appConfig.artifacts.bucket=<BUCKET NAME> \
--set global.appConfig.lfs.bucket=<BUCKET NAME> \
--set global.appConfig.packages.bucket=<BUCKET NAME> \
--set global.appConfig.uploads.bucket=<BUCKET NAME> \
--set global.appConfig.externalDiffs.bucket=<BUCKET NAME> \
--set global.appConfig.terraformState.bucket=<BUCKET NAME> \
--set global.appConfig.ciSecureFiles.bucket=<BUCKET NAME> \
--set global.appConfig.dependencyProxy.bucket=<BUCKET NAME>
```

#### storage_options

`storage_options`は、[S3サーバー側の暗号化](https://docs.gitlab.com/administration/object_storage/#server-side-encryption-headers)を設定するために使用されます。

暗号化を有効にする最も簡単な方法はS3バケットでデフォルトの暗号化を設定することですが、[暗号化されたオブジェクトだけがアップロードされるようにバケットポリシーを設定する](https://repost.aws/knowledge-center/s3-bucket-store-kms-encrypted-objects)こともできます。そのためには、`storage_options`設定セクションで適切な暗号化ヘッダーを送信するようにGitLabを設定する必要があります。

|            設定                  | 説明 |
|-------------------------------------|-------------|
| `server_side_encryption`            | 暗号化モード（`AES256`または`aws:kms`） |
| `server_side_encryption_kms_key_id` | Amazonリソース名。これが必要になるのは`server_side_encryption`で`aws:kms`を使用する場合だけです。[KMS暗号化の使用に関するAmazonドキュメント](https://docs.aws.amazon.com/AmazonS3/latest/userguide/UsingKMSEncryption.html)を参照してください |

例：

```yaml
  enabled: true
  proxy_download: true
  connection:
    secret: gitlab-rails-storage
    key: connection
  storage_options:
    server_side_encryption: aws:kms
    server_side_encryption_kms_key_id: arn:aws:kms:us-west-2:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab
```

### LFS、アーティファクト、アップロード、パッケージ、外部MR差分、および依存プロキシ

これらの設定の詳細を以下に示します。`bucket`プロパティのデフォルト値を除けば、構造的に同じなので、ドキュメントを個別に繰り返すことはしません。

```yaml
  enabled: true
  proxy_download: true
  bucket:
  connection:
    secret:
    key:
```

| 名前             | 型    | デフォルト | 説明 |
|:---------------- |:-------:|:------- |:----------- |
| `enabled`        | ブール値 | LFS、アーティファクト、アップロード、およびパッケージのデフォルトは`true`  | オブジェクトストレージでこれらの機能の使用を有効にします。 |
| `proxy_download` | ブール値 | `true`  | GitLab経由のすべてのダウンロードについて、`bucket`から直接ダウンロードする代わりにプロキシを有効にします。 |
| `bucket`         | 文字列  | さまざま | オブジェクトストレージプロバイダーから使用するバケットの名前。サービスに応じて、デフォルトは`git-lfs`、`gitlab-artifacts`、`gitlab-uploads`、`gitlab-packages`のどれかになります。 |
| `connection`     | 文字列  | `{}`    | [下記を参照](#connection)。 |

#### connection（接続）

`connection`プロパティは、Kubernetes Secretに移行されました。このシークレットの内容は、YAML形式のファイルでなければなりません。デフォルトは`{}`であり、`global.minio.enabled`が`true`の場合は無視されます。

このプロパティには、`secret`と`key`の2つのサブキーがあります:

- `secret`はKubernetes Secretの名前です。外部オブジェクトストレージを使用するには、この値が必要です。
- `key`は、YAMLブロックが含まれるシークレット内でのキーの名前です。デフォルトは`connection`です。

有効な設定キーについては、[GitLabジョブアーティファクトの管理](https://docs.gitlab.com/administration/cicd/secure_files/#s3-compatible-connection-settings)のドキュメントに記載されています。これは[Fog](https://github.com/fog/fog.github.com)に対応しており、プロバイダーモジュールに応じて異なります。

[AWS](https://fog.github.io/storage/#using-amazon-s3-and-fog)と[Google](https://fog.github.io/storage/#google-cloud-storage)プロバイダーの場合の例が、[`examples/objectstorage`](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/objectstorage)にあります。

- [`rails.s3.yaml`](https://gitlab.com/gitlab-org/charts/gitlab/-/blob/master/examples/objectstorage/rails.s3.yaml)
- [`rails.gcs.yaml`](https://gitlab.com/gitlab-org/charts/gitlab/-/blob/master/examples/objectstorage/rails.gcs.yaml)
- [`rails.azurerm.yaml`](https://gitlab.com/gitlab-org/charts/gitlab/-/blob/master/examples/objectstorage/rails.azurerm.yaml)

`connection`の内容を含むYAMLファイルを作成したら、このファイルを使用してKubernetesにシークレットを作成します。

```shell
kubectl create secret generic gitlab-rails-storage \
    --from-file=connection=rails.yaml
```

#### when（外部MR差分のみ）

`externalDiffs`の設定には、[オブジェクトストレージに特定の差分を条件付きで保存する](https://docs.gitlab.com/administration/merge_request_diffs/#alternative-in-database-storage)ための追加キー`when`があります。Railsコードによってデフォルト値が割り当てられるようにするため、チャートではこの設定がデフォルトで空のままになっています。

#### CDN（CIアーティファクトのみ）

`artifacts`の設定には、[Google Cloud Storageバケットより前にGoogle CDNを設定する](../advanced/external-object-storage/_index.md#google-cloud-cdn)ための追加キー`cdn`があります。

### 受信メールの設定

受信メールの設定については、[コマンドラインオプション](../installation/command-line-options.md#incoming-email-configuration)のページで説明されています。

### KASの設定

#### カスタムシークレット

オプションとして、KAS `secret`の名前と`key`をカスタマイズできます。そのためには、以下のようにしてHelmの`--set variable`オプションを使用するか、

```shell
--set global.appConfig.gitlab_kas.secret=custom-secret-name \
--set global.appConfig.gitlab_kas.key=custom-secret-key \
```

または、`values.yaml`を以下のように設定します。

```yaml
global:
  appConfig:
    gitlab_kas:
      secret: "custom-secret-name"
      key: "custom-secret-key"
```

シークレット値をカスタマイズする場合は、[シークレットに関するドキュメント](../installation/secrets.md#gitlab-kas-secret)を参照してください。

#### カスタムURL

GitLabバックエンドでKASに使用されるURLは、Helmの`--set variable`オプションを使用してカスタマイズできます。

```shell
--set global.appConfig.gitlab_kas.externalUrl="wss://custom-kas-url.example.com" \
--set global.appConfig.gitlab_kas.internalUrl="grpc://custom-internal-url" \
--set global.appConfig.gitlab_kas.clientTimeoutSeconds=10 # Optional, default is 5 seconds
```

または、`values.yaml`を以下のように設定します。

```yaml
global:
  appConfig:
    gitlab_kas:
      externalUrl: "wss://custom-kas-url.example.com"
      internalUrl: "grpc://custom-internal-url"
      clientTimeoutSeconds: 10 # Optional, default is 5 seconds
```

#### 外部KAS

外部KASサーバー（チャートによって管理されていないもの）は、それを明示的に有効にして必要なURLを設定することにより、GitLabバックエンドに認識させることができます。そのためには、以下のようにしてHelmの`--set variable`オプションを使用するか、

```shell
--set global.appConfig.gitlab_kas.enabled=true \
--set global.appConfig.gitlab_kas.externalUrl="wss://custom-kas-url.example.com" \
--set global.appConfig.gitlab_kas.internalUrl="grpc://custom-internal-url" \
--set global.appConfig.gitlab_kas.clientTimeoutSeconds=10 # Optional, default is 5 seconds
```

または、`values.yaml`を以下のように設定します。

```yaml
global:
  appConfig:
    gitlab_kas:
      enabled: true
      externalUrl: "wss://custom-kas-url.example.com"
      internalUrl: "grpc://custom-internal-url"
      clientTimeoutSeconds: 10 # Optional, default is 5 seconds
```

#### TLSの設定

KASでは、その`kas`ポッドと他のGitLabチャートコンポーネントとの間のTLS通信がサポートされています。

前提要件：

- [GitLab 15.5.1以降](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/101571#note_1146419137)を使用する。GitLabのバージョンは、`global.gitlabVersion: <version>`で設定できます。最初のデプロイ後にイメージを強制的に更新する必要がある場合は、`global.image.pullPolicy: Always`も設定します。
- `kas`ポッドが信頼する[公開認証局（CA）を作成](../advanced/internal-tls/_index.md)し、証明書を作成します。

作成した証明書を使用するように`kas`を設定するため、次の値を設定します。

| 値                                    | 説明                                                                      |
|------------------------------------------|----------------------------------------------------------------------------------|
| `global.kas.tls.enabled`                 | 証明書のボリュームをマウントし、`kas`エンドポイントへのTLS通信を有効にします。 |
| `global.kas.tls.secretName`    | どのKubernetes TLSシークレットに証明書を保存するかを指定します。                  |
| `global.kas.tls.caSecretName`    | どのKubernetes TLSシークレットにカスタムCAを保存するかを指定します。                     |

たとえば、チャートをデプロイするには、`values.yaml`ファイルで以下を使用することができます。

```yaml
.internal-ca: &internal-ca gitlab-internal-tls-ca # The secret name you used to share your TLS CA.
.internal-tls: &internal-tls gitlab-internal-tls # The secret name you used to share your TLS certificate.

global:
  certificates:
    customCAs:
    - secret: *internal-ca
  hosts:
    domain: gitlab.example.com # Your gitlab domain
  kas:
    tls:
      enabled: true
      secretName: *internal-tls
      caSecretName: *internal-ca
```

### レビュアーの推奨設定

{{< alert type="note" >}}

レビュアーの推奨シークレットは自動的に作成され、GitLab.comでのみ使用されます。このシークレットは、GitLab Self-Managedインスタンスでは不要です。

{{< /alert >}}

オプションとして、レビュアーの推奨の`secret`の名前と`key`をカスタマイズできます。そのためには、以下のようにしてHelmの`--set variable`オプションを使用するか、

```shell
--set global.appConfig.suggested_reviewers.secret=custom-secret-name \
--set global.appConfig.suggested_reviewers.key=custom-secret-key \
```

または、`values.yaml`を以下のように設定します。

```yaml
global:
  appConfig:
    suggested_reviewers:
      secret: "custom-secret-name"
      key: "custom-secret-key"
```

シークレット値をカスタマイズする場合は、[シークレットに関するドキュメント](../installation/secrets.md#gitlab-suggested-reviewers-secret)を参照してください。

### LDAP

`ldap.servers`の設定により、[LDAP](https://docs.gitlab.com/administration/auth/ldap/)ユーザー認証を設定できます。これはマップとして提示され、ソースからのインストールと同じようにして、`gitlab.yml`の中の適切なLDAPサーバー設定に変換されます。

パスワードを設定するには、パスワードを保持する`secret`を指定します。このパスワードは、実行時にGitLabの設定に挿入されます。

設定スニペットの例：

```yaml
ldap:
  preventSignin: false
  servers:
    # 'main' is the GitLab 'provider ID' of this LDAP server
    main:
      label: 'LDAP'
      host: '_your_ldap_server'
      port: 636
      uid: 'sAMAccountName'
      bind_dn: 'cn=administrator,cn=Users,dc=domain,dc=net'
      base: 'dc=domain,dc=net'
      password:
        secret: my-ldap-password-secret
        key: the-key-containing-the-password
```

グローバルチャートを使用する場合の`--set`設定項目の例：

```shell
--set global.appConfig.ldap.servers.main.label='LDAP' \
--set global.appConfig.ldap.servers.main.host='your_ldap_server' \
--set global.appConfig.ldap.servers.main.port='636' \
--set global.appConfig.ldap.servers.main.uid='sAMAccountName' \
--set global.appConfig.ldap.servers.main.bind_dn='cn=administrator\,cn=Users\,dc=domain\,dc=net' \
--set global.appConfig.ldap.servers.main.base='dc=domain\,dc=net' \
--set global.appConfig.ldap.servers.main.password.secret='my-ldap-password-secret' \
--set global.appConfig.ldap.servers.main.password.key='the-key-containing-the-password'
```

{{< alert type="note" >}}

Helmの`--set`項目の中で、カンマは[特殊文字](https://helm.sh/docs/intro/using_helm/#the-format-and-limitations-of---set)と見なされます。`bind_dn`などの値では、カンマをエスケープしてください（例：`--set global.appConfig.ldap.servers.main.bind_dn='cn=administrator\,cn=Users\,dc=domain\,dc=net'`）。

{{< /alert >}}

#### LDAP Webサインインを無効にする

SAMLなどの代替手段が望ましいなら、Web UIを通じてLDAP認証情報を使用しないようにすると便利な場合があります。これにより、グループ同期にLDAPを使用しつつ、SAML Identity Providerがカスタム2FAなどの追加チェックを処理できるようになります。

LDAP Webサインインが無効になっている場合、ユーザーのサインインページにLDAPタブが表示されません。その場合も、[GitアクセスにLDAP認証情報を使用する](https://docs.gitlab.com/administration/auth/ldap/#git-password-authentication)ことが無効になるわけではありません。

WebサインインにLDAPを使用することを無効にするには、`global.appConfig.ldap.preventSignin: true`を設定します。

#### カスタムCAまたは自己署名LDAP証明書の使用

LDAPサーバーでカスタムCAまたは自己署名証明書を使用する場合は、以下を実行する必要があります。

1. カスタムCA/自己署名証明書がクラスター/ネームスペース内のシークレットまたはConfigMapとして作成されていることを確認します。

   ```shell
   # Secret
   kubectl -n gitlab create secret generic my-custom-ca-secret --from-file=unique_name.crt=my-custom-ca.pem

   # ConfigMap
   kubectl -n gitlab create configmap my-custom-ca-configmap --from-file=unique_name.crt=my-custom-ca.pem
   ```

1. その上で、以下を指定します。

   ```shell
   # Configure a custom CA from a Secret
   --set global.certificates.customCAs[0].secret=my-custom-ca-secret

   # Or from a ConfigMap
   --set global.certificates.customCAs[0].configMap=my-custom-ca-configmap

   # Configure the LDAP integration to trust the custom CA
   --set global.appConfig.ldap.servers.main.ca_file=/etc/ssl/certs/unique_name.pem
   ```

これにより、CA証明書が`/etc/ssl/certs/unique_name.pem`の関連するポッドにマウントされ、LDAP設定でそれを使用することが指定されます。

{{< alert type="note" >}}

GitLab 15.9以降、`/etc/ssl/certs/`の証明書に`ca-cert-`のプレフィックスが付くことはなくなりました。そのようになっていたのは、デプロイ済みポッドの証明書シークレットを準備したコンテナ用にAlpineを使用したことによる古い動作です。現在では、この操作にDebianに基づく`gitlab-base`コンテナが使用されるようになっています。

{{< /alert >}}

詳細については、[カスタム公開認証局（CA）](#custom-certificate-authorities)を参照してください。

### DuoAuth

[GitLab Duoで2要素認証（2FA）を有効にする](https://docs.gitlab.com/user/profile/account/two_factor_authentication/#enable-one-time-password)には、以下の設定を使用します。

```yaml
global:
  appConfig:
    duoAuth:
      enabled:
      hostname:
      integrationKey:
      secretKey:
      #  secret:
      #  key:
```

| 名前              | 型    | デフォルト | 説明                                |
|:----------------- |:-------:|:------- |:------------------------------------------ |
| `enabled`         | ブール値 | `false` | GitLab Duoとのインテグレーションを有効または無効にする |
| `hostname`        | 文字列  |         | GitLab Duo APIのホスト名                           |
| `integrationKey` | 文字列  |         | GitLab Duo APIインテグレーションキー                    |
| `secretKey`      |         |         | GitLab Duo APIシークレットキー。[シークレットの名前とキーの名前で構成](#configure-the-gitlab-duo-secret-key)されていなければなりません。 |

### GitLab Duoシークレットキーを設定する

GitLab HelmチャートでGitLab Duo認証インテグレーションを設定するには、`global.appConfig.duoAuth.secretKey.secret`の設定の中でGitLab Duo認証secret_key値を含むシークレットを提供する必要があります。

GitLab Duoアカウント`secretKey`を格納するKubernetes Secretオブジェクトを作成するには、コマンドラインから次を実行します。

```shell
kubectl create secret generic <secret_object_name> --from-literal=secretKey=<duo_secret_key_value>
```

### OmniAuth

GitLabでは、OmniAuthを利用することにより、ユーザーがGitHub、Google、その他の一般的なサービスを使用してサインインできるようになっています。詳細については、GitLabの[OmniAuthドキュメント](https://docs.gitlab.com/integration/omniauth/#configure-common-settings)を参照してください。

```yaml
omniauth:
  enabled: false
  autoSignInWithProvider:
  syncProfileFromProvider: []
  syncProfileAttributes: ['email']
  allowSingleSignOn: ['saml']
  blockAutoCreatedUsers: true
  autoLinkLdapUser: false
  autoLinkSamlUser: false
  autoLinkUser: ['openid_connect']
  externalProviders: []
  allowBypassTwoFactor: []
  providers: []
  # - secret: gitlab-google-oauth2
  #   key: provider
  # - name: group_saml
```

| 名前                      | 型    | デフォルト     |
|:------------------------- |:-------:|:----------- |
| `allowBypassTwoFactor`    | ブール値または配列 |   `false` |
| `allowSingleSignOn`       | ブール値または配列   | `['saml']`  |
| `autoLinkLdapUser`        | ブール値 | `false`     |
| `autoLinkSamlUser`        | ブール値 | `false`     |
| `autoLinkUser`            | ブール値または配列 | `false` |
| `autoSignInWithProvider`  |         | `nil`       |
| `blockAutoCreatedUsers`   | ブール値 | `true`      |
| `enabled`                 | ブール値 | `false`     |
| `externalProviders`       |         | `[]`        |
| `providers`               |         | `[]`        |
| `syncProfileAttributes`   |         | `['email']` |
| `syncProfileFromProvider` |         | `[]`        |

#### プロバイダー

`providers`は、ソースからインストールする場合と同じように、`gitlab.yml`の設定に使用されるマップの配列として提示されます。[サポートされているプロバイダー](https://docs.gitlab.com/integration/omniauth/#supported-providers)の利用可能な選択については、GitLabドキュメントを参照してください。デフォルトは`[]`です。

このプロパティには、`secret`と`key`の2つのサブキーがあります。

- `secret`：*（必須）*プロバイダーブロックを含むKubernetes `Secret`の名前。
- `key`：*（オプション）*`Secret`の中で、プロバイダーブロックを含むキーの名前。デフォルトは`provider`

あるいは、プロバイダーに名前以外の設定がない場合、name属性だけを指定した2番目の形式を使うことができます。オプションとして`label`または`icon`の属性も指定できます。対象となるプロバイダーは次のとおりです。

- [`group_saml`](https://docs.gitlab.com/integration/saml/#configure-group-saml-sso-on-a-self-managed-instance)
- [`kerberos`](https://docs.gitlab.com/integration/saml/#configure-group-saml-sso-on-a-self-managed-instance)

[OmniAuthプロバイダー](https://docs.gitlab.com/integration/omniauth/)で説明されているように、これらのエントリの`Secret`にはYAML形式またはJSON形式のブロックが含まれています。このシークレットを作成するには、これらの項目を取得するための適切な手順に従い、YAMLまたはJSONのファイルを作成します。

Google OAuth2の設定例：

```yaml
name: google_oauth2
label: Google
app_id: 'APP ID'
app_secret: 'APP SECRET'
args:
  access_type: offline
  approval_prompt: ''
```

SAML設定の例：

```yaml
name: saml
label: 'SAML'
args:
  assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback'
  idp_cert_fingerprint: 'xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx'
  idp_sso_target_url: 'https://SAML_IDP/app/xxxxxxxxx/xxxxxxxxx/sso/saml'
  issuer: 'https://gitlab.example.com'
  name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:transient'
```

Microsoft Azure OAuth 2.0 OmniAuthプロバイダーの設定例：

```yaml
name: azure_activedirectory_v2
label: Azure
args:
  client_id: '<CLIENT_ID>'
  client_secret: '<CLIENT_SECRET>'
  tenant_id: '<TENANT_ID>'
```

この内容は`provider.yaml`として保存でき、そこからシークレットを作成できます。

```shell
kubectl create secret generic -n NAMESPACE SECRET_NAME --from-file=provider=provider.yaml
```

それが作成されたら、以下に示すように、設定の中にマップを提供することにより`providers`が有効になります。

```yaml
omniauth:
  providers:
    - secret: gitlab-google-oauth2
    - secret: azure_activedirectory_v2
    - secret: gitlab-azure-oauth2
    - secret: gitlab-cas3
```

[グループSAML](https://docs.gitlab.com/integration/saml/#configuring-group-saml-on-a-self-managed-gitlab-instance)の設定例：

```yaml
omniauth:
  providers:
    - name: group_saml
```

グローバルチャートを使用する場合の設定`--set`項目の例：

```shell
--set global.appConfig.omniauth.providers[0].secret=gitlab-google-oauth2 \
```

`--set`引数は使い方が複雑であるため、ユーザーは、YAMLスニペットを使用し、`-f omniauth.yaml`によって`helm`に渡したいと思うかもしれません。

### Cronジョブ関連の設定

Sidekiqには、cronスタイルのスケジュールを使用して定期的に実行されるように設定できるメンテナンスジョブが含まれています。いくつかの例を以下に示します。ジョブのその他の例については、サンプル[`gitlab.yml`](https://gitlab.com/gitlab-org/gitlab/blob/master/config/gitlab.yml.example)の`cron_jobs`と`ee_cron_jobs`のセクションを参照してください。

これらの設定は、Sidekiq、Webサービス（UIにツールチップを表示するため）、およびToolbox（デバッグ目的）のポッドの間で共有されます。

```yaml
global:
  appConfig:
    cron_jobs:
      stuck_ci_jobs_worker:
        cron: "0 * * * *"
      pipeline_schedule_worker:
        cron: "3-59/10 * * * *"
      expire_build_artifacts_worker:
        cron: "*/7 * * * *"
```

### Sentryの設定

これらの設定は、[SentryによるGitLabエラーレポート](https://docs.gitlab.com/omnibus/settings/configuration/#error-reporting-and-logging-with-sentry)を有効にするために使用します。

```yaml
global:
  appConfig:
    sentry:
      enabled:
      dsn:
      clientside_dsn:
      environment:
```

| 名前        | 型    | デフォルト | 説明 |
|:----------- |:-------:|:------- |:----------- |
| `enabled`        | ブール値 | `false`  | インテグレーションを有効または無効にする |
| `dsn`            | 文字列  |        | バックエンドエラーのSentry DSN |
| `clientside_dsn` | 文字列  |        | フロントエンドエラーのSentry DSN |
| `environment`    | 文字列  |        | [Sentry環境](https://docs.sentry.io/concepts/key-terms/environments/)を参照 |

### `gitlab_docs`の設定

これらの設定は、`gitlab_docs`を有効するために使用します。

```yaml
global:
  appConfig:
    gitlab_docs:
      enabled:
      host:
```

| 名前        | 型    | デフォルト | 説明 |
|:----------- |:-------:|:------- |:----------- |
| `enabled`         | ブール値 | `false`  | `gitlab_docs`を有効または無効にする |
| `host`            | 文字列  |  ""        | ドキュメントホスト                       |

### スマートカード認証の設定

```yaml
global:
  appConfig:
    smartcard:
      enabled: false
      CASecret:
      clientCertificateRequiredHost:
      sanExtensions: false
      requiredForGitAccess: false
```

| 名前                            | 型    | デフォルト | 説明                                      |
| :------------------------------ | :-----: | :------ | :----------------------------------------------- |
| `enabled`                       | ブール値 | `false` | スマートカード認証を有効または無効にする       |
| `CASecret`                      | 文字列  |         | CA証明書が含まれるシークレットの名前 |
| `clientCertificateRequiredHost` | 文字列  |         | スマートカード認証に使用するホスト名。デフォルトでは、提供された、または計算によるスマートカードホスト名が使用されます。 |
| `sanExtensions`                 | ブール値 | `false` | ユーザーと証明書を照合するためにSAN拡張機能を使用できるようにします。 |
| `requiredForGitAccess`          | ブール値 | `false` | Gitアクセスのためのスマートカードサインインでブラウザセッションを必須にします。 |

### Sidekiqルーティングルールの設定

GitLabでは、ジョブのスケジュールを設定する前に、ワーカーから目的のキューへのジョブルーティングがサポートされています。Sidekiqクライアントは、設定されたルーティングルールリストに基づいてジョブを照合します。ルールは先頭から順に評価され、特定のワーカーで一致した時点で、そのワーカーの処理は停止されます（最初の一致が優先されます）。ワーカーがどのルールにも一致しない場合、ワーカー名から生成されるキュー名に戻ります。

デフォルトの場合、ルーティングルールは未設定です（または空の配列で示されます）。すべてのジョブは、ワーカー名から生成されるキューにルーティングされます。

ルーティングルールリストは、クエリとそれに対応するキューのタプルを要素とする順序付き配列です。

- クエリは、[ワーカー一致クエリ](https://docs.gitlab.com/administration/sidekiq/processing_specific_job_classes/#worker-matching-query)の構文に従います。
- `<queue_name>`は、[`sidekiq.pods`](gitlab/sidekiq/_index.md#per-pod-settings)で定義されている有効なSidekiqキュー名`sidekiq.pods[].queues`と一致する必要があります。キュー名（queue_name）が`nil`の場合、または空の文字列の場合、ワーカーはワーカー名から生成されるキューにルーティングされます。参考として、[Sidekiq設定の例（フルバージョン）](gitlab/sidekiq/_index.md#full-example-of-sidekiq-configuration)を参照してください。

クエリでは、すべてのワーカーに一致するワイルドカード一致`*`がサポートされています。その結果として、ワイルドカードクエリはリストの最後でなければなりません。そうでない場合、それ以降のルールは無視されます。

```yaml
global:
  appConfig:
    sidekiq:
      routingRules:
      - ["resource_boundary=cpu", "cpu-boundary"]
      - ["feature_category=pages", null]
      - ["feature_category=search", "search"]
      - ["feature_category=memory|resource_boundary=memory", "memory-bound"]
      - ["*", "default"]
```

## Railsの設定

GitLabスイートの大部分はRailsに基づいています。そのため、このプロジェクト内の多くのコンテナはこのスタックで動作します。以下の設定は、それらのコンテナすべてに適用され、個別に設定するのではなく、グローバルに設定するための簡単なアクセス手段となります。

```yaml
global:
  rails:
    bootsnap:
      enabled: true
```

## Workhorseの設定

GitLabスイートのいくつかのコンポーネントは、GitLab Workhorseを介してAPIと通信します。現在、これはWebserviceチャートの一部となっています。これらの設定は、GitLab Workhorseに接続することの必要なすべてのチャートで使用されます。それは、個別に設定するのではなく、グローバルに設定するための簡単なアクセス手段となります。

```yaml
global:
  workhorse:
    serviceName: webservice-default
    host: api.example.com
    port: 8181
```

| 名前        | 型    | デフォルト | 説明 |
| :---------- | :------ | :------ | :---------- |
| serviceName | 文字列  | `webservice-default` | 内部APIトラフィックの宛先となるサービスの名前。リリース名はテンプレートとして設定されるので、含めないでください。`gitlab.webservice.deployments`のエントリと一致する必要があります。[`gitlab/webservice`チャート](gitlab/webservice/_index.md#deployments-settings)を参照 |
| scheme      | 文字列  | `http` | APIエンドポイントのスキーム |
| host        | 文字列  | | APIエンドポイントの完全修飾ホスト名またはIPアドレス。`serviceName`があればそれをオーバーライドします。 |
| port        | 整数 | `8181` | 関連するAPIサーバーのポート番号。 |
| tls.enabled | ブール値 | `false` | `true`に設定すると、WorkhorseのTLSサポートが有効になります。 |

### Bootsnapキャッシュ

Railsコードベースでは、[ShopifyのBootsnap](https://github.com/Shopify/bootsnap) Gemを使用しています。その動作を設定するため、以下の設定が使用されます。

`bootsnap.enabled`は、この機能をアクティブにするかどうかを制御します。デフォルトは`true`です。

テストの結果、Bootsnapを有効にすると、アプリケーションのパフォーマンスが全体として向上することが示されました。プリコンパイル済みキャッシュが利用可能な場合、一部のアプリケーションコンテナでは33％を超えるゲインになります。現時点で、GitLabではコンテナにこのプリコンパイル済みキャッシュが同梱されていないため、「わずか」14％の向上にとどまっています。プリコンパイル済みキャッシュが存在しない場合、このゲインには、各ポッドの初回起動時に小さなIOが多数発生するというコストがかかります。このため、Bootsnapの使用が問題となる環境でBootsnapの使用を無効にする手段が公開されています。

可能な場合は、これを有効にしておくことをお勧めします。

## GitLab Shellを設定する

[GitLab Shell](gitlab/gitlab-shell/_index.md)チャートのグローバル設定には、複数の項目があります。

```yaml
global:
  shell:
    port:
    authToken: {}
    hostKeys: {}
    tcp:
      proxyProtocol: false
```

| 名前                  | 型    | デフォルト | 説明 |
|:--------------------- |:-------:|:------- |:----------- |
| `port`                | 整数 | `22`    | 具体的なドキュメントについては、下記の[ポート](#port)を参照。 |
| `authToken`           |         |         | GitLab Shellチャート固有のドキュメントにある[authToken](gitlab/gitlab-shell/_index.md#authtoken)を参照。 |
| `hostKeys`            |         |         | GitLab Shellチャート固有のドキュメントにある[hostKeys](gitlab/gitlab-shell/_index.md#hostkeyssecret)を参照。 |
| `tcp.proxyProtocol`   | ブール値 | `false` | 具体的なドキュメントについては、下記の[TCPプロキシプロトコル](#tcp-proxy-protocol)を参照。 |

### ポート

IngressがSSHトラフィックを渡すために使用するポートと、GitLabから提供されるSSH URLで使用されるポートは、`global.shell.port`により制御できます。これは、サービスがリッスンするポートと、プロジェクトUIで提供されるSSHクローンURLに反映されます。

```yaml
global:
  shell:
    port: 32022
```

`global.shell.port`と`nginx-ingress.controller.service.type=NodePort`を組み合わせることにより、NGINXコントローラーのServiceオブジェクトのNodePortを設定できます。`nginx-ingress.controller.service.nodePorts.gitlab-shell`が設定されている場合、NGINXのNodePortを設定すると`global.shell.port`がオーバーライドされることに注意してください。

```yaml
global:
  shell:
    port: 32022

nginx-ingress:
  controller:
    service:
      type: NodePort
```

### TCPプロキシプロトコル

SSH Ingressで[プロキシプロトコル](https://www.haproxy.com/blog/use-the-proxy-protocol-to-preserve-a-clients-ip-address)の処理を有効にすると、プロキシプロトコルヘッダーを追加するアップストリームプロキシからの接続を適切に処理できます。それにより、SSHが追加のヘッダーを受信してSSHが損なわれるのを防ぐことができます。

プロキシプロトコルの処理を有効にすることが必要になる環境としてよくあるのは、クラスターへの受信接続を処理するELBでAWSを使用している場合です。そのための適切な設定については、[AWSレイヤ4ロードバランサーの例](https://gitlab.com/gitlab-org/charts/gitlab/-/blob/master/examples/aws/elb-layer4-loadbalancer.yaml)を参照してください。

```yaml
global:
  shell:
    tcp:
      proxyProtocol: true # default false
```

## GitLab Pagesを設定する

他のチャートで使用されるグローバルGitLab Pages設定についてのドキュメントは、`global.pages`キーの下にあります。

```yaml
global:
  pages:
    enabled:
    accessControl:
    path:
    host:
    port:
    https:
    externalHttp:
    externalHttps:
    artifactsServer:
    objectStore:
      enabled:
      bucket:
      proxy_download: true
      connection: {}
        secret:
        key:
    localStore:
      enabled: false
      path:
    apiSecret: {}
      secret:
      key:
    namespaceInPath: false
```

| 名前                            | 型      | デフォルト                    | 説明 |
| :---------------------------    | :-------: | :-------                   | :-----------|
| `enabled`                       | ブール値   | false                      | クラスターにGitLab Pagesチャートをインストールするかどうかを決定します |
| `accessControl`                 | ブール値   | false                      | GitLab Pagesアクセス制御を有効にします |
| `path`                          | 文字列    | `/srv/gitlab/shared/pages` | Pagesデプロイ関連のファイルを保存するパス。注：オブジェクトストレージが使用されるため、デフォルトでは未使用。 |
| `host`                          | 文字列    |                            | Pagesルートドメイン。 |
| `port`                          | 文字列    |                            | UIでPagesのURLを構成するために使用されるポート。設定されていない場合、PagesのHTTPS状況に基づいて80または443がデフォルト値として設定されます。 |
| `https`                         | ブール値   | true                       | GitLab UIにPagesのHTTPS URLを表示するかどうか。`global.hosts.pages.https`と`global.hosts.https`のどちらよりも優先されます。デフォルトの設定はtrueです。 |
| `externalHttp`                  | リスト      | `[]`                       | HTTPリクエストがPagesデーモンに到達するまでのIPアドレスのリスト。カスタムドメインのサポート用。 |
| `externalHttps`                 | リスト      | `[]`                       | HTTPSリクエストがPagesデーモンに到達するまでのIPアドレスのリスト。カスタムドメインのサポート用。 |
| `artifactsServer`               | ブール値   | true                       | GitLab Pagesでアーティファクトの表示を有効にします。|
| `objectStore.enabled`           | ブール値   | true                       | Pagesでオブジェクトストレージの使用を有効にします。 |
| `objectStore.bucket`            | 文字列    | `gitlab-pages`             | Pagesに関連するコンテンツの保存に使用されるバケット |
| `objectStore.connection.secret` | 文字列    |                            | オブジェクトストレージの接続詳細を含むシークレット。 |
| `objectStore.connection.key`    | 文字列    |                            | 接続シークレットのうち、接続の詳細が格納されるキー。 |
| `localStore.enabled`            | ブール値   | false                      | Pagesに関連するコンテンツに（objectStoreではなく）ローカルストレージを使用できるようにします |
| `localStore.path`               | 文字列    | `/srv/gitlab/shared/pages` | Pagesのファイル保存先のパス。localStoreがtrueに設定されている場合にのみ使用されます。 |
| `apiSecret.secret`              | 文字列    |                            | Base64エンコード形式の32ビットAPIキーを内容とするシークレット。 |
| `apiSecret.key`                 | 文字列    |                            | APIキーシークレットのうち、APIキーが格納されるキー。 |
| `namespaceInPath`               | ブール値   | false                      | （ベータ版）ワイルドカードなしでのDNS設定をサポートするため、URLパスでのネームスペースを有効または無効にします。詳細については、[PagesドメインのワイルドカードなしDNSのドキュメント](gitlab/gitlab-pages/_index.md#pages-domain-without-wildcard-dns)を参照してください。 |

## Webサービスの設定

（他のチャートでも使用される）Webサービスのグローバル設定についてのドキュメントは、`global.webservice`キーの下にあります。

```yaml
global:
  webservice:
    workerTimeout: 60
```

### workerTimeout

WebサービスワーカープロセスがWebサービスマスタープロセスによって強制終了されるまでのリクエストタイムアウト（秒単位）を設定します。デフォルト値は60秒です。

`global.webservice.workerTimeout`の設定は、最大リクエスト時間には影響しません。最大リクエスト時間を設定するには、次の環境変数を設定します。

```yaml
gitlab:
  webservice:
    workerTimeout: 60
    extraEnv:
      GITLAB_RAILS_RACK_TIMEOUT: "60"
      GITLAB_RAILS_WAIT_TIMEOUT: "90"
```

## カスタム公開認証局（CA）

{{< alert type="note" >}}

これらの設定は、`requirements.yaml`を介したこのリポジトリ外からのチャートには影響しません。

{{< /alert >}}

一部のユーザーは、TLSサービス用に内部発行のSSL証明書を使用する場合などに、カスタム公開認証局（CA）を追加することが必要になるかもしれません。この機能を提供するため、シークレットまたはConfigMapにより、アプリケーションでこれらのカスタムルート公開認証局（CA）を採用するメカニズムが用意されています。

シークレットまたはConfigMapを作成するには、次のようにします。

```shell
# Create a Secret from a certificate file
kubectl create secret generic secret-custom-ca --from-file=unique_name.crt=/path/to/cert

# Create a ConfigMap from a certificate file
kubectl create configmap cm-custom-ca --from-file=unique_name.crt=/path/to/cert
```

シークレットまたはConfigMap（またはその両方）を設定するには、グローバルでそれらを指定します。

```yaml
global:
  certificates:
    customCAs:
      - secret: secret-custom-CAs           # Mount all keys of a Secret
      - secret: secret-custom-CAs           # Mount only the specified keys of a Secret
        keys:
          - unique_name.crt
      - configMap: cm-custom-CAs            # Mount all keys of a ConfigMap
      - configMap: cm-custom-CAs            # Mount only the specified keys of a ConfigMap
        keys:
          - unique_name_1.crt
          - unique_name_2.crt
```

{{< alert type="note" >}}

シークレットのキー名に含まれる`.crt`拡張子は、[Debian update-ca-certificatesパッケージ](https://manpages.debian.org/bullseye/ca-certificates/update-ca-certificates.8.en.html)にとって重要です。この手順を実行すれば、カスタムCAファイルがその拡張子でマウントされ、証明書initContainersで処理されることが保証されます。以前は、[ドキュメント](https://gitlab.alpinelinux.org/alpine/ca-certificates/-/blob/master/update-ca-certificates.8)の記述とは異なり、証明書ヘルパーイメージがAlpineベースだった場合、実際にはファイル拡張子が必須ではありませんでした。UBIベースの`update-ca-trust`ユーティリティには、同じ要求事項がないと思われます。

{{< /alert >}}

シークレットまたはConfigMapは、任意の数を指定でき、そのそれぞれにPEMエンコードのCA証明書を保持する任意の数のキーを含めることができます。これらは、`global.certificates.customCAs`の下のエントリとして設定します。マウントする特定のキーのリストを示す`keys:`が指定されているのでない限り、すべてのキーがマウントされます。すべてのシークレットおよびConfigMapにわたるマウントされたキーは、いずれも一意でなければなりません。シークレットとConfigMapには任意の方法で名前を付けることができますが、キー名の競合があっては*なりません*。

## アプリケーションリソース

GitLabには、オプションで[Applicationリソース](https://github.com/kubernetes-sigs/application)を含めることができます。これは、クラスター内でGitLabアプリケーションを識別するために作成できます。バージョン`v1beta1`の[Application CRD](https://github.com/kubernetes-sigs/application#installing-the-crd)がすでにクラスターにデプロイされている必要があります。

有効にするには、`global.application.create`を`true`に設定します。

```yaml
global:
  application:
    create: true
```

Google GKE Marketplaceなどの一部の環境においては、ClusterRoleリソースの作成が許可されていません。以下の値を設定することにより、アプリケーションカスタムリソース定義に含まれるClusterRoleのコンポーネントと、クラウドネイティブGitLabに同梱の関連チャートを無効にしてください。

```yaml
global:
  application:
    allowClusterRoles: false
nginx:
  controller:
    scope:
      enabled: true
gitlab-runner:
  rbac:
    clusterWideAccess: false
certmanager:
  install: false
```

## GitLabベースイメージ

GitLab Helmチャートでは、さまざまな初期化タスクのために1つの共通のGitLabベースイメージを使用します。このイメージではUBIビルドがサポートされており、レイヤを他のイメージと共有します。

## サービスアカウント

GitLab Helmチャートでは、カスタム[サービスアカウント](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/)を使用してポッドを実行することができます。これは、`global.serviceAccount`の中で次のように設定します。

```yaml
global:
  serviceAccount:
    enabled: false
    create: true
    annotations: {}
    automountServiceAccountToken: false
    ## Name to be used for serviceAccount, otherwise defaults to chart fullname
    # name:
```

- `global.serviceAccount.enabled`の設定は、各コンポーネントでの`spec.serviceAccountName`を介したServiceAccountへの参照を制御します。
- `global.serviceAccount.create`の設定は、Helmを介したServiceAccountオブジェクトの作成を制御します。
- `global.serviceAccount.name`の設定は、ServiceAccountのオブジェクト名と、各コンポーネントが参照する名前を制御します。
- `global.serviceAccount.automountServiceAccountToken`の設定は、デフォルトのServiceAccountアクセストークンをポッドにマウントする必要があるかどうかを制御します。これは、特定のサイドカーが正常に機能するために必要という場合（Istioなど）を除き、有効にしないようにしてください。

{{< alert type="note" >}}

`global.serviceAccount.create=true`と`global.serviceAccount.name`を一緒に使用しないでください。同じ名前の複数のServiceAccountオブジェクトを作成するようにチャートに指示することになるためです。グローバル名を指定する場合は、代わりに`global.serviceAccount.create=false`を使用します。

{{< /alert >}}

## アノテーション

Deployment、Service、およびIngressの各オブジェクトには、カスタムアノテーション適用できます。

```yaml
global:
  deployment:
    annotations:
      environment: production

  service:
    annotations:
      environment: production

  ingress:
    annotations:
      environment: production
```

## ノードセレクター

カスタム`nodeSelector`をすべてのコンポーネントにグローバルに適用することができます。グローバルのデフォルト値があるなら、各サブチャートで個別にそれをオーバーライドすることもできます。

```yaml
global:
  nodeSelector:
    disktype: ssd
```

{{< alert type="note" >}}

現時点で、外部管理のチャートは、`global.nodeSelector`が考慮されていないため、使用可能なチャート値に基づいて個別に構成することが必要な場合があります。これには、Prometheus、cert-manager、Redisなどが含まれます。

{{< /alert >}}

## ラベル

### 共通ラベル

ラベルは、設定`common.labels`を使用することにより、さまざまなオブジェクトによって作成されるほぼすべてのオブジェクトに適用できます。これは、`global`キーの下、または特定のチャートの設定の下で適用できます。例：

```yaml
global:
  common:
    labels:
      environment: production
gitlab:
  gitlab-shell:
    common:
      labels:
        foo: bar
```

上記の設定例の場合、Helmチャートによってデプロイされるほぼすべてのコンポーネントに、ラベルセット`environment: production`が指定されています。GitLab Shellチャートのすべてのコンポーネントが、ラベルセット`foo: bar`を受け取ることになります。一部のチャートでは、追加のネストが可能です。たとえば、SidekiqチャートとWebservicesチャートでは、設定のニーズに応じて追加のデプロイが可能です。

```yaml
gitlab:
  sidekiq:
    pods:
      - name: pod-0
        common:
          labels:
            baz: bat
```

上記の例の場合、`pod-0` Sidekiqデプロイに関連するすべてのコンポーネントが、ラベルセット`baz: bat`も受け取ることになります。詳細については、SidekiqチャートとWebserviceチャートを参照してください。

ここで利用している一部のチャートは、このラベル設定から除外されています。これらの追加ラベルを受け取るのは、[GitLabコンポーネントのサブチャート](gitlab/_index.md)だけです。

### ポッド

カスタムラベルは、さまざまなデプロイとジョブに適用できます。これらのラベルは、このHelmチャートによって構築される既存のラベルまたは事前設定済みラベルを補完するものです。これらの補足ラベルは、`matchSelectors`では**利用されません**。

```yaml
global:
  pod:
    labels:
      environment: production
```

### サービス

カスタムラベルをサービスに適用することができます。これらのラベルは、このHelmチャートによって構築される既存のラベルまたは事前設定済みラベルを補完するものです。

```yaml
global:
  service:
    labels:
      environment: production
```

## トレーシング

GitLab Helmチャートではトレーシングがサポートされており、それは次のようにして設定できます。

```yaml
global:
  tracing:
    connection:
      string: 'opentracing://jaeger?http_endpoint=http%3A%2F%2Fjaeger.example.com%3A14268%2Fapi%2Ftraces&sampler=const&sampler_param=1'
    urlTemplate: 'http://jaeger-ui.example.com/search?service={{ service }}&tags=%7B"correlation_id"%3A"{{ correlation_id }}"%7D'
```

- `global.tracing.connection.string`は、トレーシングスパンの送信先を設定するために使用します。詳細については、[GitLabトレーシングのドキュメント](https://docs.gitlab.com/development/distributed_tracing/)を参照してください
- `global.tracing.urlTemplate`は、GitLabパフォーマンスバーでのトレーシング情報URLレンダリングのためのテンプレートとして使用します。

## extraEnv

`extraEnv`を使用すると、GitLabチャート（`charts/gitlab/charts`）によりデプロイされるポッド内のすべてのコンテナで、追加の環境変数を公開できます。グローバルレベルで設定された追加の環境変数は、チャートレベルで指定された変数にマージされ、チャートレベルで指定された変数が優先されます。

`extraEnv`の使用例を以下に示します。

```yaml
global:
  extraEnv:
    SOME_KEY: some_value
    SOME_OTHER_KEY: some_other_value
```

## extraEnvFrom

`extraEnvFrom`を使用すると、ポッド内のすべてのコンテナで、他のデータソースからの追加の環境変数を公開できます。追加の環境変数は、`global`レベル（`global.extraEnvFrom`）およびサブチャートレベル（`<subchart_name>.extraEnvFrom`）で設定できます。

SidekiqチャートとWebserviceチャートでは、追加のローカルオーバーライドがサポートされています。詳細については、それぞれのドキュメントを参照してください。

`extraEnvFrom`の使用例を以下に示します。

```yaml
global:
  extraEnvFrom:
    MY_NODE_NAME:
      fieldRef:
        fieldPath: spec.nodeName
    MY_CPU_REQUEST:
      resourceFieldRef:
        containerName: test-container
        resource: requests.cpu
gitlab:
  kas:
    extraEnvFrom:
      CONFIG_STRING:
        configMapKeyRef:
          name: useful-config
          key: some-string
          # optional: boolean
```

{{< alert type="note" >}}

この実装において、異なるコンテンツタイプで値名を再利用することはサポートされていません。同じ名前を類似の内容でオーバーライドすることは可能ですが、`secretKeyRef`や`configMapKeyRef`などのソースが混在しないようにしてください。

{{< /alert >}}

## OAuthの設定

OAuthインテグレーションは、サポートするサービスに合わせてすぐに利用できる設定になっています。`global.oauth`で指定されているサービスは、デプロイ中に、OAuthクライアントアプリケーションとして自動的にGitLabに登録されます。デフォルトでは、アクセス制御が有効になっている場合、このリストにGitLab Pagesが含まれています。

```yaml
global:
  oauth:
    gitlab-pages: {}
    # secret
    # appid
    # appsecret
    # redirectUri
    # authScope
```

| 名前           | 型   | デフォルト | 説明                                                                                            |
| :---           | :--:   | :------ | :----------                                                                                            |
| `secret`       | 文字列 |         | サービスのOAuth認証情報を含むシークレットの名前。                                             |
| `appIdKey`     | 文字列 |         | シークレットのうち、サービスのアプリIDが格納されるキー。設定されるデフォルト値は`appid`です。         |
| `appSecretKey` | 文字列 |         | シークレットのうち、サービスのアプリシークレットが格納されるキー。設定されるデフォルト値は`appsecret`です。 |
| `redirectUri`  | 文字列 |         | 認証が成功した後、ユーザーがリダイレクトされる先のURI。                                 |
| `authScope`    | 文字列 | `api`   | GitLab APIでの認証に使用されるスコープ。                                                         |

シークレットの詳細については、[シークレットのドキュメント](../installation/secrets.md#oauth-integration)を参照してください。

## Kerberos

GitLab HelmチャートでKerberosインテグレーションを設定するには、GitLabホストのサービスプリンシパルを指定したKerberos [keytab](https://web.mit.edu/kerberos/krb5-devel/doc/basic/keytab_def.html)を含むシークレットを、`global.appConfig.kerberos.keytab.secret`設定に指定する必要があります。keytabファイルがない場合は、Kerberos管理者にお問い合わせください。

次のスニペットを使用してシークレットを作成できます（`gitlab`ネームスペースにチャートをインストールしており、サービスプリンシパルを含むkeytabファイルが`gitlab.keytab`であると仮定しています）。

```shell
kubectl create secret generic gitlab-kerberos-keytab --namespace=gitlab --from-file=keytab=./gitlab.keytab
```

GitのKerberosインテグレーションは、`global.appConfig.kerberos.enabled=true`を設定することにより有効になります。これにより、ブラウザでのチケットベース認証のために有効な[OmniAuth](https://docs.gitlab.com/integration/omniauth/)プロバイダーのリストに、`kerberos`プロバイダーも追加されます。

`false`のままにした場合も、Helmチャートは、ツールボックス、Sidekiq、およびWebサービスのポッドに`keytab`をマウントします。それを、Kerberos用に手動で設定された[OmniAuth設定](#omniauth)で使用することができます。

Kerberosクライアントの設定は、`global.appConfig.kerberos.krb5Config`の中で指定できます。

```yaml
global:
  appConfig:
    kerberos:
      enabled: true
      keytab:
        secret: gitlab-kerberos-keytab
        key: keytab
      servicePrincipalName: ""
      krb5Config: |
        [libdefaults]
            default_realm = EXAMPLE.COM
      dedicatedPort:
        enabled: false
        port: 8443
        https: true
      simpleLdapLinkingAllowedRealms:
        - example.com
```

詳細については、[Kerberosのドキュメント](https://docs.gitlab.com/integration/kerberos/)を参照してください。

### Kerberos専用ポート

GitLabでは、Git操作にHTTPプロトコルを使用する場合、認証交換で`negotiate`ヘッダーが含まれていると基本認証にフォールバックするというGitの制限の回避策として、[Kerberosネゴシエーション専用ポート](https://docs.gitlab.com/integration/kerberos/#http-git-access-with-kerberos-token-passwordless-authentication)の使用がサポートされています。

現在のところ、GitLab CI/CDを使用する場合に専用ポートの使用は必須です。GitLab Runnerのヘルパーは、GitLabからのクローン作成で、URL内の認証情報に依存しているためです。

これは、`global.appConfig.kerberos.dedicatedPort`の設定により有効にすることができます。

```yaml
global:
  appConfig:
    kerberos:
      [...]
      dedicatedPort:
        enabled: true
        port: 8443
        https: true
```

これにより、GitLab UIでKerberosネゴシエーション専用の追加クローンURLが有効になります。`https: true`の設定はURL生成専用であり、追加のTLS設定は公開されていません。TLSは、Ingressの中でGitLab用に終端処理され、設定されます。

{{< alert type="note" >}}

[`nginx-ingress` Helmチャートのフォーク](nginx/fork.md)に関する現在の制限のため、現在のところ、`dedicatedPort`を指定しても、チャートの`nginx-ingress`コントローラーで使用するためのポートは公開されません。クラスターのオペレーターが、このポートを自分で公開する必要があります。詳細について、また可能な回避策については、[こちらのチャートイシュー](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/3531)を参照してください。

{{< /alert >}}

### LDAPカスタム許可レルム

ユーザーのLDAP DNがユーザーのKerberosレルムと一致しない場合、LDAPのアイデンティティとKerberosのアイデンティティをリンクするために使用されるドメインのセットを、`global.appConfig.kerberos.simpleLdapLinkingAllowedRealms`により指定できます。詳細については、[Kerberosインテグレーションのドキュメントに含まれるカスタム許可レルムのセクション](https://docs.gitlab.com/integration/kerberos/#custom-allowed-realms)を参照してください。

## 送信メール

送信メールは、`global.smtp.*`、`global.appConfig.microsoft_graph_mailer.*`、および`global.email.*`により設定できます。

```yaml
global:
  email:
    display_name: 'GitLab'
    from: 'gitlab@example.com'
    reply_to: 'noreply@example.com'
  smtp:
    enabled: true
    address: 'smtp.example.com'
    tls: true
    authentication: 'plain'
    user_name: 'example'
    password:
      secret: 'smtp-password'
      key: 'password'
  appConfig:
    microsoft_graph_mailer:
      enabled: false
      user_id: "YOUR-USER-ID"
      tenant: "YOUR-TENANT-ID"
      client_id: "YOUR-CLIENT-ID"
      client_secret:
        secret:
        key: secret
      azure_ad_endpoint: "https://login.microsoftonline.com"
      graph_endpoint: "https://graph.microsoft.com"
```

使用可能な設定オプションの詳細については、[送信メールのドキュメント](../installation/command-line-options.md#outgoing-email-configuration)を参照してください。

[LinuxパッケージSMTP設定のドキュメント](https://docs.gitlab.com/omnibus/settings/smtp/)に、詳しい例が含まれています。

## プラットフォーム

`platform`キーは、GKEやEKSなどの特定のプラットフォームをターゲットとする特定の機能のために予約されています。

## アフィニティ

アフィニティは、`global.antiAffinity`と`global.affinity`により設定できます。アフィニティを使用すると、ノードのラベルまたはノードで既に実行されているポッドのラベルに基づいて、ポッドをスケジュールできるノードを制限できます。これにより、ポッドをクラスター全体に分散させたり、特定のノードを選択したりして、ノードに障害が発生した場合の復元力を高めることができます。

```yaml
global:
  antiAffinity: soft
  affinity:
    podAntiAffinity:
      topologyKey: "kubernetes.io/hostname"
```

| 名前                                   | 型   | デフォルト                   | 説明                         |
| :------------------------------------- | :--:   | :------------------------ | :---------------------------------- |
| `antiAffinity`                         | 文字列 |  `soft`                   | ポッドに適用するポッドアンチアフィニティ。 |
| `affinity.podAntiAffinity.topologyKey` | 文字列 |  `kubernetes.io/hostname` | ポッドアンチアフィニティのトポロジキー。     |

- `global.antiAffinity`には、次の2種類の値が可能です。
  - `soft`：`preferredDuringSchedulingIgnoredDuringExecution`アンチアフィニティを定義します。この場合、Kubernetesスケジューラーが、結果を保証せずにルールの適用を試みます。
  - `hard`：`requiredDuringSchedulingIgnoredDuringExecution`アンチアフィニティを定義します。この場合、ノードに対してスケジュール設定する対象のポッドについて、必ずルールが_満たされていなければなりません_。
- `global.affinity.podAntiAffinity.topologyKey`は、それらを論理ゾーンに分割するために使用されるノード属性を定義します。`topologyKey`の値として最も一般的なものは次のとおりです。
  - `kubernetes.io/hostname`
  - `topology.kubernetes.io/zone`
  - `topology.kubernetes.io/region`

[ポッド間アフィニティとアンチアフィニティ](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity)に関するKubernetesリファレンス

## ポッドの優先度とプリエンプション

ポッドの優先度は、`global.priorityClassName`により、またはサブチャートごとに`priorityClassName`により設定できます。ポッドの優先度を設定すると、保留中のポッドのスケジューリングを可能にするために、優先度の低いポッドを排除するようスケジューラーに対して指示することができます。

```yaml
global:
  priorityClassName: system-cluster-critical
```

| 名前                | 型   | デフォルト | 説明                      |
| :-------------------| :--:   | :------ | :------------------------------- |
| `priorityClassName` | 文字列 |         | ポッドに割り当てられる優先度クラス。 |

## ログローテーション

{{< history >}}

- GitLab 15.6で[導入](https://gitlab.com/gitlab-org/cloud-native/gitlab-logger/-/merge_requests/10)されました。

{{< /history >}}

デフォルトの場合、GitLab Helmチャートはログのローテーションを実施しません。これにより、長時間実行されるコンテナで、一時的なストレージの問題が発生する可能性があります。

ログのローテーションを有効にするには、`GITLAB_LOGGER_TRUNCATE_LOGS`環境変数を`true`に設定します。詳細については、[GitLab Loggerのドキュメント](https://gitlab.com/gitlab-org/cloud-native/gitlab-logger#configuration)を参照してください。特に、以下の情報を参照してください。

- [`GITLAB_LOGGER_TRUNCATE_INTERVAL`](https://gitlab.com/gitlab-org/cloud-native/gitlab-logger#truncate-logs-interval)。
- [`GITLAB_LOGGER_MAX_FILESIZE`](https://gitlab.com/gitlab-org/cloud-native/gitlab-logger#max-log-file-size)。

## ジョブ

元々、GitLabのジョブには、Helmの`.Release.Revision`がサフィックスとして付いていましたが、`helm upgrade --install`を実行すると、何も変更されていなくても、常にジョブが更新されてしまうため、理想的な方法ではありませんでした。また、ArgoCDを使用している場合などに、`helm template`に基づくワークフローでの適切な動作の妨げにもなっていました。名前の中に`.Release.Revision`を使用するという決定は、ジョブが1回しか実行されない可能性があり、かつ`helm uninstall`がジョブを削除しないという前提に基づいていましたが、これは（現在では）間違っています。

GitLab Helmチャート7.9以降では、ジョブ名にチャートのアプリバージョンとチャートの値に基づくハッシュがサフィックスとして付くというのがデフォルトになっており、それに`global.gitlabVersion`も含まれる可能性があります。このアプローチにより、（何も変更されていない場合は）`helm template`および`helm upgrade --install`の複数回の実行にわたって安定してジョブ名が保たれ、ジョブの不変フィールドの値を変更しても（新しい名前のためジョブが新しいジョブに置き換わるだけであり）デプロイ中にエラーが発生しない、ということも可能になります。

`global.job.nameSuffixOverride`を設定することにより、デフォルトで生成されるハッシュを、カスタムサフィックスでオーバーライドすることができます。このフィールドではテンプレート作成がサポートされているため、`.Release.Revision`を名前のサフィックスとして使用する古い動作を再現することができます。

```yaml
global:
  job:
    nameSuffixOverride: '{{ .Release.Revision }}'
```

すべてのバージョンで`latest`のような浮動タグ付けを使用しているなどの理由で、意図的に常に変更をトリガーする場合、デフォルトで生成されるハッシュを、タイムスタンプなどの動的な値でオーバーライドすることができます。

```yaml
global:
  job:
    nameSuffixOverride: '{{ dateInZone "2006-01-02-15-04-05" (now) "UTC" }}'
```

または、コマンドラインで`helm`を使用することもできます。

```shell
helm <command> <options> --set global.job.nameSuffixOverride=$(date +%Y-%m-%d-%H-%M-%S)
```

| 名前                 | 型   | デフォルト | 説明                                               |
| :--------------------| :--:   | :------ | :-------------------------------------------------------- |
| `nameSuffixOverride` | 文字列 |         | 自動的に生成されるハッシュを置き換えるカスタムサフィックス |

## Traefik

Traefikは、`globals.traefik`により設定できます。

```yaml
global:
  traefik:
    apiVersion: ""
```

| 名前         | 型   | デフォルト | 説明                                             |
| :------------| :----- | :------ | :------------------------------------------------------ |
| `apiVersion` | 文字列 |         | Traefikのリソースのデフォルトの`apiVersion`をオーバーライドします |
