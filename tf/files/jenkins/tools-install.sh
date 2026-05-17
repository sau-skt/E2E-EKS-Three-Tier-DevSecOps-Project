#!/bin/bash
set -e  # Exit on any error
set -x  # Print commands for debugging

# For Ubuntu 22.04 - User data runs as root, no sudo needed

# Installing base dependencies
apt update -y
apt install -y ca-certificates curl fontconfig gnupg gpg lsb-release unzip wget

# Installing Java
apt install -y openjdk-21-jre openjdk-21-jdk
java -version

# Installing Jenkins
install -m 0755 -d /etc/apt/keyrings
wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
apt update -y
apt install -y jenkins
systemctl enable jenkins
systemctl start jenkins

# Installing Docker - Add GPG key and repository
apt update -y
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository
tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

apt update -y
apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Configure Docker permissions for Jenkins
usermod -aG docker jenkins
id -u ubuntu >/dev/null 2>&1 && usermod -aG docker ubuntu
systemctl restart docker
if [ -S /var/run/docker.sock ]; then
  chown root:docker /var/run/docker.sock
  chmod 660 /var/run/docker.sock
fi
systemctl restart jenkins

# Start SonarQube container
echo "vm.max_map_count=262144" > /etc/sysctl.d/99-sonarqube.conf
sysctl --system
docker rm -f sonar >/dev/null 2>&1 || true
docker run -d --name sonar -p 9000:9000 sonarqube:lts-community

# Installing AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
if command -v aws >/dev/null 2>&1; then
  ./aws/install --update
else
  ./aws/install
fi
rm -rf awscliv2.zip aws/

# Installing Kubectl
apt update -y
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/
kubectl version --client

# Installing eksctl
ARCH=amd64
PLATFORM=Linux_$ARCH

curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp
install -m 0755 /tmp/eksctl /usr/local/bin/eksctl
rm eksctl_$PLATFORM.tar.gz /tmp/eksctl
eksctl version

# Installing Terraform
wget -O - https://apt.releases.hashicorp.com/gpg | gpg --dearmor --yes -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
apt update -y
apt install -y terraform

# Installing Trivy
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor --yes -o /usr/share/keyrings/trivy.gpg
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | tee /etc/apt/sources.list.d/trivy.list
apt-get update -y
apt-get install -y trivy

# Installing Helm (Official Chart Repository)
apt-get install -y apt-transport-https
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version
