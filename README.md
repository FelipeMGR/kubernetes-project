# Kubernetes Monitoring Project: Zabbix & Grafana

Este repositório contém a infraestrutura completa de um cluster Kubernetes (K8s) monitorado por **Zabbix** e **Grafana**, utilizando **containerd** como Container Runtime Interface (CRI).

## Tecnologias Utilizadas

*   **SO:** Ubuntu (Master e Workers).
*   **Runtime:** containerd (CRI).
*   **Orquestração:** Kubernetes (kubeadm).
*   **Monitoramento:** Zabbix (via Helm) e Grafana.
*   **Infra:** VirtualBox.

## Ordem de Instalação e Configuração

Para replicar este ambiente, os scripts contidos na pasta `/scripts` devem ser executados na seguinte ordem em todos os nodes (Master e Workers), exceto onde indicado:

### 1. Preparação do Sistema
Executa a desativação do Swap e configura módulos do kernel necessários para a rede do cluster.

*   **Script:** `01-prepare-os.sh`

### 2. Instalação da CRI - Container Run Time (containerd)
Instala o containerd e configura o `SystemdCgroup = true`, assim garantimos que o runtime e o kubelet utilizem o mesmo grupo de drivers.

*   **Script:** `02-install-cri.sh`

### 3. Ferramentas Kubernetes
Instala o `kubeadm`, `kubelet` e `kubectl` (componentes do kubernetes).

*   **Script:** `03-install-k8s-tools.sh`

### 4. Setup do Monitoramento
Instala o Helm e faz o deploy do Zabbix Server e Zabbix Agent dentro do cluster. Esse script deve ser rodado no node que atuará como Master.

*   **Script:** `04-install-helm-zabbix.sh`

### 5. Visualização (Node de Gerenciamento)
Configura o Grafana e instala o plugin `alexanderzobnin-zabbix-app` para integrar o Grafana ao Zabbix.

*   **Script:** `05-install-grafana.sh`

---

## Deploy da Aplicação

Após o cluster estar online (`Ready`), o deploy da aplicação de teste deve ser feito para validar as métricas de CPU e memória:

```bash
kubectl apply -f k8s-manifests/app-producao.yaml
```

### Configurações para o app de teste

* CPU Limit: 250mi
* Memória: 128mi

## Monitoramento e Teste de Estresse

O projeto foi testado através de estresse da aplicação. O dashboard do Grafana utiliza Expressões Regulares (Regex) para monitorar os Pods, garantindo que mesmo após um novo deploy (mudança de hash), os dados continuem sendo coletados.

### Comando para o teste de estresse da aplicação:

```bash
kubectl exec -it $(kubectl get pod -l app=minha-app -o jsonpath='{.items[0].metadata.name}') -- /bin/sh -c "while true; do dd if=/dev/urandom bs=1M count=10 | md5sum; done"
```

### Filtros Regex para o Grafana:

* Regex CPU: /^Pod \[.*app-producao-.*\] Usage: CPU/
* Regex Memória: /^Pod \[.*app-producao-.*\] Usage: Memory/
