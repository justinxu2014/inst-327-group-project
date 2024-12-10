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

