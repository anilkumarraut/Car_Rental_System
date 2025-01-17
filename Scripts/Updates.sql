-- (Updates - ASHFAK file)

-- APP_USER Table Updates
UPDATE app_user 
SET phone = '555-9999', account_type = 'premium' 
WHERE user_id = 1;

UPDATE app_user 
SET address = '789 Updated Ave', email = 'alice.new@example.com' 
WHERE fname = 'Alice' AND lname = 'Johnson';

UPDATE app_user 
SET account_type = 'premium' 
WHERE user_id IN (3, 4, 6);

UPDATE app_user 
SET phone = REPLACE(phone, '555', '777') 
WHERE account_type = 'standard';

-- LOCATION Table Updates
UPDATE location 
SET zip_code = '60602' 
WHERE city = 'Chicago';

UPDATE location 
SET county = 'Updated County' 
WHERE state IN ('NY', 'CA');

UPDATE location 
SET city = city || ' City', state = UPPER(state) 
WHERE location_id < 5;

UPDATE location 
SET zip_code = '90210' 
WHERE city = 'Los Angeles' AND state = 'CA';

-- VEHICLE_CATEGORY Table Updates
UPDATE vehicle_category 
SET price_range = price_range * 1.1 
WHERE category_name IN ('Luxury', 'Exotic');

UPDATE vehicle_category 
SET description = 'Premium ' || description 
WHERE price_range > 300;

UPDATE vehicle_category 
SET category_name = UPPER(category_name) 
WHERE category_id <= 5;

UPDATE vehicle_category 
SET price_range = price_range + 50 
WHERE category_name LIKE '%SUV%' OR category_name LIKE '%Truck%';

-- INSURANCE Table Updates
UPDATE insurance 
SET expiration_date = expiration_date + INTERVAL '1 year' 
WHERE company_name = 'State Farm';

UPDATE insurance 
SET insurance_type = 'Premium ' || insurance_type 
WHERE policy_num LIKE 'POL10%';

UPDATE insurance 
SET company_name = company_name || ' Insurance' 
WHERE insurance_id IN (2, 4, 6, 8);

UPDATE insurance 
SET expiration_date = '2026-12-31' 
WHERE insurance_type = 'Comprehensive';

-- EMPLOYEE Table Updates
UPDATE employee 
SET salary = salary * 1.05 
WHERE join_date < '2022-01-01';

UPDATE employee 
SET position = 'Senior ' || position 
WHERE salary > 50000;

UPDATE employee 
SET location_id = location_id + 1 
WHERE employee_id IN (1, 3, 5, 7) AND location_id < 10;

UPDATE employee 
SET name = UPPER(name) 
WHERE position LIKE '%Manager%';

-- VEHICLE Table Updates
UPDATE vehicle 
SET year = 2024 
WHERE make = 'Honda';

UPDATE vehicle 
SET employee_id = employee_id + 1 
WHERE category_id IN (1, 3, 5) AND employee_id < 10;

UPDATE vehicle 
SET license_plate_num = CONCAT('NEW', license_plate_num) 
WHERE year < 2020;

UPDATE vehicle 
SET location_id = location_id + 1 
WHERE make IN ('Ford', 'Toyota') AND location_id < 10;

-- PAYMENT_GATEWAY Table Updates
UPDATE payment_gateway 
SET amount = amount * 1.1 
WHERE payment_method = 'Credit Card';

UPDATE payment_gateway 
SET confirmation_num = 'NEW' || confirmation_num 
WHERE amount > 100;

UPDATE payment_gateway 
SET payment_method = 'Digital Payment' 
WHERE date >= '2024-01-05';

UPDATE payment_gateway 
SET date = date + INTERVAL '1 day' 
WHERE payment_id IN (1, 3, 5, 7);

-- RESERVATION Table Updates
UPDATE reservation 
SET total_cost = total_cost * 1.15 
WHERE end_date - start_date > 5;

UPDATE reservation 
SET end_date = end_date + INTERVAL '2 days' 
WHERE user_id IN (1, 3, 5);

UPDATE reservation 
SET total_cost = total_cost + 50 
WHERE vehicle_id IN (SELECT vehicle_id FROM vehicle WHERE make = 'Honda');

UPDATE reservation 
SET start_date = start_date + INTERVAL '1 day', 
    end_date = end_date + INTERVAL '1 day' 
WHERE reservation_id > 3005;

-- CAR_CARE Table Updates
UPDATE car_care 
SET cost = cost * 1.2 
WHERE service_type = 'Oil Change';

UPDATE car_care 
SET performing_employee_id = receiving_employee_id 
WHERE cost < 50;

UPDATE car_care 
SET date = date + INTERVAL '1 month' 
WHERE care_id > 1005;

UPDATE car_care 
SET service_type = 'Premium ' || service_type 
WHERE cost > 100;

-- SUPPORT Table Updates
UPDATE support 
SET status = 'URGENT' 
WHERE date < '2024-02-01' AND status = 'OPEN';

UPDATE support 
SET message = 'PRIORITY: ' || message 
WHERE support_id IN (9001, 9003, 9005);

UPDATE support 
SET status = 'CLOSED', 
    message = message || ' - Resolved' 
WHERE status = 'OPEN' AND date < '2024-05-01';

UPDATE support 
SET date = CURRENT_DATE 
WHERE status = 'OPEN';

-- RENTAL_AGREEMENT Table Updates
UPDATE rental_agreement 
SET total_amount = total_amount * 1.1 
WHERE agreement_id < 4005;

UPDATE rental_agreement 
SET agreement_terms = 'Updated: ' || agreement_terms 
WHERE signed_date >= '2024-04-01';

UPDATE rental_agreement 
SET signed_date = signed_date + INTERVAL '1 day' 
WHERE total_amount > 250;

UPDATE rental_agreement 
SET total_amount = total_amount + 25, 
    agreement_terms = agreement_terms || ' (Fee Added)' 
WHERE reservation_id IN (SELECT reservation_id FROM reservation WHERE total_cost > 300);

-- CUSTOMER_FEEDBACK Table Updates
UPDATE customer_feedback 
SET rating = rating + 1 
WHERE rating < 4;

UPDATE customer_feedback 
SET comments = 'VERIFIED: ' || comments 
WHERE rating = 5;

UPDATE customer_feedback 
SET date_submitted = date_submitted + INTERVAL '1 day' 
WHERE feedback_id > 5005;

UPDATE customer_feedback 
SET comments = comments || ' - Thanks for your feedback!', 
    rating = LEAST(rating + 1, 5) 
WHERE length(comments) > 30;



