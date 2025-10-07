#!/bin/bash

# Script de inicialización para VM de Azure con SonarQube
# Este script se ejecuta automáticamente al crear la VM

set -e

echo "=== Starting SonarQube VM Initialization ==="

# Actualizar el sistema
echo "[1/6] Updating system packages..."
sudo apt-get update
sudo apt-get upgrade -y

# Instalar Docker
echo "[2/6] Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker azureuser
rm get-docker.sh

# Instalar Docker Compose
echo "[3/6] Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verificar instalación de Docker
docker --version
docker-compose --version

# Instalar Trivy
echo "[4/6] Installing Trivy..."
sudo apt-get install wget apt-transport-https gnupg lsb-release -y
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy -y

# Verificar instalación de Trivy
trivy --version

# Configurar límites del sistema para SonarQube
echo "[5/6] Configuring system limits for SonarQube..."
sudo sysctl -w vm.max_map_count=524288
sudo sysctl -w fs.file-max=131072
sudo bash -c 'echo "vm.max_map_count=524288" >> /etc/sysctl.conf'
sudo bash -c 'echo "fs.file-max=131072" >> /etc/sysctl.conf'

# Crear directorio para SonarQube
echo "[6/6] Setting up SonarQube with Docker Compose..."
mkdir -p /home/azureuser/sonarqube
cd /home/azureuser/sonarqube

# Crear archivo docker-compose.yml
cat > docker-compose.yml <<'EOF'
version: "3.8"

services:
  sonarqube:
    image: sonarqube:community
    container_name: sonarqube
    depends_on:
      - db
    environment:
      SONAR_JDBC_URL: jdbc:postgresql://db:5432/sonar
      SONAR_JDBC_USERNAME: sonar
      SONAR_JDBC_PASSWORD: sonar
    volumes:
      - sonarqube_data:/opt/sonarqube/data
      - sonarqube_extensions:/opt/sonarqube/extensions
      - sonarqube_logs:/opt/sonarqube/logs
    ports:
      - "9000:9000"
    restart: unless-stopped
    networks:
      - sonarnet

  db:
    image: postgres:14-alpine
    container_name: sonarqube-db
    environment:
      POSTGRES_USER: sonar
      POSTGRES_PASSWORD: sonar
      POSTGRES_DB: sonar
    volumes:
      - postgresql:/var/lib/postgresql
      - postgresql_data:/var/lib/postgresql/data
    restart: unless-stopped
    networks:
      - sonarnet

volumes:
  sonarqube_data:
  sonarqube_extensions:
  sonarqube_logs:
  postgresql:
  postgresql_data:

networks:
  sonarnet:
    driver: bridge
EOF

# Cambiar permisos
sudo chown -R azureuser:azureuser /home/azureuser/sonarqube

# Iniciar SonarQube
echo "Starting SonarQube containers..."
sudo docker-compose up -d

# Esperar a que SonarQube esté listo
echo "Waiting for SonarQube to be ready (this may take a few minutes)..."
sleep 60

# Verificar estado de los contenedores
sudo docker-compose ps

# Crear script de información
cat > /home/azureuser/sonarqube-info.txt <<EOF
=================================================
   SonarQube Installation Complete
=================================================

SonarQube URL: http://$(curl -s ifconfig.me):9000

Default Credentials:
  Username: admin
  Password: admin

IMPORTANT: Change the default password on first login!

Useful Commands:
  - Check status: cd ~/sonarqube && sudo docker-compose ps
  - View logs: cd ~/sonarqube && sudo docker-compose logs -f
  - Restart: cd ~/sonarqube && sudo docker-compose restart
  - Stop: cd ~/sonarqube && sudo docker-compose down
  - Start: cd ~/sonarqube && sudo docker-compose up -d

Trivy Commands:
  - Scan filesystem: trivy fs /path/to/code
  - Scan Docker image: trivy image <image-name>

=================================================
EOF

sudo chown azureuser:azureuser /home/azureuser/sonarqube-info.txt

echo "=== SonarQube VM Initialization Complete ==="
echo "View setup info: cat ~/sonarqube-info.txt"
