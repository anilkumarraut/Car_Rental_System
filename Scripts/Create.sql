

-- Drop Tables (with updated APP_USER name)
DROP TABLE IF EXISTS CUSTOMER_FEEDBACK CASCADE;
DROP TABLE IF EXISTS RENTAL_AGREEMENT CASCADE;
DROP TABLE IF EXISTS SUPPORT CASCADE;
DROP TABLE IF EXISTS CAR_CARE CASCADE;
DROP TABLE IF EXISTS RESERVATION CASCADE;
DROP TABLE IF EXISTS PAYMENT_GATEWAY CASCADE;
DROP TABLE IF EXISTS INSURANCE CASCADE;
DROP TABLE IF EXISTS VEHICLE CASCADE;
DROP TABLE IF EXISTS VEHICLE_CATEGORY CASCADE;
DROP TABLE IF EXISTS LOCATION CASCADE;
DROP TABLE IF EXISTS EMPLOYEE CASCADE;
DROP TABLE IF EXISTS APP_USER CASCADE;

-- APP_USER Table
CREATE TABLE APP_USER (
    user_id INT PRIMARY KEY,
    fname VARCHAR(100) NOT NULL,
    lname VARCHAR(100) NOT NULL,
    address VARCHAR(255),
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    account_type VARCHAR(50) DEFAULT 'standard'
);

-- LOCATION Table
CREATE TABLE LOCATION (
    location_id INT PRIMARY KEY,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL,
    county VARCHAR(50),
    zip_code VARCHAR(10) NOT NULL CHECK (zip_code ~ '^[0-9]{5}$')
);

-- VEHICLE_CATEGORY Table
CREATE TABLE VEHICLE_CATEGORY (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(50) UNIQUE NOT NULL,
    description VARCHAR(255),
    price_range DECIMAL(10, 2) CHECK (price_range >= 0)
);

-- INSURANCE Table
CREATE TABLE INSURANCE (
    insurance_id INT PRIMARY KEY,
    company_name VARCHAR(100) NOT NULL,
    insurance_type VARCHAR(50),
    policy_num VARCHAR(50) UNIQUE NOT NULL,
    expiration_date DATE CHECK (expiration_date > CURRENT_DATE)
);

-- EMPLOYEE Table
CREATE TABLE EMPLOYEE (
    employee_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    join_date DATE DEFAULT CURRENT_DATE,
    salary DECIMAL(10, 2) CHECK (salary >= 0),
    position VARCHAR(50) NOT NULL,
    location_id INT,
    FOREIGN KEY (location_id) REFERENCES LOCATION(location_id)
);

-- VEHICLE Table
CREATE TABLE VEHICLE (
    vehicle_id INT PRIMARY KEY,
    year INT CHECK (year BETWEEN 1885 AND EXTRACT(YEAR FROM CURRENT_DATE)),
    make VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    category_id INT,
    license_plate_num VARCHAR(20) UNIQUE NOT NULL,
    employee_id INT,
    location_id INT,
    insurance_id INT,
    FOREIGN KEY (category_id) REFERENCES VEHICLE_CATEGORY(category_id),
    FOREIGN KEY (employee_id) REFERENCES EMPLOYEE(employee_id),
    FOREIGN KEY (location_id) REFERENCES LOCATION(location_id),
    FOREIGN KEY (insurance_id) REFERENCES INSURANCE(insurance_id)
);

-- PAYMENT_GATEWAY Table
CREATE TABLE PAYMENT_GATEWAY (
    payment_id INT PRIMARY KEY,
    confirmation_num VARCHAR(50) UNIQUE NOT NULL,
    payment_method VARCHAR(50) DEFAULT 'Credit Card',
    amount DECIMAL(10, 2) CHECK (amount >= 0),
    date DATE DEFAULT CURRENT_DATE
);

-- RESERVATION Table
CREATE TABLE RESERVATION (
    reservation_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    vehicle_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE CHECK (end_date >= start_date),
    total_cost DECIMAL(10, 2) CHECK (total_cost >= 0),
    FOREIGN KEY (user_id) REFERENCES APP_USER(user_id),
    FOREIGN KEY (vehicle_id) REFERENCES VEHICLE(vehicle_id)
);

-- CAR_CARE Table
CREATE TABLE CAR_CARE (
    care_id INT PRIMARY KEY,
    vehicle_id INT NOT NULL,
    service_type VARCHAR(50) NOT NULL,
    date DATE DEFAULT CURRENT_DATE,
    cost DECIMAL(10, 2) CHECK (cost >= 0),
    receiving_employee_id INT,
    performing_employee_id INT,
    FOREIGN KEY (vehicle_id) REFERENCES VEHICLE(vehicle_id),
    FOREIGN KEY (receiving_employee_id) REFERENCES EMPLOYEE(employee_id),
    FOREIGN KEY (performing_employee_id) REFERENCES EMPLOYEE(employee_id)
);

-- SUPPORT Table
CREATE TABLE SUPPORT (
    support_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    message TEXT,
    date DATE DEFAULT CURRENT_DATE,
    status VARCHAR(50) DEFAULT 'Pending',
    FOREIGN KEY (user_id) REFERENCES APP_USER(user_id)
);

-- RENTAL_AGREEMENT Table
CREATE TABLE RENTAL_AGREEMENT (
    agreement_id INT PRIMARY KEY,
    reservation_id INT NOT NULL,
    agreement_terms TEXT NOT NULL,
    signed_date DATE DEFAULT CURRENT_DATE,
    total_amount DECIMAL(10, 2) CHECK (total_amount >= 0),
    FOREIGN KEY (reservation_id) REFERENCES RESERVATION(reservation_id)
);

-- CUSTOMER_FEEDBACK Table
CREATE TABLE CUSTOMER_FEEDBACK (
    feedback_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    reservation_id INT NOT NULL,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comments VARCHAR(255),
    date_submitted DATE DEFAULT CURRENT_DATE,
    FOREIGN KEY (user_id) REFERENCES APP_USER(user_id),
    FOREIGN KEY (reservation_id) REFERENCES RESERVATION(reservation_id)
);
