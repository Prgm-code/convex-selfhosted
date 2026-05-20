# Convex Self-Hosted (Coolify + Docker Local)

Este repositorio contiene dos modos de despliegue:

- **Coolify**: usando `docker-compose.coolify.yaml` en la raíz.
- **PC local**: usando `local-docker/docker-compose.yml`.

## Estructura

```
.
├── docker-compose.yaml            # Coolify
├── local-docker/
│   ├── docker-compose.yml         # Local (PC)
│   └── docker-compose.backup.yml  # Backup del compose original
├── README-COOLIFY.md
├── README-DOKKU.md
└── ...
```

## Despliegue en Coolify

1. En Coolify, crea un recurso **Docker Compose** y apunta a este repo.
2. Usa el archivo `docker-compose.yaml` (raíz).
3. Configura estas variables en **Environment Variables**:

```
BACKEND_HOST_PORT=3210
SITE_PROXY_HOST_PORT=3211
DASHBOARD_HOST_PORT=6791

CONVEX_CLOUD_ORIGIN=https://tu-dominio-backend
CONVEX_SITE_ORIGIN=https://tu-dominio-site
NEXT_PUBLIC_DEPLOYMENT_URL=https://tu-dominio-backend

# Opcional: forzar nuevo volumen (reset de DB)
CONVEX_DATA_VOLUME=convex-data-reset-1
```

4. **Deploy**.

> Nota: Para evitar errores del dashboard en SSR, se usa:
> `NEXT_PUBLIC_LOAD_MONACO_INTERNALLY=false` por defecto.

## Despliegue local (PC)

```bash
cd local-docker

docker compose up -d
```

Para logs:
```bash
docker compose logs -f
```

## Reset de base de datos

Si ves el error `missing _tables.by_id global`, la base está corrupta.
Soluciones:

- **Coolify**: cambia `CONVEX_DATA_VOLUME` y redeploy.
- **Local**: borra el volumen:

```bash
docker compose down -v
```

## Documentación adicional

- `README-COOLIFY.md`: guía detallada para Coolify.
- `README-DOKKU.md`: despliegue en Dokku.
