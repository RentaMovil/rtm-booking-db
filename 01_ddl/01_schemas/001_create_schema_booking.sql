-- Schema that holds every table owned by the booking-reservation service inside the shared
-- rentamovil database. CREATE SCHEMA must be the only statement in its batch, hence the EXEC wrapper.
IF SCHEMA_ID('booking') IS NULL
    EXEC('CREATE SCHEMA booking');