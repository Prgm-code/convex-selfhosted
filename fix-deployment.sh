#!/usr/bin/env zsh
# Script para corregir problemas comunes del despliegue de Convex

set -e

echo "🔧 Corrigiendo problemas del despliegue de Convex..."
echo ""

# Verificar que .env existe
if [ ! -f .env ]; then
    echo "❌ Archivo .env no encontrado. Copiando desde .env.example..."
    if [ -f .env.example ]; then
        cp .env.example .env
    else
        echo "❌ .env.example tampoco existe. Creando .env básico..."
        cat > .env << 'EOF'
# Variables de entorno para Convex Self-Hosted
PORT=3210
SITE_PROXY_PORT=3211
DASHBOARD_PORT=6791

INSTANCE_NAME=convex-instance
INSTANCE_SECRET=
DO_NOT_REQUIRE_SSL=true
DISABLE_BEACON=true
RUST_LOG=info
DOCUMENT_RETENTION_DELAY=172800

CONVEX_CLOUD_ORIGIN=http://127.0.0.1:3210
CONVEX_SITE_ORIGIN=http://127.0.0.1:3211
NEXT_PUBLIC_DEPLOYMENT_URL=http://127.0.0.1:3210
EOF
    fi
fi

# Generar INSTANCE_SECRET si es necesario
if grep -q "INSTANCE_SECRET=tu-secret-aqui-cambiar-en-produccion" .env || ! grep -q "INSTANCE_SECRET=" .env || grep -q "^INSTANCE_SECRET=$" .env; then
    echo "🔐 Generando INSTANCE_SECRET seguro..."
    INSTANCE_SECRET=$(openssl rand -hex 32)
    
    if grep -q "^INSTANCE_SECRET=" .env; then
        # Reemplazar línea existente
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            sed -i '' "s|^INSTANCE_SECRET=.*|INSTANCE_SECRET=${INSTANCE_SECRET}|" .env
        else
            # Linux
            sed -i "s|^INSTANCE_SECRET=.*|INSTANCE_SECRET=${INSTANCE_SECRET}|" .env
        fi
    else
        # Agregar nueva línea
        echo "INSTANCE_SECRET=${INSTANCE_SECRET}" >> .env
    fi
    echo "✅ INSTANCE_SECRET generado y actualizado"
else
    echo "✅ INSTANCE_SECRET ya está configurado"
fi

# Asegurar que las variables críticas estén presentes
echo "⚙️  Verificando variables de entorno críticas..."

# Función para agregar o actualizar variable en .env
add_or_update_env() {
    local key=$1
    local value=$2
    
    if grep -q "^${key}=" .env; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s|^${key}=.*|${key}=${value}|" .env
        else
            sed -i "s|^${key}=.*|${key}=${value}|" .env
        fi
    else
        echo "${key}=${value}" >> .env
    fi
}

# Agregar variables críticas si no existen
add_or_update_env "DO_NOT_REQUIRE_SSL" "true"
add_or_update_env "DISABLE_BEACON" "true"
add_or_update_env "RUST_LOG" "info"
add_or_update_env "DOCUMENT_RETENTION_DELAY" "172800"

echo "✅ Variables de entorno verificadas"
echo ""

# Verificar que Docker está disponible
echo "🐳 Verificando Docker..."
if ! docker ps &> /dev/null; then
    echo "❌ Error: Docker no está disponible o no tienes permisos"
    echo ""
    echo "📋 Solución:"
    echo "   1. Agregar tu usuario al grupo docker:"
    echo "      sudo usermod -aG docker \$USER"
    echo ""
    echo "   2. Aplicar los cambios (elige una opción):"
    echo "      Opción A: Cerrar sesión y volver a iniciar"
    echo "      Opción B: Ejecutar: newgrp docker"
    echo "      Opción C: Ejecutar este script dentro de: newgrp docker"
    echo ""
    echo "   3. Verificar: docker ps"
    echo ""
    echo "   Si ya ejecutaste 'newgrp docker', ejecuta este script de nuevo:"
    echo "   ./fix-deployment.sh"
    exit 1
fi
echo "✅ Docker accesible"

# Detener contenedores si están corriendo
echo ""
echo "🛑 Deteniendo contenedores existentes..."
docker compose down 2>/dev/null || true

# Verificar que docker-compose.yml existe
if [ ! -f docker-compose.yml ]; then
    echo "❌ docker-compose.yml no encontrado"
    exit 1
fi

echo ""
echo "🚀 Iniciando contenedores con configuración corregida..."
docker compose up -d

echo ""
echo "⏳ Esperando a que los servicios inicien (10 segundos)..."
sleep 10

echo ""
echo "📊 Estado de los contenedores:"
docker compose ps

echo ""
echo "📋 Últimas líneas de logs del backend:"
docker compose logs --tail=20 backend

echo ""
echo "✅ Proceso completado!"
echo ""
echo "📝 Próximos pasos:"
echo "   1. Ver logs en tiempo real: docker compose logs -f"
echo "   2. Verificar salud del backend: docker compose exec backend curl -f http://localhost:3210/version"
echo "   3. Acceder al dashboard: http://localhost:6791"
echo ""
echo "🔍 Si hay problemas, revisa: ANALISIS-FALLO.md"
