#!/usr/bin/env zsh
# Script para configurar Convex Self-Hosted en Dokku
# Uso: ./dokku-setup.sh <nombre-app>
# Nota: Requiere que dokku esté disponible como alias o comando en zsh

set -e

# Cargar configuración de zsh para tener acceso a aliases
if [ -f ~/.zshrc ]; then
    source ~/.zshrc
fi

APP_NAME=${1:-convex-backend}
STORAGE_PATH="/var/lib/dokku/data/storage/${APP_NAME}"

echo "🚀 Configurando Convex Self-Hosted en Dokku..."
echo "📦 Nombre de la aplicación: ${APP_NAME}"

# Crear la aplicación si no existe
if ! dokku apps:exists ${APP_NAME} &> /dev/null; then
    echo "📱 Creando aplicación Dokku: ${APP_NAME}"
    dokku apps:create ${APP_NAME}
else
    echo "✅ La aplicación ${APP_NAME} ya existe"
fi

# Crear directorio de almacenamiento persistente
echo "💾 Configurando almacenamiento persistente..."
# El directorio se creará en el servidor Dokku, no localmente
# Si el usuario dokku existe (ejecutando en el servidor), configurar permisos
if id -u dokku &>/dev/null; then
    sudo mkdir -p ${STORAGE_PATH}
    sudo chown -R dokku:dokku ${STORAGE_PATH}
else
    echo "⚠️  Usuario 'dokku' no encontrado. El directorio se creará automáticamente al montar el volumen."
    echo "   Si ejecutas esto en el servidor Dokku, asegúrate de que el usuario 'dokku' exista."
fi

# Montar volumen persistente
echo "🔗 Montando volumen de datos..."
dokku storage:mount ${APP_NAME} ${STORAGE_PATH}:/convex/data

# Configurar puertos
echo "🔌 Configurando puertos..."
dokku proxy:ports-set ${APP_NAME} http:80:3210 https:443:3210
dokku proxy:ports-add ${APP_NAME} http:3211:3211

# Configurar variables de entorno desde .env si existe
if [ -f .env ]; then
    echo "⚙️  Configurando variables de entorno desde .env..."
    dokku config:set ${APP_NAME} < .env
elif [ -f env.example ]; then
    echo "ℹ️  Archivo env.example encontrado. Copia a .env y configura los valores:"
    echo "   cp env.example .env"
    echo "   # Edita .env y luego ejecuta: dokku config:set ${APP_NAME} < .env"
else
    echo "⚠️  Archivo .env no encontrado. Configura las variables manualmente con:"
    echo "   dokku config:set ${APP_NAME} KEY=value"
fi

# Configurar variables mínimas requeridas si no están configuradas
echo "🔧 Configurando variables mínimas..."
dokku config:set ${APP_NAME} \
    INSTANCE_NAME=${INSTANCE_NAME:-convex-instance} \
    INSTANCE_SECRET=${INSTANCE_SECRET:-$(openssl rand -hex 32)} \
    RUST_LOG=${RUST_LOG:-info} \
    DOCUMENT_RETENTION_DELAY=${DOCUMENT_RETENTION_DELAY:-172800} \
    DO_NOT_REQUIRE_SSL=true \
    DISABLE_BEACON=true \
    || true

# Configurar healthcheck
echo "🏥 Configurando healthcheck..."
dokku checks:set ${APP_NAME} web curl -f http://localhost:3210/version

# Configurar dominio (opcional)
if [ -n "${DOMAIN}" ]; then
    echo "🌐 Configurando dominio: ${DOMAIN}"
    dokku domains:set ${APP_NAME} ${DOMAIN}
fi

echo ""
echo "✅ Configuración completada!"
echo ""
echo "📝 Próximos pasos:"
echo "   1. Configura las variables de entorno necesarias:"
echo "      dokku config:set ${APP_NAME} INSTANCE_SECRET=tu-secret-seguro"
echo ""
echo "   2. Si usas base de datos, configura DATABASE_URL:"
echo "      dokku config:set ${APP_NAME} DATABASE_URL=postgresql://..."
echo ""
echo "   3. Si usas S3, configura las variables de AWS:"
echo "      dokku config:set ${APP_NAME} AWS_ACCESS_KEY_ID=... AWS_SECRET_ACCESS_KEY=..."
echo ""
echo "   4. Despliega la aplicación:"
echo "      git remote add dokku dokku@tu-servidor:${APP_NAME}"
echo "      git push dokku main"
echo ""
echo "   5. Verifica el estado:"
echo "      dokku ps:report ${APP_NAME}"
echo "      dokku logs ${APP_NAME}"

