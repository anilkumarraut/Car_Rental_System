-- 1. Complex view showing comprehensive rental analytics
CREATE OR REPLACE VIEW rental_analytics AS
SELECT 
    vc.category_name,
    l.city,
    l.state,
    COUNT(DISTINCT r.reservation_id) as total_rentals,
    AVG(r.total_cost) as avg_rental_cost,
    SUM(r.total_cost) as total_revenue,
    AVG(cf.rating) as avg_rating,
    COUNT(DISTINCT cc.care_id) as maintenance_count
FROM vehicle_category vc
JOIN vehicle v ON vc.category_id = v.category_id
JOIN location l ON v.location_id = l.location_id
LEFT JOIN reservation r ON v.vehicle_id = r.vehicle_id
LEFT JOIN customer_feedback cf ON r.reservation_id = cf.reservation_id
LEFT JOIN car_care cc ON v.vehicle_id = cc.vehicle_id
GROUP BY vc.category_name, l.city, l.state;

-- 2. View for high-value customers with subqueries
CREATE OR REPLACE VIEW high_value_customers AS
SELECT 
    au.user_id,
    au.fname,
    au.lname,
    au.account_type,
    (SELECT COUNT(*) FROM reservation r WHERE r.user_id = au.user_id) as total_rentals,
    (SELECT AVG(rating) FROM customer_feedback cf WHERE cf.user_id = au.user_id) as avg_rating,
    (SELECT SUM(total_cost) FROM reservation r WHERE r.user_id = au.user_id) as total_spent
FROM app_user au
WHERE EXISTS (
    SELECT 1 
    FROM reservation r 
    WHERE r.user_id = au.user_id 
    GROUP BY r.user_id 
    HAVING COUNT(*) >= 2
);

-- 3. View for vehicle maintenance history with aggregations
CREATE OR REPLACE VIEW vehicle_maintenance_summary AS
SELECT 
    v.vehicle_id,
    v.make,
    v.model,
    v.year,
    COUNT(cc.care_id) as total_services,
    SUM(cc.cost) as total_maintenance_cost,
    MAX(cc.date) as last_service_date,
    STRING_AGG(DISTINCT cc.service_type, ', ') as service_types
FROM vehicle v
LEFT JOIN car_care cc ON v.vehicle_id = cc.vehicle_id
GROUP BY v.vehicle_id, v.make, v.model, v.year;

-- 4. Updatable view for basic vehicle information
CREATE OR REPLACE VIEW vehicle_basic_info AS
SELECT 
    vehicle_id,
    make,
    model,
    year,
    license_plate_num,
    location_id
FROM vehicle;