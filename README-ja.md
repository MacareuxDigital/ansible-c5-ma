# Ansibleの使い方

-----
Concrete CMS 用に Amazon Linux 2 や CentOS 7 に、 SSH 接続をし、Apache/Nginx, PHP-FPM, MariaDB, MySQL などの設定を自動的に実行してくれるプログラムです。

このスクリプトは仕事をしながら常に更新しているので、 **完全な動作テストを全くしていません。** 必ず、テストインスタンスなどで試してから本番インスタンスで実行してください。

2022年8月時点で、Amazon Linux 2, PHP7.4, Nginx, MariaDB 10.5 をメインに動作確認をしています。

## 準備

事前にPlayBookを実行する端末に、ansibleコマンドのインストールを行います。

- Homebrew

  ```
  $ brew install ansible
  ```

もしくは

- pip

  ```
  $ pip install ansible
  ```

## SSHキーの生成

サーバーで利用するSSHユーザーのSSHキーを [./roles/add_users/files/] 以下に生成します。

ファイル名は、サーバーに設定する[SSHユーザー名.pem]としてください。

サンプルスクリプトでは、SSH ユーザー名を「c5juser」にしていますが、 **必ず別の名前に変えてください。**

- ssh-keygenコマンド

  ```
  ssh-keygen -f ./roles/add_users/files/"USERNAME".pem -C "USERNAME"@localhost
  ```

  ※コマンドを実行すると、[username.pem] [username.pem.pub]ファイルが生成されます。

## サーバーの準備

AWS EC インスタンスや CentOS7 のサーバーを用意

### AWS CloudFormation スクリプト等を実行して EC2 インスタンスを作成し、SSH 接続を確認

- 別途用意してある（まだ非公開） `ec2-simple`  CloudFormation スクリプトを実行し EC2 インスタンスを立ち上げるか、手動で EC2 インスタンスの作成、VPC や Elastic IP 、Route 53 の設定を行ってください。
- 該当する EC2 インスタンスのアクセス用 パブリック IP アドレスを取得してください。
    - 必要に応じてセキュリティグループを編集し IP 制限などを行ってください。
- AWS で設定した `ec2-user` ユーザー用の SSH キーを取得してください。
- SSH 接続ができるか確認してください。

### CentOS サーバーを用意

CentOS 7 のサーバーを用意し、SSH でアクセスできようにして下さい。

## ファイルのファイルの修正

- host.yml と setup.yml を下記を参考に、各項目を修正ください。
    - 特に新しいバージョンの Concrete CMS がリリースされた時など、ZIPファイルを変更したり、コマンドが変更されている場合があるので、確認が必要です。
    - Concrete CMS.org で配布されている ZIP ファイルは「Concrete CMS-バージョン名」というフォルダの中に格納されているのですが、格納している Concrete CMS の ZIP ファイルは、バージョン名のフォルダを含めない形で保存されています。

## デバッグ用: Docker を使ってローカルでテスト

手軽にローカルの Docker でテストランができるデバッグオプションも用意しました。ただし、Docker の制約で、ホスト名変更、SWAPファイル作成、ファイルのアップロード、DB や DB ユーザー作成、サービス (systemcltd) での起動ができないので、必ず、本番環境で設定する前に、実際のサーバーや VM インスタンスでのテスト実行を行ってください。

- host.docker.yml を編集
  - Docker で利用するためのホスト設定ファイル
  - `ansible-test` の部分を自分が立てたコンテナー名に変更してください。
  - `server_name` はオプションです。ただそのままにしてくだしあ。
- "setup.yml"の設定については下記をご覧ください。

```
$ cd [path/to/ansible]
$ ansible-playbook -i host.docker.yml setup.yml
```

## ansible-playBookの実行

```
$ ansible-playbook -i host.yml setup.yml
```

※対象となるサーバーには事前にSSHで接続が可能となることを確認ください。

## DNS 設定なやセキュリティ設定

- Route 53 などの DNS に行き、DNS の設定を行い、ドメインの設定をしてください。
- Web サーバーに、Hosts 設定や、セキュリティグループを編集して、IP アドレスでのアクセス制限などを設定してください。

-----

==============================
設定ファイル詳細
==============================

# host.yml

対象サーバー、ホスト名、SSHの鍵ファイル、SSHユーザー名 (普段であれば ec2-user) を指定します。

- Sample:

  ```
  [servers]
  192.168.0.1 server_name="hoge01.hogehoge.com"
  [all:vars]
  ansible_ssh_user=ec2-user
  ansible_ssh_private_key_file=/PATH/TO/ec2-usr-key.pem
  ```

## [servers] セクション

- IPアドレス

  - 実行対象のサーバーを記載

- server_name=

  - サーバーに割り当てるホスト名を記載

## [all:vars]セクション

- ansible_ssh_user=ec2-user

  - サーバーに接続するSSHユーザー名（root か sudoが可能なユーザー）

- ansible_ssh_private_key_file=

  - クライアントでのSSHキーのパスをしています。

-----

# setup.yml

対象サーバーに設定する値を記載します。

setup.yml の中に書いてあるコメントが一番最新です。ここの Readme の更新はよく遅れます。

## サーバーの言語とタイムゾーンの設定

サーバーの言語とローカルタイムを設定します。 `localectl list-locales` コマンドを使うと使用可能な言語のリストを取得でき、
CentOS 6 系であれば `ls -F /usr/share/zoneinfo` CentOS 7 系であれば `sudo timedatectl list-timezones` を使うと、タイムゾーンのリストを取得できます。

```
  - locale:                 "ja_JP.UTF-8"
  - zone:                   "Asia/Tokyo"
```
## Amazon Linux であるか?

Amazon Linux で AWS 内に設置されているかを指定します。Amazon Linux の場合は「1」、Amazon Linux 2 の場合は「2」、そうでない場合は「no」と入力下さい。

```
  - aws_awslinux:           "1"
  - aws_repo_upgrade:       "yes"


```

## CentOS バージョン

CentOS のバージョンを指定します。Amazon Linux 2017.09 時点では CentOS は 6 を指定して下さい。
Amazon Linux 2 の場合は 7 を入れて下さい

```
# CentOS Version? (6 / 7)
  - centos_version:         "7"
```

## PHP レポジトリ指定 (remi/webtactics/none)

CentOS 向けのみ。追加 PHP レポジトリを指定します。

```
  - centos_phprepo:         "remi"
```

## CentOS Initialize Firewall? (yes / no) Incompleted

`yes` であれば、 `firewalld` をインストールし、http & https ポートを開放します。


```
  - centos_firewall_enable: "yes"
```


## インスタンスタイプ

AWS インスタンスに応じて最適化した Apache & Niginx 設定を行います。同じくらいのスペックの CentOS マシンでも同じです。

```
  - aws_instance_type:       "small"
```

### 利用可能なインスタンス

現時点では、下記の設定のみ利用可能です。

- micro (tx.micro 想定)
- small (tx.small 想定)
- large (mx.large 想定)

## PHP バージョン

どの PHP バージョンを利用したいかを指定してください。現在、4つのレポジトリに対応しているはずです: Amazon Linux, Remi, Webtactics and Amazon Linux 2 (ベータ). 但しレポジトリによってはインストールできないバージョンもあるかもしれません。

Amazon Linux 2 は、PHP5.6 (Apache のみ), PHP 7.2, 7.3, 7.4 の動作確認をしています。 (as of June 2022)

```
## PHP version for yum (php56 / php70 / php71 / php72 / php73 / php74)
  - php_version_yum:        "php72"
## PHP version for Remi (php56 / php70 / php71 / php72 / php73 / php74)
  - php_version_remi:       "php72"
## PHP version for Amazon Linux (5.6 / 7.0 / 7.1 / 7.2 / 7/3)
  - php_version_amznlinux:  "7.2"
## PHP version for Amazon Linux 2 (php56 / php7.1 / php7.2 / php7.3 / php7.4)
  - php_version_amznlinux2:  "php7.3"
```

## 追加するSSHユーザーの指定

- **[if_add_users] : "Yes" で sudo 権限付きの SSH ユーザーを新たに作成します。 `add_users/files` 内に「ユーザー名.pem」という秘密鍵と「ユーザー名.pem.pub」という公開鍵を保存してください。
- **[add_users]** : 作成するSSHユーザー名を記載ください。

サンプルスクリプトでは、SSH ユーザー名を「c5juser」にしていますが、 **必ず別の名前に変えてください。**


  ```
  - add_users:
    - "c5juser"
  ```

複数ユーザーを追加する場合は、下記のように記載ください。
※複数ユーザー分のSSH-Keyの生成も必要です。
  ```
    - add_users:
      - "user01"
      - "user02"
  ```

## ユーザー名, グループ名を指定

Concrete CMS が保存されるディレクトリの所有者ユーザー・グループ、Apache もしくは nginx の実行グループを指定します。

```
- c5dir_user:        "c5juser"
- c5dir_group:       "apache"
```

## 利用するWEBサーバーを選びます
- **[webserver_handle]** : Apache か Nginx　を選択ください。

  `- webserver_handle: "apache"`

## Nginx か Apache ユーザーを SSH ユーザーと同じにするか

  **[webserver_changeowner]** :　yes か no

ネットに公開されていない閉じた安全な環境などで、Apache や php-fpm 実行ユーザーを、SSH ユーザーと同じにすることで CMS が生成するファイルのオーナーを同じにするかしないかの設定をします。

安全のためデフォルトでは「no」になっています。

- `- webserver_changeowner:  "no"`

## Virtual Hostの設定

- **[vhost_domain]** : 設定するドメイン名です。

  `- vhost_domain: "example.com"`

- **[vhost_docroot]** : ドキュメントルートが設定される上位ディレクトリです。

  `- vhost_docroot: "/var/www/vhosts/"`

- **[vhost_htdocs]** : ドキュメントルートが設定されるディレクトリの追加情報です。こちらは空欄でも構いません。

  `- vhost_docroot: "/html"`

- 上記の場合、Apache & Nginx にドメイン名[example.com] & [www.example.com] のバーチャルホストが設定され、ドキュメントルートが [/var/www/vhosts/example.com/html] となります。

## MySQL or MariaDB の選択

**現時点で Amazon Linux のみ MySQL をインストールできます。Cent OS の場合は MariaDB にしか対応していません。**

DB環境を設定します (mariadb / mariadb-client / mysql / mysql-client / none )

    - mariadb: MariaDB のサーバーとクライアントをインストールします
    - mariadb-client: MariaDB のクライアントのみをインストールします。
    - mysql: MySQL のサーバーとクライアントをインストールします
    - mysql-client: MySQL のクライアントのみをインストールします。
    - none: DB のインストールは何も行いません。

```
  - db_environment:         "mariadb"
```

## CentOS にインストールする MySQL や MariaDB のバージョン

CentOS では、どの MySQL バージョンをインストールするか指定できます。
Amazon Linux は MySQL 5.6 だけです。
Amazon Linux は MariaDB を使ってください。

利用可能バージョン: 55 / 56 / 57 / 80.

```
  - mysql_repo:          "57"
```

利用可能バージョン: 5.5,  10.1~5 (これらはテスト済み)
MariaDB 5.5 は CentOS 7 レポジトリ付属のバージョンをインストールします。

```
  - mariadb_repo:           "10.5"
```

利用可能CPUアーキテクチャ: aarch64/ ppc64 / ppc64le / ppc64 / amd64 (x86_64)
aarch64 (ARM) と amd64 (Intel) はテスト済み

```
  - mariadb_arch:           "aarch64"
```

## DB の設定を行うか否か

Ansibleで MySQL ユーザーの作成、DB の作成を行うか設定します。行う場合は、下記の設定値で設定が行われます。 (Amazon Linux 2 ではまだ動きません。)

  - `- db_create:              "no"`


## MySQL or MariaDB の設定

サーバーをインストールするときのみこちらの情報が使われます。

- **[mysql_rootpass]** : MySQLのrootのパスワードを設定します。

  `- mysql_rootpass: "mysql_root_pass"`

- **[mysql_loginhost]** : MySQLが稼働するホストをしてします。通常は変更の必要はありません。

  `- mysql_loginhost: "127.0.0.1"`

- **[mysql_loginuser]** : MySQLにログインするID/パスワードを指定します。通常は変更の必要はありません。

  `- mysql_loginuser: "root"`

- **[mysql_loginpass]** : 前項で設定した[mysql_rootpass]と同じ値にしてください。

  `- mysql_loginpass: "mysql_root_pass"`

## アプリケーション用DBの設定

[mysql_loginuser] などの情報を使ってログインし、下記のデータベースと専用ユーザーを作成します。

- **[mysql_dbname]** : アプリケーション用のDB名を指定します。

  `- mysql_dbname: "dev-c5db"`

- **[mysql_username]** : DB用のMySQLユーザーです。

  `- mysql_username: "dev-c5dbuser"`

- **[mysql_userpass]** : MySQLユーザーのパスワードです。

  `- mysql_userpass: "db-password"`

- **[mysql_userpermitedhost]** : MySQLに接続するホスト名です。通常は変更の必要はありません。

  ```
  - mysql_userpermitedhost:

    - "127.0.0.1"
    - "localhost"
  ```

## Concrete CMS データ移行

既に別の環境で Concrete CMS サイトを構築仕掛けている時に、バックアップファイルを所定のフォーマットの ZIP にまとめてサーバー構築と一緒にデータ移行も一緒にやることが出来ます。

- **[c5_migration]** : 「yes」か「no」

  `- c5_migration: "no"`

- **[c5_backup_zip_filename]** : Concrete CMS バックアップシェルである [Concrete CMS backup shell](https://github.com/katzueno/concrete5-backup-shell) の All オプションを使って作成したバックアップファイルを拡張子なしで指定し、`roles/concrete5_migration/files` 配下に保存して下さい。

  `- c5_backup_zip_filename: "backup_202000000000"`



## Concrete CMSの設定

- **[c5_upload]** : 「yes」か「no」で Concrete CMS をリモートから ZIP を取得して展開します。

  `- c5_upload: "yes"`

- **[c5_package_folder_name]** : Concrete CMS が格納されている ZIP ファイル内のディレクトリ名を入れてください。

  `- c5_package_folder_name: "concrete5-8.5.6"`

- **[c5_package_url]** : 他の場所もしくはバージョンの Concrete CMS をダウンロードするのであれば変更してください。

  `- c5_package_url: "https://www.concretecms.com/download_file/61dab82f-fb01-47bc-8cf1-deffff890224"`

- **[c5_installation]** : 「yes」か「no」

  `- c5_installation: "c5juser"`

- **[c5_sitename]** : Concrete CMSのサイト名を指定します。

  `- c5_sitename: "Site Name"`

- **[c5dir_user]** : webルートのオーナーユーザーを指定します。SSHのユーザーと同じに設定にする必要があります。

  `- c5dir_user: "c5juser"`

- **[c5dir_user]** : web ルートのグループを設定します。Apache であれば「apache」、Nginx であれば「nginx」と必ず設定して下さい。

  `- c5dir_group: "apache"`   

- **[c5_starting_point]** : インストールテーマを選択します。"elemental_blank" か "elemental_full" を選択してください。

  `- c5_starting_point: "elemental_blank"`

- **[c5_admin_email]** : Concrete CMS のAdminメールアドレスを設定します。

  `- c5_admin_email: "info@hogehoge.com"`

- **[c5_admin_pass]** : Concrete CMS のAdminパスワードを設定します。

  `- c5_admin_pass: "site_password"`

- **[c5_locale]** : Concrete CMS のデフォルトロケールを設定します。

  `- c5_locale:         "ja_JP"`

- **[c5_from_*]** : Concrete CMS から送られるメールの FROM 欄の設定を行います。

  `- c5_from_email:          "info@example.com"`
  `- c5_from_name:           "From Email Name"`

- **[c5_load_balancer]** : Concrete CMS が AWS ELB などのロードバランサーの背後に設定される場合 'yes' としてください。

  `- c5_load_balancer:       "no" # (yes / no)`


-----

## NewRelicの設定

- **[use_newrelic]** :NewRelicの利用を選択ください。

  `- use_newrelic:           "no"`

  - **[use_newrelicphp]** :Newrelic-phpの
  利用を選択ください。

  `- use_newrelicphp:        "no"`

  - **[newrelic_licensekey]** :Newrelicを利用する場合、ライセンスキーを入力ください。

  `- newrelic_licensekey:　"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"`


  - **[newrelic_appname]** :Newrelic-php利用する場合、表示されるアプリケーション名を設定ください。

  `- newrelic_appname: "PHP Application_name"`

New Relic PHP を使っている際、下記のようなエラーが出て、正常にデータが送られない場合があります。

```
warning: daemon connect(fd=XX uds=/tmp/.newrelic.sock) returned -1 errno=ENOENT. Failed to connect to the newrelic-daemon. Please make sure that there is a properly configured newrelic-daemon running. For additional assistance, please see: https://newrelic.com/docs/php/newrelic-daemon-startup-modes
```

その場合は、下記を設定してみて下さい。

```
# CentOS 6
$ sudo service newrelic-daemon stop
# CentOS 7
$ sudo systemctl stop newrelic-daemon
$ sudo rm /etc/newrelic/newrelic.cfg
```

## Mackerel 設定

Mackerel のエージェントもインストール可能です。

```
# Mackerel Setting
## Use Mackerel (yes / no)
  - use_mackerel:           "no"
## Mackerel License
  - mackerel_apikey:        "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

## ユーザーディレクトリからシンボルリンク

最後に SSH ユーザーのホームディレクトリから、シンボルリンクを設定します。



## 実行するロールの指定

- **[roles]** : 通常はこのままで問題ありません。
 ```
  roles:
  - role: default_setup
  - role: users_add
    when: if_add_users=="yes"
  - role: apache
    when: webserver_handle=="apache"
  - role: nginx
    when: webserver_handle=="nginx"
  - role: users_group
    when: if_add_users=="yes"
  - role: web_dummy
  - role: mysql_repo
    when:
    - db_environment in ['mysql', 'mysql-client']
    - aws_awslinux in ['no', '2']
  - role: mysql_client
    when: db_environment in ['mysql', 'mysql-client']
  - role: mysql_server
    when: db_environment=="mysql"
  - role: mariadb_repo
    when: db_environment in ['mariadb', 'mariadb-client']
  - role: mariadb_client
    when: db_environment in ['mariadb', 'mariadb-client']
  - role: mariadb_server
    when: db_environment=="mariadb"
  - role: mysql_appdb
    when: db_create=="yes"
  - role: basic_auth
    when: use_basic_auth=="yes"
  - role: create_symlink_www
  - role: concrete5
    when: c5_upload=="yes" 
  - role: concrete5_migration
    when: c5_migration=="yes"
  - role: newrelic_repo
    when: use_newrelic=="yes" or use_newrelic_php=="yes"
  - role: newrelic
    when: use_newrelic=="yes"
  - role: newrelic_php
    when: use_newrelic_php=="yes"
  - role: mackerel
    when: use_mackerel=="yes"
  ```
