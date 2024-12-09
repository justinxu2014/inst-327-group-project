SET GLOBAL local_infile=1;

DROP DATABASE IF EXISTS chicago;
CREATE DATABASE chicago;

USE chicago;

DROP TABLE IF EXISTS citations;

CREATE TABLE citations (
	notice_number BIGINT,
	ticket_number BIGINT, 
	issue_date DATETIME, 
	location VARCHAR(50),
	zip_code INT,
	violation_code VARCHAR(10),
	violation_description VARCHAR(100),
	unit VARCHAR(5),
	unit_description VARCHAR(20),
	officer VARCHAR(6), 
	vehicle_make VARCHAR(10),
	license_plate_type VARCHAR(10), 
	fine_1 DECIMAL(7,2),
	fine_2 DECIMAL(7,2),
	current_due DECIMAL(7,2),
	total_payments DECIMAL(7,2),
	ticket_queue VARCHAR(20), 
	ticket_queue_date DATE,
	notice_level VARCHAR(10),
	hearing_dispo VARCHAR(10),
	hearing_reason VARCHAR(100)
);

-- Replace placeholder file path with your local file path.
LOAD DATA LOCAL INFILE "Full File Path/Chicago Traffic Citations.csv"
INTO TABLE citations
FIELDS TERMINATED BY ","
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
	@notice_number, 
	@ticket_number, 
	@issue_date, 
	@location, 
	@zip_code, 
	@violation_code, 
	@violation_description, 
	@unit, 
	@unit_description, 
	@officer, 
	@vehicle_make,
	@license_plate_type, 
	fine_1, 
	fine_2, 
	current_due, 
	total_payments, 
	@ticket_queue, 
	@ticket_queue_date, 
	@notice_level, 
	@hearing_dispo, 
	@hearing_reason
)
SET 
	notice_number = NULLIF(NULLIF(@notice_number, ""), "0"),
	ticket_number = NULLIF(NULLIF(@ticket_number, ""), "0"),
	issue_date = STR_TO_DATE(@issue_date, "%c/%e/%y %H:%i"),
	location = NULLIF(@location, ""), 
	zip_code = NULLIF(@zip_code, ""), 
	violation_code = NULLIF(@violation_code, ""),
	violation_description = NULLIF(@violation_description, ""), 
	unit = NULLIF(@unit, ""), 
	unit_description = NULLIF(@unit_description, ""),
	officer = NULLIF(@officer, ""),
	vehicle_make = NULLIF(@vehicle_make, ""),
	license_plate_type = NULLIF(@license_plate_type, ""), 
	ticket_queue = NULLIF(@ticket_queue, ""), 
	ticket_queue_date = STR_TO_DATE(@ticket_queue_date, "%c/%e/%Y"),
	notice_level = NULLIF(@notice_level, ""), 
	hearing_dispo = NULLIF(@hearing_dispo, ""), 
	hearing_reason = NULLIF(NULLIF(@hearing_reason, ""), "\r");

-- Inspect table.
SELECT * FROM citations;
