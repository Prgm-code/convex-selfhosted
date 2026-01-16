# Análisis del Fallo del Despliegue

## Problemas Identificados

### 1. **Permisos de Docker** ✅
**Estado**: Ya resuelto - Docker está configurado sin necesidad de `sudo`.

**Nota**: Todos los comandos de Docker en este documento asumen que Docker está disponible sin `sudo`.

### 2. **Variables de Entorno Críticas Faltantes o Inválidas** 🔴
**Problema**: El archivo `.env` tiene valores placeholder que pueden causar fallos:
- `INSTANCE_SECRET=tu-secret-aqui-cambiar-en-produccion` (debe ser un valor seguro)

**Solución**:
```bash
# Generar un secret seguro
INSTANCE_SECRET=$(openssl rand -hex 32)

# Actualizar .env
sed -i "s/INSTANCE_SECRET=.*/INSTANCE_SECRET=${INSTANCE_SECRET}/" .env
```

### 3. **Variables de Entorno No Cargadas Correctamente** ⚠️
**Problema**: `docker-compose.yml` lista variables pero algunas no tienen valores por defecto. Si no están en `.env` o en el entorno, el backend puede fallar.

**Variables críticas requeridas**:
- `INSTANCE_NAME` (tiene valor por defecto en .env)
- `INSTANCE_SECRET` (debe ser un valor seguro, no placeholder)
- `DO_NOT_REQUIRE_SSL` (recomendado para desarrollo)
- `DISABLE_BEACON` (opcional pero recomendado)

### 4. **Healthcheck Puede Estar Fallando** ⚠️
**Problema**: El dashboard depende del backend siendo saludable. Si el backend no pasa el healthcheck, el dashboard no se iniciará.

**Verificación**:
```bash
# Ver logs del backend
sudo docker compose logs backend

# Verificar healthcheck manualmente
sudo docker compose exec backend curl -f http://localhost:3210/version
```

### 5. **Volumen de Datos - Permisos** ⚠️
**Problema**: El volumen `data` puede tener permisos incorrectos que impiden que el backend escriba datos.

**Solución**:
```bash
# Verificar permisos del volumen
sudo docker volume inspect convex-selfhosted_data

# Si es necesario, ajustar permisos
sudo docker compose down
sudo docker volume rm convex-selfhosted_data
sudo docker compose up -d
```

## Pasos para Solucionar

### Paso 1: Corregir Variables de Entorno
```bash
# Generar INSTANCE_SECRET seguro
INSTANCE_SECRET=$(openssl rand -hex 32)

# Actualizar .env
cat >> .env << EOF
# Variables adicionales requeridas
DO_NOT_REQUIRE_SSL=true
DISABLE_BEACON=true
RUST_LOG=info
DOCUMENT_RETENTION_DELAY=172800
EOF

# Reemplazar el placeholder de INSTANCE_SECRET
sed -i "s/INSTANCE_SECRET=tu-secret-aqui-cambiar-en-produccion/INSTANCE_SECRET=${INSTANCE_SECRET}/" .env
```

### Paso 2: Agregar Usuario al Grupo Docker (Opcional pero Recomendado)
```bash
sudo usermod -aG docker $USER
newgrp docker
```

### Paso 3: Detener y Reiniciar con Configuración Correcta
```bash
# Detener contenedores actuales
docker compose down

# Verificar que .env está correcto
cat .env | grep -E "INSTANCE_SECRET|DO_NOT_REQUIRE_SSL"

# Iniciar de nuevo
docker compose up -d

# Ver logs en tiempo real
docker compose logs -f
```

### Paso 4: Verificar Estado
```bash
# Ver estado de los contenedores
docker compose ps

# Verificar que el backend está saludable
docker compose exec backend curl -f http://localhost:3210/version

# Verificar que el dashboard está corriendo
curl http://localhost:6791
```

## Comandos de Diagnóstico

```bash
# Ver todos los logs
docker compose logs

# Ver solo logs del backend
docker compose logs backend

# Ver solo logs del dashboard
docker compose logs dashboard

# Ver estado de salud
docker compose ps

# Verificar variables de entorno en el contenedor
docker compose exec backend env | grep -E "INSTANCE|DATABASE|AWS"

# Verificar conectividad
docker compose exec backend curl -f http://localhost:3210/version
```

## Errores Comunes y Soluciones

### Error: "permission denied while trying to connect to the Docker daemon socket"
**Estado**: Ya resuelto - Docker está configurado correctamente

### Error: Backend no inicia / Healthcheck falla
**Causas posibles**:
- `INSTANCE_SECRET` inválido o faltante
- Variables de entorno no cargadas
- Problemas de permisos en el volumen de datos

**Solución**: Verificar logs y variables de entorno

### Error: Dashboard no inicia
**Causa**: El backend no pasa el healthcheck
**Solución**: Arreglar el backend primero, luego el dashboard se iniciará automáticamente

## Verificación Final

Una vez corregido, deberías poder:
1. ✅ Ver ambos contenedores corriendo: `docker compose ps`
2. ✅ Acceder al backend: `curl http://localhost:3210/version`
3. ✅ Acceder al dashboard: `curl http://localhost:6791`
4. ✅ Ver logs sin errores críticos: `docker compose logs`
