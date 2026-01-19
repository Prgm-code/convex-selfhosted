# Despliegue en Dokku

Esta carpeta contiene lo necesario para desplegar Convex Self-Hosted en Dokku.

## Contenido

- `Dockerfile`: imagen base para Convex Backend.
- `docker-compose.yml`: compose para desarrollo local o uso con dokku-compose.
- `dokku-setup.sh`: script de configuración (volúmenes, puertos, envs).
- `README-DOKKU.md`: guía detallada.
- `COMANDOS-DOKKU.md`: referencia de comandos de Dokku.

## Pasos rápidos

1. Copia esta carpeta a tu servidor o clona el repo:

```bash
git clone https://github.com/Prgm-code/convex-selfhosted.git
cd convex-selfhosted/dokku-deploy
```

2. Ejecuta el setup en el servidor Dokku:

```bash
chmod +x dokku-setup.sh
./dokku-setup.sh convex-backend
```

3. Configura variables en Dokku (mínimas):

```bash
dokku config:set convex-backend \
  INSTANCE_NAME=convex-instance \
  INSTANCE_SECRET=$(openssl rand -hex 32) \
  RUST_LOG=info \
  DO_NOT_REQUIRE_SSL=true \
  DISABLE_BEACON=true
```

4. Despliega (desde tu PC):

```bash
git remote add dokku dokku@TU_SERVIDOR:convex-backend
git push dokku main
```

## Logs y estado

```bash
dokku logs convex-backend
dokku ps:report convex-backend
```

## Desarrollo Local con Docker Compose

Puedes probar localmente antes de desplegar a Dokku:

```bash
cd dokku-deploy
cp .env.example .env  # Si existe
# Edita .env con tus variables
docker compose up -d
```

## Nota

- Para más detalles de despliegue: `README-DOKKU.md`
- Para referencia de comandos: `COMANDOS-DOKKU.md`
