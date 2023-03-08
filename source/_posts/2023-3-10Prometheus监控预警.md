---
uuid: e9f31910-bd5b-11ed-90c2-51c8d7306491
title: Prometheus监控预警
date: 2023-3-10
tags:
  - Linux
abbrlink: f1885250
---

Prometheus监控预警

<!--more-->

## zabbix与Prometheus对比

1. zabbix诞生的 时间更早 ，是比Prometheus 更成熟 的监控软件。
2. 不过受制于时间，Prometheus的 编制语言 也会比zabbix更加简洁。
3. zabbix支持 图形化配置 ，让它在 本地计算机 上使用会更方便和快捷。
4. 但是到了 云计算 上，由于需要 自动化 ，导致zabbix的图形化需要大量人力介入
5. 在模型架构方面，zabbix采用了传统push模型，节省了人力拉取数据的时间。
6. 不过同样的，这在本地计算机上是优势，而云计算由于数量众多，需要单独配置也极大地提高了使用难度。
7. 总的来说， zabbix 更加适合用于 本地计算机 的监控，而 Prometheus 更适合在现在流行的 云计算 监控上使用。

## docker安装
```
vim docker-compose.yml
    version: "3.7"
    services:
      prometheus_node_exporter:
        image: prom/node-exporter:latest
        container_name: "prometheus_node_exporter"
        ports:
          - "9100:9100"
        restart: always

      prometheus:
        image: prom/prometheus:latest
        container_name: "prometheus"
        restart: always
        ports:
          - "9090:9090"
        volumes:
          - "./prometheus.yml:/etc/prometheus/prometheus.yml"
          - "./prometheus_data:/prometheus"

      grafana:
        image: grafana/grafana
        container_name: "grafana"
        ports:
          - "3000:3000"
        restart: always

1.备份出/etc/prometheus/prometheus.yml 到 prometheus.yml
2.mkdir prometheus_data; chmod 777 prometheus_data
3.添加node_exporter节点
4.grafana添加数据源，初始账号密码：admin、admin
5.grafana添加模板：9276
```

## 软件包安装
### 启动prometheus
```
cd /usr/local/
sudo wget https://github.com/prometheus/prometheus/releases/download/v2.27.1/prometheus-2.27.1.linux-amd64.tar.gz
sudo tar xf prometheus-2.27.1.linux-amd64.tar.gz
sudo ln -s prometheus-2.27.1.linux-amd64 prometheus
sudo chown -R root.root prometheus-2.27.1.linux-amd64

sudo vim /lib/systemd/system/prometheus.service
    [Unit]
    Description=Prometheus server daemon
    After=network.target

    [Service]
    Type=simple
    User=root
    Group=root
    ExecStart="/usr/local/prometheus/prometheus" --config.file="/usr/local/prometheus/prometheus.yml" --storage.tsdb.path="/usr/local/prometheus/data" --storage.tsdb.retention=5d --web.console.templates="/usr/local/prometheus/consoles" --web.console.libraries="/usr/local/prometheus/console_libraries" --web.max-connections=512 --web.external-url="http://192.168.33.20:9090" --web.listen-address="0.0.0.0:9090"Restart=on-failure

    [Install]
    WantedBy=multi-user.target
sudo systemctl daemon-reload
sudo systemctl restart prometheus.service
sudo systemctl status prometheus.service
```

### 启动node_exporter
```
cd /usr/local
sudo wget https://github.com/prometheus/node_exporter/releases/download/v1.1.2/node_exporter-1.1.2.linux-amd64.tar.gz
sudo tar xf node_exporter-1.1.2.linux-amd64.tar.gz
sudo ln -s node_exporter-1.1.2.linux-amd64 node_exporter
sudo chown -R root.root node_exporter-1.1.2.linux-amd64
sudo vim /lib/systemd/system/node_exporter.service
    [Unit]
    Description=node_exporter
    Documentation=https://prometheus.io/
    After=network.target

    [Service]
    Type=simple
    ExecStart=/usr/local/node_exporter/node_exporter \
    --collector.mountstats \
    --collector.systemd \
    --collector.ntp \
    --collector.tcpstat
    ExecReload=/bin/kill -HUP $MAINPID
    TimeoutStopSec=2s
    Restart=always

    [Install]
    WantedBy=multi-user.target
sudo systemctl daemon-reload
sudo systemctl start node_exporter.service
sudo systemctl status node_exporter.service
```

### 添加节点
```
sudo vim /usr/local/prometheus/prometheus.yml
    scrape_configs:
      - job_name: 'node_exporter'
        scrape_interval: 5s
        static_configs:
        - targets: ['192.168.33.20:9100']
sudo systemctl daemon-reload
sudo systemctl restart prometheus.service
sudo systemctl status prometheus.service
```

### 安装grafana
```
wget https://dl.grafana.com/enterprise/release/grafana-enterprise_8.3.3_amd64.deb
sudo dpkg -i grafana-enterprise_8.3.3_amd64.deb
sudo systemctl daemon-reload
sudo systemctl start grafana-server
sudo systemctl status grafana-server
sudo systemctl enable grafana-server.service（开机启动）
sudo grafana-cli admin reset-admin-password "admin"（初始化admin密码）

1.添加prometheus数据源
2.添加仪表盘：9276（搜寻仪表盘：https://grafana.com/grafana/dashboards/9276-1-cpu/）
```

## Zabbix安装
```
文档
    https://www.zabbix.com/
    https://www.zabbix.com/documentation/6.2/en/manual/quickstart/login
安装
    vim docker-compose.yml
        version: '3.7'
        services:
          mysql-server:
            image: mysql:latest
            environment:
              MYSQL_ROOT_PASSWORD: password
              MYSQL_USER: zabbix
              MYSQL_PASSWORD: zabbix
              MYSQL_DATABASE: zabbix
            volumes:
              - "/etc/localtime:/etc/localtime"
              - "/home/docker/mysql:/var/lib/mysql"
            ports:
              - "3306:3306"
            networks:
              - zbx_net

          zabbix-server:
            image: zabbix/zabbix-server-mysql:centos-latest
            environment:
              DB_SERVER_HOST: mysql-server
              MYSQL_DATABASE: zabbix
              MYSQL_USER: zabbix
              MYSQL_PASSWORD: zabbix
            ports:
              - "10051:10051"
            depends_on:
              - "mysql-server"
            volumes:
              - /etc/localtime:/etc/localtime:ro
              - /etc/timezone:/etc/timezone:ro
              - "zabbix:/var/lib/zabbix"
            networks:
              - zbx_net


          zabbix-web:
            image: zabbix/zabbix-web-nginx-mysql:latest
            environment:
              DB_SERVER_HOST: mysql-server
              MYSQL_DATABASE: zabbix
              MYSQL_USER: zabbix
              MYSQL_PASSWORD: zabbix
              PHP_TZ: Asia/Shanghai
              ZBX_SERVER_HOST: zabbix-server
            ports:
              - 8088:8080
            depends_on:
              - mysql-server
              - zabbix-server
            networks:
              - zbx_net

          zabbix-agent:
            image: zabbix/zabbix-agent:latest
            environment:
              ZBX_SERVER_HOST: zabbix-server
            ports:
             - "10050:10050"
            depends_on:
             - "zabbix-server"
            networks:
             - zbx_net

        networks:
         zbx_net:
        volumes:
          zabbix:
```