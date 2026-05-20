# Convex Self-Hosted

Repositorio con configuraciones Docker para desplegar Convex self-hosted en Coolify, con o sin publicacion directa de puertos, y para uso local.

## Archivos principales

| Archivo | Uso recomendado | Publica puertos en el host |
| --- | --- | --- |
| `docker-compose.coolify.yaml` | Coolify detras de Traefik/Coolify proxy | No |
| `docker-compose.yaml` | Coolify o servidor Docker con puertos locales publicados | Si, por defecto `3210`, `3211` y `6791` |
| `local-docker/docker-compose.yml` | Desarrollo o pruebas locales desde `local-docker/` | Si, usando variables locales |

## Que compose usar

Usa `docker-compose.coolify.yaml` cuando Coolify/Traefik debe exponer los servicios a internet. Este archivo no define `ports:`, por lo que los contenedores quedan accesibles dentro de la red Docker y Coolify se encarga del proxy publico.

Usa `docker-compose.yaml` cuando tambien quieres publicar puertos en el host del servidor. Por defecto expone:

- Backend API: `3210:3210`
- Site / HTTP actions: `3211:3211`
- Dashboard: `6791:6791`

Puedes cambiar esos puertos con:

```env
BACKEND_HOST_PORT=3210
SITE_PROXY_HOST_PORT=3211
DASHBOARD_HOST_PORT=6791
```

## Despliegue en Coolify sin exponer puertos

1. Crea un recurso **Docker Compose** en Coolify.
2. Apunta al archivo `docker-compose.coolify.yaml`.
3. Configura dominios/proxy para los puertos internos:

| Servicio | Puerto interno | Uso en el compose |
| --- | --- | --- |
| `backend` API | `3210` | `SERVICE_URL_BACKEND` para `CONVEX_CLOUD_ORIGIN` y `NEXT_PUBLIC_DEPLOYMENT_URL` |
| `backend` site | `3211` | `SERVICE_URL_SITE` para `CONVEX_SITE_ORIGIN` |
| `dashboard` | `6791` | Dominio/proxy configurado en Coolify para acceder al dashboard |

4. Define al menos estas variables:

```env
INSTANCE_NAME=convex-instance
INSTANCE_SECRET=<generar-con-openssl-rand-hex-32>
```

Coolify debe entregar `SERVICE_URL_BACKEND` y `SERVICE_URL_SITE`; el compose los usa para `CONVEX_CLOUD_ORIGIN`, `CONVEX_SITE_ORIGIN` y `NEXT_PUBLIC_DEPLOYMENT_URL`.

## Despliegue con puertos publicados

1. Crea un recurso **Docker Compose** en Coolify o ejecutalo en un servidor Docker.
2. Usa `docker-compose.yaml`.
3. Ajusta los puertos si los valores por defecto ya estan ocupados:

```env
BACKEND_HOST_PORT=3210
SITE_PROXY_HOST_PORT=3211
DASHBOARD_HOST_PORT=6791
PUBLIC_BACKEND_URL=http://localhost:3210
```

En Coolify, `INSTANCE_SECRET` se toma desde `SERVICE_HEX_32_SECRET`. Si lo ejecutas fuera de Coolify, define esa variable o adapta el compose para usar tu propio secret.

## Uso local

```bash
cd local-docker
docker compose up -d
```

Ver logs:

```bash
docker compose logs -f
```

Generar una admin key:

```bash
docker compose exec backend ./generate_admin_key.sh
```

## Reset de datos

El volumen persistente se llama `convex-data` salvo que definas `CONVEX_DATA_VOLUME`.

Para forzar un volumen nuevo:

```env
CONVEX_DATA_VOLUME=convex-data-reset-1
```

Para borrar el volumen local del compose activo:

```bash
docker compose down -v
```

## Seguridad antes de publicar

No publiques archivos `.env` reales. Este repo incluye `.env.example` y `env.coolify.example` solo con placeholders.

Antes de hacer publico el repositorio, revisa:

```bash
git status --short --ignored
git log --all --name-only --pretty=format: | sort -u
```

Si alguna vez se commiteo un secreto real, no basta con borrarlo del ultimo commit: hay que rotarlo y reescribir el historial antes de publicar.

## Documentacion adicional

- `README-COOLIFY.md`: guia extendida para Coolify.
- `README-DOKKU.md`: despliegue en Dokku.
- `local-docker/README.md`: notas del compose local original.
