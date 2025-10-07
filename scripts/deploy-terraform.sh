#!/bin/bash

# Script para desplegar la infraestructura de SonarQube en Azure usando Terraform
# Asegúrate de estar autenticado en Azure CLI antes de ejecutar este script

set -e

echo "=========================================="
echo "  SonarQube Azure Deployment with Terraform"
echo "=========================================="
echo ""

# Verificar que Azure CLI esté instalado
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI no está instalado. Por favor, instálalo primero."
    echo "   Visita: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

# Verificar que Terraform esté instalado
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform no está instalado. Por favor, instálalo primero."
    echo "   Visita: https://www.terraform.io/downloads"
    exit 1
fi

# Verificar que estamos autenticados en Azure
echo "🔍 Verificando autenticación de Azure..."
if ! az account show &> /dev/null; then
    echo "❌ No estás autenticado en Azure CLI."
    echo "   Ejecuta: az login"
    exit 1
fi

# Mostrar la suscripción actual
SUBSCRIPTION=$(az account show --query name -o tsv)
echo "✅ Autenticado en Azure"
echo "   Suscripción actual: $SUBSCRIPTION"
echo ""

# Información sobre autenticación
echo "ℹ️  La VM usará autenticación por usuario y contraseña"
echo "   Usuario: azureuser"
echo "   Contraseña: SonarQube2024!@#"
echo ""

# Cambiar al directorio de terraform
cd "$(dirname "$0")/../terraform"

echo "📁 Directorio de trabajo: $(pwd)"
echo ""

# Inicializar Terraform
echo "🔧 [1/4] Inicializando Terraform..."
terraform init
echo ""

# Formatear archivos Terraform
echo "✨ [2/4] Formateando archivos Terraform..."
terraform fmt
echo ""

# Validar configuración
echo "✅ [3/4] Validando configuración de Terraform..."
terraform validate
echo ""

# Crear plan de despliegue
echo "📋 [4/4] Creando plan de despliegue..."
terraform plan -out=tfplan
echo ""

# Aplicar configuración directamente
echo ""
echo "🚀 Desplegando infraestructura en Azure..."
terraform apply -auto-approve tfplan
echo ""

# Obtener outputs
echo "=========================================="
echo "  ✅ Despliegue Completado"
echo "=========================================="
echo ""

SONAR_IP=$(terraform output -raw sonarqube_public_ip)
SONAR_URL=$(terraform output -raw sonarqube_url)
SSH_CMD=$(terraform output -raw ssh_command)

echo "📊 Información de Despliegue:"
echo "  • IP Pública: $SONAR_IP"
echo "  • URL SonarQube: $SONAR_URL"
echo "  • SSH: $SSH_CMD"
echo ""
echo "🔐 Credenciales de la VM:"
echo "   Usuario: azureuser"
echo "   Contraseña: SonarQube2024!@#"
echo ""
echo "⏱️  Nota: SonarQube tardará aproximadamente 2-3 minutos en estar disponible"
echo "   después de que la VM esté lista."
echo ""
echo "🔐 Credenciales de SonarQube:"
echo "   Usuario: admin"
echo "   Contraseña: admin"
echo "   ⚠️  ¡CAMBIA LA CONTRASEÑA EN EL PRIMER LOGIN!"
echo ""
echo "📝 Próximos pasos:"
echo "   1. Espera 2-3 minutos para que SonarQube esté disponible"
echo "   2. Accede a $SONAR_URL"
echo "   3. Inicia sesión con las credenciales por defecto"
echo "   4. Cambia la contraseña"
echo "   5. Crea un token de autenticación (User > My Account > Security)"
echo "   6. Agrega los secrets en GitHub:"
echo "      - SONAR_TOKEN: <tu-token>"
echo "      - SONAR_HOST_URL: $SONAR_URL"
echo ""
echo "=========================================="

# Guardar información en archivo
cat > ../sonarqube-deployment-info.txt <<EOF
========================================
  SonarQube Azure Deployment Info
========================================

Fecha de despliegue: $(date)
Suscripción: $SUBSCRIPTION

Información de la VM:
  • IP Pública: $SONAR_IP
  • URL SonarQube: $SONAR_URL
  • Comando SSH: $SSH_CMD

Credenciales de la VM:
  • Usuario: azureuser
  • Contraseña: SonarQube2024!@#

Credenciales de SonarQube:
  • Usuario: admin
  • Contraseña: admin

GitHub Secrets a configurar:
  • SONAR_TOKEN: <generar desde SonarQube>
  • SONAR_HOST_URL: $SONAR_URL

========================================
EOF

echo "💾 Información guardada en: ../sonarqube-deployment-info.txt"
