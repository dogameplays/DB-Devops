# DB-Devops

MySQL 8.0 para Innovatech Inventory System

## Setup Local

```bash
docker-compose up          # Inicia BD en puerto 3306
docker-compose down        # Detiene BD
```

## Configurar .env

```
MYSQL_DATABASE=innovatech_ops
MYSQL_USER=innovatech_user
MYSQL_PASSWORD=innovatech_password
MYSQL_ROOT_PASSWORD=root_password
```

## Acceso

```bash
mysql -h 127.0.0.1 -u innovatech_user -p
# Password: innovatech_password
USE innovatech_ops;
SHOW TABLES;
```

## Docker

```bash
docker build -t innovatech-db .
docker run -p 3306:3306 -v mysql_data:/var/lib/mysql --env-file .env innovatech-db
```

## Deploy

Push a rama `deploy` dispara GitHub Actions que:
1. Compila imagen MySQL
2. Push a ECR
3. Despliega en EC2 via SSM
4. Inicializa schema.sql y seed.sql

## Archivos SQL

- `schema.sql` - Crea tablas Products y Tickets
- `seed.sql` - Datos iniciales de prueba
docker-compose logs -f db

# Detener contenedor
docker-compose down
```

### Acceso Directo a MySQL

```bash
# Conectar desde máquina local
mysql -h 127.0.0.1 -u innovatech_user -p

# Contraseña: innovatech_password

# Seleccionar base de datos
USE innovatech_ops;

# Mostrar tablas
SHOW TABLES;
```

### Prueba Docker Local

```bash
# Compilar imagen
docker build -t innovatech-db:latest .

# Ejecutar contenedor con volumen persistente
docker run -d \
  --name innovatech_db \
  -p 3306:3306 \
  -v mysql_data:/var/lib/mysql \
  -e MYSQL_DATABASE=innovatech_ops \
  -e MYSQL_USER=innovatech_user \
  -e MYSQL_PASSWORD=innovatech_password \
  -e MYSQL_ROOT_PASSWORD=root_password \
  innovatech-db:latest

# Verificar que contenedor está corriendo
docker ps

# Ver logs
docker logs innovatech_db
```

## Estrategia de Compilación Docker

Proceso Dockerfile:

1. Imagen base: MySQL 8.0 oficial
2. Copiar schema.sql a /docker-entrypoint-initdb.d/1-schema.sql
3. Copiar seed.sql a /docker-entrypoint-initdb.d/2-seed.sql
4. Cuando contenedor inicia, scripts se ejecutan en orden alfabético
5. Base de datos se inicializa automáticamente en primer ejecutada

Los scripts se ejecutan automáticamente porque el punto de entrada de MySQL detecta archivos .sql en /docker-entrypoint-initdb.d/.

## Persistencia de Datos

### Volumen Nombrado

Usa volumen nombrado mysql_data para persistencia:

```yaml
volumes:
  mysql_data:
    driver: local
```

Esto asegura que los datos sobrevivan reinicios y recreaciones de contenedores.

### Persistencia en Producción

En AWS EC2, usa bind mount a directorio del host:

```
-v /mnt/mysql_data:/var/lib/mysql
```

Datos almacenados en filesystem de instancia EC2 para durabilidad.

## Deployment

Automatizado vía GitHub Actions en push a rama `deploy`.

### Flujo de Deployment

1. GitHub Actions obtiene el código
2. Compila imagen Docker desde Dockerfile
3. Hace push a repositorio AWS ECR
4. Envía comando SSM a Database EC2
5. EC2 crea directorio de datos persistentes
6. EC2 descarga imagen más reciente e inicia contenedor
7. Contenedor vincula al puerto 3306
8. Scripts de inicialización se ejecutan automáticamente

### Deployment Manual

```bash
# Push a rama deploy
git checkout deploy
git commit --allow-empty -m "Desplegar base de datos"
git push origin deploy

# Monitorear en GitHub Actions
# Ver logs: docker logs innovatech_db
```

## Acceso a Base de Datos

### Desde Contenedor Backend

Backend se conecta usando variables de entorno:

```
DB_HOST=10.0.3.238
DB_PORT=3306
DB_NAME=innovatech_ops
DB_USER=innovatech_user
DB_PASSWORD=innovatech_password
```

### Security Groups

- Puerto 3306 de base de datos solo accesible desde security group de Backend
- Frontend no tiene acceso directo a base de datos
- Todas operaciones de BD van a través de API de Backend

### Aislamiento de Red

Configuración de subnets privadas:
- Frontend: Subnet pública (10.0.1.0/24) - puede acceder a internet
- Backend: Subnet privada (10.0.2.0/24) - rutas a través de NAT
- Database: Subnet privada (10.0.3.0/24) - sin acceso a internet

## Solución de Problemas

### Contenedor falla al iniciar

Ver logs:
```bash
docker logs innovatech_db
```

Problemas comunes:
- Puerto 3306 ya en uso
- Espacio de disco insuficiente
- Datos de volumen corruptos

### No se puede conectar desde Backend

Verificar:
- Contenedor de BD está corriendo: docker ps
- Puerto 3306 está expuesto: docker port innovatech_db
- Credenciales coinciden en .env del Backend
- Conectividad de red entre contenedores
- Security groups permiten tráfico de Backend a Database

### Datos no se persisten

Verificar:
- Volumen nombrado se creó correctamente: docker volume ls
- Ruta de montaje es correcta: /var/lib/mysql
- Sistema de archivos del host tiene espacio adecuado
- Permisos de volumen permiten escritura a MySQL

### Esquema no se inicializa

Si las tablas no existen después del primer ejecutada:
- Verificar que schema.sql está en directorio correcto
- Revisar permisos de archivo sean legibles
- Revisar logs del contenedor para errores SQL
- Ejecutar schema.sql manualmente si es necesario

### Deployment SSM falla

Problemas a verificar:
- Verificar que labrole tiene política AmazonSSMManagedInstanceCore
- Verificar SSM Agent está corriendo en instancia Database
- Verificar que Database Instance ID se resuelve correctamente
- Revisar logs de GitHub Actions para detalles del error
- Asegurar que directorio /mnt/mysql_data existe en instancia

## Backup de Base de Datos

### Backup Manual

```bash
# Volcar base de datos a archivo SQL
docker exec innovatech_db mysqldump \
  -u innovatech_user -pinnovatech_password \
  innovatech_ops > backup.sql

# O vía cliente mysql
mysqldump -h 127.0.0.1 -u innovatech_user -p innovatech_ops > backup.sql
```

### Restaurar desde Backup

```bash
# Importar archivo SQL
docker exec -i innovatech_db mysql \
  -u innovatech_user -pinnovatech_password \
  innovatech_ops < backup.sql
```

## Optimización de Rendimiento

- Índices apropiados en columnas frecuentemente consultadas
- Optimización de consultas en Backend
- Agrupación de conexiones en Backend
- Actualizaciones de estadísticas regulares
- Selección apropiada de tipos de datos

## Monitoreo

Verificar estado de BD vía SSM:

```bash
# Ver contenedores en ejecución
docker ps

# Ver logs
docker logs innovatech_db

# Conectar y ejecutar consultas
docker exec -it innovatech_db mysql -u root -p
```

Dentro de MySQL:
```sql
-- Mostrar bases de datos
SHOW DATABASES;

-- Seleccionar BD
USE innovatech_ops;

-- Mostrar tablas
SHOW TABLES;

-- Verificar estructura de tabla
DESCRIBE products;
DESCRIBE tickets;

-- Contar registros
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM tickets;
```

## Consideraciones de Seguridad

- Credenciales almacenadas en GitHub Secrets
- Sin acceso directo a internet pública
- SSH no requerido (usa Systems Manager)
- Credenciales AWS gestionadas vía roles IAM
- Usuario de BD tiene permisos limitados
- Contraseña root almacenada de forma segura
- Aislamiento de red vía security groups

## Flujo de Trabajo de Desarrollo

1. Modificar schema.sql o seed.sql según sea necesario
2. Probar localmente con docker-compose
3. Verificar inicialización con: docker logs innovatech_db
4. Hacer commit y push a rama main
5. Mezclar con rama deploy
6. GitHub Actions dispara deployment
7. BD se inicializa automáticamente en EC2

## Orden de Ejecución de Archivos SQL

Scripts del punto de entrada se ejecutan en orden alfabético:
1. 1-schema.sql (crea tablas)
2. 2-seed.sql (puebla datos iniciales)

La convención de nombres es importante para secuencia correcta de inicialización.

## Consideraciones de Producción

- Backups regulares a S3 o almacenamiento externo
- Monitoreo y alertas para espacio de disco
- Configuración de agrupación de conexiones
- Monitoreo de rendimiento de consultas
- Tareas de mantenimiento regular (ANALYZE, OPTIMIZE)
- Replicación para alta disponibilidad

