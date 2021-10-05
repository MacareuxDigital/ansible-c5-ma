# Concrete CMS Ansible to setup Apache/Nginx/PHP-FPM/MySQL/MariaDB on Amazon Linux or CentOS

**Work-in-Progress**: Your input is greatly appreciated.

This was originally a simple Ansible script to setup Apache or Nginx, MariaDB or MySQL and Basic Auth into an Amazon Linux or CentOS instance.

You need to install Ansible in your PC to run.

You will connect to AWS Linux or CentOS7 and start sending commands to setup the server automatically.

THIS ANSIBLE IS VERY UGRY. KEEP CHANGING AS WE WORK. WE CANNOT GURANTEE ANYTHING. SO YOU MUST USE FOR DEV INSTANCE FIRST BEFORE APPLYING PRODUCTION. I WOULD NOT DEPLOY TO PRODUCTION EITHER.

As of Oct, 2021, I've mainly tested on Amazon Linux 2 with Nginx, PHP7.4 and MariaDB 10.5

-----

[日本語はこちら](README-ja.md)

## Installation

Install Ansible using Homebrew

- Homebrew

```
  $ brew install ansible
```

OR

- pip

```
  $ pip install ansible
```

## Generate SSH Key for each user

This script will create a sudo user.

This is separate SSH key pair from `ec2-user` default SSH key.

If you want to create new user(s), and you will use this SSH key to login.

**Please start naming user different from c5juser, such as client-name, such as `CLIENT-ssh`** as we kept having the many c5juser ssh users and we may get confused.

Generate and save the SSH key inside of [./roles/add_users/files/]

File name must be `username`.pem. Default is c5juser.pem, but please change it so that it's easier to remember.

- ssh-keygen command sample

```
  ssh-keygen -f ./roles/add_users/files/"USERNAME".pem -C "USERNAME"@localhost
```

  *It will generate [username.pem] [username.pen.pub] files.

## Get ready a server

### Execute CloudFormation script & confirm SSH access

**I haven't published CloudFormation Script yet.** Just launch an Amazon LINUX EC2 instance with public IP address, then setup DNS record to be accessible from domain name.

- Execute `ec2-simple`  CloudFormation Script to launch an EC2 Instance. (OR you could create an instance manually)
- Obtain an IP address of the EC2 instance
    - Modify the security group setting if the client requires IP address blocking from AWS Console.
- Obtain the ec2-user SSH key from AWS
- Check to see if you can access to newly created EC2 instance via SSH

### Prepare a CentOS7 server, and confirm SSH access

OR prepare a CentOS7 server with public IP address.

## Modify the settings

- Edit host.yml, setup.yml reading the instruction below.
    - If there is a new version of Concrete CMS, make sure to replace it
    - This package contains Concrete CMS package as a zip file. HOWEVER, the zip file which is distributed at Concrete CMS.org contains a folder with `Concrete CMS-[version]`. You must re-zip the package without the folder.

## For Debug: you can use docker to test

There is optional setting that you can use Docker to test-run you ansible script. Please be ware that some tasks are skipped such as changing locale, making swap, making databases and db users due to the docker's restriction. It it highly recommended to test on actual server or VM instance before using it on production.

- Edit host.docker.yml
  - Use it you want to test Ansible on your local docker before launching and executing on actual server
  - Change `ansible-test` to your docker container name.
  - `server_name` is optional
- For "setup.yml", see setup.yml configuration below

```
$ cd [path/to/ansible]
$ ansible-playbook -i host.docker.yml setup.yml
```

## Execute ansible-playBook

Execute Ansible, sit and wait.

```
$ cd [path/to/ansible]
$ ansible-playbook -i host.yml setup.yml
```


## Set DNS & Some Security Measure

- Go to your DNS service (like Route53) to set DNS to point the domain to the IP
- Set additional security measure such as setting up IP address restriction, stronger SSH auth.

-----

CONFIGURATION
====================

# host.yml

Set target IP address, and SSH username (usually `ec2-user` for Amazon Linux), SSH key or SSH password.

## Sample:

  ```
  [servers]
  192.168.0.1 server_name="web01.example.com"
  [all:vars]
  ansible_ssh_user=ec2-user
  ansible_ssh_private_key_file=/PATH/TO/ec2-usr-key.pem
  # ansible_ssh_pass="PASSWORD"
  ```

## [servers] Section

- IP Address

  - Server's publicIP

- server_name=

  - Indicate the host name that you would like to set.

## [all:vars]

- ansible_ssh_user=ec2-user

  - the name of sudo user or root, usually `ec2-user` if Amazon Linux

- ansible_ssh_private_key_file=

  - Path to your SSH key

- ansible_ssh_pass=

  - SSH Password if any

-----

# setup.yml

Change the parameters where necessaries.

THE COMMENTS IN steup.yml IS LATEST, this documentation tends to be older than latest.

## DEBUG: to test using Docker

Make sure to uncomment `connection: docker` on the 4th line

```
  connection: docker
```

## Server Locale

Setup the locale and timezone of your server. Use `localectl list-locales` to list available locales.
Use `ls -F /usr/share/zoneinfo` to list timezone on CentOS6/Amazon Linux, or `sudo timedatectl list-timezones` on CentOS 7.

```
  - locale:                 "ja_JP.UTF-8"
  - zone:                   "Asia/Tokyo"
```
## Amazon Linux?

Amazon Linux has its own repo and setup. So we want you to indicate.
If you are using Amazon Linux, type "1". If you're using Amazon Linux 2, type "2". If this is not Amazon Linux, type "no".

```
  - aws_awslinux:           "1"
  - aws_repo_upgrade:       "none"


```

## CentOS Version

This script supports 6 or 7. If it's Amazon Linux earlier than 2017, please type as 6. If it's Amazone Linux 2, please type as 7.


```
# CentOS Version? (6 / 7)
  - centos_version:         "6"
```

## PHP Repo for CentOS (remi/webtactics/none)

For CentOS, select which PHP repo you want to use.

```
  - centos_phprepo:         "remi"
```

## CentOS Initialize Firewall? (yes / no) Incompleted

If set `yes`, it will install firewalld & set-up to open http & https port.


```
  - centos_firewall_enable: "yes"
```

## Instance Type

We have a few templates that optimized for each instance types.

```
  - aws_instance_type:       "t2small"
```

### Available Types

Currently we only have the following setting.

- t2micro
- t2small

## PHP Variables

Please enter which PHP version you want to install. Currently supports 4 types of repo: Amazon Linux, Remi, Webtactics and Amazon Linux 2 (beta). You may not be able to install certain types depends on the repos.

For Amazon Linux 2, I've tested PHP5.6 (Apache only) 7.2 & 7.3. (as of May 2020)

```
## PHP version for yum (php56 / php70 / php71 / php72)
  - php_version_yum:        "php72"
## PHP version for Remi (php56 / php70 / php71 / php72)
  - php_version_remi:       "php72"
## PHP version for Amazon Linux (5.6 / 7.0 / 7.1 / 7.2)
  - php_version_amznlinux:  "7.2"
## PHP version for Amazon Linux 2 (php56 / php7.1 / php7.2 / php7.3)
  - php_version_amznlinux2:  "php7.3"
```


## Add & Name your SSH user

- **[if_add_users] : "Yes" to create sudo users with attached SSH key. Please make sure to generate them and store it under `add_users/files` with the format of `[username].pem` secret ssh key and `[username].pem.pub` public key.
- **[add_users]** : Name your SSH username

**Please start naming user different from c5juser, such as client-name, such as `CLIENT-ssh`** as we kept having the many c5juser ssh users and we may get confused.

  ```
  - add_users:
    - "c5juser"
  ```

If you want, you can add multiple users by using the following format.
However, you also need to create additional SSH keys

```
    - add_users:
      - "user01"
      - "user02"
```

## Name user and group

Please indicate user and group of Concrete CMS folder owner. Apache or Nginx will run as this user and group as well.

```
- c5dir_user:        "c5juser"
- c5dir_group:       "apache"
```

## Select Web Server Type

- **[webserver_handle]** : Select Apache or Nginx

  `- webserver_handle: "apache"`

 ## Change webserver user to SSH user or not.

    **[webserver_changeowner]** :　yes or no

  If you're going to run this server at closed & secure environment, you could change the Apache or Nginx, php-fpm user to SSH user so that SSH user can easily edit CMS generated files.

  For safety, we have set the default value to be no.

  - `- webserver_changeowner:  "no"`

## Virtualhost Setting

- **[vhost_domain]** : The domain names to set. It will add www subdomain.

  `- vhost_domain: "example.com"`

- **[vhost_docroot]** : Set the web document root path

  `- vhost_docroot: "/var/www/vhosts/"`

- **[vhost_htdocs]** : Set the additional web document root path. You could leave it blank

  `- vhost_docroot: "/html"`

  With the setting above, it will set `example.com` & `www.example.com` as virtual host, and the document root of that domain will be "/var/www/vhosts/example.com/html"

## DB Environment

Choose your DB environment (mariadb / mariadb-client / mysql / mysql-client / none )

This script **MAY NOT** be able to install MySQL **UNLESS** it's Amazon Linux.
I have **NOT TESTED** yet for mariadb-client option.

    - mariadb: Install MariaDB Server & Client
    - mariadb-client: Install MariaDB Client
    - mysql: Install MySQL Server & Client
    - mysql-client: Install only MySQL Client
    - none: do nothing

```
  - db_environment:         "mariadb"
```

## MySQL vesion for CentOS.

You can choose which MySQL version you want to install onto CentOS.
For Amazon Linux, you can only specify MySQL 5.6 for now.
For Amazon Linux 2, please use MariaDB.

Available versions: 55 / 56 / 57 / 80.

```
  - mysql_repo:          "57"
```

## Create DB or not

You can set whether to create DB and user from this ansible script. (Amazon Linux 2 doesn't work yet).

  - `- db_create:              "no"`


## MySQL or MariaDB Master Setting

- **[mysql_rootpass]** : MySQL's root password

  `- mysql_rootpass: "mysql_root_pass"`

- **[mysql_loginhost]** : MySQL Host address, you don't change it usually.

  `- mysql_loginhost: "127.0.0.1"`

- **[mysql_loginuser]** : MySQL root user password. Please keep it as "root" usually.

  `- mysql_loginuser: "root"`

- **[mysql_loginpass]** : Please keep it same as [mysql_rootpass]

  `- mysql_loginpass: "mysql_root_pass"`

## MySQL Setting for Concrete CMS

It will login as [mysql_loginuser] user and create database and additional user based on the following information.

- **[mysql_dbname]** : Set the name of Concrete CMS MySQL database. Leave it as default unless instructed.

  `- mysql_dbname: "dev-c5db"`

- **[mysql_username]** : Set Concrete CMS's MySQL DB username. Leave it as default unless instructed.

  `- mysql_username: "dev-c5dbuser"`

- **[mysql_userpass]** : Set Concrete CMS's MySQL User password. Make sure to make random and secure password that fits MySQL password restriction.

  `- mysql_userpass: "db-password"`

- **[mysql_userpermitedhost]** : Setting of MySQL host names, you usually don't change it.

  ```
  - mysql_userpermitedhost:

    - "127.0.0.1"
    - "localhost"
  ```

## Concrete CMS Migration

If you already have Concrete CMS site somewhere else, and want to migrate the data, please use this option.

- **[c5_migration]** : yes or no if you want to migration Concrete CMS from different data.

  `- c5_migration:           "no"`

- **[c5_backup_zip_filename]** : You must use the backup file which was created via all option of [Concrete CMS backup shell](https://github.com/katzueno/concrete5-backup-shell). Give the file name without file extension. And save the zip files under `roles/concrete5_migration/files`.

  `- c5_backup_zip_filename: "backup_202000000000"`


## Concrete CMS Installation Setting

If you want to setup a new Concrete CMS installation, enter the information here.

- **[c5_upload]** : yes or no whether to upload a copy of Concrete CMS.

  `- c5_upload: "yes"`

- **[c5_package_folder_name]** : write down the folder name of Concrete CMS package from download.

  `- c5_package_folder_name: "concrete5-8.5.6"`

- **[c5_package_url]** : change the URL if you need to download Concrete package from somewhere else or different version.

  `- c5_package_url: "https://www.concretecms.com/download_file/61dab82f-fb01-47bc-8cf1-deffff890224"`

- **[c5_installation]** : yes or no whether to install fresh copy of Concrete CMS.

  `- c5_installation: "yes"`

- **[c5_sitename]** : Enter the site name.

  `- c5_sitename: "Concrete CMS Demo"`

- **[c5dir_user]** : Enter the user name of directory owner which must be the same as SSH user.

  `- c5dir_user: "c5juser"`

- **[c5dir_user]** : Enter the group name of directory owner. Please set "apache" for apache server and "nginx" for nginx server.

  `- c5dir_group: "apache"`  

- **[c5_starting_point]** : Select the starting point, it's either "elemental_blank" or "elemental_full".

  `- c5_starting_point: "elemental_blank"`

- **[c5_admin_email]** : Set Concrete CMS Admin user email address. Make it as server@concrete5.co.jp unless instructed.

  `- c5_admin_email: "info@example.com"`

- **[c5_admin_pass]** : Set Concrete CMS Admin user password. Please generate the secure password, and make a note.

  `- c5_admin_pass: "site_password"`

- **[c5_locale]** : Set Concrete CMS default site locale

  `- c5_locale:         "ja_JP"`

- **[c5_from_*]** : Set Concrete CMS's from email address of each notification emails.

  `- c5_from_email:          "info@example.com"`
  `- c5_from_name:           "From Email Name"`

- **[c5_load_balancer]** : If Concrete CMS is set behind load balancer such as AWS ELB, please set it 'yes'.

  `- c5_load_balancer:       "no" # (yes / no)`


-----

## NewRelic Setting

If you're not using, it please ignore it.
NewRelic is server monitoring service, if you're using it, you must set the setting.

- **[use_newrelic]** : Set `yes`, if you want to install it

  `- use_newrelic:           "no"`

  - **[use_newrelicphp]** : Set `yes`, if you're going to use newrelic.php

  `- use_newrelicphp:        "no"`

  - **[newrelic_licensekey]** : Enter your Newrelic license key.

  `- newrelic_licensekey:　"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"`


  - **[newrelic_appname]** : If you're using NewRelic-php, set the name of application

  `- newrelic_appname: "PHP Application_name"`

You may get the following error and not getting the proper response from New Relic PHP

```
warning: daemon connect(fd=XX uds=/tmp/.newrelic.sock) returned -1 errno=ENOENT. Failed to connect to the newrelic-daemon. Please make sure that there is a properly configured newrelic-daemon running. For additional assistance, please see: https://newrelic.com/docs/php/newrelic-daemon-startup-modes
```

Try the following

```
$ sudo systemctl stop newrelic-daemon
$ sudo rm /etc/newrelic/newrelic.cfg
```

## Mackerel Setting

You can also install Mackerel

```
# Mackerel Setting
## Use Mackerel (yes / no)
  - use_mackerel:           "no"
## Mackerel License
  - mackerel_apikey:        "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

## Create Symbolic link

At last, it will create a symbolic link from SSH user's home directory to webroot.

  -----

# Role Settings

- **[roles]** : Role contains the set up commands for Ansible. This package contains group set of commands. According to `roles`, it will execute each role in order, also you can use a little condition as well.

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
