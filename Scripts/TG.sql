-- 1. Trigger for INSERT - Log new reservations
CREATE OR REPLACE FUNCTION log_new_reservation()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO support (user_id, message, status)
    VALUES (
        NEW.user_id,
        'New reservation created for vehicle ID: ' || NEW.vehicle_id,
        'AUTO-LOGGED'
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER reservation_logger
AFTER INSERT ON reservation
FOR EACH ROW
EXECUTE FUNCTION log_new_reservation();

-- 2. Trigger for UPDATE - Track price changes
CREATE OR REPLACE FUNCTION track_price_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.total_cost <> OLD.total_cost THEN
        INSERT INTO support (user_id, message, status)
        VALUES (
            NEW.user_id,
            'Price changed from ' || OLD.total_cost || ' to ' || NEW.total_cost || ' for reservation ID: ' || NEW.reservation_id,
            'PRICE-CHANGE'
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER price_change_tracker
AFTER UPDATE ON reservation
FOR EACH ROW
WHEN (NEW.total_cost IS DISTINCT FROM OLD.total_cost)
EXECUTE FUNCTION track_price_changes();

-- 3. Trigger for DELETE - Archive deleted vehicles
CREATE OR REPLACE FUNCTION archive_deleted_vehicle()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO support (user_id, message, status)
    VALUES (
        1, -- System user ID
        'Vehicle deleted - ID: ' || OLD.vehicle_id || ', Make: ' || OLD.make || ', Model: ' || OLD.model,
        'VEHICLE-DELETED'
    );
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER vehicle_delete_archive
BEFORE DELETE ON vehicle
FOR EACH ROW
EXECUTE FUNCTION archive_deleted_vehicle();

-- 4. Trigger for each row - Update customer status
CREATE OR REPLACE FUNCTION update_customer_status()
RETURNS TRIGGER AS $$
BEGIN
    -- Update customer to premium if they have more than 5 rentals
    IF (
        SELECT COUNT(*) 
        FROM reservation 
        WHERE user_id = NEW.user_id
    ) >= 5 THEN
        UPDATE app_user
        SET account_type = 'premium'
        WHERE user_id = NEW.user_id
        AND account_type = 'standard';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER customer_status_updater
AFTER INSERT ON reservation
FOR EACH ROW
EXECUTE FUNCTION update_customer_status();