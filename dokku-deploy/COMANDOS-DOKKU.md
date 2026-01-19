# Comandos Útiles de Dokku

## Aplicaciones

### Listar aplicaciones
```bash
dokku apps:list
```

### Crear aplicación
```bash
dokku apps:create nombre-app
```

### Eliminar aplicación
```bash
dokku apps:destroy nombre-app
```

### Ver información de aplicación
```bash
dokku apps:report nombre-app
```

## Variables de Entorno

### Listar todas las variables
```bash
dokku config:show nombre-app
```

### Agregar/Actualizar variables
```bash
dokku config:set nombre-app KEY1=value1 KEY2=value2
```

### Eliminar variable
```bash
dokku config:unset nombre-app KEY1
```

### Exportar variables a archivo
```bash
dokku config:export nombre-app > .env.backup
```

### Importar variables desde archivo
```bash
dokku config:set nombre-app < .env
```

## Despliegue

### Agregar remoto Git
```bash
git remote add dokku dokku@servidor:nombre-app
```

### Desplegar
```bash
git push dokku main
```

### Forzar redeploy
```bash
dokku ps:rebuild nombre-app
```

### Reiniciar aplicación
```bash
dokku ps:restart nombre-app
```

### Detener aplicación
```bash
dokku ps:stop nombre-app
```

### Iniciar aplicación
```bash
dokku ps:start nombre-app
```

## Logs

### Ver logs
```bash
dokku logs nombre-app
```

### Logs en tiempo real
```bash
dokku logs -t nombre-app
```

### Últimas N líneas
```bash
dokku logs -t nombre-app -n 100
```

## Puertos y Proxy

### Listar puertos configurados
```bash
dokku proxy:ports-report nombre-app
```

### Configurar puertos
```bash
dokku proxy:ports-set nombre-app http:80:3210 https:443:3210
```

### Agregar puerto adicional
```bash
dokku proxy:ports-add nombre-app http:3211:3211
```

### Eliminar puerto
```bash
dokku proxy:ports-remove nombre-app http:3211:3211
```

## Dominios

### Listar dominios
```bash
dokku domains:report nombre-app
```

### Agregar dominio
```bash
dokku domains:set nombre-app ejemplo.com www.ejemplo.com
```

### Eliminar dominio
```bash
dokku domains:unset nombre-app ejemplo.com
```

## Almacenamiento (Storage)

### Listar volúmenes montados
```bash
dokku storage:report nombre-app
```

### Montar volumen
```bash
dokku storage:mount nombre-app /var/lib/dokku/data/storage/nombre-app:/convex/data
```

### Desmontar volumen
```bash
dokku storage:unmount nombre-app /convex/data
```

## Procesos y Estado

### Ver estado de procesos
```bash
dokku ps:report nombre-app
```

### Ver contenedores corriendo
```bash
dokku ps:inspect nombre-app
```

### Escalar procesos (si aplica)
```bash
dokku ps:scale nombre-app web=1
```

## Healthchecks

### Configurar healthcheck
```bash
dokku checks:set nombre-app web curl -f http://localhost:3210/version
```

### Ver configuración de healthcheck
```bash
dokku checks:report nombre-app
```

### Deshabilitar healthcheck
```bash
dokku checks:disable nombre-app
```

## Base de Datos (Plugins)

### Instalar plugin PostgreSQL
```bash
sudo dokku plugin:install https://github.com/dokku/dokku-postgres.git postgres
```

### Crear base de datos
```bash
dokku postgres:create nombre-db
```

### Vincular base de datos a app
```bash
dokku postgres:link nombre-db nombre-app
```

### Ver información de base de datos
```bash
dokku postgres:info nombre-db
```

### Backup de base de datos
```bash
dokku postgres:export nombre-db > backup.sql
```

### Restaurar base de datos
```bash
dokku postgres:import nombre-db < backup.sql
```

## SSL/HTTPS

### Habilitar SSL (Let's Encrypt)
```bash
dokku letsencrypt:enable nombre-app
```

### Renovar certificados
```bash
dokku letsencrypt:renew nombre-app
```

### Ver estado SSL
```bash
dokku letsencrypt:list
```

## Ejecutar Comandos

### Ejecutar comando en contenedor
```bash
dokku run nombre-app comando
```

### Abrir shell interactivo
```bash
dokku enter nombre-app
```

### Ejecutar comando como root
```bash
dokku enter nombre-app root
```

## Limpieza y Mantenimiento

### Limpiar imágenes no usadas
```bash
dokku cleanup
```

### Ver uso de recursos
```bash
dokku resource:report nombre-app
```

### Ver eventos
```bash
dokku events:on
```

## Backup y Restauración

### Backup de aplicación completa
```bash
# Backup de variables
dokku config:export nombre-app > config-backup.txt

# Backup de storage (si está montado)
sudo tar -czf storage-backup.tar.gz /var/lib/dokku/data/storage/nombre-app
```

### Restaurar aplicación
```bash
# Restaurar variables
dokku config:set nombre-app < config-backup.txt

# Restaurar storage
sudo tar -xzf storage-backup.tar.gz -C /
```

## Información del Sistema

### Versión de Dokku
```bash
dokku version
```

### Ver todas las apps y recursos
```bash
dokku apps:list
dokku postgres:list
```

### Ver logs del sistema Dokku
```bash
sudo journalctl -u dokku -f
```

## Ejemplos Completos

### Setup completo de Convex
```bash
# 1. Crear app
dokku apps:create convex-backend

# 2. Configurar storage
sudo mkdir -p /var/lib/dokku/data/storage/convex-backend
sudo chown -R dokku:dokku /var/lib/dokku/data/storage/convex-backend
dokku storage:mount convex-backend /var/lib/dokku/data/storage/convex-backend:/convex/data

# 3. Configurar puertos
dokku proxy:ports-set convex-backend http:80:3210 https:443:3210
dokku proxy:ports-add convex-backend http:3211:3211

# 4. Configurar variables
dokku config:set convex-backend \
  INSTANCE_NAME=convex-instance \
  INSTANCE_SECRET=$(openssl rand -hex 32) \
  RUST_LOG=info \
  DO_NOT_REQUIRE_SSL=true \
  DISABLE_BEACON=true

# 5. Configurar dominio
dokku domains:set convex-backend convex.tudominio.com

# 6. Configurar healthcheck
dokku checks:set convex-backend web curl -f http://localhost:3210/version

# 7. Desplegar
git remote add dokku dokku@servidor:convex-backend
git push dokku main
```
