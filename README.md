
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



