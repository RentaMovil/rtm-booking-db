-- booking_app only appends to the audit log: no SELECT/UPDATE/DELETE (audit is append-only and is
-- never read by the application). Other services grant INSERT to their own <schema>_app user
-- from their own repo, in their 03_dcl.
GRANT INSERT ON shared.audit TO booking_app;