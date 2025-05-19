# Ecommerce API

## Descripción

Este proyecto es una prueba técnica para PuntosPoint, que consiste en una API RESTful para una plataforma de ecommerce. La API permite gestionar usuarios, productos, categorías, compras y estadísticas de ventas.

## Tecnologías

- Ruby 3.3.6
- Rails 7.2.1
- PostgreSQL
- Redis
- Sidekiq
- JWT para autenticación

## Características principales

- **Autenticación con JWT**: Casi todos los endpoints están protegidos mediante JWT.
- **Roles de usuario**: Implementación de roles (admin y client) con diferentes permisos.
- **Auditoría de cambios**: Uso de la gema `audited` para registrar cambios en categorías y productos.
- **Tablas polimórficas**: Implementación de `attachments` para agregar imágenes a los productos.
- **Herencia con STI**: Productos digitales y físicos heredan de la clase Product mediante Single Table Inheritance.
- **Trabajos en segundo plano**: Uso de Sidekiq para procesar tareas asíncronas.
- **Prevención de condiciones de carrera**: Implementación con Redis para evitar duplicación de notificaciones.
- **Documentación API**: Generada con Rswag y disponible en `/api-docs`.
- **Excepciones personalizadas**: Manejo de errores con excepciones custom en `lib/api_exceptions`.
- **Serialización JSON**: Uso de la gema `jsonapi_responses` de mi autoría para formatear respuestas JSON.

## Instalación y configuración

```bash
# Clonar el repositorio
git clone https://github.com/oortega14/ecommerce-api.git
cd ecommerce-api

# Instalar dependencias
bundle install

# Configurar la base de datos
rails db:create
rails db:migrate
rails db:seed
```

## Ejecución

Para ejecutar la aplicación, necesitas iniciar varios servicios:

```bash
# Iniciar Redis (necesario para Sidekiq y prevención de condiciones de carrera)
redis-server

# Iniciar Sidekiq para procesar trabajos en segundo plano
bundle exec sidekiq

# Iniciar el servidor Rails
rails s
```

## Endpoints destacados

### Estadísticas (StatsController)

Endpoints disponibles solo para administradores:

- `GET /api/v1/stats/top_products`: Productos más comprados por cada categoría
- `GET /api/v1/stats/most_purchased`: Productos que más han recaudado por categoría (top 3)
- `GET /api/v1/stats/purchases`: Listado de compras filtrado por diversos parámetros
- `GET /api/v1/stats/purchase_counts`: Cantidad de compras según granularidad (hora, día, semana, año)

## Notificaciones por email

La aplicación implementa dos tipos de notificaciones por email:

1. **Notificación de primera compra**: Se envía un email al creador del producto con copia a otros administradores cuando un producto es comprado por primera vez.

![Email de primera compra](/docs/images/email-primera-compra.png)

2. **Reporte diario de compras**: Se genera automáticamente a las 6:00 AM todos los días y se envía a todos los administradores con un resumen de las compras del día anterior.

![Email de reporte diario](/docs/images/email-reporte-diario.png)

## Diagrama Entidad-Relación

![Diagrama ER](/docs/images/diagrama-er.png)

## Características avanzadas

### Prevención de condiciones de carrera

Se utiliza Redis para implementar locks atómicos que previenen condiciones de carrera al enviar notificaciones de primera compra, asegurando que solo se envíe un email incluso si múltiples compras ocurren simultáneamente.

### Trabajos programados

Se utiliza Sidekiq-Cron para programar la generación y envío automático del reporte diario de compras a las 6:00 AM.

### Serialización de respuestas

Se utiliza la gema `jsonapi_responses` (desarrollada por el autor) para estandarizar y serializar las respuestas JSON de la API.

## Documentación

La documentación completa de la API está disponible en `/api-docs` una vez que el servidor esté en ejecución.
