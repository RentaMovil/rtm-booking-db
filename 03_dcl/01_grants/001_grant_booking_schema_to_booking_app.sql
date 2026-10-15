-- Data access only, and only on the booking schema: no DDL (that's Liquibase's job with its own
-- account), no access to other services' schemas or to dbo (Liquibase history tables).
--
-- This is what enforces the data-ownership matrix in 09-microservices/service-catalog.md on a
-- physically shared database: booking_app cannot read iam.*, fleet.* or telemetry.* even by
-- mistake. The FKs that cross service boundaries still work (they are checked by the engine,
-- not by the application user), which is exactly the "integrity for free, not a read channel"
-- note in the service's data-model.md.
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::booking TO booking_app;