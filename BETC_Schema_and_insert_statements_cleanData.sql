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



/* 0) Normalize raw CSV staging (trim, empty -> NULL) */
UPDATE betc_csv
SET
  `INSTITUTION` = NULLIF(TRIM(`INSTITUTION`), ''),
  `WEBADDR` = NULLIF(TRIM(`WEBADDR`), ''),
  `CITY` = NULLIF(TRIM(`CITY`), ''),
  `STATE` = UPPER(NULLIF(TRIM(`STATE`), '')),
  `ACCREDITED` = NULLIF(TRIM(`ACCREDITED`), ''),
  `ACCREDITATION` = NULLIF(TRIM(`ACCREDITATION`), ''),
  `PUBLIC` = NULLIF(TRIM(`PUBLIC`), ''),
  `PRIVATE` = NULLIF(TRIM(`PRIVATE`), ''),
  `4-YEAR` = NULLIF(TRIM(`4-YEAR`), ''),
  `2 YEAR (Assoc.)` = NULLIF(TRIM(`2 YEAR (Assoc.)`), ''),
  `GRAD` = NULLIF(TRIM(`GRAD`), ''),
  `TECHNICAL` = NULLIF(TRIM(`TECHNICAL`), ''),
  `APPRENTICE` = NULLIF(TRIM(`APPRENTICE`), ''),
  `K-12` = NULLIF(TRIM(`K-12`), ''),
  `ACADEMIC` = NULLIF(TRIM(`ACADEMIC`), ''),
  `ONLINE/IN PERSON` = NULLIF(TRIM(`ONLINE/IN PERSON`), ''),
  `START DATE` = NULLIF(TRIM(`START DATE`), ''),
  `PROG LENGTH` = NULLIF(TRIM(`PROG LENGTH`), ''),
  `SPECIFIC PROGRAM TYPE` = NULLIF(TRIM(`SPECIFIC PROGRAM TYPE`), ''),
  `COURSE #` = NULLIF(TRIM(`COURSE #`), ''),
  `PROG NAME` = NULLIF(TRIM(`PROG NAME`), ''),
  `PROG POC` = NULLIF(TRIM(`PROG POC`), ''),
  `PROG E-MAIL` = LOWER(NULLIF(TRIM(`PROG E-MAIL`), '')),
  `PROG PHONE` = NULLIF(TRIM(`PROG PHONE`), ''),
  `PROG WEB` = NULLIF(TRIM(`PROG WEB`), ''),
  `PROG PREREQ:` = NULLIF(TRIM(`PROG PREREQ:`), ''),
  `PROG COST` = NULLIF(TRIM(`PROG COST`), ''),
  `AVENUES FOR FUNDING` = NULLIF(TRIM(`AVENUES FOR FUNDING`), ''),
  `PROG ADDRESS` = NULLIF(TRIM(`PROG ADDRESS`), ''),
  `PROSPECTIVE JOBS (Rough Estimate)` = NULLIF(TRIM(`PROSPECTIVE JOBS (Rough Estimate)`), '');

/* 1) Clean top-level reference tables */
UPDATE locations
SET city = NULLIF(TRIM(city), ''),
    state = UPPER(NULLIF(TRIM(state), ''));

/* 2) Standardize boolean flags (Yes/Y/True/1 -> 'Y', No/N/False/0 -> 'N') */
-- Institutions
UPDATE institutions
SET
  accredited_flag = CASE
    WHEN UPPER(accredited_flag) IN ('Y','YES','TRUE','T','1') THEN 'Y'
    WHEN UPPER(accredited_flag) IN ('N','NO','FALSE','F','0') THEN 'N'
    ELSE NULL END,
  public_flag = CASE
    WHEN UPPER(public_flag) IN ('Y','YES','TRUE','T','1') THEN 'Y'
    WHEN UPPER(public_flag) IN ('N','NO','FALSE','F','0') THEN 'N'
    ELSE NULL END,
  private_flag = CASE
    WHEN UPPER(private_flag) IN ('Y','YES','TRUE','T','1') THEN 'Y'
    WHEN UPPER(private_flag) IN ('N','NO','FALSE','F','0') THEN 'N'
    ELSE NULL END,
  k12_flag = CASE
    WHEN UPPER(k12_flag) IN ('Y','YES','TRUE','T','1','K-12','K12') THEN 'Y'
    WHEN UPPER(k12_flag) IN ('N','NO','FALSE','F','0') THEN 'N'
    ELSE NULL END;

-- Institution types
UPDATE institution_types
SET
  four_year_flag = CASE WHEN UPPER(four_year_flag) IN ('Y','YES','TRUE','T','1') THEN 'Y'
                        WHEN UPPER(four_year_flag) IN ('N','NO','FALSE','F','0') THEN 'N' ELSE NULL END,
  two_year_flag  = CASE WHEN UPPER(two_year_flag)  IN ('Y','YES','TRUE','T','1') THEN 'Y'
                        WHEN UPPER(two_year_flag)  IN ('N','NO','FALSE','F','0') THEN 'N' ELSE NULL END,
  grad_flag      = CASE WHEN UPPER(grad_flag)      IN ('Y','YES','TRUE','T','1') THEN 'Y'
                        WHEN UPPER(grad_flag)      IN ('N','NO','FALSE','F','0') THEN 'N' ELSE NULL END,
  technical_flag = CASE WHEN UPPER(technical_flag) IN ('Y','YES','TRUE','T','1') THEN 'Y'
                        WHEN UPPER(technical_flag) IN ('N','NO','FALSE','F','0') THEN 'N' ELSE NULL END,
  apprentice_flag= CASE WHEN UPPER(apprentice_flag)IN ('Y','YES','TRUE','T','1') THEN 'Y'
                        WHEN UPPER(apprentice_flag)IN ('N','NO','FALSE','F','0') THEN 'N' ELSE NULL END;

-- Programs
UPDATE programs
SET
  academic_flag = CASE
    WHEN UPPER(academic_flag) IN ('Y','YES','TRUE','T','1','ACADEMIC') THEN 'Y'
    WHEN UPPER(academic_flag) IN ('N','NO','FALSE','F','0') THEN 'N'
    ELSE NULL END,
  delivery_mode = CASE
    WHEN delivery_mode IS NULL THEN NULL
    WHEN UPPER(TRIM(delivery_mode)) IN ('ONLINE','ON-LINE','REMOTE','VIRTUAL') THEN 'Online'
    WHEN UPPER(TRIM(delivery_mode)) IN ('IN PERSON','IN-PERSON','ONSITE','ON-SITE','CAMPUS') THEN 'In Person'
    WHEN UPPER(TRIM(delivery_mode)) IN ('HYBRID','BLENDED') THEN 'Hybrid'
    ELSE delivery_mode END;

-- Battery info
UPDATE program_battery_info
SET is_batt_specific = CASE
  WHEN UPPER(is_batt_specific) IN ('Y','YES','TRUE','T','1') THEN 'Y'
  WHEN UPPER(is_batt_specific) IN ('N','NO','FALSE','F','0') THEN 'N'
  ELSE NULL END;

/* 3) Clean contact info and URLs */
-- Institutions webaddr normalize: ensure http(s) prefix
UPDATE institutions
SET webaddr = CASE
  WHEN webaddr IS NULL OR webaddr = '' THEN NULL
  WHEN LOWER(webaddr) REGEXP '^(http|https)://' THEN webaddr
  ELSE CONCAT('http://', webaddr)
END;

-- Program contact email lower-case already done via staging copy; re-apply & phone digits-only
UPDATE program_contacts
SET
  email = CASE WHEN email IS NULL OR email='' THEN NULL ELSE LOWER(email) END,
  phone = CASE
    WHEN phone IS NULL OR phone='' THEN NULL
    ELSE REGEXP_REPLACE(phone, '[^0-9]', '')
  END,
  website = CASE
    WHEN website IS NULL OR website = '' THEN NULL
    WHEN LOWER(website) REGEXP '^(http|https)://' THEN website
    ELSE CONCAT('http://', website)
  END;

/* Optional: drop obviously invalid emails (no '@') */
UPDATE program_contacts
SET email = NULL
WHERE email IS NOT NULL AND email NOT LIKE '%@%';

/* 4) Backfill institutional location_id in case of late cleaning */
UPDATE institutions i
JOIN locations l ON l.city = (SELECT city FROM betc_csv bc WHERE bc.INSTITUTION = i.name LIMIT 1)
                AND l.state = (SELECT state FROM betc_csv bc WHERE bc.INSTITUTION = i.name LIMIT 1)
SET i.location_id = COALESCE(i.location_id, l.location_id);


INSERT INTO tmp_cleaned_jobs (institution, prog_name, job_name)
WITH RECURSIVE raw_jobs AS (
  SELECT
    bc.`INSTITUTION`,
    bc.`PROG NAME` AS prog_name,
    TRIM(bc.`PROSPECTIVE JOBS (Rough Estimate)`) AS jobs_text
  FROM betc_csv bc
  WHERE bc.`PROSPECTIVE JOBS (Rough Estimate)` IS NOT NULL
    AND TRIM(bc.`PROSPECTIVE JOBS (Rough Estimate)`) <> ''
),
splitter AS (
  -- Normalize to commas
  SELECT `INSTITUTION`, prog_name,
         REPLACE(REPLACE(jobs_text, ';', ','), '|', ',') AS jobs_text
  FROM raw_jobs
),
tokens AS (
  -- Split on commas recursively
  SELECT `INSTITUTION`, prog_name,
         TRIM(SUBSTRING_INDEX(jobs_text, ',', 1)) AS job_token,
         CASE
           WHEN jobs_text LIKE '%,%' THEN TRIM(SUBSTRING(jobs_text FROM LOCATE(',', jobs_text) + 1))
           ELSE NULL
         END AS rest
  FROM splitter
  UNION ALL
  SELECT `INSTITUTION`, prog_name,
         TRIM(SUBSTRING_INDEX(rest, ',', 1)) AS job_token,
         CASE
           WHEN rest LIKE '%,%' THEN TRIM(SUBSTRING(rest FROM LOCATE(',', rest) + 1))
           ELSE NULL
         END
  FROM tokens
  WHERE rest IS NOT NULL
),
cleaned AS (
  SELECT
    `INSTITUTION`,
    prog_name,
    NULLIF(
      TRIM(
        REPLACE(REPLACE(REPLACE(job_token, CHAR(9), ' '), '  ', ' '), '  ', ' ')
      ),
      ''
    ) AS job_name
  FROM tokens
)
SELECT DISTINCT
  `INSTITUTION`      AS institution,
  prog_name,
  job_name
FROM cleaned
WHERE job_name IS NOT NULL AND job_name <> '';

-- 1) Insert unique job names
INSERT INTO jobs (job_name)
SELECT DISTINCT job_name
FROM tmp_cleaned_jobs
ON DUPLICATE KEY UPDATE job_name = VALUES(job_name);

-- 2) Link programs to jobs
INSERT IGNORE INTO course_jobs (program_id, job_id)
SELECT DISTINCT
  p.program_id,
  j.job_id
FROM tmp_cleaned_jobs cj
JOIN institutions i
  ON i.name = cj.institution
JOIN programs p
  ON p.institution_id = i.institution_id
 AND p.name = cj.prog_name
JOIN jobs j
  ON j.job_name = cj.job_name;
  

