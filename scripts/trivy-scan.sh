#!/bin/bash

# Script para ejecutar análisis de seguridad con Trivy
# Este script escanea el filesystem y las imágenes Docker en busca de vulnerabilidades

set -e

echo "=========================================="
echo "  Trivy Security Scanner"
echo "=========================================="
echo ""

# Verificar que Trivy esté instalado
if ! command -v trivy &> /dev/null; then
    echo "❌ Trivy no está instalado."
    echo "   Instalando Trivy..."
    
    # Detectar el sistema operativo
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        brew install aquasecurity/trivy/trivy
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
        echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
        sudo apt-get update
        sudo apt-get install trivy -y
    else
        echo "❌ Sistema operativo no soportado para instalación automática"
        echo "   Visita: https://aquasecurity.github.io/trivy/latest/getting-started/installation/"
        exit 1
    fi
fi

# Verificar versión de Trivy
echo "✅ Trivy instalado: $(trivy --version)"
echo ""

# Crear directorio para reportes
REPORT_DIR="security-reports"
mkdir -p $REPORT_DIR

# Timestamp para los reportes
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

echo "🔍 [1/4] Escaneando filesystem en busca de vulnerabilidades..."
trivy fs --severity HIGH,CRITICAL \
    --format json \
    --output "${REPORT_DIR}/trivy-fs-report-${TIMESTAMP}.json" \
    --exit-code 0 \
    .

echo "✅ Reporte de filesystem generado: ${REPORT_DIR}/trivy-fs-report-${TIMESTAMP}.json"
echo ""

echo "🔍 [2/4] Escaneando dependencias del proyecto..."
trivy fs --scanners vuln \
    --severity HIGH,CRITICAL \
    --format table \
    --exit-code 0 \
    .

echo ""

# Escanear imagen Docker si existe Dockerfile
if [ -f "Dockerfile" ]; then
    echo "🐳 [3/4] Detectado Dockerfile. Construyendo imagen..."
    
    # Obtener el nombre del proyecto desde package.json si existe
    if [ -f "package.json" ]; then
        PROJECT_NAME=$(node -p "require('./package.json').name" 2>/dev/null || echo "aromalife-backend")
    else
        PROJECT_NAME="aromalife-backend"
    fi
    
    IMAGE_NAME="${PROJECT_NAME}:scan-${TIMESTAMP}"
    
    docker build -t $IMAGE_NAME . --quiet
    
    echo "🔍 [4/4] Escaneando imagen Docker..."
    trivy image --severity HIGH,CRITICAL \
        --format json \
        --output "${REPORT_DIR}/trivy-image-report-${TIMESTAMP}.json" \
        --exit-code 0 \
        $IMAGE_NAME
    
    echo "✅ Reporte de imagen Docker generado: ${REPORT_DIR}/trivy-image-report-${TIMESTAMP}.json"
    echo ""
    
    # Mostrar resumen en consola
    echo "📊 Resumen de vulnerabilidades en imagen Docker:"
    trivy image --severity HIGH,CRITICAL --format table $IMAGE_NAME
    
else
    echo "ℹ️  No se encontró Dockerfile. Omitiendo escaneo de imagen Docker."
fi

echo ""
echo "=========================================="
echo "  ✅ Escaneo de Seguridad Completado"
echo "=========================================="
echo ""
echo "📁 Reportes generados en: $REPORT_DIR/"
echo ""
echo "📊 Para ver los reportes JSON:"
echo "   cat ${REPORT_DIR}/trivy-fs-report-${TIMESTAMP}.json | jq"
echo ""
echo "💡 Para integrar con GitHub Actions:"
echo "   Los reportes JSON pueden ser parseados y enviados a GitHub Security"
echo ""
