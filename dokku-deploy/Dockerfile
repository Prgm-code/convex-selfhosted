# Dockerfile para despliegue en Dokku
# Usa la imagen oficial de Convex Backend
FROM ghcr.io/get-convex/convex-backend:latest

# El directorio de datos se montará como volumen persistente
VOLUME ["/convex/data"]

# Exponer los puertos necesarios
EXPOSE 3210 3211

# Healthcheck
HEALTHCHECK --interval=5s --timeout=3s --start-period=10s \
  CMD curl -f http://localhost:3210/version || exit 1

# El comando de inicio está definido en la imagen base
# No es necesario especificarlo aquí
