-- Database identity the rtm-booking-reservation service connects with (never sa).
-- LOGIN = credentials to enter the SQL Server instance; USER = its identity inside rentamovil.
-- The password comes from liquibase.properties (parameter.bookingAppPassword), never from this repo.

-- Fail fast if the parameter wasn't provided: Liquibase would otherwise leave the literal text.
IF '${bookingAppPassword}' = '$' + '{bookingAppPassword}'
    THROW 50000, 'Missing parameter.bookingAppPassword in liquibase.properties', 1;

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'booking_app')
    CREATE LOGIN booking_app WITH PASSWORD = '${bookingAppPassword}', CHECK_POLICY = ON;

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'booking_app')
    CREATE USER booking_app FOR LOGIN booking_app WITH DEFAULT_SCHEMA = booking;