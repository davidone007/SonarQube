
# 🧩 SonarQube Configuration Report – AromaLife Backend

## 📘 Overview
This report summarizes the setup and execution of **SonarQube** analysis for the project **AromaLife Backend**, using Docker Compose for local deployment and configuration via `sonar-project.properties`.

---

## ⚙️ Step 1: Docker Compose Configuration

A `docker-compose.yaml` file was created to deploy **SonarQube** and **PostgreSQL** services locally.

```yaml
sonarqube:
  image: sonarqube
  ports:
    - "9000:9000"
  networks:
    - sonarnet
  environment:
    SONARQUBE_JDBC_URL: jdbc:postgresql://db:5432/sonar
    SONARQUBE_JDBC_USERNAME: sonar
    SONARQUBE_JDBC_PASSWORD: sonar
  volumes:
    - sonarqube_conf:/opt/sonarqube/conf
    - sonarqube_data:/opt/sonarqube/data
    - sonarqube_extensions:/opt/sonarqube/extensions
    - sonarqube_bundled-plugins:/opt/sonarqube/lib/bundled-plugins

sonar-db:
  image: postgres
  networks:
    - sonarnet
  environment:
    POSTGRES_USER: sonar
    POSTGRES_PASSWORD: sonar
  volumes:
    - postgresql:/var/lib/postgresql
    - postgresql_data:/var/lib/postgresql/data
```

📸 **Screenshot: Docker Compose**
![Docker Compose](./img/1.png)

---

## 🧩 Step 2: SonarQube Project Configuration

A `sonar-project.properties` file was configured to define the analysis parameters for the backend codebase.

```properties
# Project information
sonar.projectKey=aromalife-backend
sonar.projectName=AromaLife Backend
sonar.projectVersion=1.0

# Source and test directories
sonar.sources=src
sonar.tests=test
sonar.exclusions=**/node_modules/**,**/*.spec.ts,**/test/**,**/dist/**,**/coverage/**,**/scripts/**,**/postgres-data/**,**/pgadmin-data/**

# TypeScript/JavaScript configuration
sonar.typescript.lcov.reportPaths=coverage/lcov.info
sonar.javascript.lcov.reportPaths=coverage/lcov.info

# Encoding
sonar.sourceEncoding=UTF-8
```

📸 **Screenshot: sonar-project.properties**
![Sonar Project Properties](./img/3.png)

---

## 🚀 Step 3: Running SonarQube Analysis

Once SonarQube was up and running at `http://localhost:9000`, the project analysis was executed using the following command:

```bash
sonar \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.token=sqp_3138e9c80c49bc501aded4f717490c087ae7174c \
  -Dsonar.projectKey=front
```

📸 **Screenshot: Project Bind and Dashboard**
![Bind Project](./img/2.png)

---

## 📊 Step 4: Analysis Results

After the analysis completed successfully, the results were visible in the SonarQube dashboard.

📸 **Screenshot: SonarQube Report**
![SonarQube Results](./img/4.png)

### ✅ Summary of Results

| Metric                | Result                |
| --------------------- | --------------------- |
| **Security**          | 0 Open Issues         |
| **Reliability**       | 11 Issues (Grade A)   |
| **Maintainability**   | 63 Issues (Grade C)   |
| **Coverage**          | 27.3% (on 2.3k lines) |
| **Duplications**      | 6.1%                  |
| **Security Hotspots** | 2 (Grade E)           |

---

## 🧾 Conclusion

The SonarQube setup was successfully completed using Docker and integrated with the **AromaLife Backend** repository.
Static code analysis provided valuable insights into maintainability, coverage, and reliability, helping improve overall code quality.

---

## 🚀 Deployment with Terraform and Azure

### 📋 Prerequisites

Before deploying, ensure you have the following installed and configured:

- **Azure CLI** installed and configured ([Installation Guide](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli))
- **Terraform** v1.0+ ([Installation Guide](https://www.terraform.io/downloads))
- **Git** and **GitHub** account
- **Node.js** v18+ (for running the application)

> **Nota:** La VM usa autenticación por usuario y contraseña, no requiere SSH keys.

### 🔧 Step 1: Deploy SonarQube Infrastructure to Azure

1. **Authenticate with Azure:**
   ```bash
   az login
   ```

2. **Set your Azure subscription (if you have multiple):**

   ```bash
   az account list --output table
   az account set --subscription "<your-subscription-id>"
   ```

3. **Deploy the infrastructure:**

   ```bash
   chmod +x scripts/deploy-terraform.sh
   ./scripts/deploy-terraform.sh
   ```

   This script will:
   - Initialize Terraform
   - Validate the configuration
   - Create a deployment plan
   - Deploy the Azure VM with SonarQube
   - Install Docker, Docker Compose, and Trivy
   - Start SonarQube automatically

4. **Wait for deployment (approximately 5-10 minutes)**

   The script will output:

   ```text
   📊 Información de Despliegue:
     • IP Pública: <VM_IP_ADDRESS>
     • URL SonarQube: http://<VM_IP_ADDRESS>:9000
     • SSH: ssh azureuser@<VM_IP_ADDRESS>
   
   🔐 Credenciales de la VM:
     Usuario: azureuser
     Contraseña: SonarQube2024!@#
   ```

### 🔐 Step 2: Configure SonarQube

1. **Access SonarQube** at `http://<VM_IP_ADDRESS>:9000`
   - Wait 2-3 minutes after VM deployment for SonarQube to start

2. **Login with default credentials:**
   - Username: `admin`
   - Password: `admin`

3. **Change the password** (mandatory on first login)

4. **Create a new project:**
   - Go to **Projects** → **Create Project** → **Manually**
   - Project key: `aromalife-backend`
   - Display name: `AromaLife Backend`

5. **Generate an authentication token:**
   - Go to **My Account** → **Security** → **Generate Tokens**
   - Name: `GitHub Actions CI/CD`
   - Type: `Global Analysis Token` or `Project Analysis Token`
   - Click **Generate** and **copy the token**

### 🔒 Step 3: Configure GitHub Secrets

Add the following secrets to your GitHub repository:

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret** and add:

   | Secret Name | Value | Description |
   |-------------|-------|-------------|
   | `SONAR_TOKEN` | `<your-sonarqube-token>` | Token generated in SonarQube |
   | `SONAR_HOST_URL` | `http://<VM_IP_ADDRESS>:9000` | SonarQube server URL |

### 🔍 Step 4: Run Security Scan with Trivy (Local)

You can run Trivy security scans locally before pushing code:

```bash
chmod +x scripts/trivy-scan.sh
./scripts/trivy-scan.sh
```

This will:
- Scan the filesystem for vulnerabilities
- Scan dependencies (HIGH and CRITICAL severity)
- Scan Docker images (if Dockerfile exists)
- Generate JSON reports in `security-reports/` directory

### 🔄 Step 5: CI/CD Pipeline Configuration

The pipeline is configured to run automatically on **every push** to any branch.

**Pipeline workflow** (`.github/workflows/sonarqube-pipeline.yml`):

1. **Trivy Security Scan** 🔒
   - Scans filesystem for vulnerabilities
   - Uploads results to GitHub Security tab
   - Generates JSON reports

2. **Tests & Coverage** 🧪
   - Runs unit and integration tests
   - Generates coverage reports
   - Uploads artifacts

3. **SonarQube Analysis** 📊
   - Analyzes code quality
   - Checks coverage
   - Validates quality gates
   - Reports to SonarQube server

4. **Security Report Summary** 📋
   - Consolidates all findings
   - Generates GitHub Actions summary

### 📊 Step 6: Monitor Analysis Results

**View Trivy Security Results:**
- Go to your GitHub repository
- Navigate to **Security** → **Code scanning alerts**
- Review vulnerabilities detected by Trivy

**View SonarQube Results:**
- Access your SonarQube server: `http://<VM_IP_ADDRESS>:9000`
- Go to **Projects** → **aromalife-backend**
- Review:
  - Security vulnerabilities
  - Code smells
  - Coverage metrics
  - Duplications
  - Technical debt

**View GitHub Actions:**
- Go to **Actions** tab in your repository
- Click on the latest workflow run
- Review each job's logs and artifacts

### 🛠️ Infrastructure Management

**SSH into the VM:**
```bash
ssh azureuser@<VM_IP_ADDRESS>
```

**Check SonarQube status:**
```bash
cd ~/sonarqube
sudo docker-compose ps
```

**View SonarQube logs:**
```bash
cd ~/sonarqube
sudo docker-compose logs -f sonarqube
```

**Restart SonarQube:**
```bash
cd ~/sonarqube
sudo docker-compose restart
```

**Stop SonarQube:**
```bash
cd ~/sonarqube
sudo docker-compose down
```

**Start SonarQube:**
```bash
cd ~/sonarqube
sudo docker-compose up -d
```

**View VM information:**
```bash
cat ~/sonarqube-info.txt
```

### 🗑️ Step 7: Destroy Infrastructure (Optional)

When you want to remove all Azure resources:

```bash
cd terraform
terraform destroy
```

This will remove:
- Virtual Machine
- Network resources
- Resource Group
- All associated resources

### 📁 Project Structure

```
├── .github/
│   └── workflows/
│       └── sonarqube-pipeline.yml  # CI/CD pipeline
├── terraform/
│   ├── main.tf                     # Azure infrastructure definition
│   ├── variables.tf                # Terraform variables
│   ├── .gitignore                  # Terraform gitignore
│   └── scripts/
│       └── init.sh                 # VM initialization script
├── scripts/
│   ├── deploy-terraform.sh         # Deployment automation
│   └── trivy-scan.sh               # Local security scanning
├── sonar-project.properties        # SonarQube configuration
└── README.md                       # This file
```

### 🔑 Key Features Implemented

✅ **Automated Infrastructure Deployment**
- Terraform IaC for reproducible infrastructure
- Azure VM with Ubuntu 22.04
- Network security groups with proper rules
- Automatic installation of Docker, Trivy, and SonarQube

✅ **Continuous Security Scanning**
- Trivy integration for vulnerability detection
- Filesystem and dependency scanning
- Docker image scanning
- SARIF format for GitHub Security integration

✅ **Continuous Code Quality**
- SonarQube analysis on every push
- Code coverage tracking
- Quality gates enforcement
- Technical debt monitoring

✅ **CI/CD Pipeline**
- Automated testing
- Security scanning
- Code quality analysis
- Artifact preservation
- GitHub Security integration

### 🎯 Best Practices Implemented

1. **Security First**: Vulnerability scanning before code quality checks
2. **Fail Gracefully**: Pipeline continues even if quality gates fail (configurable)
3. **Comprehensive Reporting**: Multiple report formats and storage locations
4. **Infrastructure as Code**: Reproducible and version-controlled infrastructure
5. **Automated Deployment**: One-command deployment with validation
6. **Monitoring**: Detailed logs and status checks at each step

### 🆘 Troubleshooting

**SonarQube not accessible after deployment:**
- Wait 2-3 minutes for services to start
- Check VM logs: `ssh azureuser@<VM_IP> "sudo docker-compose -f ~/sonarqube/docker-compose.yml logs"`
- Verify NSG rules allow port 9000

**Pipeline failing on SonarQube step:**
- Verify `SONAR_TOKEN` and `SONAR_HOST_URL` secrets are set correctly
- Check SonarQube server is accessible from the internet
- Review SonarQube logs for authentication errors

**Terraform deployment fails:**
- Ensure you're logged in to Azure: `az login`
- Check you have proper permissions in the subscription
- Verify SSH public key exists at `~/.ssh/id_rsa.pub`
- Review terraform logs for specific errors

**Trivy scan fails:**
- Update Trivy database: `trivy image --download-db-only`
- Check internet connectivity for vulnerability database updates

### 📚 Additional Resources

- [SonarQube Documentation](https://docs.sonarqube.org/)
- [Trivy Documentation](https://aquasecurity.github.io/trivy/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

---



