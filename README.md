<h1 align="center">Battery Education and Training Programs Across U.S. Institutions</h1>

## Interns:

Zuhra Totakhail

Edward Torres

Nima Mahanloo

Advisor/ Mentor: Arijit Das

Start date:8/21/2025

End date: 9/30/2025

## Introduction:
This dataset provides a comprehensive overview of battery-focused and related educational programs offered by institutions across the United States. With 438 entries and 35 attributes, it captures essential details about universities, colleges, technical schools, and training providers that deliver programs in areas such as battery technology, energy systems, and advanced manufacturing. The data includes institutional characteristics (e.g., accreditation, public/private status, degree level), program details (e.g., name, length, delivery mode, prerequisites, costs, and funding avenues), and industry relevance (e.g., battery-specific offerings, STEM alignment, and prospective job opportunities).

By highlighting both academic and professional training opportunities, this dataset serves as a valuable resource for researchers, policymakers, educators, and workforce development planners seeking to understand the educational landscape driving the clean energy and electric vehicle revolution.

## ERD- Diagram:
<img width="1000" height="1022" alt="betc_ER_diagram" src="https://github.com/user-attachments/assets/d6c3b974-369c-42f5-9311-b134091b5a79" />



<img width="997" height="1208" alt="betc_ER_diagram (1)" src="https://github.com/user-attachments/assets/60a41039-fc3f-43ac-adbd-e4f6911b378b" />




## SQL Schema

CREATE DATABASE IF NOT EXISTS betc;

USE betc;

-- 1. Locations (City, State)
CREATE TABLE locations (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    city VARCHAR(100),
    state VARCHAR(100),
    UNIQUE(city, state)
);

-- 2. Institutions
CREATE TABLE institutions (
    institution_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) UNIQUE,
    webaddr VARCHAR(255),
    location_id INT,
    accredited_flag VARCHAR(10),
    accreditation VARCHAR(255),
    public_flag VARCHAR(10),
    private_flag VARCHAR(10),
    k12_flag VARCHAR(100),
    FOREIGN KEY (location_id) REFERENCES locations(location_id)
);

-- 3. Institution Types
CREATE TABLE institution_types (
    institution_type_id INT AUTO_INCREMENT PRIMARY KEY,
    institution_id INT,
    four_year_flag VARCHAR(10),
    two_year_flag VARCHAR(10),
    grad_flag VARCHAR(10),
    technical_flag VARCHAR(10),
    apprentice_flag VARCHAR(10),
    FOREIGN KEY (institution_id) REFERENCES institutions(institution_id)
);

-- 4. Programs
CREATE TABLE programs (
    program_id INT AUTO_INCREMENT PRIMARY KEY,
    institution_id INT,
    name VARCHAR(255),
    program_type VARCHAR(255),
    academic_flag VARCHAR(10),
    delivery_mode VARCHAR(255),
    start_date VARCHAR(255),
    program_length VARCHAR(255),
    num_total_programs INT,
    num_stem_programs INT,
    address VARCHAR(255),
    web_address TEXT,
    FOREIGN KEY (institution_id) REFERENCES institutions(institution_id)
);

-- 5. Program Battery Info
CREATE TABLE program_battery_info (
    battery_id INT AUTO_INCREMENT PRIMARY KEY,
    program_id INT,
    num_batt_specific INT,
    num_batt_related INT,
    is_batt_specific VARCHAR(10),
    FOREIGN KEY (program_id) REFERENCES programs(program_id)
);

-- 6. Program Contacts
CREATE TABLE program_contacts (
    contact_id INT AUTO_INCREMENT PRIMARY KEY,
    program_id INT,
    contact_name VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(255),
    website TEXT,
    FOREIGN KEY (program_id) REFERENCES programs(program_id)
);

-- 7. Program Costs & Funding
CREATE TABLE program_costs (
    cost_id INT AUTO_INCREMENT PRIMARY KEY,
    program_id INT,
    prereqs VARCHAR(255),
    cost VARCHAR(255),
    funding VARCHAR(255),
    FOREIGN KEY (program_id) REFERENCES programs(program_id)
);

-- 8. Jobs (formerly prospective_jobs)
CREATE TABLE jobs (
    job_id INT PRIMARY KEY,
    job_name VARCHAR(255) UNIQUE
);

-- 9. Junction table linking programs to jobs
CREATE TABLE course_jobs (
    program_id INT,
    job_id INT,
    PRIMARY KEY (program_id, job_id),
    FOREIGN KEY (program_id) REFERENCES programs(program_id),
    FOREIGN KEY (job_id) REFERENCES jobs(job_id)
);

-- 10. Main BETC Table (remove job_id)
CREATE TABLE betc (
    betc_id INT AUTO_INCREMENT PRIMARY KEY,
    institution_id INT,
    institution_type_id INT,
    program_id INT,
    battery_id INT,
    contact_id INT,
    cost_id INT,
    FOREIGN KEY (institution_id) REFERENCES institutions(institution_id),
    FOREIGN KEY (institution_type_id) REFERENCES institution_types(institution_type_id),
    FOREIGN KEY (program_id) REFERENCES programs(program_id),
    FOREIGN KEY (battery_id) REFERENCES program_battery_info(battery_id),
    FOREIGN KEY (contact_id) REFERENCES program_contacts(contact_id),
    FOREIGN KEY (cost_id) REFERENCES program_costs(cost_id)
);

CREATE TABLE betc_csv (
    `INSTITUTION` VARCHAR(255),
    `WEBADDR` VARCHAR(255),
    `0` INT,
    `CITY` VARCHAR(100),
    `STATE` VARCHAR(100),
    `ACCREDITED` VARCHAR(10),
    `ACCREDITATION` VARCHAR(255),
    `PUBLIC` VARCHAR(10),
    `PRIVATE` VARCHAR(10),
    `4-YEAR` VARCHAR(10),
    `2 YEAR (Assoc.)` VARCHAR(10),
    `GRAD` VARCHAR(10),
    `TECHNICAL` VARCHAR(10),
    `APPRENTICE` VARCHAR(10),
    `K-12` VARCHAR(100),
    `# TOTAL PROG` INT,
    `# STEM PROG` INT,
    `ACADEMIC` VARCHAR(10),
    `ONLINE/IN PERSON` VARCHAR(255),
    `START DATE` VARCHAR(255),
    `PROG LENGTH` VARCHAR(255),
    `# BATT SPECIFIC PROGRAMS` INT,
    `# BATT RELATED` INT,
    `BATT SPECIFIC` VARCHAR(10),
    `SPECIFIC PROGRAM TYPE` VARCHAR(255),
    `COURSE #` VARCHAR(255),
    `PROG NAME` VARCHAR(255),
    `PROG POC` VARCHAR(255),
    `PROG E-MAIL` VARCHAR(255),
    `PROG PHONE` VARCHAR(255),
    `PROG WEB` TEXT,
    `PROG PREREQ:` VARCHAR(255),
    `PROG COST` VARCHAR(255),
    `AVENUES FOR FUNDING` VARCHAR(255),
    `PROG ADDRESS` VARCHAR(255),
    `PROSPECTIVE JOBS (Rough Estimate)` TEXT,
    `MyUnknownColumn` TEXT,
    `MyUnknownColumn_[0]` TEXT
);


INSERT INTO locations (city, state)
SELECT DISTINCT CITY, STATE
FROM betc_csv;

INSERT INTO institutions (name, webaddr, location_id, accredited_flag, accreditation, public_flag, private_flag, k12_flag)
SELECT 
    bc.INSTITUTION,
    MIN(bc.WEBADDR),
    MIN(l.location_id), 
    MIN(bc.ACCREDITED),
    MIN(bc.ACCREDITATION),
    MIN(bc.PUBLIC),
    MIN(bc.PRIVATE),
    MIN(bc.`K-12`)
FROM betc_csv bc
JOIN locations l ON l.city = bc.CITY AND l.state = bc.STATE
GROUP BY bc.INSTITUTION;

INSERT INTO institution_types (
    institution_id, four_year_flag, two_year_flag, grad_flag, technical_flag, apprentice_flag
)
SELECT DISTINCT 
    i.institution_id,
    bc.`4-YEAR`,
    bc.`2 YEAR (Assoc.)`,
    bc.GRAD,
    bc.TECHNICAL,
    bc.APPRENTICE
FROM betc_csv bc
JOIN institutions i ON i.name = bc.INSTITUTION;

INSERT INTO programs (
    institution_id, name, program_type, academic_flag, delivery_mode, start_date,
    program_length, num_total_programs, num_stem_programs, address, web_address
)
SELECT DISTINCT 
    i.institution_id,
    bc.`PROG NAME`,
    bc.`SPECIFIC PROGRAM TYPE`,
    bc.ACADEMIC,
    bc.`ONLINE/IN PERSON`,
    bc.`START DATE`,
    bc.`PROG LENGTH`,
    bc.`# TOTAL PROG`,
    bc.`# STEM PROG`,
    bc.`PROG ADDRESS`,
    bc.`PROG WEB`
FROM betc_csv bc
JOIN institutions i ON i.name = bc.INSTITUTION;

INSERT INTO program_battery_info (
    program_id, num_batt_specific, num_batt_related, is_batt_specific
)
SELECT 
    p.program_id,
    bc.`# BATT SPECIFIC PROGRAMS`,
    bc.`# BATT RELATED`,
    bc.`BATT SPECIFIC`
FROM betc_csv bc
JOIN institutions i ON i.name = bc.INSTITUTION
JOIN programs p 
  ON p.institution_id = i.institution_id AND p.name = bc.`PROG NAME`;

INSERT INTO program_contacts (
    program_id, contact_name, email, phone, website
)
SELECT 
    p.program_id,
    bc.`PROG POC`,
    bc.`PROG E-MAIL`,
    bc.`PROG PHONE`,
    bc.`PROG WEB`
FROM betc_csv bc
JOIN institutions i ON i.name = bc.INSTITUTION
JOIN programs p 
  ON p.institution_id = i.institution_id AND p.name = bc.`PROG NAME`;

INSERT INTO program_costs (
    program_id, prereqs, cost, funding
)
SELECT 
    p.program_id,
    bc.`PROG PREREQ:`,
    bc.`PROG COST`,
    bc.`AVENUES FOR FUNDING`
FROM betc_csv bc
JOIN institutions i ON i.name = bc.INSTITUTION
JOIN programs p 
  ON p.institution_id = i.institution_id AND p.name = bc.`PROG NAME`;

INSERT INTO betc (
    institution_id, institution_type_id, program_id, battery_id, contact_id, cost_id
)
SELECT 
    i.institution_id,
    it.institution_type_id,
    p.program_id,
    pb.battery_id,
    pc.contact_id,
    c.cost_id
FROM betc_csv bc
JOIN institutions i ON i.name = bc.INSTITUTION
JOIN institution_types it ON it.institution_id = i.institution_id
JOIN programs p ON p.institution_id = i.institution_id AND p.name = bc.`PROG NAME`
JOIN program_battery_info pb ON pb.program_id = p.program_id
JOIN program_contacts pc ON pc.program_id = p.program_id
JOIN program_costs c ON c.program_id = p.program_id;

