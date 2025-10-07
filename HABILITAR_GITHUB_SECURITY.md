# 🔒 Guía para Habilitar GitHub Advanced Security

## ❌ Error Actual

```
Warning: Resource not accessible by integration
Error: Resource not accessible by integration - https://docs.github.com/rest
```

Este error ocurre porque **GitHub Advanced Security** no está habilitado en tu repositorio.

---

## ✅ Solución: Habilitar GitHub Advanced Security

### 📋 Prerequisitos

- ✅ Tu repositorio **SÍ es público** (davidone007/SonarQube)
- ✅ GitHub Advanced Security es **GRATIS para repositorios públicos**
- ✅ Solo necesitas habilitarlo en la configuración

---

## 🚀 Pasos para Habilitar (2 minutos)

### **Paso 1: Acceder a Settings del Repositorio**

1. Ve a tu repositorio: `https://github.com/davidone007/SonarQube`
2. Haz clic en **Settings** (⚙️ Configuración)

### **Paso 2: Ir a Code Security**

1. En el menú lateral izquierdo, busca **"Code security and analysis"**
2. Haz clic en esa opción

### **Paso 3: Habilitar GitHub Advanced Security**

Busca la sección **"GitHub Advanced Security"** y verás algo como:

```
GitHub Advanced Security
○ Enable    (botón deshabilitado actualmente)
```

**Si el repositorio es PÚBLICO:**
- Verás que dice: "Free for public repositories"
- Simplemente haz clic en **"Enable"**

**Si el repositorio es PRIVADO:**
- Necesitas una suscripción de GitHub Enterprise Cloud o GitHub Enterprise Server
- O puedes hacer el repositorio público temporalmente

### **Paso 4: Habilitar Code Scanning**

Después de habilitar GitHub Advanced Security, busca:

```
Code scanning
○ Enable    ← Habilita esto también
```

Opciones:
- **Default setup:** GitHub configura automáticamente
- **Advanced setup:** Configuración manual (ya tienes el workflow configurado)

Selecciona **"Default"** o deja que use tu workflow existente.

### **Paso 5: Habilitar Dependabot Alerts (Opcional)**

También puedes habilitar:

```
✓ Dependency graph
✓ Dependabot alerts
✓ Dependabot security updates
```

Esto te ayudará a detectar vulnerabilidades en dependencias automáticamente.

---

## 🔍 Verificación

Después de habilitar todo, deberías ver:

```
✅ GitHub Advanced Security: Enabled
✅ Code scanning: Enabled
✅ Secret scanning: Enabled (automático)
```

---

## 🎯 Resultado Esperado

Una vez habilitado, cuando ejecutes el pipeline nuevamente:

1. ✅ El upload de SARIF funcionará sin errores
2. ✅ Verás los resultados de Trivy en la pestaña **"Security"** → **"Code scanning"**
3. ✅ Recibirás alertas automáticas de vulnerabilidades
4. ✅ No más warnings de "Resource not accessible by integration"

---

## 📸 Captura de Pantalla Esperada

Después de habilitar, en la pestaña **Security** de tu repositorio verás:

```
Security
├── Overview
├── Code scanning alerts    ← Aquí aparecerán los resultados de Trivy
├── Dependabot alerts
└── Secret scanning alerts
```

---

## 🔄 Próximo Paso

1. **Habilita GitHub Advanced Security** siguiendo los pasos anteriores
2. **Haz un nuevo commit** (puede ser cualquier cambio pequeño)
3. **Push al repositorio** para que el pipeline se ejecute nuevamente
4. **Verifica** en la pestaña Security que aparecen los resultados

---

## ⚡ Comando Rápido para Re-ejecutar Pipeline

Después de habilitar, puedes re-ejecutar el pipeline:

```bash
# Hacer un cambio mínimo para trigger el pipeline
git commit --allow-empty -m "test: trigger pipeline con GitHub Security habilitado"
git push origin main
```

O simplemente ve a GitHub Actions y haz clic en **"Re-run all jobs"** en el último workflow.

---

## 📝 Alternativa: Si No Puedes Habilitar

Si por alguna razón no puedes habilitar GitHub Advanced Security:

1. **El pipeline seguirá funcionando correctamente** ✅
2. Los reportes de Trivy se guardan como **artefactos** ✅
3. Solo no aparecerán en la pestaña Security (pero los datos están disponibles)
4. El `continue-on-error: true` evita que el pipeline falle

---

## 🆘 Soporte

Si tienes problemas para habilitar:

- **GitHub Docs:** https://docs.github.com/en/code-security/code-scanning/introduction-to-code-scanning/about-code-scanning
- **Verificar que el repo es público:** Settings → General → Repository visibility
- **Re-intentar:** A veces GitHub tarda unos segundos en activar la función

---

**✨ Nota:** Esta es una característica muy útil y completamente gratuita para repositorios públicos. ¡Vale la pena habilitarla!
