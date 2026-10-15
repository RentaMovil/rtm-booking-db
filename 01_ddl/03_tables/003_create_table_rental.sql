-- 06-data/models.md -> rental. The physical execution of a CONFIRMED reservation: pickup to return.
-- Bounded Context "Rental Execution", but deployed inside the booking-reservation service (see
-- 09-microservices/service-catalog.md for why the three contexts are one deployable).
CREATE TABLE booking.rental (
    rental_id         INT IDENTITY(1,1) NOT NULL,
    -- 1:1 with reservation (UNIQUE): a reservation is executed exactly once (modeling decision 1).
    -- The row only exists once pickup is registered -- there is no empty "reserved rental" row.
    reservation_id    INT               NOT NULL,
    -- The GPS device the Administrator installed at pickup. Passed in the pickup request body,
    -- not assigned via a call to telemetry-gps (see the service's decisions.md).
    gps_id            INT               NOT NULL,
    actual_start_date DATETIME          NOT NULL,
    -- Nullable because they don't exist yet while status = IN_PROGRESS (modeling decision 2).
    actual_end_date   DATETIME          NULL,
    initial_mileage   DECIMAL(10,2)     NOT NULL,
    final_mileage     DECIMAL(10,2)     NULL,
    status            VARCHAR(30)       NOT NULL,

    CONSTRAINT pk_rental PRIMARY KEY (rental_id),
    CONSTRAINT uq_rental_reservation_id UNIQUE (reservation_id),
    CONSTRAINT ck_rental_status CHECK (status IN ('IN_PROGRESS','COMPLETED')),
    -- A COMPLETED rental must have both its return date and its final mileage.
    CONSTRAINT ck_rental_completion CHECK (
        status = 'IN_PROGRESS' OR (actual_end_date IS NOT NULL AND final_mileage IS NOT NULL)),
    CONSTRAINT ck_rental_mileage CHECK (initial_mileage >= 0)
);