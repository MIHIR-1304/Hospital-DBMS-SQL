-- ========================================================
-- Hospital Management System: 3NF Relational Database Schema
-- Author: Mihir Mahato
-- ========================================================

CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    building_wing VARCHAR(50),
    head_doctor_id INT
);

CREATE TABLE doctors (
    doctor_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    specialization VARCHAR(100) NOT NULL,
    department_id INT REFERENCES departments(department_id),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20)
);

CREATE TABLE patients (
    patient_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender VARCHAR(10),
    blood_group VARCHAR(5),
    phone VARCHAR(20),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE rooms (
    room_id SERIAL PRIMARY KEY,
    room_number VARCHAR(20) UNIQUE NOT NULL,
    department_id INT REFERENCES departments(department_id),
    room_type VARCHAR(50) DEFAULT 'GENERAL', -- ICU, GENERAL, PRIVATE
    is_occupied BOOLEAN DEFAULT FALSE,
    daily_rate NUMERIC(10, 2) NOT NULL
);

CREATE TABLE admissions (
    admission_id SERIAL PRIMARY KEY,
    patient_id INT REFERENCES patients(patient_id) ON DELETE CASCADE,
    room_id INT REFERENCES rooms(room_id),
    attending_doctor_id INT REFERENCES doctors(doctor_id),
    admission_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    discharge_date TIMESTAMP,
    discharge_status VARCHAR(50)
);

CREATE TABLE medical_records (
    record_id SERIAL PRIMARY KEY,
    admission_id INT REFERENCES admissions(admission_id) ON DELETE CASCADE,
    doctor_id INT REFERENCES doctors(doctor_id),
    diagnosis TEXT NOT NULL,
    treatment_plan TEXT,
    record_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE billing_invoices (
    invoice_id SERIAL PRIMARY KEY,
    admission_id INT REFERENCES admissions(admission_id) ON DELETE CASCADE,
    total_amount NUMERIC(12, 2) NOT NULL,
    payment_status VARCHAR(20) DEFAULT 'PENDING', -- PENDING, PAID, PARTIAL
    invoice_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index optimizations
CREATE INDEX idx_patients_name ON patients(last_name, first_name);
CREATE INDEX idx_admissions_patient ON admissions(patient_id, admission_date);
CREATE INDEX idx_rooms_occupied ON rooms(room_type, is_occupied);
