-- Modified trigger function
CREATE OR REPLACE FUNCTION log_new_reservation()
RETURNS TRIGGER AS $$
DECLARE
    next_support_id INT;
BEGIN
    -- Get the next support_id
    SELECT COALESCE(MAX(support_id), 9000) + 1
    INTO next_support_id
    FROM support;

    INSERT INTO support (support_id, user_id, message, status)
    VALUES (
        next_support_id,
        NEW.user_id,
        'New reservation created for vehicle ID: ' || NEW.vehicle_id,
        'AUTO-LOGGED'
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;