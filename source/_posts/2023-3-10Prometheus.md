---
uuid: e9f31910-bd5b-11ed-90c2-51c8d7306491
title: Prometheus
date: 2023-3-10
tags: [Linux]
---

Prometheus

<!--more-->

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