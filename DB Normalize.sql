SET SQL_SAFE_UPDATES = 0;

DROP DATABASE IF EXISTS chicago_norm;
CREATE DATABASE chicago_norm;

USE chicago_norm;

CREATE TABLE notices (
	id INT NOT NULL AUTO_INCREMENT,
	notice_number BIGINT NOT NULL,
	PRIMARY KEY (id)
);

CREATE TABLE violations (
	id INT NOT NULL AUTO_INCREMENT,
	violation_code VARCHAR(50),
	description VARCHAR(100),
	PRIMARY KEY (id)
);

CREATE TABLE officers (
	id INT NOT NULL AUTO_INCREMENT,
	officer_id VARCHAR(50),
	PRIMARY KEY (id)
);

CREATE TABLE units (
	id INT NOT NULL AUTO_INCREMENT,
	unit_code VARCHAR(50),
	description VARCHAR(100),
	PRIMARY KEY (id)
);

CREATE TABLE vehicle_makes (
	id INT NOT NULL AUTO_INCREMENT,
	vehicle_make VARCHAR(10),
	PRIMARY KEY (id)
);

CREATE TABLE locations (
	id INT NOT NULL AUTO_INCREMENT,
	address VARCHAR(50),
	PRIMARY KEY (id)
);

CREATE TABLE zip_codes (
	id INT NOT NULL AUTO_INCREMENT,
	zip_code INT,
	PRIMARY KEY (id)
);

CREATE TABLE license_plate_types (
	id INT NOT NULL AUTO_INCREMENT,
	license_plate_type VARCHAR(10),
	PRIMARY KEY (id)
);

CREATE TABLE fines (
	ticket_id BIGINT,
	fine_1 INT,
    fine_2 INT,
	PRIMARY KEY (ticket_id)
);

CREATE TABLE dues (
	ticket_id BIGINT,
	current_due DOUBLE,
	PRIMARY KEY (ticket_id)
);

CREATE TABLE payments (
	ticket_id BIGINT,
	total_payments DOUBLE,
	PRIMARY KEY (ticket_id)
);

CREATE TABLE queues (
	ticket_id BIGINT,
	queue_status VARCHAR(20),
    queue_date DATE,
	PRIMARY KEY (ticket_id)
);

CREATE TABLE hearing_dispos (
	id INT NOT NULL AUTO_INCREMENT,
	hearing_dispo VARCHAR(50),
	PRIMARY KEY (id)
);

CREATE TABLE hearing_reasons (
	id INT NOT NULL AUTO_INCREMENT,
	hearing_reason VARCHAR(100),
	PRIMARY KEY (id)
);

CREATE TABLE notice_levels (
	id INT NOT NULL AUTO_INCREMENT,
	notice_level VARCHAR(10),
	PRIMARY KEY (id)
);

CREATE TABLE tickets (
	id BIGINT NOT NULL,
	notice_id INT,
	issue_date DATETIME,
	location_id INT,
	zip_code_id INT,
	violation_id INT,
	unit_id INT, 
	officer_id INT, 
	vehicle_make_id INT,
	license_plate_id INT,
	hearing_dispo_id INT,
	hearing_reason_id INT,
  notice_level_id INT,
	PRIMARY KEY (id),
	FOREIGN KEY (notice_id) REFERENCES notices(id),
	FOREIGN KEY (location_id) REFERENCES locations(id),
	FOREIGN KEY (zip_code_id) REFERENCES zip_codes(id),
	FOREIGN KEY (violation_id) REFERENCES violations(id),
	FOREIGN KEY (unit_id) REFERENCES units(id),
	FOREIGN KEY (officer_id) REFERENCES officers(id),
	FOREIGN KEY (vehicle_make_id) REFERENCES vehicle_makes(id),
	FOREIGN KEY (license_plate_id) REFERENCES license_plate_types(id),
  FOREIGN KEY (id) REFERENCES fines(ticket_id),
  FOREIGN KEY (id) REFERENCES dues(ticket_id),
	FOREIGN KEY (id) REFERENCES payments(ticket_id),
	FOREIGN KEY (id) REFERENCES queues(ticket_id),
	FOREIGN KEY (hearing_dispo_id) REFERENCES hearing_dispos(id),
	FOREIGN KEY (hearing_reason_id) REFERENCES hearing_reasons(id),
  FOREIGN KEY (notice_level_id) REFERENCES notice_levels(id)
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

INSERT INTO officers (officer_id)
SELECT DISTINCT 
	officer
FROM chicago.citations
WHERE officer IS NOT NULL;

INSERT INTO units (unit_code, description)
SELECT DISTINCT
	unit, 
	unit_description
FROM chicago.citations
WHERE unit IS NOT NULL;

INSERT INTO vehicle_makes (vehicle_make)
SELECT DISTINCT 
	vehicle_make 
FROM chicago.citations
WHERE vehicle_make IS NOT NULL;

INSERT INTO locations (address)
SELECT DISTINCT 
	location
FROM chicago.citations
WHERE location IS NOT NULL;

INSERT INTO zip_codes (zip_code)
SELECT DISTINCT 
	zip_code
FROM chicago.citations
WHERE location IS NOT NULL;

INSERT INTO license_plate_types (license_plate_type)
SELECT DISTINCT
	license_plate_type
FROM chicago.citations
WHERE license_plate_type IS NOT NULL;

INSERT INTO fines (
	ticket_id,
	fine_1,
	fine_2
)
SELECT ticket_number, fine_1, fine_2
FROM chicago.citations
WHERE ticket_number IS NOT NULL;

INSERT INTO dues (
	ticket_id,
	current_due
)
SELECT ticket_number, current_due
FROM chicago.citations
WHERE ticket_number IS NOT NULL;

INSERT INTO payments (
	ticket_id,
	total_payments
)
SELECT ticket_number, total_payments
FROM chicago.citations
WHERE ticket_number IS NOT NULL;

INSERT INTO queues (
	ticket_id,
	queue_status,
  queue_date
)
SELECT ticket_number, ticket_queue, ticket_queue_date
FROM chicago.citations
WHERE ticket_number IS NOT NULL;

INSERT INTO hearing_dispos (hearing_dispo)
SELECT DISTINCT 
	hearing_dispo
FROM chicago.citations
WHERE hearing_dispo IS NOT NULL;

INSERT INTO hearing_reasons (hearing_reason)
SELECT DISTINCT
	hearing_reason
FROM chicago.citations
WHERE hearing_reason IS NOT NULL;

INSERT INTO notice_levels (notice_level)
SELECT DISTINCT 
	notice_level
FROM chicago.citations
WHERE notice_level IS NOT NULL;

INSERT INTO tickets (
	id, 
	issue_date
) 
SELECT 
	ticket_number, 
	issue_date
FROM chicago.citations;

WITH notices_link AS (
	SELECT DISTINCT
		chicago.citations.ticket_number, 
		notices.id
	FROM chicago.citations 
		RIGHT JOIN notices
			ON chicago.citations.notice_number = notices.notice_number
)
UPDATE tickets JOIN notices_link
SET tickets.notice_id = notices_link.id
WHERE tickets.id = notices_link.ticket_number;

WITH locations_link AS (
	SELECT DISTINCT
		chicago.citations.ticket_number, 
		locations.id
	FROM chicago.citations 
		RIGHT JOIN locations
    	ON chicago.citations.location = locations.address
)
UPDATE tickets JOIN locations_link
SET tickets.location_id = locations_link.id
WHERE tickets.id = locations_link.ticket_number;

WITH zip_codes_link AS (
	SELECT DISTINCT
		chicago.citations.ticket_number, 
		zip_codes.id
	FROM chicago.citations 
		RIGHT JOIN zip_codes
    	ON chicago.citations.zip_code = zip_codes.zip_code
)
UPDATE tickets JOIN zip_codes_link
SET tickets.zip_code_id = zip_codes_link.id
WHERE tickets.id = zip_codes_link.ticket_number;

WITH violations_link AS (
	SELECT DISTINCT
		chicago.citations.ticket_number, 
		violations.id
	FROM chicago.citations 
		RIGHT JOIN violations
    	ON chicago.citations.violation_code = violations.violation_code
) 
UPDATE tickets JOIN violations_link
SET tickets.violation_id = violations_link.id
WHERE tickets.id = violations_link.ticket_number;

WITH units_link AS (
	SELECT DISTINCT
		chicago.citations.ticket_number, 
		units.id
	FROM chicago.citations 
		RIGHT JOIN units
			ON chicago.citations.unit = units.unit_code
)
UPDATE tickets JOIN units_link
SET tickets.unit_id = units_link.id
WHERE tickets.id = units_link.ticket_number;

WITH officers_link AS (
	SELECT DISTINCT
		chicago.citations.ticket_number, 
		officers.id
	FROM chicago.citations 
		RIGHT JOIN officers
			ON chicago.citations.officer = officers.officer_id
)
UPDATE tickets JOIN officers_link
SET tickets.officer_id = officers_link.id
WHERE tickets.id = officers_link.ticket_number;

WITH vehicle_makes_link AS (
	SELECT DISTINCT
		chicago.citations.ticket_number, 
		vehicle_makes.id
	FROM chicago.citations 
		RIGHT JOIN vehicle_makes
			ON chicago.citations.vehicle_make = vehicle_makes.vehicle_make
)
UPDATE tickets JOIN vehicle_makes_link
SET tickets.vehicle_make_id = vehicle_makes_link.id
WHERE tickets.id = vehicle_makes_link.ticket_number;

WITH license_plate_types_link AS (
	SELECT DISTINCT
		chicago.citations.ticket_number, 
		license_plate_types.id
	FROM chicago.citations 
		RIGHT JOIN license_plate_types
			ON chicago.citations.license_plate_type = license_plate_types.license_plate_type
)
UPDATE tickets JOIN license_plate_types_link
SET tickets.license_plate_id = license_plate_types_link.id
WHERE tickets.id = license_plate_types_link.ticket_number;

WITH hearing_dispos_link AS (
	SELECT DISTINCT
		chicago.citations.ticket_number,
		hearing_dispos.id
	FROM chicago.citations 
		RIGHT JOIN hearing_dispos
			ON chicago.citations.hearing_dispo = hearing_dispos.hearing_dispo
) 
UPDATE tickets JOIN hearing_dispos_link
SET tickets.hearing_dispo_id = hearing_dispos_link.id
WHERE tickets.id = hearing_dispos_link.ticket_number;

WITH hearing_reasons_link AS (
	SELECT DISTINCT
		chicago.citations.ticket_number, 
		hearing_reasons.id
	FROM chicago.citations 
		RIGHT JOIN hearing_reasons
			ON chicago.citations.hearing_reason = hearing_reasons.hearing_reason
)
UPDATE tickets JOIN hearing_reasons_link
SET tickets.hearing_reason_id = hearing_reasons_link.id
WHERE tickets.id = hearing_reasons_link.ticket_number;

-- Store combined table view
CREATE VIEW chicago_norm_all AS 
SELECT 
	notices.notice_number AS notice_number,
	tickets.id AS ticket_number,
	tickets.issue_date,
	locations.address AS location,
	zip_codes.zip_code AS zip_code,
	violations.violation_code,
	violations.description AS violation_description,
	units.unit_code AS unit,
	units.description AS unit_description,
	officers.officer_id AS officer,
	vehicle_makes.vehicle_make,
	license_plate_types.license_plate_type,
	fines.fine_1,
	fines.fine_2,
	dues.current_due,
	payments.total_payments,
	queues.queue_status AS "ticket_queue",
	queues.queue_date AS "ticket_queue_date",
	hearing_dispos.hearing_dispo,
	hearing_reasons.hearing_reason,
  notice_levels.notice_level
FROM tickets
	LEFT OUTER JOIN notices
		ON tickets.notice_id = notices.id
	LEFT OUTER JOIN locations
		ON tickets.location_id = locations.id
	LEFT OUTER JOIN zip_codes
		ON tickets.zip_code_id = zip_codes.id
	LEFT OUTER JOIN violations
		ON tickets.violation_id = violations.id
	LEFT OUTER JOIN units
		ON tickets.unit_id = units.id
	LEFT OUTER JOIN officers
		ON tickets.officer_id = officers.id
	LEFT OUTER JOIN vehicle_makes
		ON tickets.vehicle_make_id = vehicle_makes.id
	LEFT OUTER JOIN license_plate_types
		ON tickets.license_plate_id = license_plate_types.id
	LEFT OUTER JOIN fines
		ON tickets.id = fines.ticket_id
	LEFT OUTER JOIN dues
		ON tickets.id = dues.ticket_id
	LEFT OUTER JOIN payments
		ON tickets.id = payments.ticket_id
	LEFT OUTER JOIN queues
		ON tickets.id = queues.ticket_id
	LEFT OUTER JOIN hearing_dispos
		ON tickets.hearing_dispo_id = hearing_dispos.id
	LEFT OUTER JOIN hearing_reasons
		ON tickets.hearing_reason_id = hearing_reasons.id
	LEFT OUTER JOIN notice_levels
		ON tickets.notice_level_id = notice_levels.id
	ORDER BY notices.notice_number DESC, tickets.id DESC;
    
-- Examine tickets 
SELECT * FROM tickets; 

-- Compare citations query results to normalized database query results
SELECT * FROM chicago.citations
ORDER BY notice_number DESC, ticket_number DESC;

SELECT * FROM chicago_norm_all;
