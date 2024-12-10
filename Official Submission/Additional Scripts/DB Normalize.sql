SET SQL_SAFE_UPDATES = 0;

DROP DATABASE IF EXISTS chicago_official;
CREATE DATABASE chicago_official;

USE chicago_official;

CREATE TABLE notices (
	notice_id INT NOT NULL AUTO_INCREMENT,
	notice_number BIGINT NOT NULL,
	PRIMARY KEY (notice_id)
);

CREATE TABLE violations (
	violation_id INT NOT NULL AUTO_INCREMENT,
	violation_code VARCHAR(10),
	description VARCHAR(100),
	PRIMARY KEY (violation_id)
);

CREATE TABLE units (
	unit_id INT NOT NULL AUTO_INCREMENT,
	unit_code VARCHAR(5),
	description VARCHAR(20),
	PRIMARY KEY (unit_id)
);

CREATE TABLE officers (
	officer_id INT NOT NULL AUTO_INCREMENT,
	officer VARCHAR(6),
	unit_id INT,
	PRIMARY KEY (officer_id),
	FOREIGN KEY (unit_id) REFERENCES units(unit_id)
);

CREATE TABLE vehicle_makes (
	vehicle_make_id INT NOT NULL AUTO_INCREMENT,
	vehicle_make VARCHAR(10),
	PRIMARY KEY (vehicle_make_id)
);

CREATE TABLE license_plate_types (
	license_plate_type_id INT NOT NULL AUTO_INCREMENT,
	license_plate_type VARCHAR(10),
	PRIMARY KEY (license_plate_type_id)
);

CREATE TABLE vehicle_makes_plate_types (
	vehicle_make_plate_type_id INT NOT NULL AUTO_INCREMENT,
	vehicle_make_id INT NOT NULL,
	license_plate_type_id INT NOT NULL,
	PRIMARY KEY (vehicle_make_plate_type_id),
	FOREIGN KEY (vehicle_make_id) REFERENCES vehicle_makes(vehicle_make_id),
	FOREIGN KEY (license_plate_type_id) REFERENCES license_plate_types(license_plate_type_id)
);

CREATE TABLE locations (
	location_id INT NOT NULL AUTO_INCREMENT,
	address VARCHAR(50),
	zip_code INT,
	PRIMARY KEY (location_id)
);

CREATE TABLE hearing_reasons (
	hearing_reason_id INT NOT NULL AUTO_INCREMENT,
	hearing_reason VARCHAR(100),
	PRIMARY KEY (hearing_reason_id)
);

CREATE TABLE tickets (
	ticket_id BIGINT NOT NULL,
	notice_id INT,
	issue_date DATETIME,
	location_id INT,
	violation_id INT,
	officer_id INT, 
	vehicle_make_plate_type_id INT,
	fine_1 DECIMAL(7,2),
	fine_2 DECIMAL(7,2),
	current_due DECIMAL(7,2),
	total_payments DECIMAL(7,2),
	ticket_queue VARCHAR(20),
	ticket_queue_date DATE,
	hearing_dispo VARCHAR(10),
	hearing_reason_id INT,
	notice_level VARCHAR(10),
	PRIMARY KEY (ticket_id),
	FOREIGN KEY (notice_id) REFERENCES notices(notice_id),
	FOREIGN KEY (location_id) REFERENCES locations(location_id),
	FOREIGN KEY (violation_id) REFERENCES violations(violation_id),
	FOREIGN KEY (officer_id) REFERENCES officers(officer_id),
	FOREIGN KEY (vehicle_make_plate_type_id) REFERENCES vehicle_makes_plate_types(vehicle_make_plate_type_id),
	FOREIGN KEY (hearing_reason_id) REFERENCES hearing_reasons(hearing_reason_id)
);

INSERT INTO notices (notice_number)
SELECT DISTINCT 
	notice_number
FROM chicago.citations
WHERE notice_number IS NOT NULL;

INSERT INTO violations (violation_code, description)
SELECT DISTINCT
	violation_code,
	violation_description
FROM chicago.citations
WHERE violation_code IS NOT NULL;

INSERT INTO officers (officer)
SELECT DISTINCT 
	officer
FROM chicago.citations
WHERE officer IS NOT NULL;

INSERT INTO vehicle_makes (vehicle_make)
SELECT DISTINCT 
	vehicle_make 
FROM chicago.citations
WHERE vehicle_make IS NOT NULL;

INSERT INTO license_plate_types (license_plate_type)
SELECT DISTINCT
	license_plate_type
FROM chicago.citations
WHERE license_plate_type IS NOT NULL;

INSERT INTO vehicle_makes_plate_types (vehicle_make_id, license_plate_type_id)
SELECT DISTINCT
	vehicle_makes.vehicle_make_id,
	license_plate_types.license_plate_type_id
FROM chicago.citations
	LEFT OUTER JOIN vehicle_makes
		ON chicago.citations.vehicle_make = vehicle_makes.vehicle_make
	LEFT OUTER JOIN license_plate_types
		ON chicago.citations.license_plate_type = license_plate_types.license_plate_type
WHERE vehicle_makes.vehicle_make IS NOT NULL AND license_plate_types.license_plate_type IS NOT NULL;

INSERT INTO units (unit_code, description)
SELECT DISTINCT
	unit, 
	unit_description
FROM chicago.citations
WHERE unit IS NOT NULL;

INSERT INTO locations (address, zip_code)
SELECT DISTINCT 
	location, zip_code
FROM chicago.citations
WHERE location IS NOT NULL;

INSERT INTO hearing_reasons (hearing_reason)
SELECT DISTINCT
	hearing_reason
FROM chicago.citations
WHERE hearing_reason IS NOT NULL;

INSERT INTO tickets (
	ticket_id, 
	issue_date,
	fine_1,
	fine_2,
	current_due,
	total_payments,
	ticket_queue,
	ticket_queue_date,
	hearing_dispo,
	notice_level
) 
SELECT 
	ticket_number, 
	issue_date,
	fine_1,
	fine_2,
	current_due,
	total_payments,
	ticket_queue,
	ticket_queue_date,
	hearing_dispo,
	notice_level
FROM chicago.citations
WHERE chicago.citations.ticket_number IS NOT NULL
	OR chicago.citations.issue_date IS NOT NULL
	OR chicago.citations.fine_1 IS NOT NULL
	OR chicago.citations.fine_2 IS NOT NULL
	OR chicago.citations.current_due IS NOT NULL
	OR chicago.citations.total_payments IS NOT NULL
	OR chicago.citations.ticket_queue IS NOT NULL
	OR chicago.citations.ticket_queue_date IS NOT NULL
	OR chicago.citations.hearing_dispo IS NOT NULL
	OR chicago.citations.notice_level IS NOT NULL;

WITH notices_link AS (
	SELECT DISTINCT
		chicago.citations.ticket_number, 
		notices.notice_id
	FROM chicago.citations 
		RIGHT JOIN notices
			ON chicago.citations.notice_number = notices.notice_number
)
UPDATE tickets JOIN notices_link
SET tickets.notice_id = notices_link.notice_id
WHERE tickets.ticket_id = notices_link.ticket_number;

WITH locations_link AS (
	SELECT DISTINCT
		chicago.citations.ticket_number, 
		locations.location_id
	FROM chicago.citations 
		RIGHT JOIN locations
    	ON chicago.citations.location = locations.address
)
UPDATE tickets JOIN locations_link
SET tickets.location_id = locations_link.location_id
WHERE tickets.ticket_id = locations_link.ticket_number;

WITH violations_link AS (
	SELECT DISTINCT
		chicago.citations.ticket_number, 
		violations.violation_id
	FROM chicago.citations 
		RIGHT JOIN violations
    	ON chicago.citations.violation_code = violations.violation_code
) 
UPDATE tickets JOIN violations_link
SET tickets.violation_id = violations_link.violation_id
WHERE tickets.ticket_id = violations_link.ticket_number;

WITH units_link AS (
	SELECT DISTINCT
		chicago.citations.ticket_number,
        chicago.citations.officer,
		units.unit_id
	FROM chicago.citations 
		RIGHT JOIN units
			ON chicago.citations.unit = units.unit_code
)
UPDATE officers JOIN units_link
SET officers.unit_id = units_link.unit_id
WHERE officers.officer = units_link.officer;

WITH officers_link AS (
	SELECT DISTINCT
		chicago.citations.ticket_number, 
		officers.officer_id
	FROM chicago.citations 
		RIGHT JOIN officers
			ON chicago.citations.officer = officers.officer
)
UPDATE tickets JOIN officers_link
SET tickets.officer_id = officers_link.officer_id
WHERE tickets.ticket_id = officers_link.ticket_number;

WITH vehicle_makes_plate_types_join AS (
	SELECT 
		vehicle_makes_plate_types.vehicle_make_plate_type_id, 
        vehicle_makes.vehicle_make,
        license_plate_types.license_plate_type
	FROM vehicle_makes_plate_types
		LEFT OUTER JOIN vehicle_makes
			ON vehicle_makes_plate_types.vehicle_make_id = vehicle_makes.vehicle_make_id
		LEFT OUTER JOIN license_plate_types
			ON vehicle_makes_plate_types.license_plate_type_id = license_plate_types.license_plate_type_id
),
vehicle_makes_plate_types_link AS (
	SELECT DISTINCT
		chicago.citations.ticket_number, 
		chicago.citations.vehicle_make, 
		chicago.citations.license_plate_type,
        vehicle_makes_plate_types_join.vehicle_make_plate_type_id
	FROM chicago.citations 
		RIGHT JOIN vehicle_makes_plate_types_join
			ON chicago.citations.vehicle_make = vehicle_makes_plate_types_join.vehicle_make AND chicago.citations.license_plate_type = vehicle_makes_plate_types_join.license_plate_type
)
UPDATE tickets JOIN vehicle_makes_plate_types_link
SET tickets.vehicle_make_plate_type_id = vehicle_makes_plate_types_link.vehicle_make_plate_type_id
WHERE tickets.ticket_id = vehicle_makes_plate_types_link.ticket_number;

WITH hearing_reasons_link AS (
	SELECT DISTINCT
		chicago.citations.ticket_number, 
		hearing_reasons.hearing_reason_id
	FROM chicago.citations 
		RIGHT JOIN hearing_reasons
			ON chicago.citations.hearing_reason = hearing_reasons.hearing_reason
)
UPDATE tickets JOIN hearing_reasons_link
SET tickets.hearing_reason_id = hearing_reasons_link.hearing_reason_id
WHERE tickets.ticket_id = hearing_reasons_link.ticket_number;

-- Create views 
-- Create combined table view
CREATE VIEW chicago_norm_all AS 
SELECT 
	notices.notice_number AS notice_number,
	tickets.ticket_id AS ticket_number,
	tickets.issue_date,
	locations.address AS location,
	locations.zip_code,
	violations.violation_code,
	violations.description AS violation_description,
	units.unit_code AS unit,
	units.description AS unit_description,
	officers.officer_id AS officer,
	vehicle_makes.vehicle_make,
	license_plate_types.license_plate_type,
	tickets.fine_1,
	tickets.fine_2,
	tickets.current_due,
	tickets.total_payments,
	tickets.ticket_queue,
	tickets.ticket_queue_date,
	tickets.notice_level,
	tickets.hearing_dispo,
	hearing_reasons.hearing_reason
FROM tickets
	LEFT OUTER JOIN notices
		ON tickets.notice_id = notices.notice_id
	LEFT OUTER JOIN locations
		ON tickets.location_id = locations.location_id
	LEFT OUTER JOIN violations
		ON tickets.violation_id = violations.violation_id
	LEFT OUTER JOIN officers
		ON tickets.officer_id = officers.officer_id
	LEFT OUTER JOIN units
		ON officers.unit_id = units.unit_id
	LEFT OUTER JOIN vehicle_makes_plate_types
		ON tickets.vehicle_make_plate_type_id = vehicle_makes_plate_types.vehicle_make_plate_type_id
	LEFT OUTER JOIN vehicle_makes
		ON vehicle_makes_plate_types.vehicle_make_id = vehicle_makes.vehicle_make_id
	LEFT OUTER JOIN license_plate_types
		ON vehicle_makes_plate_types.license_plate_type_id = license_plate_types.license_plate_type_id
	LEFT OUTER JOIN hearing_reasons
		ON tickets.hearing_reason_id = hearing_reasons.hearing_reason_id
ORDER BY notices.notice_number DESC, tickets.ticket_id DESC;
    
-- Create officer-units view
CREATE VIEW officers_units_all AS 
SELECT 
	officers.officer, 
  units.unit_code
FROM officers 
	LEFT OUTER JOIN units
		ON officers.unit_id = units.unit_id
ORDER BY officers.officer ASC;

-- Create vehicle_makes_plate_types combined view
CREATE VIEW vehicle_makes_plate_types_all AS 
SELECT 
	vehicle_makes_plate_types.vehicle_make_plate_type_id, 
	vehicle_makes.vehicle_make,
	license_plate_types.license_plate_type
FROM vehicle_makes_plate_types
	LEFT OUTER JOIN vehicle_makes
		ON vehicle_makes_plate_types.vehicle_make_id = vehicle_makes.vehicle_make_id
	LEFT OUTER JOIN license_plate_types
		ON vehicle_makes_plate_types.license_plate_type_id = license_plate_types.license_plate_type_id
ORDER BY vehicle_makes_plate_types.vehicle_make_plate_type_id ASC;

-- Create tickets per notice view
CREATE VIEW tickets_per_notice AS 
SELECT 
	notices.notice_number, 
  COUNT(tickets.ticket_id)
FROM tickets
	JOIN notices
WHERE tickets.notice_id = notices.notice_id
GROUP BY notices.notice_id
ORDER BY notices.notice_number ASC;

-- Create officers per unit view
CREATE VIEW officers_per_unit AS 
SELECT 
	units.unit_code,
  COUNT(officers.officer_id)
FROM officers 
	JOIN units
WHERE officers.unit_id = units.unit_id
GROUP BY units.unit_id
ORDER BY units.unit_code ASC;

-- tickets from a unit with a police count less than 5
CREATE VIEW tickets_from_small_units AS 
SELECT 
	tickets.ticket_id 
FROM tickets 
	LEFT OUTER JOIN officers
		ON tickets.officer_id = officers.officer_id
WHERE officers.unit_id IN (
    SELECT 
		units.unit_id
	FROM officers 
		JOIN units
	WHERE officers.unit_id = units.unit_id
	GROUP BY units.unit_id
    HAVING COUNT(officers.officer_id) < 5
    );
