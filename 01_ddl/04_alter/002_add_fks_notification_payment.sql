-- Las dos FKs que 001_add_fks_reservation.sql dejó pendientes: payment-billing ya existe y
-- rtm-payment-billing-db corre antes que este changeset (migra 5.º, después de este repo, pero
-- ambos repos avanzan por changesets propios -- este changeset se aplica cuando payment.invoice y
-- payment.payment ya existen en la base, sin importar en qué PR nació cada repo).
ALTER TABLE booking.notification
    ADD CONSTRAINT fk_notification_invoice FOREIGN KEY (invoice_id)
        REFERENCES payment.invoice(invoice_id);

ALTER TABLE booking.notification
    ADD CONSTRAINT fk_notification_payment FOREIGN KEY (payment_id)
        REFERENCES payment.payment(payment_id);
