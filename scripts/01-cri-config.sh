#!/bin/bash
# install_cri_containerd.sh - Configuração do Container Runtime para K8s

echo "--- 1. Carregando módulos do Kernel para o containerd ---"
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

echo "--- 2. Configurando parâmetros do Sysctl para rede ---"
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system

echo "--- 3. Instalando o containerd (via repositório apt) ---"
sudo apt-get update
sudo apt-get install -y containerd

echo "--- 4. Gerando configuração padrão e ajustando Cgroup Driver ---"
# Criando diretório de configuração
sudo mkdir -p /etc/containerd

# Gerando o arquivo padrão e alterando SystemdCgroup para true
# Esse passo é vital para que o kubelet e o containerd conversem na mesma língua (systemd)
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

echo "--- 5. Reiniciando o serviço ---"
sudo systemctl restart containerd
sudo systemctl enable containerd

echo "Containerd configurado com sucesso como CRI!"
