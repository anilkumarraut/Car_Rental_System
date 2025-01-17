-- USING CHAMATH

-- Truncate tables in correct order to avoid foreign key violations
TRUNCATE TABLE customer_feedback, rental_agreement, support, car_care, 
    reservation, vehicle, payment_gateway, insurance, employee, 
    vehicle_category, location, app_user CASCADE;

-- APP_USER Table (No changes needed)
INSERT INTO app_user (user_id, fname, lname, address, email, phone, account_type)
VALUES 
(1, 'Alice', 'Johnson', '123 Maple St', 'alice@example.com', '555-1234', 'standard'),
(2, 'Bob', 'Smith', '456 Oak Ave', 'bobsmith@example.com', '555-5678', 'premium'),
(3, 'Carol', 'White', '789 Pine Rd', 'carolw@example.com', '555-8765', 'standard'),
(4, 'David', 'Brown', '101 Elm Blvd', 'dbrown@example.com', '555-4321', 'standard'),
(5, 'Eva', 'Green', '202 Cedar St', 'eva@example.com', '555-3456', 'premium'),
(6, 'Frank', 'Black', '303 Birch Ln', 'fblack@example.com', '555-6789', 'standard'),
(7, 'Grace', 'Wilson', '404 Spruce Pl', 'gwilson@example.com', '555-9876', 'standard'),
(8, 'Henry', 'Lee', '505 Aspen Ct', 'henrylee@example.com', '555-4567', 'premium'),
(9, 'Ivy', 'Adams', '606 Poplar Way', 'ivyadams@example.com', '555-7654', 'standard'),
(10, 'Jack', 'Stone', '707 Cedar Dr', 'jackstone@example.com', '555-6543', 'standard');

-- LOCATION Table (No changes needed)
INSERT INTO location (location_id, city, state, county, zip_code)
VALUES
(1, 'Chicago', 'IL', 'Cook', '60601'),
(2, 'New York', 'NY', 'New York', '10001'),
(3, 'Los Angeles', 'CA', 'Los Angeles', '90001'),
(4, 'Houston', 'TX', 'Harris', '77001'),
(5, 'Phoenix', 'AZ', 'Maricopa', '85001'),
(6, 'Philadelphia', 'PA', 'Philadelphia', '19101'),
(7, 'San Antonio', 'TX', 'Bexar', '78201'),
(8, 'San Diego', 'CA', 'San Diego', '92101'),
(9, 'Dallas', 'TX', 'Dallas', '75201'),
(10, 'San Jose', 'CA', 'Santa Clara', '95101');

-- VEHICLE_CATEGORY Table (No changes needed)
INSERT INTO vehicle_category (category_id, category_name, description, price_range)
VALUES
(1, 'Luxury', 'High-end luxury vehicles', 300),
(2, 'Exotic', 'High-performance vehicles', 500),
(3, 'Standard', 'Standard vehicles for everyday use', 150),
(4, 'SUV', 'Sport Utility Vehicles', 250),
(5, 'Electric', 'Electric vehicles', 350),
(6, 'Compact', 'Fuel-efficient vehicles', 100),
(7, 'Sports', 'High-speed vehicles', 400),
(8, 'Convertible', 'Retractable roof vehicles', 350),
(9, 'Truck', 'Heavy-duty vehicles', 275),
(10, 'Minivan', 'Spacious family vehicles', 200);

-- EMPLOYEE Table (No changes needed)
INSERT INTO employee (employee_id, name, join_date, salary, position, location_id)
VALUES
(1, 'Tom Harris', '2021-01-10', 55000.00, 'Manager', 1),
(2, 'Sue Green', '2022-03-15', 45000.00, 'Assistant Manager', 2),
(3, 'Bill Brown', '2023-05-20', 38000.00, 'Technician', 3),
(4, 'Mary White', '2020-11-11', 40000.00, 'Customer Service', 4),
(5, 'Sam Black', '2019-06-06', 32000.00, 'Sales Associate', 5),
(6, 'Linda Blue', '2021-09-09', 60000.00, 'Finance', 6),
(7, 'Nancy Gray', '2022-02-14', 45000.00, 'IT Specialist', 7),
(8, 'Peter Yellow', '2023-07-30', 50000.00, 'Analyst', 8),
(9, 'John Silver', '2023-08-05', 48000.00, 'Mechanic', 9),
(10, 'Ella Orange', '2022-12-20', 42000.00, 'Support', 10);

-- INSURANCE Table (Fixed expiration dates to be in the future)
INSERT INTO insurance (insurance_id, company_name, insurance_type, policy_num, expiration_date)
VALUES
(1, 'State Farm', 'Collision', 'POL1001', '2025-12-31'),
(2, 'Geico', 'Comprehensive', 'POL1002', '2025-12-30'),
(3, 'Progressive', 'Liability', 'POL1003', '2025-01-15'),
(4, 'Allstate', 'Collision', 'POL1004', '2025-09-10'),
(5, 'Liberty Mutual', 'Comprehensive', 'POL1005', '2025-05-22'),
(6, 'Nationwide', 'Liability', 'POL1006', '2025-11-01'),
(7, 'Farmers', 'Collision', 'POL1007', '2025-07-19'),
(8, 'USAA', 'Comprehensive', 'POL1008', '2025-03-05'),
(9, 'AAA', 'Liability', 'POL1009', '2025-08-14'),
(10, 'Travelers', 'Collision', 'POL1010', '2025-10-28');

-- VEHICLE Table
INSERT INTO vehicle (vehicle_id, year, make, model, category_id, license_plate_num, employee_id, location_id, insurance_id)
VALUES
(1, 2020, 'Honda', 'Accord', 3, 'ABC123', 1, 1, 1),
(2, 2019, 'Nissan', 'Altima', 3, 'XYZ789', 2, 2, 2),
(3, 2021, 'Chevrolet', 'Malibu', 3, 'LMN456', 3, 3, 3),
(4, 2018, 'Ford', 'Taurus', 3, 'QRS654', 4, 4, 4),
(5, 2022, 'Kia', 'Sorento', 4, 'TUV321', 5, 5, 5),
(6, 2023, 'Nissan', 'Rogue', 4, 'VWX852', 6, 6, 6),
(7, 2017, 'Toyota', 'Camry', 6, 'DEF963', 7, 7, 7),
(8, 2023, 'Honda', 'Insight', 3, 'GHJ741', 8, 8, 8),
(9, 2020, 'Volkswagen', 'Jetta', 1, 'KLM258', 9, 9, 9),
(10, 2021, 'Ford', 'Escape', 10, 'NOP369', 10, 10, 10);

-- PAYMENT_GATEWAY Table (No changes needed)
INSERT INTO payment_gateway (payment_id, confirmation_num, payment_method, amount, date)
VALUES
(1, 'CONF123', 'Credit Card', 150.75, '2024-01-01'),
(2, 'CONF456', 'Check', 89.99, '2024-01-02'),
(3, 'CONF789', 'Cash', 200.00, '2024-01-03'),
(4, 'CONF101', 'Credit Card', 120.50, '2024-01-04'),
(5, 'CONF102', 'Check', 75.25, '2024-01-05'),
(6, 'CONF103', 'Cash', 60.99, '2024-01-06'),
(7, 'CONF104', 'Credit Card', 250.45, '2024-01-07'),
(8, 'CONF105', 'Check', 130.80, '2024-01-08'),
(9, 'CONF106', 'Cash', 95.30, '2024-01-09'),
(10, 'CONF107', 'Credit Card', 180.00, '2024-01-10');

-- RESERVATION Table
INSERT INTO reservation (reservation_id, user_id, vehicle_id, start_date, end_date, total_cost)
VALUES
(3001, 1, 1, '2024-02-01', '2024-02-10', 300.00),
(3002, 1, 2, '2024-02-15', '2024-02-20', 150.00),
(3003, 3, 3, '2024-03-01', '2024-03-07', 250.00),
(3004, 4, 4, '2024-03-15', '2024-03-20', 200.00),
(3005, 5, 5, '2024-04-01', '2024-04-10', 350.00),
(3006, 6, 6, '2024-04-15', '2024-04-18', 180.00),
(3007, 7, 7, '2024-05-01', '2024-05-07', 220.00),
(3008, 8, 8, '2024-05-10', '2024-05-15', 270.00),
(3009, 9, 9, '2024-06-01', '2024-06-05', 190.00),
(3010, 10, 10, '2024-06-10', '2024-06-15', 210.00);

-- CAR_CARE Table
INSERT INTO car_care (care_id, vehicle_id, service_type, date, cost, receiving_employee_id, performing_employee_id)
VALUES
(1001, 1, 'Oil Change', '2024-01-10', 29.99, 1, 3),
(1002, 2, 'Tire Rotation', '2024-02-05', 19.99, 2, 3),
(1003, 3, 'Brake Inspection', '2024-03-15', 49.99, 3, 9),
(1004, 4, 'Battery Replacement', '2024-04-10', 89.99, 4, 9),
(1005, 5, 'Fluid Check', '2024-05-20', 15.99, 5, 3),
(1006, 6, 'Tire Replacement', '2024-06-15', 99.99, 6, 9),
(1007, 7, 'Transmission Service', '2024-07-25', 120.00, 7, 3),
(1008, 8, 'Engine Tune-Up', '2024-08-30', 150.00, 8, 9),
(1009, 9, 'Windshield Wiper Replacement', '2024-09-12', 10.99, 9, 3),
(1010, 10, 'Air Filter Change', '2024-10-20', 12.99, 10, 9);

-- SUPPORT Table (No changes needed)
INSERT INTO support (support_id, user_id, message, date, status)
VALUES
(9001, 1, 'Issue with reservation confirmation.', '2024-01-15', 'OPEN'),
(9002, 2, 'Question about payment methods.', '2024-02-18', 'CLOSED'),
(9003, 3, 'Request for additional car features.', '2024-03-10', 'OPEN'),
(9004, 4, 'Complaint about vehicle cleanliness.', '2024-04-05', 'CLOSED'),
(9005, 5, 'Assistance with insurance information.', '2024-05-15', 'OPEN'),
(9006, 6, 'Help with online account.', '2024-06-10', 'CLOSED'),
(9007, 7, 'Feedback on support service.', '2024-07-25', 'OPEN'),
(9008, 8, 'Problem with vehicle selection.', '2024-08-15', 'CLOSED'),
(9009, 9, 'Inquiry about rental terms.', '2024-09-05', 'OPEN'),
(9010, 10, 'Technical issue with mobile app.', '2024-10-12', 'OPEN');

-- RENTAL_AGREEMENT Table
INSERT INTO rental_agreement (agreement_id, reservation_id, agreement_terms, signed_date, total_amount)
VALUES
(4001, 3001, 'Customer agrees to all rental terms.', '2024-02-01', 300.00),
(4002, 3002, 'Customer agrees to return vehicle clean.', '2024-02-15', 150.00),
(4003, 3003, 'Customer agrees to mileage limits.', '2024-03-01', 250.00),
(4004, 3004, 'Customer responsible for fuel refill.', '2024-03-15', 200.00),
(4005, 3005, 'Customer to report any damages.', '2024-04-01', 350.00),
(4006, 3006, 'No smoking in vehicle.', '2024-04-15', 180.00),
(4007, 3007, 'Early return incurs fee.', '2024-05-01', 220.00),
(4008, 3008, 'Customer agrees to insurance coverage.', '2024-05-10', 270.00),
(4009, 3009, 'Customer to follow traffic laws.', '2024-06-01', 190.00),
(4010, 3010, 'Customer will pay late fees.', '2024-06-10', 210.00);

-- CUSTOMER_FEEDBACK Table (with complete and valid entries)
INSERT INTO customer_feedback (feedback_id, user_id, reservation_id, rating, comments, date_submitted)
VALUES
(5001, 1, 3001, 4, 'Excellent service and clean vehicle.', '2024-02-12'),
(5002, 1, 3002, 5, 'Great car condition and smooth rental process!', '2024-02-22'),
(5003, 3, 3003, 3, 'Average experience, car was okay.', '2024-03-10'),
(5004, 4, 3004, 2, 'Vehicle needed better cleaning.', '2024-03-25'),
(5005, 5, 3005, 5, 'Outstanding service from start to finish.', '2024-04-12'),
(5006, 6, 3006, 4, 'Very satisfied with the rental experience.', '2024-04-20'),
(5007, 7, 3007, 3, 'Car performance was decent but not great.', '2024-05-09'),
(5008, 8, 3008, 4, 'Professional staff and good vehicle condition.', '2024-05-18'),
(5009, 9, 3009, 2, 'Some issues with vehicle features.', '2024-06-07'),
(5010, 10, 3010, 5, 'Perfect rental experience, will use again!', '2024-06-17');