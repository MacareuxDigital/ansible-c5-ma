# Ansibleの使い方

-----
Amazon Linux や CentOS 7 に、 SSH 接続をし、Apache/Nginx, PHP-FPM, MariaDB, MySQL などの設定を自動的に実行してくれるプログラムです。

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
  ssh-keygen -f ./roles/default_setup/files/"USERNAME".pem -C "USERNAME"@localhost
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
    - 特に新しいバージョンの concrete5 がリリースされた時など、ZIPファイルを変更したり、コマンドが変更されている場合があるので、確認が必要です。
    - concrete5.org で配布されている ZIP ファイルは「concrete5-バージョン名」というフォルダの中に格納されているのですが、格納している concrete5 の ZIP ファイルは、バージョン名のフォルダを含めない形で保存されています。

## AnsiblePlayBookの実行

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

## サーバーの言語とタイムゾーンの設定

サーバーの言語とローカルタイムを設定します。 `localectl list-locales` コマンドを使うと使用可能な言語のリストを取得でき、
CentOS 6 系であれば `ls -F /usr/share/zoneinfo` CentOS 7 系であれば `sudo timedatectl list-timezones` を使うと、タイムゾーンのリストを取得できます。

```
  - locale:                 "ja_JP.UTF-8"
  - zone:                   "Asia/Tokyo"
```
## Amazon Linux であるか?

Amazon Linux で AWS 内に設置されているかを指定します。

```
  - aws_awslinux:           "yes"
  - aws_repo_upgrade:       "none"


```

## CentOS バージョン

CentOS のバージョンを指定します。Amazon Linux 2017.03 時点では CentOS は 6 を指定して下さい。

```
# CentOS Version? (6 / 7)
  - centos_version:         "6"
```

## インスタンスタイプ

AWS インスタンスに応じて最適化した設定を行います。

```
  - aws_instance_type:       "t2small"
```

### 利用可能なインスタンス

現時点では、下記の設定のみ利用可能です。

- t2micro
- t2small

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

concrete5 が保存されるディレクトリの所有者ユーザー・グループ、Apache もしくは nginx の実行グループを指定します。

```
- c5dir_user:        "c5juser"
- c5dir_group:       "apache"
```

## 利用するWEBサーバーを選びます
- **[webserver_handle]** : Apache か Nginx　を選択ください。

  `- webserver_handle: "apache"`

## Virtualhostの設定

- **[vhost_domain]** : 設定するドメイン名です。

  `- vhost_domain: "example.com"`

- **[vhost_docroot]** : ドキュメントルートが設定される上位ディレクトリです。

  `- vhost_docroot: "/var/www/vhosts/"`

- 上記の場合、Apacheにドメイン名[example.com] & [www.example.com] のバーチャルホストが設定され、ドキュメントルートが[/var/www/vhosts/example.com]となります。

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

## concrete5 データ移行

既に別の環境で concrete5 サイトを構築仕掛けている時に、バックアップファイルを所定のフォーマットの ZIP にまとめてサーバー構築と一緒にデータ移行も一緒にやることが出来ます。

- **[c5_migration]** : 「yes」か「no」

  `- c5_migration: "no"`

- **[c5_backup_zip_filename]** : concrete5 バックアップシェルである [concrete5 backup shell](https://github.com/katzueno/concrete5-backup-shell) の All オプションを使って作成したバックアップファイルを拡張子なしで指定し、`roles/concrete5_migration/files` 配下に保存して下さい。

  `- c5_backup_zip_filename: "backup_202000000000"`



## concrete5の設定

- **[c5_installation]** : 「yes」か「no」

  `- c5_installation: "c5juser"`

- **[c5_sitename]** : concrete5のサイト名を指定します。

  `- c5_sitename: "Site Name"`

- **[c5dir_user]** : webルートのオーナーユーザーを指定します。SSHのユーザーと同じに設定にする必要があります。

  `- c5dir_user: "c5juser"`

- **[c5dir_user]** : web ルートのグループを設定します。Apache であれば「apache」、Nginx であれば「nginx」と必ず設定して下さい。

  `- c5dir_group: "apache"`   

- **[c5_starting_point]** : インストールテーマを選択します。"elemental_blank" か "elemental_full" を選択してください。

  `- c5_starting_point: "elemental_blank"`

- **[c5_admin_email]** : concrete5 のAdminメールアドレスを設定します。

  `- c5_admin_email: "info@hogehoge.com"`

- **[c5_admin_pass]** : concrete5 のAdminパスワードを設定します。

  `- c5_admin_pass: "site_password"`

- **[c5_locale]** : concrete5 のデフォルトロケールを設定します。

  `- c5_locale:         "ja_JP"`

- **[c5_from_*]** : concrete5 から送られるメールの FROM 欄の設定を行います。

  `- c5_from_email:          "info@example.com"`
  `- c5_from_name:           "From Email Name"`

- **[c5_load_balancer]** : concrete5 が AWS ELB などのロードバランサーの背後に設定される場合 'yes' としてください。

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
  - role: add_users
    when: if_add_users=="yes"
  - role: apache
    when: webserver_handle=="apache"
  - role: nginx
    when: webserver_handle=="nginx"
  - role: web_dummy
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
  - role: concrete5
    when: c5_installation=="yes"
  - role: concrete5_migration
    when: c5_migration=="yes"
  - role: basic_auth
    when: use_basic_auth=="yes"
  - role: newrelic_repo
    when: use_newrelic=="yes" or use_newrelic_php=="yes"
  - role: newrelic
    when: use_newrelic=="yes"
  - role: newrelic_php
    when: use_newrelic_php=="yes"
  - role: mackerel
    when: use_mackerel=="yes"
  - role: create_symlink_www
  ```
