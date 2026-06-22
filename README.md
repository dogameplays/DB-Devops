# Base de Datos DevOps

Capa de datos para la solución Innovatech Chile, basada en MySQL 8.0.

## 🚀 Descripción
Base de datos relacional que almacena toda la información de inventario y tickets del sistema. Proporciona un esquema estructurado con datos de inicialización automática mediante scripts SQL.

## 📋 Requisitos
- Docker y Docker Compose
- MySQL 8.0+

## 🛠️ Stack Tecnológico
- **MySQL** 8.0
- **SQL** para esquema y seed

## 🌍 Puerto
- **3306** (MySQL)

## 🐳 Docker
```bash
docker-compose up --build
```

**Dockerfile:**
- Imagen base: MySQL 8.0
- Copia scripts SQL a `/docker-entrypoint-initdb.d/`
- Se ejecutan automáticamente en orden alfabético (1-schema.sql, 2-seed.sql)

## 🔐 Variables de Entorno
Configuradas en `docker-compose.yml`:
```
MYSQL_DATABASE=innovatech_ops
MYSQL_USER=innovatech_user
MYSQL_PASSWORD=innovatech_password
MYSQL_ROOT_PASSWORD=root_password
```

## 📊 Esquema de Base de Datos

### Tablas Principales (definidas en schema.sql)
- **inventory_items** - Registro de items del inventario
- **support_tickets** - Sistema de tickets de soporte

### Datos Iniciales (cargados desde seed.sql)
- Datos de ejemplo para desarrollo y testing

## 🔄 Proceso de Inicialización
1. Docker crea el contenedor MySQL
2. Se crea la base de datos: `innovatech_ops`
3. Se ejecuta `1-schema.sql` (estructura de tablas)
4. Se ejecuta `2-seed.sql` (datos de ejemplo)
5. MySQL queda listo para conexiones

## 🔗 Conexión desde el Backend
El Backend se conecta usando credenciales configuradas en `docker-compose.yml`:
```
Host: 10.0.3.238
Puerto: 3306
Usuario: innovatech_user
Contraseña: innovatech_password
Base de Datos: innovatech_ops
```

**Para desarrollo local:**
```
Host: localhost
Puerto: 3306
Usuario: innovatech_user
Contraseña: innovatech_password
Base de Datos: innovatech_ops
```

## 📦 Persistencia de Datos

El `docker-compose.yml` incluye:
- **Volumen `mysql_data`:** Persiste datos entre reinicios del contenedor
- **Health check:** Verifica que MySQL esté listo (mysqladmin ping)
- **Restart policy:** `always` - reinicia automáticamente si falla

## ✅ Health Check
```bash
# Verificar estado de MySQL
docker-compose ps

# Ver logs
docker-compose logs -f db

# Conectarse a la base de datos
docker exec -it innovatech_db mysql -u innovatech_user -p innovatech_ops
```

## 📝 Notas Importantes
- Los datos en el volumen `mysql_data` persisten incluso si el contenedor se elimina
- Para producción, cambiar las contraseñas en las variables de entorno
- El timeout del health check es 20 segundos (máximo 10 intentos)
- En producción, la DB está alojada en **10.0.3.238**
- Hacer backups regulares de `mysql_data` para garantizar recuperación ante desastres