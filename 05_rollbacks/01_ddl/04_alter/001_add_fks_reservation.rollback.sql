ALTER TABLE booking.notification DROP CONSTRAINT fk_notification_reservation;
ALTER TABLE booking.notification DROP CONSTRAINT fk_notification_person;
ALTER TABLE booking.rental DROP CONSTRAINT fk_rental_reservation;
ALTER TABLE booking.reservation DROP CONSTRAINT fk_reservation_insurance_type;
ALTER TABLE booking.reservation DROP CONSTRAINT fk_reservation_client;