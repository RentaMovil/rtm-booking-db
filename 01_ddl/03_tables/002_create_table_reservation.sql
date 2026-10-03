-- 06-data/models.md -> reservation. The Aggregate Root of the Booking & Reservation context.
--
-- Created without foreign keys; they are added in 04_alter, once the tables they reference exist.
-- See the comment in 04_alter/001_add_fks_reservation.sql for which ones are still missing.
CREATE TABLE booking.reservation (
    reservation_id     INT IDENTITY(1,1) NOT NULL,
    -- The reservation holder is a Person (iam), not necessarily a User.
    client_id          INT               NOT NULL,
    vehicle_id         INT               NOT NULL,
    -- Insurance is optional, but insurance_subtotal is NOT NULL anyway (defaults to 0) so the
    -- total calculation never has to null-check it (modeling decision 3).
    insurance_type_id  INT               NULL,
    -- Two separate FKs to branch, not one field: a customer can pick up at one branch and
    -- return at another — a real feature, not an edge case (modeling decision 1).
    pickup_branch_id   INT               NOT NULL,
    return_branch_id   INT               NOT NULL,
    reservation_date   DATETIME          NOT NULL,
    start_date         DATETIME          NOT NULL,
    end_date           DATETIME          NOT NULL,
    vehicle_subtotal   DECIMAL(10,2)     NOT NULL,
    insurance_subtotal DECIMAL(10,2)     NOT NULL,
    total_amount       DECIMAL(10,2)     NOT NULL,
    status             VARCHAR(30)       NOT NULL,

    CONSTRAINT pk_reservation PRIMARY KEY (reservation_id),
    CONSTRAINT ck_reservation_status CHECK (status IN
        ('PENDING_PAYMENT','PENDING_REVIEW','CONFIRMED','CANCELLED','COMPLETED')),
    -- INV-008: the total is always the sum of the two subtotals
    CONSTRAINT ck_reservation_total CHECK (total_amount = vehicle_subtotal + insurance_subtotal),
    CONSTRAINT ck_reservation_amounts CHECK (vehicle_subtotal >= 0 AND insurance_subtotal >= 0)
    -- NOTE: end_date > start_date is NOT a CHECK. It is validated in the application layer,
    -- like the 3-day deadline of INV-013 (modeling decision 2 of models.md): both depend on
    -- "now", which a CHECK constraint can't evaluate reliably in SQL Server.
);