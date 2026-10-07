# rtm-booking-reservation-db

Migraciones Liquibase de las tablas del servicio **Booking & Reservation** de RentaMovil
(reservas + ejecución de renta + notificaciones in-app — un solo ciclo de vida, no tres
servicios; ver `rtm-docs/09-microservices/service-catalog.md`).

- **Base de datos:** `rentamovil` (SQL Server), **compartida** por todos los servicios.
- **Schema propio:** `booking` — toda tabla de este repo se crea como `booking.<tabla>`. Ninguna
  tabla va en `dbo`.
- **Tablas:** `insurance_type`, `reservation`, `rental`, `notification`.
- **Historial Liquibase propio:** `dbo.DATABASECHANGELOG_BOOKING` / `dbo.DATABASECHANGELOGLOCK_BOOKING`.
- **Orden entre repos:** `rtm-iam-db` corre **primero** — `reservation.client_id` y
  `notification.person_id` tienen FK a `iam.person`, y este repo concede `INSERT` sobre
  `shared.audit`, que IAM también crea.

Convenciones completas (estructura, nombres, orden, rollback): `rtm-docs/06-data/migration-strategy.md`.

## Estado actual

El esquema existe y el servicio `rtm-booking-reservation` ya crea y gestiona reservas con
normalidad. Las FKs hacia `payment.invoice`/`payment.payment` se agregaron en
`04_alter/002_add_fks_notification_payment` una vez que `rtm-payment-billing-db` migró. Quedan
pendientes las de Fleet & Maintenance y Telemetry & GPS — no bloquean el funcionamiento (las
columnas ya son `NOT NULL` con el tipo correcto), son integridad adicional a nivel de motor:

| Columna | FK pendiente hacia | Servicio dueño |
|---------|-------------------|----------------|
| `reservation.vehicle_id` | `fleet.vehicle` | `fleet-maintenance` |
| `reservation.pickup_branch_id`, `return_branch_id` | `fleet.branch` | `fleet-maintenance` |
| `rental.gps_id` | `telemetry.gps` | `telemetry-gps` |
| `notification.maintenance_id` | `fleet.vehicle_maintenance` | `fleet-maintenance` |

Las columnas ya están declaradas con el tipo y el nombre exactos que dice
`06-data/models.md`, y son `NOT NULL`, así que la aplicación no puede escribir una fila que
apunte a un vehículo inexistente. Cada FK se añade en un changeset posterior de **este** repo,
cuando el servicio dueño ya esté migrado (un changeset nunca reescribe uno ya aplicado).

## Estructura

```
changelog/changelog-master.yaml   ← punto de entrada: incluye 01_ddl → 02_dml → 03_dcl → 04_tcl
01_ddl/                           DDL
  01_schemas/                       CREATE SCHEMA booking
  03_tables/                        CREATE TABLE, sin FKs
  04_alter/                         FKs y demás ALTER
  05_views/                         CREATE VIEW
  10_indexes/                       CREATE INDEX
02_dml/                           DML
  00_inserts/                       datos de referencia
  01_updates/                       backfills y correcciones de datos
  02_deletes/                       eliminación de datos
03_dcl/                           DCL
  00_roles/                         usuario de BD del servicio
  01_grants/                        permisos sobre el schema booking
04_tcl/                           TCL
  02_release_tags/                  tags de versión (tagDatabase)
05_rollbacks/                     espejo de 01_ddl … 03_dcl: un .rollback.sql por cada .sql
```

Todas estas carpetas existen aunque estén vacías: una carpeta sin changesets tiene
`databaseChangeLog: []` en su `changelog.yaml` (y `.gitkeep` en su espejo de `05_rollbacks`).
Los huecos en la numeración son a propósito — el porqué de cada carpeta que no existe está en
`rtm-docs/06-data/migration-strategy.md`.

Cada carpeta hoja tiene:
- `NNN_descripcion.sql` — el SQL real (dialecto SQL Server).
- `changelog.yaml` — un `changeSet` por `.sql`, con su `rollback` apuntando a `05_rollbacks/`.

`02_dml/` está vacío a propósito: los planes de seguro los crea un Administrador
(HU-BOOKING-009), no un seed. A diferencia de IAM, este servicio no tiene catálogos de referencia
propios.

## Requisitos

- Java 17+
- Maven 3.9+
- Docker Desktop
- **SQL Server ya levantado y migrado desde `rtm-iam-db`** (este repo no lo levanta)

## Uso local

```bash
# 1. Configuración local (una sola vez)
cp .env.example .env
cp liquibase.properties.example liquibase.properties
# edita la contraseña de sa en los dos archivos (deben coincidir) y pon en
# liquibase.properties una contraseña para booking_app (parameter.bookingAppPassword)

# 2. Verificar que rtm-iam-db ya corrió (crea la base y las tablas iam.*)
cd ../rtm-iam-db && docker compose up -d

# 3. Ver qué changesets faltan
mvn liquibase:status

# 4. Ver el SQL sin ejecutarlo
mvn liquibase:updateSQL

# 5. Aplicar
mvn liquibase:update
```

Otros comandos:

```bash
mvn liquibase:rollback -Dliquibase.rollbackCount=1   # deshace el último changeset
```

### Con Docker (red compartida `rentamovil`)

```bash
# Una sola vez por PC (los repos de datos usan la misma red)
docker network create rentamovil

# SQL Server + base + migraciones de IAM primero (rtm-iam-db)
cd ../rtm-iam-db && docker compose up -d

# Después, las migraciones de booking
docker compose up -d
```

| Contenedor | Qué hace | Estado normal |
|---|---|---|
| `migrations` | Corre las migraciones de este repo (igual que `mvn liquibase:update`) | `Exited (0)` |

Orden para levantar todo: **rtm-iam-db → rtm-booking-reservation-db → rtm-iam →
rtm-booking-reservation → rtm-api-gateway** (`docker compose up -d` en cada uno).

## Usuario de base de datos del servicio (`03_dcl`)

Las migraciones corren con `sa`. El servicio `rtm-booking-reservation` **nunca** usa `sa`: se
conecta con `booking_app`, que solo puede leer y escribir datos del schema `booking` (sin DDL, sin
acceso a otros schemas ni a `dbo`). Su contraseña **no está en el repo**: sale de
`parameter.bookingAppPassword` en `liquibase.properties` (git-ignored). Si falta, el changeset
falla a propósito.

Esa restricción es lo que hace coherente la base compartida con la matriz de propiedad de datos
(`09-microservices/service-catalog.md`): `booking_app` no puede leer `iam.*`, `fleet.*` ni
`telemetry.*` ni por error. Las FKs que cruzan servicios funcionan igual, porque las valida el
motor y no el usuario de aplicación.

> Al usar parámetros, el plugin de Maven imprime un `NoSuchFieldException: The field
> 'parameter.bookingAppPassword' could not be found...` con stack trace. Es inofensivo: el plugin
> intenta leerlo como opción propia y después lo usa correctamente como parámetro. Lo que importa
> es el `BUILD SUCCESS` final.

## Ramas

`feat/`, `fix/`, `chore/` → PR a `develop` (Squash and Merge). Ver
`rtm-docs/00-governance/git-conventions.md`.