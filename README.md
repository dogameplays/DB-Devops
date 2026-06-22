# Base de Datos DevOps

Capa de datos para la solución Innovatech Chile, basada en MySQL/MariaDB.

## 🚀 Descripción
Base de datos relacional que almacena toda la información de inventario y tickets del sistema. Proporciona un esquema estructurado con datos de inicialización.

## 📋 Requisitos
- Docker y Docker Compose
- MySQL 8.0+ o MariaDB 10.5+

## 🛠️ Stack Tecnológico
- **MySQL** 8.0+ o **MariaDB** 10.5+
- **SQL** para esquema y seed

## 🌍 Puerto
- **3306** (MySQL/MariaDB)

## 🐳 Docker
```bash
docker-compose up --build
```

## 🔐 Variables de Entorno
Configurar en `docker-compose.yml` o archivo `.env`:
```
MYSQL_DATABASE=innovatech
MYSQL_USER=innovatech_user
MYSQL_PASSWORD=innovatech_pass
MYSQL_ROOT_PASSWORD=root_secure_password
```

## 📊 Esquema de Base de Datos

### Tablas Principales
- **inventory_items** - Registro de items del inventario
- **support_tickets** - Sistema de tickets de soporte

## 🔄 Inicialización

### Archivo `schema.sql`
Define la estructura de las tablas y sus relaciones.

### Archivo `seed.sql`
Inserta datos de ejemplo para pruebas iniciales.

### Proceso de Inicialización
Los archivos SQL se ejecutan automáticamente cuando se levanta el contenedor:
1. Se crea la base de datos
2. Se ejecuta `schema.sql` (estructura)
3. Se ejecuta `seed.sql` (datos de ejemplo)

## 🔗 Conexión desde el Backend
El backend Node.js se conectará usando:
```
Host: localhost (o nombre del servicio en Docker)
Puerto: 3306
Usuario: innovatech_user
Contraseña: innovatech_pass
Base de Datos: innovatech
```

## 📝 Notas
- Cambiar contraseñas en producción
- Los datos de ejemplo son solo para desarrollo/testing
- El volumen de datos se persiste en Docker para mantener información entre reinicios
- Hacer backup regular de los datos en producción