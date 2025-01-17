import streamlit as st
import pandas as pd
import numpy as np
from sqlalchemy import create_engine, text
from datetime import datetime, date, timedelta

# Database connection
engine = create_engine('postgresql://ryanh:1564@localhost:5432/car_rental')

def main():
    st.title("Car Rental Management System")
    
    page = st.sidebar.selectbox(
        "Select Operation",
        ["Reservations", "Vehicle Management", "Customer Analytics", 
         "Support Tickets", "Maintenance", "Reports", "Location Analytics"]
    )
    
    if page == "Reservations":
        show_reservation_management()
    elif page == "Vehicle Management":
        show_vehicle_management()
    elif page == "Customer Analytics":
        show_customer_analytics()
    elif page == "Support Tickets":
        show_support_management()
    elif page == "Maintenance":
        show_maintenance()
    elif page == "Reports":
        show_reports()
    else:
        show_location_analytics()

def show_reservation_management():
    st.header("Reservation Management")
    
    operation = st.selectbox("Select Operation", ["View", "Create", "Update", "Cancel"])
    
    if operation == "Create":
        users_df = pd.read_sql("SELECT user_id, fname, lname, account_type FROM app_user", engine)
        user_id = st.selectbox("Select Customer", 
            options=users_df['user_id'].tolist(),
            format_func=lambda x: f"{users_df[users_df['user_id']==x]['fname'].iloc[0]} {users_df[users_df['user_id']==x]['lname'].iloc[0]} ({users_df[users_df['user_id']==x]['account_type'].iloc[0]})"
        )
        
        # Show loyalty score
        with engine.connect() as conn:
            result = conn.execute(text("SELECT calculate_customer_loyalty(:uid)"), {'uid': int(user_id)})
            loyalty_score = result.scalar()
            st.info(f"Customer Loyalty Score: {loyalty_score}")
        
        # Available vehicles
        vehicles_df = pd.read_sql("""
            SELECT v.vehicle_id, v.make, v.model, v.year, 
                   vc.category_name, vc.price_range,
                   vms.last_service_date,
                   vms.total_maintenance_cost
            FROM vehicle v 
            JOIN vehicle_category vc ON v.category_id = vc.category_id
            LEFT JOIN vehicle_maintenance_summary vms ON v.vehicle_id = vms.vehicle_id
            WHERE v.vehicle_id NOT IN (
                SELECT vehicle_id FROM reservation 
                WHERE CURRENT_DATE BETWEEN start_date AND end_date
            )
        """, engine)
        
        vehicle_id = st.selectbox("Select Vehicle", 
            options=vehicles_df['vehicle_id'].tolist(),
            format_func=lambda x: (
                f"{vehicles_df[vehicles_df['vehicle_id']==x]['year'].iloc[0]} "
                f"{vehicles_df[vehicles_df['vehicle_id']==x]['make'].iloc[0]} "
                f"{vehicles_df[vehicles_df['vehicle_id']==x]['model'].iloc[0]} - "
                f"{vehicles_df[vehicles_df['vehicle_id']==x]['category_name'].iloc[0]}"
            )
        )
        
        start_date = st.date_input("Start Date", min_value=date.today())
        end_date = st.date_input("End Date", min_value=start_date)
        
        if start_date and end_date and vehicle_id:
            duration = (end_date - start_date).days
            daily_rate = float(vehicles_df[vehicles_df['vehicle_id']==vehicle_id]['price_range'].iloc[0])
            total_cost = float(duration * daily_rate)
            
            if users_df[users_df['user_id']==user_id]['account_type'].iloc[0] == 'premium':
                total_cost = float(total_cost * 0.9)  # 10% discount
                st.write("Premium customer discount applied!")
            
            # Convert numpy float64 to Python float
            if isinstance(total_cost, np.floating):
                total_cost = float(total_cost)
            
            total_cost = round(total_cost, 2)
            st.write(f"Total Cost: ${total_cost:.2f}")
            
            if st.button("Create Reservation"):
                try:
                    with engine.connect() as conn:
                        # Get next reservation ID
                        result = conn.execute(text("SELECT MAX(reservation_id) FROM reservation"))
                        next_id = int((result.fetchone()[0] or 3000) + 1)
                        
                        # Create reservation
                        conn.execute(text("""
                            INSERT INTO reservation (reservation_id, user_id, vehicle_id, start_date, end_date, total_cost)
                            VALUES (:rid, :uid, :vid, :sd, :ed, :tc)
                        """), {
                            'rid': next_id,
                            'uid': int(user_id),
                            'vid': int(vehicle_id),
                            'sd': start_date,
                            'ed': end_date,
                            'tc': float(total_cost)
                        })
                        
                        # Create rental agreement
                        conn.execute(text("""
                            INSERT INTO rental_agreement (agreement_id, reservation_id, agreement_terms, total_amount)
                            VALUES (:aid, :rid, :terms, :amount)
                        """), {
                            'aid': int(next_id + 1000),
                            'rid': next_id,
                            'terms': 'Standard rental terms and conditions apply.',
                            'amount': float(total_cost)
                        })
                        
                        conn.commit()
                        st.success("Reservation created successfully!")
                except Exception as e:
                    st.error(f"Error creating reservation: {e}")
    
    elif operation == "View":
        # Show all reservations
        reservations_df = pd.read_sql("""
            SELECT 
                r.reservation_id,
                CONCAT(au.fname, ' ', au.lname) as customer_name,
                CONCAT(v.year, ' ', v.make, ' ', v.model) as vehicle,
                r.start_date,
                r.end_date,
                r.total_cost
            FROM reservation r
            JOIN app_user au ON r.user_id = au.user_id
            JOIN vehicle v ON r.vehicle_id = v.vehicle_id
            ORDER BY r.start_date DESC
        """, engine)
        st.dataframe(reservations_df)

def show_reports():
    st.header("Reports and Analytics")
    
    report_type = st.selectbox("Select Report Type", [
        "Rental Analytics by Category",
        "High Value Customers",
        "Vehicle Maintenance Summary",
        "Location Performance",
        "Customer Rental Patterns"
    ])
    
    if report_type == "Rental Analytics by Category":
        df = pd.read_sql("SELECT * FROM rental_analytics", engine)
        st.subheader("Rental Performance by Category and Location")
        st.dataframe(df)
        
        # Visualization
        st.bar_chart(df.groupby('category_name')['total_revenue'].sum())
        
    elif report_type == "High Value Customers":
        df = pd.read_sql("SELECT * FROM high_value_customers", engine)
        st.subheader("High Value Customer Analysis")
        st.dataframe(df)
        
    elif report_type == "Vehicle Maintenance Summary":
        df = pd.read_sql("SELECT * FROM vehicle_maintenance_summary", engine)
        st.subheader("Vehicle Maintenance History")
        st.dataframe(df)
        
        st.bar_chart(df.groupby('make')['total_maintenance_cost'].mean())

def show_maintenance():
    st.header("Vehicle Maintenance Management")
    
    # Get vehicles needing maintenance based on your query
    maintenance_df = pd.read_sql("""
        SELECT 
            v.vehicle_id,
            v.make,
            v.model,
            v.year,
            cc.service_type as last_service,
            cc.date as last_service_date
        FROM vehicle v
        LEFT JOIN car_care cc ON v.vehicle_id = cc.vehicle_id
        WHERE cc.date = (
            SELECT MAX(date)
            FROM car_care cc2
            WHERE cc2.vehicle_id = v.vehicle_id
        )
        AND v.vehicle_id NOT IN (
            SELECT vehicle_id
            FROM reservation
            WHERE start_date <= CURRENT_DATE AND end_date >= CURRENT_DATE
        )
    """, engine)
    
    st.subheader("Vehicles Requiring Maintenance")
    st.dataframe(maintenance_df)

    # Maintenance scheduling form
    st.subheader("Schedule Maintenance")
    vehicle_id = st.selectbox("Select Vehicle", maintenance_df['vehicle_id'].tolist())
    service_type = st.selectbox("Service Type", [
        "Oil Change", "Tire Rotation", "Brake Inspection", 
        "Battery Check", "General Maintenance"
    ])
    
    # Employee assignment - modified to include Technicians
    employees_df = pd.read_sql(
        """
        SELECT employee_id, name 
        FROM employee 
        WHERE position IN ('Technician', 'Mechanic')
        """, 
        engine
    )
    
    if not employees_df.empty:
        employee_id = st.selectbox("Assign Technician", 
            options=employees_df['employee_id'].tolist(),
            format_func=lambda x: employees_df[employees_df['employee_id']==x]['name'].iloc[0]
        )
        
        if st.button("Schedule Maintenance"):
            try:
                with engine.connect() as conn:
                    # Get next care_id
                    result = conn.execute(text("SELECT MAX(care_id) FROM car_care"))
                    next_id = int((result.fetchone()[0] or 1000) + 1)
                    
                    # Create maintenance record
                    conn.execute(text("""
                        INSERT INTO car_care (
                            care_id, vehicle_id, service_type, date, 
                            cost, receiving_employee_id, performing_employee_id
                        ) VALUES (
                            :cid, :vid, :stype, CURRENT_DATE,
                            :cost, :emp_id, :emp_id
                        )
                    """), {
                        'cid': next_id,
                        'vid': int(vehicle_id),
                        'stype': service_type,
                        'cost': 50.00,  # Default cost, you might want to make this dynamic
                        'emp_id': int(employee_id)
                    })
                    
                    conn.commit()
                    st.success("Maintenance scheduled successfully!")
            except Exception as e:
                st.error(f"Error scheduling maintenance: {e}")
    else:
        st.error("No technicians or mechanics found in the system. Please add qualified personnel first.")
def show_vehicle_management():
    st.header("Vehicle Management")
    
    operation = st.selectbox("Select Operation", ["View", "Add", "Update", "Delete"])
    
    if operation == "View":
        vehicles_df = pd.read_sql("""
            SELECT 
                v.vehicle_id,
                v.year,
                v.make,
                v.model,
                v.license_plate_num,
                vc.category_name,
                l.city,
                l.state,
                e.name as assigned_employee,
                i.company_name as insurance_provider,
                i.policy_num
            FROM vehicle v
            JOIN vehicle_category vc ON v.category_id = vc.category_id
            JOIN location l ON v.location_id = l.location_id
            JOIN employee e ON v.employee_id = e.employee_id
            JOIN insurance i ON v.insurance_id = i.insurance_id
            ORDER BY v.vehicle_id
        """, engine)
        st.dataframe(vehicles_df)

    elif operation == "Add":
        # Get all required foreign key references
        categories_df = pd.read_sql("SELECT * FROM vehicle_category", engine)
        locations_df = pd.read_sql("SELECT * FROM location", engine)
        employees_df = pd.read_sql("SELECT * FROM employee", engine)
        insurance_df = pd.read_sql("SELECT * FROM insurance", engine)
        
        # Form for new vehicle
        year = st.number_input("Year", min_value=1885, max_value=date.today().year, value=2024)
        make = st.text_input("Make")
        model = st.text_input("Model")
        license_plate = st.text_input("License Plate Number")
        
        category_id = st.selectbox("Category", 
            options=categories_df['category_id'].tolist(),
            format_func=lambda x: categories_df[categories_df['category_id']==x]['category_name'].iloc[0]
        )
        
        location_id = st.selectbox("Location", 
            options=locations_df['location_id'].tolist(),
            format_func=lambda x: f"{locations_df[locations_df['location_id']==x]['city'].iloc[0]}, {locations_df[locations_df['location_id']==x]['state'].iloc[0]}"
        )
        
        employee_id = st.selectbox("Assigned Employee", 
            options=employees_df['employee_id'].tolist(),
            format_func=lambda x: employees_df[employees_df['employee_id']==x]['name'].iloc[0]
        )
        
        insurance_id = st.selectbox("Insurance", 
            options=insurance_df['insurance_id'].tolist(),
            format_func=lambda x: f"{insurance_df[insurance_df['insurance_id']==x]['company_name'].iloc[0]} - {insurance_df[insurance_df['insurance_id']==x]['policy_num'].iloc[0]}"
        )
        
        if st.button("Add Vehicle"):
            try:
                with engine.connect() as conn:
                    # Get next vehicle ID
                    result = conn.execute(text("SELECT MAX(vehicle_id) FROM vehicle"))
                    next_id = int((result.fetchone()[0] or 0) + 1)
                    
                    # Add new vehicle
                    conn.execute(text("""
                        INSERT INTO vehicle (
                            vehicle_id, year, make, model, category_id, 
                            license_plate_num, employee_id, location_id, insurance_id
                        ) VALUES (
                            :vid, :year, :make, :model, :cat_id,
                            :license, :emp_id, :loc_id, :ins_id
                        )
                    """), {
                        'vid': next_id,
                        'year': int(year),
                        'make': make,
                        'model': model,
                        'cat_id': int(category_id),
                        'license': license_plate,
                        'emp_id': int(employee_id),
                        'loc_id': int(location_id),
                        'ins_id': int(insurance_id)
                    })
                    
                    conn.commit()
                    st.success("Vehicle added successfully!")
            except Exception as e:
                st.error(f"Error adding vehicle: {e}")

    elif operation == "Update":
        # Get vehicle to update
        vehicles_df = pd.read_sql("SELECT vehicle_id, year, make, model FROM vehicle", engine)
        vehicle_id = st.selectbox("Select Vehicle to Update", 
            options=vehicles_df['vehicle_id'].tolist(),
            format_func=lambda x: f"{vehicles_df[vehicles_df['vehicle_id']==x]['year'].iloc[0]} {vehicles_df[vehicles_df['vehicle_id']==x]['make'].iloc[0]} {vehicles_df[vehicles_df['vehicle_id']==x]['model'].iloc[0]}"
        )
        
        # Get current vehicle data
        current_vehicle = pd.read_sql(f"SELECT * FROM vehicle WHERE vehicle_id = {vehicle_id}", engine).iloc[0]
        
        # Form for updating vehicle
        locations_df = pd.read_sql("SELECT * FROM location", engine)
        employees_df = pd.read_sql("SELECT * FROM employee", engine)
        
        new_location = st.selectbox("New Location", 
            options=locations_df['location_id'].tolist(),
            format_func=lambda x: f"{locations_df[locations_df['location_id']==x]['city'].iloc[0]}, {locations_df[locations_df['location_id']==x]['state'].iloc[0]}",
            index=locations_df['location_id'].tolist().index(current_vehicle['location_id'])
        )
        
        new_employee = st.selectbox("New Assigned Employee", 
            options=employees_df['employee_id'].tolist(),
            format_func=lambda x: employees_df[employees_df['employee_id']==x]['name'].iloc[0],
            index=employees_df['employee_id'].tolist().index(current_vehicle['employee_id'])
        )
        
        if st.button("Update Vehicle"):
            try:
                with engine.connect() as conn:
                    conn.execute(text("""
                        UPDATE vehicle 
                        SET location_id = :loc_id,
                            employee_id = :emp_id
                        WHERE vehicle_id = :vid
                    """), {
                        'loc_id': int(new_location),
                        'emp_id': int(new_employee),
                        'vid': int(vehicle_id)
                    })
                    
                    conn.commit()
                    st.success("Vehicle updated successfully!")
            except Exception as e:
                st.error(f"Error updating vehicle: {e}")

    elif operation == "Delete":
        vehicles_df = pd.read_sql("SELECT vehicle_id, year, make, model FROM vehicle", engine)
        vehicle_id = st.selectbox("Select Vehicle to Delete", 
            options=vehicles_df['vehicle_id'].tolist(),
            format_func=lambda x: f"{vehicles_df[vehicles_df['vehicle_id']==x]['year'].iloc[0]} {vehicles_df[vehicles_df['vehicle_id']==x]['make'].iloc[0]} {vehicles_df[vehicles_df['vehicle_id']==x]['model'].iloc[0]}"
        )
        
        if st.button("Delete Vehicle"):
            try:
                with engine.connect() as conn:
                    # Check if vehicle has any reservations
                    result = conn.execute(text(
                        "SELECT COUNT(*) FROM reservation WHERE vehicle_id = :vid"
                    ), {'vid': vehicle_id})
                    reservation_count = result.scalar()
                    
                    if reservation_count > 0:
                        st.error("Cannot delete vehicle with existing reservations!")
                    else:
                        conn.execute(text(
                            "DELETE FROM vehicle WHERE vehicle_id = :vid"
                        ), {'vid': vehicle_id})
                        conn.commit()
                        st.success("Vehicle deleted successfully!")
            except Exception as e:
                st.error(f"Error deleting vehicle: {e}")

def show_customer_analytics():
    st.header("Customer Analytics")
    
    analysis_type = st.selectbox(
        "Select Analysis Type",
        ["Customer Overview", "Rental History", "Customer Loyalty Analysis", "Feedback Analysis"]
    )
    
    if analysis_type == "Customer Overview":
        # Get customer overview using high_value_customers view
        customers_df = pd.read_sql("""
            SELECT 
                au.user_id,
                au.fname || ' ' || au.lname as customer_name,
                au.email,
                au.phone,
                au.account_type,
                COUNT(r.reservation_id) as total_rentals,
                COALESCE(SUM(r.total_cost), 0) as total_spent,
                ROUND(AVG(cf.rating), 2) as avg_rating
            FROM app_user au
            LEFT JOIN reservation r ON au.user_id = r.user_id
            LEFT JOIN customer_feedback cf ON r.reservation_id = cf.reservation_id
            GROUP BY au.user_id, au.fname, au.lname, au.email, au.phone, au.account_type
            ORDER BY total_spent DESC
        """, engine)
        
        st.subheader("Customer Overview")
        st.dataframe(customers_df)
        
        # Visualization of customer spending by account type
        spending_by_type = customers_df.groupby('account_type')['total_spent'].sum()
        st.subheader("Total Spending by Account Type")
        st.bar_chart(spending_by_type)

    elif analysis_type == "Rental History":
        # Customer selection
        customers_df = pd.read_sql(
            "SELECT user_id, fname || ' ' || lname as name FROM app_user", 
            engine
        )
        selected_customer = st.selectbox(
            "Select Customer",
            options=customers_df['user_id'].tolist(),
            format_func=lambda x: customers_df[customers_df['user_id']==x]['name'].iloc[0]
        )
        
        # Get detailed rental history
        rental_history = pd.read_sql("""
            SELECT 
                r.reservation_id,
                v.make || ' ' || v.model as vehicle,
                vc.category_name,
                r.start_date,
                r.end_date,
                r.total_cost,
                COALESCE(cf.rating, 0) as rating,
                cf.comments
            FROM reservation r
            JOIN vehicle v ON r.vehicle_id = v.vehicle_id
            JOIN vehicle_category vc ON v.category_id = vc.category_id
            LEFT JOIN customer_feedback cf ON r.reservation_id = cf.reservation_id
            WHERE r.user_id = :user_id
            ORDER BY r.start_date DESC
        """, engine, params={'user_id': selected_customer})
        
        st.subheader("Customer Rental History")
        st.dataframe(rental_history)
        
        # Show preferred vehicle categories
        st.subheader("Preferred Vehicle Categories")
        category_preference = rental_history.groupby('category_name').size()
        st.bar_chart(category_preference)

    elif analysis_type == "Customer Loyalty Analysis":
        # Get loyalty analysis using your stored procedure
        loyalty_df = pd.read_sql("""
            SELECT 
                au.user_id,
                au.fname || ' ' || au.lname as customer_name,
                au.account_type,
                calculate_customer_loyalty(au.user_id) as loyalty_score,
                COUNT(r.reservation_id) as rental_count,
                ROUND(AVG(cf.rating), 2) as avg_rating
            FROM app_user au
            LEFT JOIN reservation r ON au.user_id = r.user_id
            LEFT JOIN customer_feedback cf ON r.reservation_id = cf.reservation_id
            GROUP BY au.user_id, au.fname, au.lname, au.account_type
            ORDER BY loyalty_score DESC
        """, engine)
        
        st.subheader("Customer Loyalty Scores")
        st.dataframe(loyalty_df)
        
        # Visualization of loyalty distribution
        fig_col1, fig_col2 = st.columns(2)
        with fig_col1:
            st.subheader("Loyalty Score Distribution")
            st.bar_chart(loyalty_df['loyalty_score'].value_counts())
        with fig_col2:
            st.subheader("Average Rating by Account Type")
            avg_rating_by_type = loyalty_df.groupby('account_type')['avg_rating'].mean()
            st.bar_chart(avg_rating_by_type)

    elif analysis_type == "Feedback Analysis":
        # Get detailed feedback analysis
        feedback_df = pd.read_sql("""
            SELECT 
                cf.feedback_id,
                au.fname || ' ' || au.lname as customer_name,
                v.make || ' ' || v.model as vehicle,
                cf.rating,
                cf.comments,
                cf.date_submitted,
                r.total_cost
            FROM customer_feedback cf
            JOIN app_user au ON cf.user_id = au.user_id
            JOIN reservation r ON cf.reservation_id = r.reservation_id
            JOIN vehicle v ON r.vehicle_id = v.vehicle_id
            ORDER BY cf.date_submitted DESC
        """, engine)
        
        st.subheader("Customer Feedback Analysis")
        st.dataframe(feedback_df)
        
        # Rating distribution
        st.subheader("Rating Distribution")
        rating_dist = feedback_df['rating'].value_counts().sort_index()
        st.bar_chart(rating_dist)
        
        # Average rating over time
        st.subheader("Average Rating Trend")
        feedback_df['month'] = pd.to_datetime(feedback_df['date_submitted']).dt.to_period('M')
        monthly_ratings = feedback_df.groupby('month')['rating'].mean()
        st.line_chart(monthly_ratings)
        
        # Show recent low ratings (3 or below) for immediate attention
        st.subheader("Recent Low Ratings (≤ 3)")
        low_ratings = feedback_df[
            (feedback_df['rating'] <= 3) & 
            (pd.to_datetime(feedback_df['date_submitted']) > pd.Timestamp.now() - pd.Timedelta(days=30))
        ]
        st.dataframe(low_ratings)

def show_support_management():
    st.header("Support Ticket Management")
    
    operation = st.selectbox(
        "Select Operation",
        ["View All Tickets", "Create Ticket", "Update Status", "Urgent Tickets", "Support Analytics"]
    )
    
    if operation == "View All Tickets":
        # Get all support tickets with customer details
        tickets_df = pd.read_sql("""
            SELECT 
                s.support_id,
                au.fname || ' ' || au.lname as customer_name,
                au.email,
                s.message,
                s.date,
                s.status,
                CASE 
                    WHEN s.status = 'OPEN' AND s.date < CURRENT_DATE - INTERVAL '3 days' 
                    THEN 'YES' ELSE 'NO' 
                END as needs_attention
            FROM support s
            JOIN app_user au ON s.user_id = au.user_id
            ORDER BY 
                CASE WHEN s.status = 'OPEN' THEN 0
                     WHEN s.status = 'URGENT' THEN 1
                     ELSE 2 END,
                s.date DESC
        """, engine)
        
        st.subheader("All Support Tickets")
        st.dataframe(tickets_df)
        
        # Show ticket statistics
        col1, col2, col3 = st.columns(3)
        with col1:
            open_tickets = len(tickets_df[tickets_df['status'] == 'OPEN'])
            st.metric("Open Tickets", open_tickets)
        with col2:
            urgent_tickets = len(tickets_df[tickets_df['status'] == 'URGENT'])
            st.metric("Urgent Tickets", urgent_tickets)
        with col3:
            attention_needed = len(tickets_df[tickets_df['needs_attention'] == 'YES'])
            st.metric("Needs Attention", attention_needed)

    elif operation == "Create Ticket":
        # Customer selection
        users_df = pd.read_sql(
            "SELECT user_id, fname || ' ' || lname as name FROM app_user", 
            engine
        )
        user_id = st.selectbox(
            "Select Customer",
            options=users_df['user_id'].tolist(),
            format_func=lambda x: users_df[users_df['user_id']==x]['name'].iloc[0]
        )
        
        message = st.text_area("Support Message")
        status = st.selectbox("Status", ["OPEN", "URGENT"])
        
        if st.button("Create Ticket"):
            try:
                with engine.connect() as conn:
                    # Get next support ID
                    result = conn.execute(text("SELECT MAX(support_id) FROM support"))
                    next_id = int((result.fetchone()[0] or 9000) + 1)
                    
                    # Create support ticket
                    conn.execute(text("""
                        INSERT INTO support (support_id, user_id, message, date, status)
                        VALUES (:sid, :uid, :msg, CURRENT_DATE, :status)
                    """), {
                        'sid': next_id,
                        'uid': int(user_id),
                        'msg': message,
                        'status': status
                    })
                    
                    conn.commit()
                    st.success("Support ticket created successfully!")
            except Exception as e:
                st.error(f"Error creating support ticket: {e}")

    elif operation == "Update Status":
        # Get open tickets for status update
        open_tickets_df = pd.read_sql("""
            SELECT 
                s.support_id,
                au.fname || ' ' || au.lname as customer_name,
                s.message,
                s.date,
                s.status
            FROM support s
            JOIN app_user au ON s.user_id = au.user_id
            WHERE s.status IN ('OPEN', 'URGENT')
            ORDER BY s.date DESC
        """, engine)
        
        if not open_tickets_df.empty:
            ticket_id = st.selectbox(
                "Select Ticket to Update",
                options=open_tickets_df['support_id'].tolist(),
                format_func=lambda x: f"Ticket #{x} - {open_tickets_df[open_tickets_df['support_id']==x]['customer_name'].iloc[0]}"
            )
            
            new_status = st.selectbox(
                "New Status",
                ["OPEN", "URGENT", "CLOSED", "RESOLVED"]
            )
            
            if st.button("Update Status"):
                try:
                    with engine.connect() as conn:
                        conn.execute(text("""
                            UPDATE support 
                            SET status = :status
                            WHERE support_id = :sid
                        """), {
                            'status': new_status,
                            'sid': int(ticket_id)
                        })
                        
                        conn.commit()
                        st.success("Ticket status updated successfully!")
                except Exception as e:
                    st.error(f"Error updating ticket status: {e}")
        else:
            st.info("No open tickets to update")

    elif operation == "Urgent Tickets":
        # Show urgent and overdue tickets
        urgent_tickets_df = pd.read_sql("""
            SELECT 
                s.support_id,
                au.fname || ' ' || au.lname as customer_name,
                au.email,
                au.phone,
                s.message,
                s.date,
                s.status,
                CURRENT_DATE - s.date as days_open
            FROM support s
            JOIN app_user au ON s.user_id = au.user_id
            WHERE s.status = 'URGENT' 
               OR (s.status = 'OPEN' AND s.date < CURRENT_DATE - INTERVAL '3 days')
            ORDER BY s.status DESC, s.date ASC
        """, engine)
        
        st.subheader("Urgent and Overdue Tickets")
        st.dataframe(urgent_tickets_df)

    elif operation == "Support Analytics":
        # Show support analytics
        st.subheader("Support Ticket Analytics")
        
        # Tickets by status
        status_df = pd.read_sql("""
            SELECT 
                status,
                COUNT(*) as count,
                AVG(CURRENT_DATE - date) as avg_days_open
            FROM support
            GROUP BY status
        """, engine)
        
        col1, col2 = st.columns(2)
        with col1:
            st.subheader("Tickets by Status")
            st.bar_chart(status_df.set_index('status')['count'])
        
        with col2:
            st.subheader("Average Days to Resolution")
            st.bar_chart(status_df.set_index('status')['avg_days_open'])
        
        # Recent ticket trend
        trend_df = pd.read_sql("""
            SELECT 
                date_trunc('week', date) as week,
                COUNT(*) as ticket_count
            FROM support
            GROUP BY date_trunc('week', date)
            ORDER BY week DESC
            LIMIT 12
        """, engine)
        
        st.subheader("Weekly Ticket Trend")
        st.line_chart(trend_df.set_index('week')['ticket_count'])
        
        # Common issues (word frequency in messages)
        common_issues = pd.read_sql("""
            SELECT 
                message,
                COUNT(*) as frequency
            FROM support
            GROUP BY message
            HAVING COUNT(*) > 1
            ORDER BY COUNT(*) DESC
            LIMIT 10
        """, engine)
        
        st.subheader("Common Support Issues")
        st.dataframe(common_issues)

def show_location_analytics():
    st.header("Location Analytics")
    
    analysis_type = st.selectbox(
        "Select Analysis Type",
        ["Location Overview", "Fleet Analysis", "Revenue Analysis", "Employee Performance", "Maintenance by Location"]
    )
    
    if analysis_type == "Location Overview":
        # Get comprehensive location overview
        location_overview = pd.read_sql("""
            SELECT 
                l.location_id,
                l.city,
                l.state,
                COUNT(DISTINCT v.vehicle_id) as total_vehicles,
                COUNT(DISTINCT e.employee_id) as total_employees,
                COUNT(DISTINCT r.reservation_id) as total_rentals,
                COALESCE(SUM(r.total_cost), 0) as total_revenue
            FROM location l
            LEFT JOIN vehicle v ON l.location_id = v.location_id
            LEFT JOIN employee e ON l.location_id = e.location_id
            LEFT JOIN reservation r ON v.vehicle_id = r.vehicle_id
            GROUP BY l.location_id, l.city, l.state
            ORDER BY total_revenue DESC
        """, engine)
        
        st.subheader("Location Performance Overview")
        st.dataframe(location_overview)
        
        # Visualizations
        col1, col2 = st.columns(2)
        with col1:
            st.subheader("Revenue by Location")
            st.bar_chart(location_overview.set_index('city')['total_revenue'])
        with col2:
            st.subheader("Fleet Size by Location")
            st.bar_chart(location_overview.set_index('city')['total_vehicles'])

    elif analysis_type == "Fleet Analysis":
        # Get fleet composition by location
        fleet_analysis = pd.read_sql("""
            SELECT 
                l.city,
                l.state,
                vc.category_name,
                COUNT(v.vehicle_id) as vehicle_count,
                AVG(vc.price_range) as avg_daily_rate,
                COUNT(r.reservation_id) as rental_count
            FROM location l
            LEFT JOIN vehicle v ON l.location_id = v.location_id
            LEFT JOIN vehicle_category vc ON v.category_id = vc.category_id
            LEFT JOIN reservation r ON v.vehicle_id = r.vehicle_id
            GROUP BY l.city, l.state, vc.category_name
            ORDER BY l.city, vehicle_count DESC
        """, engine)
        
        st.subheader("Fleet Composition by Location")
        st.dataframe(fleet_analysis)
        
        # Location selector for detailed view
        locations = fleet_analysis['city'].unique()
        selected_location = st.selectbox("Select Location for Detailed View", locations)
        
        # Filter and display location-specific data
        location_data = fleet_analysis[fleet_analysis['city'] == selected_location]
        st.subheader(f"Category Distribution in {selected_location}")
        st.bar_chart(location_data.set_index('category_name')['vehicle_count'])

    elif analysis_type == "Revenue Analysis":
        # Get detailed revenue analysis
        revenue_analysis = pd.read_sql("""
            SELECT 
                l.city,
                l.state,
                DATE_TRUNC('month', r.start_date) as month,
                COUNT(r.reservation_id) as rental_count,
                SUM(r.total_cost) as revenue,
                AVG(r.total_cost) as avg_rental_value,
                SUM(r.total_cost) / COUNT(DISTINCT v.vehicle_id) as revenue_per_vehicle
            FROM location l
            JOIN vehicle v ON l.location_id = v.location_id
            JOIN reservation r ON v.vehicle_id = r.vehicle_id
            GROUP BY l.city, l.state, DATE_TRUNC('month', r.start_date)
            ORDER BY l.city, month DESC
        """, engine)
        
        st.subheader("Revenue Analysis by Location")
        st.dataframe(revenue_analysis)
        
        # Revenue trends
        st.subheader("Monthly Revenue Trends by Location")
        pivot_data = revenue_analysis.pivot(index='month', columns='city', values='revenue')
        st.line_chart(pivot_data)

    elif analysis_type == "Employee Performance":
        # Employee performance by location
        employee_performance = pd.read_sql("""
            SELECT 
                l.city,
                l.state,
                e.name as employee_name,
                e.position,
                COUNT(cc.care_id) as services_performed,
                COUNT(DISTINCT v.vehicle_id) as vehicles_managed,
                AVG(cc.cost) as avg_service_cost
            FROM location l
            JOIN employee e ON l.location_id = e.location_id
            LEFT JOIN car_care cc ON e.employee_id = cc.performing_employee_id
            LEFT JOIN vehicle v ON e.employee_id = v.employee_id
            GROUP BY l.city, l.state, e.name, e.position
            ORDER BY l.city, services_performed DESC
        """, engine)
        
        st.subheader("Employee Performance by Location")
        st.dataframe(employee_performance)

    elif analysis_type == "Maintenance by Location":
        # Maintenance analysis by location
        maintenance_analysis = pd.read_sql("""
            SELECT 
                l.city,
                l.state,
                COUNT(cc.care_id) as total_services,
                AVG(cc.cost) as avg_service_cost,
                SUM(cc.cost) as total_maintenance_cost,
                STRING_AGG(DISTINCT cc.service_type, ', ') as service_types
            FROM location l
            JOIN vehicle v ON l.location_id = v.location_id
            JOIN car_care cc ON v.vehicle_id = cc.vehicle_id
            GROUP BY l.city, l.state
            ORDER BY total_maintenance_cost DESC
        """, engine)
        
        st.subheader("Maintenance Analysis by Location")
        st.dataframe(maintenance_analysis)
        
        # Maintenance cost comparison
        st.subheader("Maintenance Costs by Location")
        st.bar_chart(maintenance_analysis.set_index('city')['total_maintenance_cost'])
        
        # Service type breakdown
        locations = maintenance_analysis['city'].unique()
        selected_location = st.selectbox("Select Location for Service Details", locations)
        
        service_details = pd.read_sql("""
            SELECT 
                cc.service_type,
                COUNT(*) as service_count,
                AVG(cc.cost) as avg_cost,
                SUM(cc.cost) as total_cost
            FROM location l
            JOIN vehicle v ON l.location_id = v.location_id
            JOIN car_care cc ON v.vehicle_id = cc.vehicle_id
            WHERE l.city = :city
            GROUP BY cc.service_type
            ORDER BY service_count DESC
        """, engine, params={'city': selected_location})
        
        st.subheader(f"Service Type Breakdown for {selected_location}")
        st.dataframe(service_details)

if __name__ == "__main__":
    main()