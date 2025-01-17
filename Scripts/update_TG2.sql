DROP FUNCTION IF EXISTS archive_deleted_vehicle CASCADE;

CREATE OR REPLACE FUNCTION archive_deleted_vehicle()
RETURNS TRIGGER AS $$
DECLARE
    next_support_id INT;
BEGIN
    -- Get the next support_id
    SELECT COALESCE(MAX(support_id), 9000) + 1
    INTO next_support_id
    FROM support;

    INSERT INTO support (
        support_id,
        user_id,
        message,
        status
    )
    VALUES (
        next_support_id,
        1,
        'Vehicle deleted - ID: ' || OLD.vehicle_id || ', Make: ' || OLD.make || ', Model: ' || OLD.model,
        'VEHICLE-DELETED'
    );
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS vehicle_delete_archive ON vehicle;

CREATE TRIGGER vehicle_delete_archive
BEFORE DELETE ON vehicle
FOR EACH ROW
EXECUTE FUNCTION archive_deleted_vehicle();