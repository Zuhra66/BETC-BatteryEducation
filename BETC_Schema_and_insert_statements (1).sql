drop database betc;
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

-- 8. Prospective Jobs
CREATE TABLE prospective_jobs (
    job_id INT AUTO_INCREMENT PRIMARY KEY,
    job_description TEXT
);

-- 9. Main BETC Table
CREATE TABLE betc (
    betc_id INT AUTO_INCREMENT PRIMARY KEY,
    institution_id INT,
    institution_type_id INT,
    program_id INT,
    battery_id INT,
    contact_id INT,
    cost_id INT,
    job_id INT,
    FOREIGN KEY (institution_id) REFERENCES institutions(institution_id),
    FOREIGN KEY (institution_type_id) REFERENCES institution_types(institution_type_id),
    FOREIGN KEY (program_id) REFERENCES programs(program_id),
    FOREIGN KEY (battery_id) REFERENCES program_battery_info(battery_id),
    FOREIGN KEY (contact_id) REFERENCES program_contacts(contact_id),
    FOREIGN KEY (cost_id) REFERENCES program_costs(cost_id),
    FOREIGN KEY (job_id) REFERENCES prospective_jobs(job_id)
);

-- table betc_csv wasnt exist, and causing errors for the following INSERT statements
-- Creating a wide staging table 
CREATE TABLE IF NOT EXISTS betc_csv (
  `INSTITUTION`                       TEXT,
  `WEBADDR`                           TEXT,
  `0`                                 TEXT,
  `CITY`                              TEXT,
  `STATE`                             TEXT,
  `ACCREDITED`                        TEXT,
  `ACCREDITATION`                     TEXT,
  `PUBLIC`                            TEXT,
  `PRIVATE`                           TEXT,
  `4-YEAR`                            TEXT,
  `2 YEAR (Assoc.)`                   TEXT,
  `GRAD`                              TEXT,
  `TECHNICAL`                         TEXT,
  `APPRENTICE`                        TEXT,
  `K-12`                              TEXT,
  `# TOTAL PROG`                      TEXT,
  `# STEM PROG`                       TEXT,
  `ACADEMIC`                          TEXT,
  `ONLINE/IN PERSON`                  TEXT,
  `START DATE`                        TEXT,
  `PROG LENGTH`                        TEXT,
  `# BATT SPECIFIC PROGRAMS`          TEXT,
  `# BATT RELATED`                    TEXT,
  `BATT SPECIFIC`                     TEXT,
  `SPECIFIC PROGRAM TYPE`             TEXT,
  `COURSE #`                          TEXT,
  `PROG NAME`                         TEXT,
  `PROG POC`                          TEXT,
  `PROG E-MAIL`                       TEXT,
  `PROG PHONE`                        TEXT,
  `PROG WEB`                          TEXT,
  `PROG PREREQ:`                      TEXT,
  `PROG COST`                         TEXT,
  `AVENUES FOR FUNDING`               TEXT,
  `PROG ADDRESS`                      TEXT,
  `PROSPECTIVE JOBS (Rough Estimate)` TEXT,
  `Unnamed: 36`                       TEXT,
  `Unnamed: 37`                       TEXT
) ;
-- Find allowed directory:
SHOW VARIABLES LIKE 'secure_file_priv';
-- Move your CSV into that directory (Finder/Terminal), then run:

LOAD DATA INFILE '/the/secure_file_priv/Users/zuhra/Downloads/betc_csv.csv'
INTO TABLE betc_csv
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','  ENCLOSED BY '"'
LINES  TERMINATED BY '\n'
IGNORE 1 LINES;

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

INSERT INTO prospective_jobs (job_description)
SELECT DISTINCT `PROSPECTIVE JOBS (Rough Estimate)`
FROM betc_csv;

INSERT INTO betc (
    institution_id, institution_type_id, program_id, battery_id, contact_id, cost_id, job_id
)
SELECT 
    i.institution_id,
    it.institution_type_id,
    p.program_id,
    pb.battery_id,
    pc.contact_id,
    c.cost_id,
    pj.job_id
FROM betc_csv bc
JOIN institutions i ON i.name = bc.INSTITUTION
JOIN institution_types it ON it.institution_id = i.institution_id
JOIN programs p ON p.institution_id = i.institution_id AND p.name = bc.`PROG NAME`
JOIN program_battery_info pb ON pb.program_id = p.program_id
JOIN program_contacts pc ON pc.program_id = p.program_id
JOIN program_costs c ON c.program_id = p.program_id
JOIN prospective_jobs pj ON pj.job_description = bc.`PROSPECTIVE JOBS (Rough Estimate)`;

-- 1) Create normalized jobs table
DROP TABLE IF EXISTS jobs;
CREATE TABLE jobs (
  job_id    INT NOT NULL AUTO_INCREMENT,
  job_title VARCHAR(255) NOT NULL,
  PRIMARY KEY (job_id),
  UNIQUE KEY uq_job_title (job_title)
) ;

-- 2) Normalize delimiters to commas, then split by comma using a 1..100 numbers inline table
INSERT IGNORE INTO jobs (job_title)
SELECT DISTINCT
  TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(j.clean_desc, ',', n.n), ',', -1)) AS job_title
FROM (
  SELECT
    REPLACE(
      REPLACE(
        REPLACE(
          REPLACE(
            REPLACE(TRIM(job_description), ';', ','),   -- ;
          '/', ','),                                     -- /
        '|', ','),                                       -- |
      ' and ', ','),                                     -- " and "
    '&', ',') AS clean_desc                              -- &
  FROM prospective_jobs
  WHERE job_description IS NOT NULL AND job_description <> ''
) AS j
JOIN (
  -- numbers 1..100; expand if needed
  SELECT a.n + b.n*10 + 1 AS n
  FROM (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
        UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a
  CROSS JOIN
       (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
        UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b
) AS n
  ON n.n <= 1 + LENGTH(j.clean_desc) - LENGTH(REPLACE(j.clean_desc, ',', ''))
WHERE TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(j.clean_desc, ',', n.n), ',', -1)) <> '';

-- Quick peek
SELECT COUNT(*) AS distinct_jobs FROM jobs;
SELECT * FROM jobs ORDER BY job_title LIMIT 25;