-- 1. Procedure that retrieves and updates vehicle status based on maintenance
CREATE OR REPLACE PROCEDURE update_vehicle_maintenance_status(
    IN vehicle_id_param INT,
    OUT maintenance_count INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Count recent maintenance records
    SELECT COUNT(*)
    INTO maintenance_count
    FROM car_care
    WHERE vehicle_id = vehicle_id_param
    AND date >= CURRENT_DATE - INTERVAL '6 months';

    -- Update vehicle category based on maintenance history
    IF maintenance_count > 3 THEN
        -- If vehicle has had too many maintenance issues, move to standard category
        UPDATE vehicle
        SET category_id = (SELECT category_id FROM vehicle_category WHERE category_name = 'Standard')
        WHERE vehicle_id = vehicle_id_param;
    END IF;
END;
$$;

-- 2. Function that calculates customer loyalty score
CREATE OR REPLACE FUNCTION calculate_customer_loyalty(user_id_param INT)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    rental_count INT;
    avg_rating DECIMAL;
    loyalty_score INT;
BEGIN
    -- Get number of rentals
    SELECT COUNT(*) INTO rental_count
    FROM reservation
    WHERE user_id = user_id_param;

    -- Get average rating given by customer
    SELECT COALESCE(AVG(rating), 0) INTO avg_rating
    FROM customer_feedback
    WHERE user_id = user_id_param;

    -- Calculate loyalty score
    loyalty_score := (rental_count * 10) + (avg_rating * 5);

    RETURN loyalty_score;
END;
$$;

-- 3. Procedure to handle vehicle transfer between locations
CREATE OR REPLACE PROCEDURE transfer_vehicle(
    IN vehicle_id_param INT,
    IN new_location_id INT,
    IN employee_id_param INT,
    OUT transfer_status VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Check if vehicle is currently reserved
    IF EXISTS (
        SELECT 1 FROM reservation 
        WHERE vehicle_id = vehicle_id_param 
        AND CURRENT_DATE BETWEEN start_date AND end_date
    ) THEN
        transfer_status := 'FAILED: Vehicle currently reserved';
        RETURN;
    END IF;

    -- Perform transfer
    UPDATE vehicle
    SET location_id = new_location_id,
        employee_id = employee_id_param
    WHERE vehicle_id = vehicle_id_param;

    transfer_status := 'SUCCESS: Vehicle transferred';
END;
$$;

-- 4. Function to generate rental summary report
CREATE OR REPLACE FUNCTION generate_rental_summary(start_date_param DATE)
RETURNS TABLE (
    category_name VARCHAR,
    total_rentals BIGINT,
    total_revenue DECIMAL,
    avg_rating DECIMAL
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        vc.category_name,
        COUNT(r.reservation_id),
        SUM(r.total_cost),
        AVG(cf.rating)
    FROM vehicle_category vc
    JOIN vehicle v ON vc.category_id = v.category_id
    JOIN reservation r ON v.vehicle_id = r.vehicle_id
    LEFT JOIN customer_feedback cf ON r.reservation_id = cf.reservation_id
    WHERE r.start_date >= start_date_param
    GROUP BY vc.category_name;
END;
$$;