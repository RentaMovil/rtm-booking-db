-- La última FK que 001_add_fks_reservation.sql dejó pendiente ("telemetry.gps MISSING
-- telemetry-gps service does not exist yet"). Ahora que rtm-telemetry-gps-db existe y migró,
-- se agrega en este changeset nuevo (nunca se edita uno ya aplicado).
ALTER TABLE booking.rental
    ADD CONSTRAINT fk_rental_gps FOREIGN KEY (gps_id) REFERENCES telemetry.gps(gps_id);
