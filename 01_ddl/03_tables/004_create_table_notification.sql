-- 06-data/models.md -> notification. In-app only for now, no email delivery (confirmed decision).
-- Bounded Context "Notification", deployed inside the booking-reservation service.
CREATE TABLE booking.notification (
    notification_id  INT IDENTITY(1,1) NOT NULL,
    person_id        INT           NOT NULL,   -- recipient
    notification_type VARCHAR(50)   NOT NULL,
    message          TEXT          NOT NULL,
    sent_date        DATETIME      NOT NULL,
    is_read          BIT           NOT NULL,   -- read by the RECIPIENT, not "delivered successfully"
    -- Exactly one of the four below is set, depending on which event produced the row.
    -- notification_type says WHAT kind of event it was; these say WHICH record it is about --
    -- complementary, not redundant (modeling decision).
    reservation_id   INT           NULL,
    invoice_id       INT           NULL,
    payment_id       INT           NULL,
    maintenance_id   INT           NULL,

    CONSTRAINT pk_notification PRIMARY KEY (notification_id),
    -- One value per domain event that produces a notification. INVOICE_GENERATED is deliberately
    -- absent: approving a payment generates the invoice in the same moment, so both land under
    -- PAYMENT_APPROVED (see the service's events.md). Adding a separate value later is a schema
    -- change: a new changeset, never an edit to this one once it has run.
    CONSTRAINT ck_notification_type CHECK (notification_type IN (
        'RESERVATION_CREATED','RESERVATION_CANCELLED','RESERVATION_RETURN_BRANCH_CHANGED',
        'RESERVATION_RETURN_DATE_EXTENDED','RESERVATION_EXPIRED',
        'PAYMENT_APPROVED','PAYMENT_REJECTED','MAINTENANCE_COMPLETED'))
);