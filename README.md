# Car Rental Management System

## Overview
The **Car Rental Management System** is a comprehensive database project designed to manage the operations of a car rental company. This system efficiently handles reservations, payments, vehicle maintenance, customer feedback, and support requests while providing insightful analytics and automations. It has been implemented using **PostgreSQL** and **Oracle Cloud**, showcasing the versatility of relational databases in handling complex business logic.

---

## Features

### 1. **Database Schema**
- **12 interconnected tables** to manage data for users, vehicles, locations, reservations, payments, feedback, and support tickets.
- Enforced **data consistency and integrity** using primary keys, foreign keys, and constraints.
- Scalable design for real-world business operations.

### 2. **Business Logic Automation**
- **Triggers** to automate operations:
  - Log new reservations and track price changes.
  - Archive deleted vehicle records.
  - Update customer statuses dynamically based on rental history.
- **Stored Procedures** and **Functions**:
  - Calculate customer loyalty scores.
  - Automate vehicle transfers between locations.
  - Generate real-time rental summary reports.

### 3. **Data Analytics**
- **Optimized SQL queries** for actionable insights:
  - Identify popular vehicle categories, high-value customers, and profitable rental agreements.
  - Analyze rental patterns, customer support issues, and vehicle maintenance trends.
- **Views** for analytics and reporting:
  - Comprehensive rental analytics dashboard.
  - Maintenance history summaries for vehicles.
  - High-value customer identification.

### 4. **Cloud Integration**
- Fully tested and deployed on **Oracle Cloud Infrastructure** using **Oracle Autonomous Database** for high availability and scalability.
- Cross-platform compatibility between PostgreSQL and Oracle.

---

## Table Structure

### Key Tables:
- **APP_USER**: Manages user accounts, including premium and standard customers.
- **VEHICLE**: Tracks vehicles, categories, and locations.
- **RESERVATION**: Stores customer reservation details.
- **CAR_CARE**: Records vehicle maintenance activities.
- **SUPPORT**: Logs support tickets and system-generated messages.
- **CUSTOMER_FEEDBACK**: Collects customer feedback and ratings.

---

## Key SQL Implementations

### Triggers
- **Reservation Logger**: Logs new reservations automatically into the support system.
- **Price Change Tracker**: Tracks changes in reservation costs and logs them.
- **Vehicle Deletion Archiver**: Archives vehicle information before deletion.
- **Customer Status Updater**: Automatically upgrades customers to premium status after 5 rentals.

### Views
- **rental_analytics**: Combines data from reservations, feedback, and maintenance for high-level insights.
- **high_value_customers**: Identifies top customers based on rental history and feedback.
- **vehicle_maintenance_summary**: Summarizes vehicle maintenance history, costs, and service types.

### Stored Procedures
- **update_vehicle_maintenance_status**: Updates vehicle categories based on maintenance records.
- **transfer_vehicle**: Automates vehicle transfers between locations.

---

## Deployment Instructions

### 1. **PostgreSQL Setup**
- Install PostgreSQL (if not already installed).
- Import the schema from `schema.sql` into your database.
- Populate the tables using `insert.sql`.

### 2. **Oracle Cloud Deployment**
- Set up an **Oracle Autonomous Database**.
- Use **Oracle SQL Developer** to migrate the PostgreSQL schema and data to Oracle.
- Validate the triggers, views, and procedures to ensure compatibility.

### 3. **Testing**
- Execute provided queries (`queries.sql`) to validate the functionality.
- Test stored procedures and triggers for expected behavior.
- Review views for accurate analytics.

---

## Project Highlights
- **Efficiency**: Automates key business processes using triggers and procedures.
- **Scalability**: Tested and deployed on Oracle Cloud for large-scale operations.
- **Insightful Analytics**: Advanced queries and views provide actionable insights.
- **Data Integrity**: Ensures consistency through robust constraints and relationships.

---

## Future Enhancements
- Implement a **web-based frontend** using **Streamlit** for end-user interaction.
- Introduce **machine learning** to predict customer preferences and optimize fleet management.
- Enable real-time notifications for reservation and support updates.

---

## Acknowledgments
This project is part of the **Car Rental Database Management System** coursework, showcasing advanced database design and analytics techniques.



# Create Virtual Environment
python -m venv venv

# Activate Virtual Environment
# Git Bash / Unix-like terminal
source venv/Scripts/activate

# Install dependencies
pip install streamlit sqlalchemy psycopg2 pandas numpy








