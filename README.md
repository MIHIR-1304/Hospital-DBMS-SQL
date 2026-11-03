# 🏥 CareHealth DBMS — Hospital Relational Database & SQL Analytics Studio

[![SQL](https://img.shields.io/badge/SQL-3NF%20Normalized-4479A1?logo=mysql&logoColor=white)](https://www.mysql.com/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-4169E1?logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Frontend](https://img.shields.io/badge/Frontend-Tailwind%20%2B%20SQL%20Studio-0284C7?logo=tailwindcss&logoColor=white)](https://mihir-1304.github.io/Hospital-DBMS-SQL/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

> 🚀 **Live Interactive Demo**: [https://mihir-1304.github.io/Hospital-DBMS-SQL/](https://mihir-1304.github.io/Hospital-DBMS-SQL/)

**CareHealth DBMS** is a production-grade relational database architecture and clinical analytics web studio engineered for healthcare and hospital operational intelligence. Normalized strictly to **Third Normal Form (3NF)** across 7 relational entities, CareHealth DBMS eliminates data anomalies, enforces referential integrity through foreign key cascades, and optimizes query response times using multi-column B-tree composite indexes.

Designed with a clean, simple, professional healthcare UI/UX (avoiding exaggerated cyberpunk or dark gaming aesthetics), the platform includes an in-browser **Interactive SQL Studio**, a **Table Data Explorer**, a **Visual 3NF Entity-Relationship Diagram (ERD)**, and an **Executive KPI Dashboard**.

---

## 🌟 Key Engineering Highlights

- **Strict Third Normal Form (3NF) Normalization**:
  - **1NF**: Atomic scalar values across all columns; eliminates repeating multi-attribute groups.
  - **2NF**: Complete functional dependence on table primary keys; eliminates partial key dependencies.
  - **3NF**: Zero transitive dependencies (e.g. room rates, department metadata, and doctor credentials isolated in parent entities).
- **Interactive SQL Query Studio**:
  - Live query console with sub-millisecond execution times.
  - Pre-loaded enterprise queries with multi-table `JOIN`s, `GROUP BY`, `HAVING`, and aggregate window functions.
  - Tabular results grid with CSV data export.
- **Table Data Browser**:
  - Instant live search and inspection across all 7 database tables (`patients`, `doctors`, `departments`, `rooms`, `admissions`, `medical_records`, `billing_invoices`).
- **Visual Entity-Relationship (ER) Diagram**:
  - Clean mapping of Primary Keys (`PK`), Foreign Keys (`FK`), and 1-to-many (`1:N`) relationships.
- **B-Tree Indexing Strategy**:
  - `idx_patients_name` on `(last_name, first_name)` for rapid patient chart retrieval.
  - `idx_admissions_patient` on `(patient_id, admission_date)` for chronological inpatient history scans.
  - `idx_rooms_occupied` on `(room_type, is_occupied)` for real-time triage bed allocation.

---

## 🏗️ 3NF Relational Architecture (7 Tables)

```
[ departments ] (1) ───────────── (N) [ doctors ]
       │                                     │
       │ (1)                                 │ (1)
       ▼                                     ▼
   [ rooms ] (1) ──────── (N) [ admissions ] (Inpatient Junction)
                                     ▲
                                     │ (1)
                              [ patients ]
                                     │
                     ┌───────────────┴───────────────┐
                     ▼                               ▼
            [ medical_records ]             [ billing_invoices ]
```

---

## ⚡ Pre-Configured Enterprise SQL Analytics

### 1. Bed Occupancy & Potential Daily Revenue
```sql
SELECT 
    d.name AS department_name,
    COUNT(r.room_id) AS total_rooms,
    SUM(CASE WHEN r.is_occupied THEN 1 ELSE 0 END) AS occupied_rooms,
    ROUND((SUM(CASE WHEN r.is_occupied THEN 1.0 ELSE 0.0 END) / COUNT(r.room_id)) * 100, 1) AS occupancy_rate_pct,
    CONCAT('$', TO_CHAR(SUM(r.daily_rate), 'FM999,990.00')) AS potential_daily_revenue
FROM departments d
JOIN rooms r ON d.department_id = r.department_id
GROUP BY d.name
ORDER BY occupancy_rate_pct DESC, total_rooms DESC;
```

### 2. Active Inpatients & Attending Physicians (4-Table JOIN)
```sql
SELECT 
    a.admission_id,
    p.patient_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    p.blood_group,
    r.room_number,
    r.room_type,
    CONCAT('Dr. ', d.first_name, ' ', d.last_name) AS attending_doctor,
    d.specialization,
    a.admission_date,
    a.discharge_status
FROM admissions a
JOIN patients p ON a.patient_id = p.patient_id
JOIN rooms r ON a.room_id = r.room_id
JOIN doctors d ON a.attending_doctor_id = d.doctor_id
WHERE a.discharge_date IS NULL
ORDER BY a.admission_date ASC;
```

### 3. Doctor Workload & Inpatient Case Distribution
```sql
SELECT 
    d.doctor_id,
    CONCAT('Dr. ', d.first_name, ' ', d.last_name) AS doctor_name,
    dept.name AS department,
    COUNT(a.admission_id) AS total_admissions,
    SUM(CASE WHEN a.discharge_date IS NULL THEN 1 ELSE 0 END) AS active_inpatient_cases
FROM doctors d
JOIN departments dept ON d.department_id = dept.department_id
LEFT JOIN admissions a ON d.doctor_id = a.attending_doctor_id
GROUP BY d.doctor_id, d.first_name, d.last_name, dept.name
ORDER BY active_inpatient_cases DESC, total_admissions DESC;
```

### 4. Billing Invoices & Financial Collections (Aggregate Summary)
```sql
SELECT 
    b.payment_status,
    COUNT(b.invoice_id) AS invoice_count,
    CONCAT('$', TO_CHAR(SUM(b.total_amount), 'FM999,990.00')) AS total_billed_amount,
    CONCAT('$', TO_CHAR(ROUND(AVG(b.total_amount), 2), 'FM999,990.00')) AS avg_invoice_amount,
    ROUND((SUM(b.total_amount) / 126890.00) * 100, 1) AS percent_of_hospital_revenue
FROM billing_invoices b
GROUP BY b.payment_status
ORDER BY SUM(b.total_amount) DESC;
```

---

## 🚀 Running the Database Locally

```bash
# Clone the repository
git clone https://github.com/MIHIR-1304/Hospital-DBMS-SQL.git
cd Hospital-DBMS-SQL

# Execute schema and seed data in PostgreSQL
psql -U postgres -d hospital_db -f schema.sql
```

Access the web studio:
- **Live Demo**: `https://mihir-1304.github.io/Hospital-DBMS-SQL/`

---

## 🛠️ Technology Stack

- **Relational DBMS**: PostgreSQL 16 / MySQL 8.0
- **Normalization**: Boyce-Codd / 3NF Normalization Standards
- **Web Studio**: Modern Tailwind CSS, Responsive Reactive Engine, SVG ERD
- **Storage & Performance**: B-Tree Composite Indexing, Foreign Key Cascade Constraints

---

## 👨‍💻 Author

**Mihir Mahato**  
Software Developer | B.Tech CSE 2026  
GitHub: [@MIHIR-1304](https://github.com/MIHIR-1304)  
LinkedIn: [Mihir Mahato](https://www.linkedin.com/in/mihir-mahato-btech)  
Email: mihirmahato1304@gmail.com
