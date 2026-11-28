#!/bin/bash
set -euxo pipefail

# Disable swap
swapoff -a
sed -ri '/\sswap\s/s/^#?/#/' /etc/fstab

# Kernel modules
cat >/etc/modules-load.d/k8s.conf <<'EOF'
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

# Network prerequisites for Kubernetes
cat >/etc/sysctl.d/99-kubernetes-cri.conf <<'EOF'
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system

# Install containerd
apt-get update
apt-get install -y ca-certificates curl gpg containerd

mkdir -p /etc/containerd
containerd config default >/etc/containerd/config.toml

sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' \
  /etc/containerd/config.toml

systemctl enable --now containerd
systemctl restart containerd

# Kubernetes repository
K8S_MINOR="v1.37"

mkdir -p -m 755 /etc/apt/keyrings

curl -fsSL \
  "https://pkgs.k8s.io/core:/stable:/${K8S_MINOR}/deb/Release.key" \
  | gpg --dearmor --yes \
      -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${K8S_MINOR}/deb/ /" \
  >/etc/apt/sources.list.d/kubernetes.list

# Install Kubernetes components
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-get install vim -y
apt-mark hold kubelet kubeadm kubectl

systemctl enable --now kubelet

echo "CP system preparation completed."
echo "kubeadm init has NOT been executed."

# start kubernetes cluster
MASTER_PRIVATE_IP=$(hostname -I | awk '{print $1}')
sudo kubeadm init --apiserver-advertise-address="$MASTER_PRIVATE_IP" --pod-network-cidr=10.244.0.0/16

mkdir -p "$HOME/.kube"
mkdir -p /home/ubuntu/k8s
chown ubuntu:ubuntu /home/ubuntu/k8s

sudo cp /etc/kubernetes/admin.conf "$HOME/.kube/config"

sudo chown "$(id -u):$(id -g)" "$HOME/.kube/config"

kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml