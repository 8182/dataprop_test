# Consulta de UF - Proyecto Rails

## Descripción
Aplicación para consultar el valor de la UF (Unidad de Fomento) en Chile:

- Consulta diaria de la UF.
- Búsqueda por día, mes o año.
- Guardado opcional de resultados en la base de datos.
- Caché inteligente para mejorar el rendimiento.
- Cron job diario para actualizar el valor de hoy.
- Manejo de errores y reintentos en la API externa.

---

## Requisitos

- **Ruby:** 3.4.x
- **Rails:** 8.0.2.x
- **Base de datos:** PostgreSQL
- **Servicios:** Rails.cache (puede ser Redis)
- **Variables de entorno:**  
  - `CMF_API_KEY` → API key para consultar la UF desde la CMF.

---

## Instalación

1. Instalar las gemas del proyecto:

```bash
bundle install

2-Configurar la variable de entorno para la API, o colocar en archivo .env:
.export CMF_API_KEY=tu_api_key_aqui

3-Configurar la base de datos (config/database.yml):
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: dataprop_test_development

  4- Crear la base de datos y ejecutar migraciones:
  rails db:create
  rails db:migrate

