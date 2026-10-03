-- reservation(status) — the admin panel and the payment-review queue filter by status.
-- reservation(client_id) — HU-BOOKING-004 ("my reservations").
CREATE INDEX ix_reservation_client_id ON booking.reservation (client_id);

CREATE INDEX ix_reservation_status_reservation_date
    ON booking.reservation (status, reservation_date);

-- The UNIQUE constraint on rental(reservation_id) already creates its own index, so there is
-- nothing extra to add here for the 1:1 lookup.

-- notification(person_id, is_read) — the bell filters unread notifications per user.
CREATE INDEX ix_notification_person_is_read ON booking.notification (person_id, is_read);