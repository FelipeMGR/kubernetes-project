#!/bin/bash
# install_grafana.sh - Grafana Enterprise no Debian/Ubuntu

echo "--- 1. Adicionando repositório oficial Grafana ---"
sudo apt-get install -y apt-transport-https software-properties-common wget
sudo mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com  stable main" | sudo tee /etc/apt/sources.list.d/grafana.list

echo "--- 2. Instalando Grafana ---"
sudo apt-get update
sudo apt-get install grafana -y

echo "--- 3. Habilitando o Plugin do Zabbix ---"
# Importante: O Grafana não vem com o plugin do Zabbix por padrão
sudo grafana-cli plugins install alexanderzobnin-zabbix-app

echo "--- 4. Iniciando o serviço ---"
sudo systemctl daemon-reload
sudo systemctl enable grafana-server
sudo systemctl start grafana-server
