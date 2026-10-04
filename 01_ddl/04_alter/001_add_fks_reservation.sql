-- Foreign keys for the tables created in 03_tables.
--
-- WHICH ONES EXIST AND WHICH DON'T, AND WHY:
--
--   iam.person                 EXISTS   (rtm-iam-db runs first), FK added below.
--   booking.*                  EXISTS   own tables, FKs added below.
--   fleet.vehicle              MISSING  fleet-maintenance service does not exist yet.
--   fleet.branch               MISSING  same as vehicle.
--   telemetry.gps              MISSING  telemetry-gps service does not exist yet.
--   payment.invoice            MISSING  payment-billing service does not exist yet.
--   payment.payment            MISSING  same as invoice.
--   fleet.vehicle_maintenance  MISSING  same as vehicle.
--
-- The columns pointing at the missing tables are already NOT NULL, so the application cannot
-- write a row that references a vehicle that does not exist. The FKs are added in later
-- changesets of THIS repo once each owning service has been migrated. Until then nothing is
-- lost: the column names and types already match 06-data/models.md.
--
-- The FK that does exist on purpose across services is reservation.client_id -> iam.person: it
-- is integrity for free, not a read channel. booking_app has no SELECT on iam.*, so this
-- service can never read person data directly (see data-model.md of the service).

-- reservation -> iam.person (rtm-iam-db migrated before this repo)
ALTER TABLE booking.reservation
    ADD CONSTRAINT fk_reservation_client FOREIGN KEY (client_id) REFERENCES iam.person(person_id);

-- reservation -> own insurance_type catalog
ALTER TABLE booking.reservation
    ADD CONSTRAINT fk_reservation_insurance_type FOREIGN KEY (insurance_type_id)
        REFERENCES booking.insurance_type(insurance_type_id);

-- rental -> reservation (1:1, same service)
ALTER TABLE booking.rental
    ADD CONSTRAINT fk_rental_reservation FOREIGN KEY (reservation_id)
        REFERENCES booking.reservation(reservation_id);

-- notification -> iam.person
ALTER TABLE booking.notification
    ADD CONSTRAINT fk_notification_person FOREIGN KEY (person_id) REFERENCES iam.person(person_id);

-- notification -> reservation (nullable: set when the notification is about one)
ALTER TABLE booking.notification
    ADD CONSTRAINT fk_notification_reservation FOREIGN KEY (reservation_id)
        REFERENCES booking.reservation(reservation_id);