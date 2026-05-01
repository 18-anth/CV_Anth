#!/bin/bash

# 📋 GUÍA RÁPIDA: Configurar Sincronización Drive → Firebase
# 
# Este script te guía paso a paso para configurar el sistema de sincronización

set -e

echo "════════════════════════════════════════════════════════════"
echo "🔄 SINCRONIZACIÓN: GOOGLE DRIVE → FIREBASE"
echo "════════════════════════════════════════════════════════════"
echo ""

# Paso 1: Verificar dependencias
echo "📦 Paso 1: Verificar dependencias..."
if ! command -v node &> /dev/null; then
  echo "❌ Node.js no está instalado. Instálalo desde https://nodejs.org"
  exit 1
fi
echo "✅ Node.js: $(node --version)"

# Paso 2: Crear archivo .env.sync
echo ""
echo "📝 Paso 2: Crear archivo .env.sync..."
if [ ! -f ".env.sync" ]; then
  cp .env.sync.example .env.sync
  echo "✅ Archivo .env.sync creado"
  echo "   📌 Ahora debes editar este archivo con tus credenciales"
else
  echo "ℹ️  .env.sync ya existe"
fi

# Paso 3: Mostrar instrucciones de obtener credenciales
echo ""
echo "🔐 Paso 3: Obtener Google Service Account"
echo ""
echo "Sigue estos pasos:"
echo "  1. Ve a https://console.cloud.google.com"
echo "  2. Selecciona tu proyecto"
echo "  3. Ve a 'Credenciales' → 'Crear credencial' → 'Service Account'"
echo "  4. Crea una clave JSON"
echo "  5. Descarga el archivo JSON"
echo "  6. Copia el archivo a esta carpeta: scripts/service-account.json"
echo ""
echo "📌 O configura GOOGLE_APPLICATION_CREDENTIALS en .env.sync"
echo ""

# Paso 4: Instalar dependencias
echo "📦 Paso 4: Instalar dependencias Node.js..."
if [ ! -d "node_modules" ]; then
  npm install
  echo "✅ Dependencias instaladas"
else
  echo "ℹ️  node_modules ya existe"
fi

# Paso 5: Verificar configuración
echo ""
echo "🔧 Paso 5: Verificar configuración..."
echo ""
echo "Abre .env.sync y asegúrate de tener:"
echo ""
echo "  GOOGLE_APPLICATION_CREDENTIALS=scripts/service-account.json"
echo "  FIREBASE_DATABASE_URL=https://TU_PROYECTO.firebaseio.com"
echo "  REACT_APP_GOOGLE_DRIVE_FOLDER_ID=1yT6iFdqcfY-6omMcmuM-Y9aBrBOzmdOI"
echo ""
echo "Presiona ENTER cuando hayas configurado .env.sync"
read -p "➡️  "

# Paso 6: Probar sincronización
echo ""
echo "🧪 Paso 6: Probar sincronización..."
echo ""
node scripts/sync-certifications.js

echo ""
echo "════════════════════════════════════════════════════════════"
echo "✅ ¡SINCRONIZACIÓN CONFIGURADA!"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "🚀 Opciones disponibles:"
echo ""
echo "  1️⃣  Sincronización Manual (cuando lo necesites):"
echo "     node scripts/sync-certifications.js"
echo ""
echo "  2️⃣  Sincronización Automática (cada hora):"
echo "     firebase deploy --only functions:syncCertificationsScheduled"
echo ""
echo "  3️⃣  Sincronización Periódica (cron job):"
echo "     0 * * * * cd /ruta/proyecto && node scripts/sync-certifications.js"
echo ""
echo "📚 Más información: scripts/README.md"
echo ""
