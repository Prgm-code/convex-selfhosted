# Despliegue de Convex Self-Hosted en Coolify

Esta guía te ayudará a desplegar Convex Self-Hosted en Coolify usando Docker Compose.

## Requisitos Previos

- Coolify instalado y funcionando
- Acceso a la interfaz web de Coolify
- Un dominio configurado (recomendado)

## Despliegue Rápido

### 1. Crear Nuevo Proyecto en Coolify

1. Ve a tu instancia de Coolify
2. Click en **"+ New Resource"**
3. Selecciona **"Docker Compose"**
4. Elige **"From GitHub"** o **"Empty"**

### 2. Configurar el Repositorio

**Opción A: Desde GitHub**
- URL del repositorio: `https://github.com/tu-usuario/convex-selfhosted`
- Branch: `main`
- Compose file: `docker-compose.coolify.yml`

**Opción B: Compose Manual**
- Copia el contenido de `docker-compose.coolify.yml` directamente en Coolify

### 3. Configurar Variables de Entorno

En la sección **"Environment Variables"** de Coolify, configura:

#### Variables Requeridas

```env
# Nombre de la instancia
INSTANCE_NAME=convex-instance

# ⚠️ IMPORTANTE: Genera un secret seguro
# Ejecuta: openssl rand -hex 32
INSTANCE_SECRET=tu-secret-seguro-aqui

# URLs con tu dominio de Coolify
CONVEX_CLOUD_ORIGIN=https://convex-backend.tudominio.com
CONVEX_SITE_ORIGIN=https://convex-site.tudominio.com
NEXT_PUBLIC_DEPLOYMENT_URL=https://convex-backend.tudominio.com
```

#### Variables Recomendadas

```env
RUST_LOG=info
DO_NOT_REQUIRE_SSL=true
DISABLE_BEACON=true
DOCUMENT_RETENTION_DELAY=172800
```

### 4. Configurar Dominios en Coolify

Para cada servicio, configura un dominio:

| Servicio | Puerto Interno | Dominio Sugerido |
|----------|---------------|------------------|
| backend | 3210 | convex-api.tudominio.com |
| backend (site) | 3211 | convex-site.tudominio.com |
| dashboard | 6791 | convex-dashboard.tudominio.com |

En Coolify:
1. Ve a la configuración del servicio
2. En **"Domains"**, agrega tu dominio
3. Habilita **"HTTPS"** si tienes SSL configurado

### 5. Configurar Volumen Persistente

El volumen `convex-data` se crea automáticamente. Para respaldos:

1. En Coolify, ve a **"Storage"**
2. Verifica que el volumen `convex-data` esté montado
3. La ruta en el contenedor es `/convex/data`

### 6. Desplegar

1. Click en **"Deploy"**
2. Espera a que los contenedores inicien
3. Verifica los logs para asegurar que no hay errores

## Configuración Avanzada

### Base de Datos Externa (PostgreSQL)

Si quieres usar PostgreSQL en lugar de SQLite:

```env
DATABASE_URL=postgresql://usuario:password@host:5432/convex
```

O si tienes PostgreSQL como otro servicio en Coolify, usa el nombre del servicio:
```env
DATABASE_URL=postgresql://usuario:password@postgres:5432/convex
```

### Almacenamiento S3

Para usar S3 o un servicio compatible (MinIO):

```env
AWS_ACCESS_KEY_ID=tu-access-key
AWS_SECRET_ACCESS_KEY=tu-secret-key
AWS_REGION=us-east-1
S3_ENDPOINT_URL=https://s3.amazonaws.com

S3_STORAGE_FILES_BUCKET=convex-files
S3_STORAGE_MODULES_BUCKET=convex-modules
S3_STORAGE_SEARCH_BUCKET=convex-search
S3_STORAGE_EXPORTS_BUCKET=convex-exports
S3_STORAGE_SNAPSHOT_IMPORTS_BUCKET=convex-snapshots
```

Para MinIO u otros compatibles con S3:
```env
AWS_S3_FORCE_PATH_STYLE=true
AWS_S3_DISABLE_CHECKSUMS=true
AWS_S3_DISABLE_SSE=true
S3_ENDPOINT_URL=https://minio.tudominio.com
```

### Proxy Reverso con Traefik (Automático en Coolify)

Coolify configura Traefik automáticamente. Si necesitas configuración personalizada:

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.convex.rule=Host(`convex.tudominio.com`)"
  - "traefik.http.routers.convex.tls=true"
  - "traefik.http.routers.convex.tls.certresolver=letsencrypt"
```

## Verificación

### Verificar Backend

```bash
curl https://convex-backend.tudominio.com/version
```

Debería devolver la versión del backend.

### Verificar Dashboard

Abre en tu navegador:
```
https://convex-dashboard.tudominio.com
```

### Ver Logs en Coolify

1. Ve a tu proyecto en Coolify
2. Click en el servicio (backend o dashboard)
3. Ve a la pestaña **"Logs"**

## Solución de Problemas

### El backend no inicia

1. Verifica que `INSTANCE_SECRET` esté configurado
2. Revisa los logs en Coolify
3. Asegúrate de que el volumen tenga permisos correctos

### El dashboard no se conecta al backend

1. Verifica que `NEXT_PUBLIC_DEPLOYMENT_URL` apunte al dominio correcto del backend
2. Asegúrate de que el backend esté healthy
3. Verifica que ambos servicios estén en la misma red

### Error de permisos en volumen

En Coolify, puedes ejecutar comandos en el contenedor:
```bash
# En la terminal del contenedor
ls -la /convex/data
```

### Healthcheck falla

1. Espera al menos 30 segundos después del inicio
2. Verifica que el puerto 3210 esté expuesto
3. Revisa los logs del backend

## Backup y Restauración

### Backup del Volumen

En Coolify, puedes hacer backup del volumen desde la UI o via SSH:

```bash
# En el servidor de Coolify
docker run --rm -v convex-data:/data -v $(pwd):/backup alpine tar czf /backup/convex-backup-$(date +%Y%m%d).tar.gz -C /data .
```

### Restauración

```bash
docker run --rm -v convex-data:/data -v $(pwd):/backup alpine sh -c "cd /data && tar xzf /backup/convex-backup-YYYYMMDD.tar.gz"
```

## Actualización

Para actualizar a una nueva versión:

1. En Coolify, ve a tu proyecto
2. Click en **"Redeploy"** o **"Pull & Deploy"**
3. Coolify descargará la última imagen y reiniciará los contenedores

## Variables de Entorno - Referencia Completa

| Variable | Requerida | Descripción | Valor por Defecto |
|----------|-----------|-------------|-------------------|
| `INSTANCE_NAME` | Sí | Nombre de tu instancia | `convex-instance` |
| `INSTANCE_SECRET` | Sí | Secret para autenticación | - |
| `CONVEX_CLOUD_ORIGIN` | Sí | URL pública del backend | - |
| `CONVEX_SITE_ORIGIN` | Sí | URL del site proxy | - |
| `NEXT_PUBLIC_DEPLOYMENT_URL` | Sí | URL para el dashboard | - |
| `RUST_LOG` | No | Nivel de logging | `info` |
| `DO_NOT_REQUIRE_SSL` | No | Deshabilitar SSL requerido | `true` |
| `DISABLE_BEACON` | No | Deshabilitar telemetría | `true` |
| `DOCUMENT_RETENTION_DELAY` | No | Retención de documentos (segundos) | `172800` |
| `DATABASE_URL` | No | URL de PostgreSQL/MySQL | - |
| `AWS_*` | No | Configuración de S3 | - |

## Soporte

- [Documentación de Convex](https://docs.convex.dev/)
- [Documentación de Coolify](https://coolify.io/docs/)
- [GitHub de Convex Backend](https://github.com/get-convex/convex-backend)
