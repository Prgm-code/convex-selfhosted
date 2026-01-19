# Despliegue de Convex Self-Hosted en Dokku

Esta guía te ayudará a desplegar Convex Self-Hosted en Dokku con persistencia de datos.

## Requisitos Previos

- Dokku instalado en tu servidor
- Acceso SSH al servidor Dokku
- Git configurado

## Configuración Inicial

### 1. Configurar Variables de Entorno

Copia el archivo de ejemplo y configura tus variables:

```bash
cp .env.example .env
# Edita .env con tus valores
```

### 2. Ejecutar Script de Configuración

Ejecuta el script de configuración para crear la aplicación y configurar volúmenes:

```bash
chmod +x dokku-setup.sh
./dokku-setup.sh convex-backend
```

O especifica un nombre personalizado:

```bash
./dokku-setup.sh mi-convex-app
```

### 3. Configurar Variables de Entorno en Dokku

Configura las variables de entorno necesarias:

```bash
# Variables mínimas requeridas
dokku config:set convex-backend \
  INSTANCE_NAME=convex-instance \
  INSTANCE_SECRET=$(openssl rand -hex 32) \
  RUST_LOG=info \
  DO_NOT_REQUIRE_SSL=true \
  DISABLE_BEACON=true

# Si usas base de datos PostgreSQL
dokku config:set convex-backend \
  DATABASE_URL=postgresql://user:password@host:5432/dbname

# Si usas S3 para almacenamiento
dokku config:set convex-backend \
  AWS_ACCESS_KEY_ID=tu-key \
  AWS_SECRET_ACCESS_KEY=tu-secret \
  AWS_REGION=us-east-1 \
  S3_STORAGE_FILES_BUCKET=convex-files \
  S3_STORAGE_MODULES_BUCKET=convex-modules \
  S3_STORAGE_SEARCH_BUCKET=convex-search
```

### 4. Configurar Dominio (Opcional)

```bash
dokku domains:set convex-backend tu-dominio.com
```

## Despliegue

### Opción 1: Push desde Git

```bash
# Agregar remoto de Dokku
git remote add dokku dokku@tu-servidor:convex-backend

# Desplegar
git push dokku main
```

### Opción 2: Build Local y Push

```bash
# Construir imagen localmente
docker build -t convex-backend .

# Tag y push a registro de Dokku
docker tag convex-backend dokku/convex-backend:latest
docker save dokku/convex-backend:latest | ssh dokku@tu-servidor "docker load"
ssh dokku@tu-servidor "dokku tags:deploy convex-backend latest"
```

## Persistencia de Datos

Los datos se almacenan en el volumen persistente montado en `/convex/data`. El script de configuración crea automáticamente el volumen en:

```
/var/lib/dokku/data/storage/convex-backend
```

Para verificar el montaje:

```bash
dokku storage:report convex-backend
```

Para hacer backup del volumen:

```bash
# En el servidor Dokku
sudo tar -czf convex-backup-$(date +%Y%m%d).tar.gz /var/lib/dokku/data/storage/convex-backend
```

## Verificación

Verifica que la aplicación está funcionando:

```bash
# Ver logs
dokku logs convex-backend

# Ver estado
dokku ps:report convex-backend

# Verificar healthcheck
curl http://tu-dominio.com/version
```

## Comandos Útiles

```bash
# Ver todas las configuraciones
dokku config:show convex-backend

# Ver logs en tiempo real
dokku logs -t convex-backend

# Reiniciar la aplicación
dokku ps:restart convex-backend

# Ver uso de recursos
dokku resource:report convex-backend

# Ver información de almacenamiento
dokku storage:report convex-backend
```

## Solución de Problemas

### La aplicación no inicia

1. Verifica los logs: `dokku logs convex-backend`
2. Verifica las variables de entorno: `dokku config:show convex-backend`
3. Verifica el healthcheck: `dokku checks:report convex-backend`

### Problemas de persistencia

1. Verifica que el volumen está montado: `dokku storage:report convex-backend`
2. Verifica permisos: `sudo ls -la /var/lib/dokku/data/storage/convex-backend`

### Problemas de conexión

1. Verifica los puertos: `dokku proxy:ports-report convex-backend`
2. Verifica el dominio: `dokku domains:report convex-backend`

## Actualización

Para actualizar a una nueva versión:

```bash
# Pull de la nueva imagen
git pull
git push dokku main

# O si usas tags específicos, actualiza el Dockerfile con la nueva versión
```

## Backup y Restauración

### Backup

```bash
# Backup del volumen de datos
ssh dokku@tu-servidor "sudo tar -czf /tmp/convex-backup.tar.gz /var/lib/dokku/data/storage/convex-backend"

# Backup de variables de entorno
dokku config:export convex-backend > convex-config-backup.txt
```

### Restauración

```bash
# Restaurar volumen
ssh dokku@tu-servidor "sudo tar -xzf /tmp/convex-backup.tar.gz -C /"

# Restaurar variables de entorno
dokku config:set convex-backend < convex-config-backup.txt
```




