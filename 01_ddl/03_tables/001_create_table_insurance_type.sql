-- Catalog of the optional insurance plans a customer can attach to a reservation.
-- 06-data/models.md -> insurance_type. Managed by an Administrator (HU-BOOKING-009).
CREATE TABLE booking.insurance_type (
    insurance_type_id INT IDENTITY(1,1) NOT NULL,
    name             VARCHAR(100)      NOT NULL,
    coverage_details TEXT              NULL,
    -- Charged once per reservation, not per extra day when the rental is extended (INV-007)
    daily_cost       DECIMAL(10,2)     NOT NULL,

    CONSTRAINT pk_insurance_type PRIMARY KEY (insurance_type_id),
    CONSTRAINT ck_insurance_type_daily_cost CHECK (daily_cost >= 0)
);