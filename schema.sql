-- ========================================================
-- Hospital Management System: 3NF Relational Database Schema
-- Architecture & Implementation: Mihir Mahato
-- Database: PostgreSQL 14+ / MySQL 8.0 Compatible
-- ========================================================

-- Drop existing tables in dependency order if re-initializing
DROP TABLE IF EXISTS billing_invoices CASCADE;
DROP TABLE IF EXISTS medical_records CASCADE;
DROP TABLE IF EXISTS admissions CASCADE;
DROP TABLE IF EXISTS rooms CASCADE;
DROP TABLE IF EXISTS patients CASCADE;
DROP TABLE IF EXISTS doctors CASCADE;
DROP TABLE IF EXISTS departments CASCADE;

-- --------------------------------------------------------
-- 1. Departments Table
-- --------------------------------------------------------
CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    building_wing VARCHAR(50) NOT NULL,
    head_doctor_name VARCHAR(100),
    contact_ext VARCHAR(10)
);

-- --------------------------------------------------------
-- 2. Doctors Table
-- --------------------------------------------------------
CREATE TABLE doctors (
    doctor_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    specialization VARCHAR(100) NOT NULL,
    department_id INT REFERENCES departments(department_id) ON DELETE SET NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE
);

-- --------------------------------------------------------
-- 3. Patients Table (Demographics & Baseline)
-- --------------------------------------------------------
CREATE TABLE patients (
    patient_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender VARCHAR(10) NOT NULL,
    blood_group VARCHAR(5) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    emergency_contact VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- --------------------------------------------------------
-- 4. Rooms & Bed Management
-- --------------------------------------------------------
CREATE TABLE rooms (
    room_id SERIAL PRIMARY KEY,
    room_number VARCHAR(20) UNIQUE NOT NULL,
    department_id INT REFERENCES departments(department_id) ON DELETE CASCADE,
    room_type VARCHAR(50) NOT NULL, -- ICU, PRIVATE, GENERAL, TRAUMA
    is_occupied BOOLEAN DEFAULT FALSE,
    daily_rate NUMERIC(10, 2) NOT NULL
);

-- --------------------------------------------------------
-- 5. Admissions Table (Inpatient Visits)
-- --------------------------------------------------------
CREATE TABLE admissions (
    admission_id SERIAL PRIMARY KEY,
    patient_id INT REFERENCES patients(patient_id) ON DELETE CASCADE,
    room_id INT REFERENCES rooms(room_id) ON DELETE SET NULL,
    attending_doctor_id INT REFERENCES doctors(doctor_id) ON DELETE SET NULL,
    admission_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    discharge_date TIMESTAMP,
    discharge_status VARCHAR(50) -- 'Active Inpatient', 'Discharged', 'Transferred'
);

-- --------------------------------------------------------
-- 6. Medical Records & Clinical Consultations
-- --------------------------------------------------------
CREATE TABLE medical_records (
    record_id SERIAL PRIMARY KEY,
    admission_id INT REFERENCES admissions(admission_id) ON DELETE CASCADE,
    doctor_id INT REFERENCES doctors(doctor_id) ON DELETE SET NULL,
    diagnosis VARCHAR(255) NOT NULL,
    treatment_plan TEXT NOT NULL,
    prescribed_medication TEXT,
    record_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- --------------------------------------------------------
-- 7. Billing & Financial Invoices
-- --------------------------------------------------------
CREATE TABLE billing_invoices (
    invoice_id SERIAL PRIMARY KEY,
    admission_id INT REFERENCES admissions(admission_id) ON DELETE CASCADE,
    room_charges NUMERIC(10, 2) NOT NULL,
    procedure_charges NUMERIC(10, 2) NOT NULL,
    medication_charges NUMERIC(10, 2) NOT NULL,
    total_amount NUMERIC(12, 2) NOT NULL,
    payment_status VARCHAR(20) DEFAULT 'PENDING', -- 'PAID', 'PENDING', 'OVERDUE'
    invoice_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- --------------------------------------------------------
-- Indexing Optimizations for Sub-Millisecond Queries
-- --------------------------------------------------------
CREATE INDEX idx_patients_name ON patients(last_name, first_name);
CREATE INDEX idx_admissions_patient ON admissions(patient_id, admission_date);
CREATE INDEX idx_rooms_occupied ON rooms(room_type, is_occupied);
CREATE INDEX idx_invoices_status ON billing_invoices(payment_status);
CREATE INDEX idx_doctors_dept ON doctors(department_id);

-- --------------------------------------------------------
-- Seed Data: Enterprise Hospital Records
-- --------------------------------------------------------

-- Insert Departments
INSERT INTO departments (department_id, name, building_wing, head_doctor_name, contact_ext) VALUES
(1, 'Cardiology', 'Wing A - 3rd Floor', 'Dr. Robert Chen', '4101'),
(2, 'Neurology', 'Wing B - 4th Floor', 'Dr. Elena Rostova', '4202'),
(3, 'Pediatrics', 'Wing C - 2nd Floor', 'Dr. Marcus Vance', '4303'),
(4, 'Orthopedics', 'Wing D - 1st Floor', 'Dr. Sarah Jenkins', '4404'),
(5, 'Oncology', 'Wing E - 5th Floor', 'Dr. Ananya Sharma', '4505'),
(6, 'Emergency & Trauma', 'Ground Floor North', 'Dr. David Miller', '4000');

-- Insert Doctors
INSERT INTO doctors (doctor_id, first_name, last_name, specialization, department_id, email, phone) VALUES
(101, 'Robert', 'Chen', 'Chief Cardiologist', 1, 'r.chen@carehealth.org', '+1-555-0101'),
(102, 'Elena', 'Rostova', 'Neurosurgeon & Spine Specialist', 2, 'e.rostova@carehealth.org', '+1-555-0102'),
(103, 'Marcus', 'Vance', 'Neonatal & Pediatric Care', 3, 'm.vance@carehealth.org', '+1-555-0103'),
(104, 'Sarah', 'Jenkins', 'Orthopedic Trauma & Joints', 4, 's.jenkins@carehealth.org', '+1-555-0104'),
(105, 'Ananya', 'Sharma', 'Clinical Hematology & Oncology', 5, 'a.sharma@carehealth.org', '+1-555-0105'),
(106, 'David', 'Miller', 'Emergency Trauma Director', 6, 'd.miller@carehealth.org', '+1-555-0106'),
(107, 'Michael', 'Chang', 'Interventional Cardiologist', 1, 'm.chang@carehealth.org', '+1-555-0107'),
(108, 'Emily', 'Watson', 'Clinical Neurologist', 2, 'e.watson@carehealth.org', '+1-555-0108');

-- Insert Patients
INSERT INTO patients (patient_id, first_name, last_name, date_of_birth, gender, blood_group, phone, emergency_contact) VALUES
(201, 'Arthur', 'Pendelton', '1968-04-12', 'Male', 'O+', '+1-555-2001', 'Martha Pendelton (Wife)'),
(202, 'Beatrice', 'Holloway', '1992-09-24', 'Female', 'A+', '+1-555-2002', 'Samuel Holloway (Spouse)'),
(203, 'Carlos', 'Mendoza', '1981-01-15', 'Male', 'B-', '+1-555-2003', 'Lucia Mendoza (Sister)'),
(204, 'Diana', 'Prince', '1997-07-03', 'Female', 'AB+', '+1-555-2004', 'Hippolyta Prince (Mother)'),
(205, 'Edward', 'Norton', '1959-11-20', 'Male', 'O-', '+1-555-2005', 'Rachel Norton (Daughter)'),
(206, 'Fiona', 'Gallagher', '2014-06-18', 'Female', 'A-', '+1-555-2006', 'Frank Gallagher (Father)'),
(207, 'George', 'Bailey', '1974-03-30', 'Male', 'B+', '+1-555-2007', 'Mary Hatch (Spouse)'),
(208, 'Hannah', 'Abbott', '1985-12-14', 'Female', 'O+', '+1-555-2008', 'Neville Longbottom (Partner)'),
(209, 'Ian', 'Malcolm', '1978-08-08', 'Male', 'A+', '+1-555-2009', 'Kelly Malcolm (Daughter)'),
(210, 'Julia', 'Roberts', '1963-10-28', 'Female', 'AB-', '+1-555-2010', 'Daniel Moder (Husband)');

-- Insert Rooms
INSERT INTO rooms (room_id, room_number, department_id, room_type, is_occupied, daily_rate) VALUES
(301, 'ICU-101', 1, 'ICU', TRUE, 1850.00),
(302, 'ICU-102', 1, 'ICU', FALSE, 1850.00),
(303, 'PRV-201', 2, 'PRIVATE', TRUE, 850.00),
(304, 'PRV-202', 2, 'PRIVATE', FALSE, 850.00),
(305, 'GEN-301', 3, 'GENERAL', TRUE, 420.00),
(306, 'GEN-302', 3, 'GENERAL', FALSE, 420.00),
(307, 'PRV-401', 4, 'PRIVATE', TRUE, 850.00),
(308, 'GEN-402', 4, 'GENERAL', FALSE, 420.00),
(309, 'ICU-501', 5, 'ICU', TRUE, 1850.00),
(310, 'TRM-001', 6, 'TRAUMA', TRUE, 1250.00);

-- Insert Admissions
INSERT INTO admissions (admission_id, patient_id, room_id, attending_doctor_id, admission_date, discharge_date, discharge_status) VALUES
(401, 201, 301, 101, '2026-10-24 08:30:00', '2026-10-29 14:00:00', 'Discharged'),
(402, 202, 303, 106, '2026-10-28 11:15:00', NULL, 'Active Inpatient'),
(403, 203, 307, 104, '2026-10-27 16:45:00', NULL, 'Active Inpatient'),
(404, 204, 304, 102, '2026-10-25 09:00:00', '2026-10-27 12:30:00', 'Discharged'),
(405, 205, 301, 107, '2026-10-29 22:10:00', NULL, 'Active Inpatient'),
(406, 206, 305, 103, '2026-10-30 07:45:00', NULL, 'Active Inpatient'),
(407, 207, 306, 101, '2026-10-26 14:20:00', '2026-10-30 11:00:00', 'Discharged'),
(408, 208, 309, 105, '2026-10-20 10:00:00', NULL, 'Active Inpatient'),
(409, 209, 307, 104, '2026-10-22 13:30:00', '2026-10-26 16:00:00', 'Discharged'),
(410, 210, 310, 102, '2026-10-31 03:15:00', NULL, 'Active Inpatient');

-- Insert Medical Records
INSERT INTO medical_records (record_id, admission_id, doctor_id, diagnosis, treatment_plan, prescribed_medication, record_date) VALUES
(501, 401, 101, 'Cardiac Arrhythmia & Atrial Fibrillation', 'Cardioversion protocol, telemetry monitoring', 'Amiodarone 200mg, Warfarin 5mg', '2026-10-24 10:00:00'),
(502, 402, 106, 'Acute Suppurative Appendicitis', 'Laparoscopic appendectomy, IV hydration', 'Ceftriaxone 1g, Metronidazole 500mg', '2026-10-28 13:00:00'),
(503, 403, 104, 'Compound Femur Fracture (Right Leg)', 'Open reduction internal fixation (ORIF), orthopedic traction', 'Cefazolin 1g, Morphine 5mg PRN', '2026-10-27 18:00:00'),
(504, 404, 102, 'Severe Intractable Migraine with Aura', 'Neurological screening, IV hydration, sumatriptan trial', 'Sumatriptan 50mg, Ondansetron 4mg', '2026-10-25 11:30:00'),
(505, 405, 107, 'Acute STEMI Myocardial Infarction', 'Emergency coronary angioplasty with drug-eluting stent', 'Ticagrelor 90mg, Atorvastatin 80mg', '2026-10-30 01:15:00'),
(506, 406, 103, 'Status Asthmaticus & Severe Bronchospasm', 'Continuous nebulization, systemic corticosteroids, O2 support', 'Albuterol sulfate, Methylprednisolone', '2026-10-30 09:30:00'),
(507, 407, 101, 'Essential Hypertensive Crisis', 'Intravenous anti-hypertensive titration, renal panel evaluation', 'Labetalol IV, Lisinopril 20mg', '2026-10-26 16:00:00'),
(508, 408, 105, 'Stage IIB Diffuse Large B-Cell Lymphoma', 'R-CHOP immunochemotherapy Cycle 1 infusion', 'Rituximab, Cyclophosphamide, Prednisone', '2026-10-20 12:00:00'),
(509, 409, 104, 'L4-L5 Lumbar Disc Herniation with Radiculopathy', 'Microdiscectomy, physical therapy consultation', 'Pregabalin 75mg, Meloxicam 15mg', '2026-10-22 15:00:00'),
(510, 410, 102, 'Transient Ischemic Attack (Left MCA)', 'Cerebral CT angiography, antiplatelet therapy initiation', 'Aspirin 325mg, Clopidogrel 75mg', '2026-10-31 05:00:00');

-- Insert Billing Invoices
INSERT INTO billing_invoices (invoice_id, admission_id, room_charges, procedure_charges, medication_charges, total_amount, payment_status, invoice_date) VALUES
(601, 401, 9250.00, 3400.00, 850.00, 13500.00, 'PAID', '2026-10-29 15:30:00'),
(602, 402, 2550.00, 4800.00, 620.00, 7970.00, 'PENDING', '2026-10-29 10:00:00'),
(603, 403, 4250.00, 8900.00, 1150.00, 14300.00, 'PENDING', '2026-10-30 14:00:00'),
(604, 404, 1700.00, 1200.00, 320.00, 3220.00, 'PAID', '2026-10-27 13:45:00'),
(605, 405, 5550.00, 14500.00, 1850.00, 21900.00, 'PENDING', '2026-10-31 09:00:00'),
(606, 406, 1260.00, 950.00, 440.00, 2650.00, 'PAID', '2026-10-31 16:30:00'),
(607, 407, 1680.00, 2100.00, 580.00, 4360.00, 'PAID', '2026-10-30 12:15:00'),
(608, 408, 18500.00, 12400.00, 6800.00, 37700.00, 'PENDING', '2026-10-28 17:00:00'),
(609, 409, 3400.00, 7200.00, 890.00, 11490.00, 'PAID', '2026-10-26 17:00:00'),
(610, 410, 3750.00, 5100.00, 920.00, 9770.00, 'OVERDUE', '2026-10-31 08:00:00');
