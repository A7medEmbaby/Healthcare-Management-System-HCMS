# Healthcare Management System (HCMS)

## Description

The **Healthcare Management System (HCMS)** is a fully designed and implemented database system aimed at managing the various aspects of a healthcare organization. This system includes tables for managing **patients**, **doctors**, **appointments**, **medical records**, **staff**, **billing**, and more. The project focuses on advanced SQL techniques such as **joins**, **subqueries**, **CTEs**, **stored procedures**, **triggers**, **transactions**, **indexing**, and **performance optimization**.

---

## Features

- **Comprehensive Database Design**: 
  - Relational schema includes entities like Patients, Doctors, Appointments, Medical Records, and more.
  - Normalized to 3NF to ensure data consistency and reduce redundancy.
- **Advanced SQL Operations**:
  - Complex **JOINs**, **subqueries**, and **CTEs** for data retrieval.
  - **Stored procedures** and **functions** to encapsulate business logic.
  - **Triggers** for automating actions like logging changes.
  - **Transactions** for ensuring data integrity during critical operations.
- **Performance Tuning**:
  - Indexes for faster query performance.
  - Optimized queries using execution plans and performance analysis.

---

## Database Schema

The following tables are included in this system:

- **Patients**: Stores patient details including personal information and medical history.
- **Doctors**: Holds doctor details such as specialties and departments.
- **Appointments**: Manages patient appointments with doctors.
- **Medical Records**: Stores medical records created by doctors for each patient.
- **Staff**: Includes staff roles like nurses and receptionists, along with their contact information.
- **Billing**: Manages billing for appointments.
- **Medications**: Information about medications used for prescriptions.
- **Prescriptions**: Records prescriptions given to patients by doctors.
- **Rooms**: Details about hospital rooms including their availability.
- **Visits**: Keeps track of patient visits to doctors.
- **Insurance**: Information about patient insurance providers and coverage.
- **Lab Tests**: Stores lab test information for patients.
- **Schedules**: Doctor schedules for appointments.
- **Emergency Contacts**: Patient emergency contact details.
- **Departments**: stores the information about various departments.
- **AppointmentLogs**: racks the history of changes to appointments, including status changes and updates to appointment details.

---

## ER Diagram

![HCMS Diagram](https://github.com/user-attachments/assets/295ec7e1-56ae-41a6-8d76-5c55a27a7ca4)

---

## Requirements

To set up the database, execute the following SQL scripts in order:

1. **Create Database**:  
   Run the SQL script `HCMS create objects.sql` to create the database.

2. **Populate Data**:  
   Run the script `Population.sql` to populate the database with sample data.

---

## How to Use

1. Clone this repository to your local machine:
   ```bash
   git clone https://github.com/A7medEmbaby/Healthcare-Management-System-HCMS.git
2. Run the following script in sequence:
   - `HCMS create objects.sql`
   - `Population.sql`

---

## 📞 Contact Information

For questions, feedback, or support, feel free to reach out:

- **Name**: Ahmed Embaby
- [a7medembaby@gmail.com](mailto:a7medembaby@gmail.com)
- [GitHub](https://github.com/A7medEmbaby)
- [LinkedIn](https://www.linkedin.com/in/ahmed-m-embaby)

I welcome any inquiries or collaboration opportunities!

## 🤝 Contributing

Contributions are welcome! Please open an issue or submit a pull request for any features or improvements.
