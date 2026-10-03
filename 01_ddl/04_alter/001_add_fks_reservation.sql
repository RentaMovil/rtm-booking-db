-- Foreign keys for the tables created in 03_tables.
--
-- WHICH ONES EXIST AND WHICH DON'T, AND WHY:
--
--   iam.person         ✅ exists now (rtm-iam-db runs first), FK added below.
--   booking.*          ✅ own tables, FKs added below.
--   fleet.vehicle      ❌ fleet-maintenance service does not exist yet.
--   fleet.branch       ❌ same.
--   telemetry.gps      ❌ telemetry-gps service does not exist yet.
--   payment.invoice    ❌ payment-billing service does not exist yet.
--   fleet.vehicle_maintenance ❌ same as vehicle.
--
-- The columns pointing at the missing tables are already NOT NULL, so the application cannot
-- write a row that references a vehicle that does not exist — the FKs are added in later
-- changesets of THIS repo once each owning service has been migrated. Until then nothing is
-- lost: the column names and types already match 06-data/models.md.

-- reservation -> iam.person (rtm-iam-db migrated before this repo)
ALTER TABLE booking.reservation
    ADD CONSTRAINT fk_reservation_client FOREIGN KEY (client_id) REFERENCES iam.person(person_id);

ALTER TABLE booking.reservation
    ADD CONSTRAINT fk_reservation_insurance_type FOREIGN KEY (insurance_type_id)
        REFERENCES booking.insurance_type(insurance_type_id);

-- rental -> reservation (1:1, same service)
ALTER TABLE booking.rental
    ADD CONSTRAINT fk_rental_reservation FOREIGN KEY (reservation_id)
        REFERENCES booking.reservation(reservation_id);

-- notification -> iam.person and -> reservation
ALTER TABLE booking.notification
    ADD CONSTRAINT fk_notification_person FOREIGN KEY (person_id) REFERENCES iam.person(person_id);

ALTER TABLE booking.notification
    ADD CONSTRAINT fk_notification_reservation FOREIGN KEY (reservation_id)
        REFERENCES booking.reservation(reservation_id);