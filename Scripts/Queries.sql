-- 1. Query to find the most popular vehicle categories based on number of reservations,
-- including total revenue generated per category
SELECT 
    vc.category_name,
    COUNT(r.reservation_id) as total_reservations,
    SUM(r.total_cost) as total_revenue
FROM vehicle_category vc
JOIN vehicle v ON vc.category_id = v.category_id
JOIN reservation r ON v.vehicle_id = r.vehicle_id
GROUP BY vc.category_name
HAVING COUNT(r.reservation_id) > 0
ORDER BY total_reservations DESC;

-- 2. Query to find employees who have handled more than one car care service,
-- along with their locations and total service cost
SELECT 
    e.name as employee_name,
    l.city,
    l.state,
    COUNT(cc.care_id) as services_performed,
    SUM(cc.cost) as total_service_value
FROM employee e
JOIN location l ON e.location_id = l.location_id
JOIN car_care cc ON e.employee_id = cc.performing_employee_id
GROUP BY e.name, l.city, l.state
HAVING COUNT(cc.care_id) > 1
ORDER BY total_service_value DESC;

-- 3. Query to identify premium customers who have made multiple reservations
-- and have an average rating above 3
SELECT 
    au.fname,
    au.lname,
    au.account_type,
    COUNT(r.reservation_id) as total_reservations,
    AVG(cf.rating) as avg_rating
FROM app_user au
JOIN reservation r ON au.user_id = r.user_id
JOIN customer_feedback cf ON r.reservation_id = cf.reservation_id
WHERE au.account_type = 'premium'
GROUP BY au.fname, au.lname, au.account_type
HAVING AVG(cf.rating) > 3;

-- 4. Query to find vehicles that need maintenance based on their last service date
-- and current reservations
SELECT 
    v.make,
    v.model,
    v.year,
    cc.service_type as last_service,
    cc.date as last_service_date
FROM vehicle v
JOIN car_care cc ON v.vehicle_id = cc.vehicle_id
WHERE cc.date = (
    SELECT MAX(date)
    FROM car_care cc2
    WHERE cc2.vehicle_id = v.vehicle_id
)
AND v.vehicle_id NOT IN (
    SELECT vehicle_id
    FROM reservation
    WHERE start_date <= CURRENT_DATE AND end_date >= CURRENT_DATE
);

-- 5. Query to find the average rating and number of rentals for each vehicle category
-- including vehicle details and total revenue
SELECT 
    vc.category_name,
    v.make,
    v.model,
    COUNT(DISTINCT r.reservation_id) as total_rentals,
    AVG(cf.rating) as avg_rating,
    SUM(r.total_cost) as total_revenue
FROM vehicle_category vc
JOIN vehicle v ON vc.category_id = v.category_id
JOIN reservation r ON v.vehicle_id = r.vehicle_id
JOIN customer_feedback cf ON r.reservation_id = cf.reservation_id
GROUP BY vc.category_name, v.make, v.model
ORDER BY avg_rating DESC, total_rentals DESC;

-- 6. Query to analyze customer support issues by location and vehicle category
SELECT 
    l.city,
    l.state,
    vc.category_name,
    COUNT(s.support_id) as total_issues,
    COUNT(CASE WHEN s.status = 'OPEN' THEN 1 END) as open_issues
FROM support s
JOIN app_user au ON s.user_id = au.user_id
JOIN reservation r ON au.user_id = r.user_id
JOIN vehicle v ON r.vehicle_id = v.vehicle_id
JOIN vehicle_category vc ON v.category_id = vc.category_id
JOIN location l ON v.location_id = l.location_id
GROUP BY l.city, l.state, vc.category_name
ORDER BY total_issues DESC;

-- 7. Query to find the most profitable rental agreements by location
-- including insurance and maintenance costs
SELECT 
    l.city,
    l.state,
    COUNT(ra.agreement_id) as total_agreements,
    SUM(ra.total_amount) as total_revenue,
    SUM(cc.cost) as maintenance_costs,
    SUM(ra.total_amount) - SUM(cc.cost) as net_profit
FROM rental_agreement ra
JOIN reservation r ON ra.reservation_id = r.reservation_id
JOIN vehicle v ON r.vehicle_id = v.vehicle_id
JOIN location l ON v.location_id = l.location_id
LEFT JOIN car_care cc ON v.vehicle_id = cc.vehicle_id
GROUP BY l.city, l.state
ORDER BY net_profit DESC;

-- 8. Query to analyze vehicle rental duration and revenue by make and model
SELECT 
    v.make,
    v.model,
    COUNT(r.reservation_id) as total_reservations,
    SUM(r.end_date - r.start_date) as total_rental_days,
    AVG(r.total_cost) as avg_rental_cost,
    SUM(r.total_cost) as total_revenue
FROM vehicle v
JOIN reservation r ON v.vehicle_id = r.vehicle_id
GROUP BY v.make, v.model
ORDER BY total_revenue DESC;

-- 9. Query to analyze customer rental patterns across different vehicle categories
SELECT 
    au.account_type,
    vc.category_name,
    COUNT(r.reservation_id) as total_rentals,
    AVG(r.total_cost) as avg_rental_cost,
    SUM(r.total_cost) as total_revenue
FROM app_user au
JOIN reservation r ON au.user_id = r.user_id
JOIN vehicle v ON r.vehicle_id = v.vehicle_id
JOIN vehicle_category vc ON v.category_id = vc.category_id
GROUP BY au.account_type, vc.category_name
ORDER BY total_revenue DESC;

-- 10. Query to identify high-value customers based on rental history and feedback
SELECT 
    au.fname,
    au.lname,
    au.account_type,
    COUNT(DISTINCT r.reservation_id) as total_rentals,
    AVG(cf.rating) as avg_rating,
    SUM(r.total_cost) as total_spent
FROM app_user au
JOIN reservation r ON au.user_id = r.user_id
JOIN customer_feedback cf ON r.reservation_id = cf.reservation_id
GROUP BY au.fname, au.lname, au.account_type
HAVING COUNT(DISTINCT r.reservation_id) >= 1 
    AND AVG(cf.rating) >= 4
ORDER BY total_spent DESC;