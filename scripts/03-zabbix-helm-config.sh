#!/bin/bash
# install_zabbix_helm.sh - Helm + Zabbix no Kubernetes

echo "--- 1. Instalando o Helm ---"
curl https://baltocdn.com/helm/signing.asc | sudo gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm -y

echo "--- 2. Adicionando repositório do Zabbix Helm ---"
helm repo add zabbix-community https://zabbix-community.github.io/helm-zabbix
helm repo update

echo "--- 3. Criação do namespace e instalação do Zabbix ---"
kubectl create namespace monitoring
# Instalando com configurações básicas (Server + Web + Agent)
helm install zabbix zabbix-community/zabbix --namespace monitoring \
  --set zabbix-server.enabled=true \
  --set zabbix-web.enabled=true \
  --set zabbix-agent.enabled=true
