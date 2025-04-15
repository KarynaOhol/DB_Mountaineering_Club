-- Populate experience_level table
INSERT INTO experience_level (level_name, min_climbs_required, min_years_experience)
VALUES ('Beginner', 0, 0),
       ('Intermediate', 5, 1),
       ('Advanced', 15, 3),
       ('Expert', 30, 5)
ON CONFLICT (level_name) DO NOTHING;


-- Populate peak_type table
INSERT INTO peak_type (type_name)
VALUES ('Volcanic'),
       ('Granite'),
       ('Limestone'),
       ('Sandstone')
ON CONFLICT (type_name) DO NOTHING;

-- Populate area table
INSERT INTO area (area_name, country, latitude, longitude, local_authority, permit_requirements, access_restrictions,
                  nearest_city, distance_to_nearest_hospital_km)
VALUES ('Alps', 'Switzerland', 46.8182, 8.2275, 'Swiss Alpine Club', 'None for basic hiking',
        'Some routes closed in winter', 'Zurich', 45.5),
       ('Dolomites', 'Italy', 46.4102, 11.8440, 'Italian Alpine Club', 'Required for certain peaks',
        'National park regulations apply', 'Bolzano', 35.2),
       ('Cascades', 'USA', 47.5211, -121.4380, 'US Forest Service', 'Wilderness permits required',
        'Winter access limited', 'Seattle', 80.7)
ON CONFLICT ON CONSTRAINT unique_area_country DO NOTHING;

-- CREATE INDEX IF NOT EXISTS on country for faster filtering by country
CREATE INDEX IF NOT EXISTS idx_area_country ON area (country);

-- Populate climber table (requires experience_level to exist)
INSERT INTO climber (first_name, last_name, birth_date, address_line1, city, postal_code, country, email, phone,
                     experience_level_id, emergency_contact_name, emergency_contact_phone, blood_type)
VALUES ('Alex', 'Johnson', '2001-05-15', '123 Mountain Way', 'Boulder', '80302', 'USA', 'alex@example.com',
        '303-555-1234', (SELECT experience_level_id FROM experience_level WHERE LOWER(level_name) = 'intermediate'),
        'Sarah Johnson', '303-555-4321', 'O+'),
       ('Maria', 'Garcia', '2002-07-22', '456 Alpine Street', 'Denver', '80201', 'USA', 'maria@example.com',
        '303-555-5678', (SELECT experience_level_id FROM experience_level WHERE LOWER(level_name) = 'advanced'),
        'Carlos Garcia', '303-555-8765', 'A-'),
       ('Hiroshi', 'Tanaka', '2002-11-10', '789 Summit Avenue', 'Portland', '97201', 'USA', 'hiroshi@example.com',
        '503-555-9012', (SELECT experience_level_id FROM experience_level WHERE LOWER(level_name) = 'beginner'),
        'Yuki Tanaka', '503-555-2109', 'B+')
ON CONFLICT (email) DO NOTHING;

-- CREATE INDEX IF NOT EXISTS on experience_level_id for faster lookups
CREATE INDEX IF NOT EXISTS idx_climber_experience_level ON climber (experience_level_id);

-- Populate mountain table (requires area and peak_type to exist)
INSERT INTO mountain (mountain_name, height_meters, area_id, mountain_range, climbing_season_start, climbing_season_end,
                      permits_required, peak_type_id)
VALUES ('Matterhorn', 4478.0, (SELECT area_id FROM area WHERE LOWER(area_name) = 'alps'),
        'Alps', '2025-06-15', '2025-09-30', TRUE,
        (SELECT peak_type_id FROM peak_type WHERE LOWER(type_name) = 'granite')),
       ('Tre Cime di Lavaredo', 2999.0, (SELECT area_id FROM area WHERE LOWER(area_name) = 'dolomites'),
        'Dolomites', '2025-06-01', '2025-10-15', TRUE,
        (SELECT peak_type_id FROM peak_type WHERE LOWER(type_name) = 'limestone')),
       ('Mount Rainier', 4392.0, (SELECT area_id FROM area WHERE LOWER(area_name) = 'cascades'),
        'Cascades', '2025-05-15', '2025-09-15', TRUE,
        (SELECT peak_type_id FROM peak_type WHERE LOWER(type_name) = 'volcanic'))
ON CONFLICT ON CONSTRAINT unique_mountain_in_area DO NOTHING;

-- CREATE INDEX IF NOT EXISTSes for mountain
CREATE INDEX IF NOT EXISTS idx_mountain_area ON mountain (area_id);
CREATE INDEX IF NOT EXISTS idx_mountain_peak_type ON mountain (peak_type_id);
CREATE INDEX IF NOT EXISTS idx_mountain_height ON mountain (height_meters);

-- Populate risk_level table
INSERT INTO risk_level (risk_name, requires_special_insurance, requires_special_training)
VALUES ('Low', FALSE, FALSE),
       ('Moderate', FALSE, TRUE),
       ('High', TRUE, TRUE),
       ('Extreme', TRUE, TRUE)
ON CONFLICT (risk_name) DO NOTHING;

-- Populate difficulty_level table (requires experience_level to exist)
INSERT INTO difficulty_level (difficulty_name, min_experience_level_id, technical_grade, commitment_grade,
                              altitude_grade)
VALUES ('Easy', (SELECT experience_level_id FROM experience_level WHERE LOWER(level_name) = 'beginner'),
        'F', 'I', 'A1'),
       ('Moderate', (SELECT experience_level_id FROM experience_level WHERE LOWER(level_name) = 'intermediate'),
        'PD', 'II', 'A2'),
       ('Difficult', (SELECT experience_level_id FROM experience_level WHERE LOWER(level_name) = 'advanced'),
        'AD', 'III', 'A3'),
       ('Very Difficult', (SELECT experience_level_id FROM experience_level WHERE LOWER(level_name) = 'expert'),
        'D', 'IV', 'A4')
ON CONFLICT (difficulty_name) DO NOTHING;

-- CREATE INDEX IF NOT EXISTS on min_experience_level_id for faster joins
CREATE INDEX IF NOT EXISTS idx_difficulty_experience ON difficulty_level (min_experience_level_id);

-- Populate route table (requires mountain, difficulty_level, and risk_level to exist)
INSERT INTO route (mountain_id, route_name, difficulty_level_id, length_meters, is_seasonal, best_season,
                   avg_completion_days, technical_climbing_required, risk_level_id)
VALUES ((SELECT mountain_id FROM mountain WHERE LOWER(mountain_name) = 'matterhorn'),
        'Hörnli Ridge',
        (SELECT difficulty_level_id FROM difficulty_level WHERE LOWER(difficulty_name) = 'difficult'),
        1200, TRUE, 'Summer', 2.0, TRUE,
        (SELECT risk_level_id FROM risk_level WHERE LOWER(risk_name) = 'high')),
       ((SELECT mountain_id FROM mountain WHERE LOWER(mountain_name) = 'tre cime di lavaredo'),
        'Normal Route',
        (SELECT difficulty_level_id FROM difficulty_level WHERE LOWER(difficulty_name) = 'moderate'),
        800, TRUE, 'Summer', 1.0, FALSE,
        (SELECT risk_level_id FROM risk_level WHERE LOWER(risk_name) = 'moderate')),
       ((SELECT mountain_id FROM mountain WHERE LOWER(mountain_name) = 'mount rainier'),
        'Disappointment Cleaver',
        (SELECT difficulty_level_id FROM difficulty_level WHERE LOWER(difficulty_name) = 'difficult'),
        4400, TRUE, 'Summer', 2.5, TRUE,
        (SELECT risk_level_id FROM risk_level WHERE LOWER(risk_name) = 'high')),
       ((SELECT mountain_id FROM mountain WHERE LOWER(mountain_name) = 'matterhorn'),
        'Lion Ridge',
        (SELECT difficulty_level_id FROM difficulty_level WHERE LOWER(difficulty_name) = 'very difficult'),
        1400, TRUE, 'Summer', 2.5, TRUE,
        (SELECT risk_level_id FROM risk_level WHERE LOWER(risk_name) = 'extreme'))
ON CONFLICT ON CONSTRAINT unique_route_on_mountain DO NOTHING;

-- CREATE INDEX IF NOT EXISTSes for routes
CREATE INDEX IF NOT EXISTS idx_route_mountain ON route (mountain_id);
CREATE INDEX IF NOT EXISTS idx_route_difficulty ON route (difficulty_level_id);
CREATE INDEX IF NOT EXISTS idx_route_risk ON route (risk_level_id);

-- Populate base_camp table (requires mountain to exist)
INSERT INTO base_camp (mountain_id, camp_name, height_meters, max_capacity, has_medical_facility, latitude, longitude,
                       has_wifi, has_electricity, has_water_source)
VALUES ((SELECT mountain_id FROM mountain WHERE LOWER(mountain_name) = 'matterhorn'),
        'Hörnli Hut', 3260, 50, TRUE, 45.9763, 7.6586, TRUE, TRUE, TRUE),
       ((SELECT mountain_id FROM mountain WHERE LOWER(mountain_name) = 'mount rainier'),
        'Camp Muir', 3072, 25, FALSE, 46.8350, -121.7330, FALSE, FALSE, TRUE),
       ((SELECT mountain_id FROM mountain WHERE LOWER(mountain_name) = 'tre cime di lavaredo'),
        'Auronzo Hut', 2320, 120, TRUE, 46.6169, 12.3026, TRUE, TRUE, TRUE)
ON CONFLICT ON CONSTRAINT unique_camp_on_mountain DO NOTHING;

-- CREATE INDEX IF NOT EXISTSes for base camps
CREATE INDEX IF NOT EXISTS idx_basecamp_mountain ON base_camp (mountain_id);
CREATE INDEX IF NOT EXISTS idx_basecamp_height ON base_camp (height_meters);

-- Populate equipment_category table
INSERT INTO equipment_category (category_name)
VALUES ('Clothing'),
       ('Technical'),
       ('Safety'),
       ('Camping')
ON CONFLICT (category_name) DO NOTHING;

-- Populate equipment table (requires equipment_category to exist)
INSERT INTO equipment (equipment_name, weight_kg, is_technical, is_safety, is_rental_available, rental_cost_per_day,
                       equipment_category_id, lifespan_years)
VALUES ('Ice Axe', 0.5, TRUE, TRUE, TRUE, 10.00,
        (SELECT equipment_category_id FROM equipment_category WHERE LOWER(category_name) = 'technical'), 8),
       ('Crampons', 1.2, TRUE, TRUE, TRUE, 15.00,
        (SELECT equipment_category_id FROM equipment_category WHERE LOWER(category_name) = 'technical'), 5),
       ('Helmet', 0.4, FALSE, TRUE, TRUE, 8.00,
        (SELECT equipment_category_id FROM equipment_category WHERE LOWER(category_name) = 'safety'), 5),
       ('Down Jacket', 0.8, FALSE, FALSE, TRUE, 12.00,
        (SELECT equipment_category_id FROM equipment_category WHERE LOWER(category_name) = 'clothing'), 4),
       ('Tent', 2.5, FALSE, FALSE, TRUE, 25.00,
        (SELECT equipment_category_id FROM equipment_category WHERE LOWER(category_name) = 'camping'), 6)
ON CONFLICT ON CONSTRAINT unique_equipment_in_category DO NOTHING;

-- CREATE INDEX IF NOT EXISTS for equipment category
CREATE INDEX IF NOT EXISTS idx_equipment_category ON equipment (equipment_category_id);

-- Populate equipment_inventory table (requires equipment to exist)
INSERT INTO equipment_inventory (equipment_id, serial_number, purchase_date, last_maintenance, condition, available)
VALUES ((SELECT equipment_id FROM equipment WHERE LOWER(equipment_name) = 'ice axe'),
        'AX-10001', '2023-03-15', '2025-01-10', 'Good', TRUE),
       ((SELECT equipment_id FROM equipment WHERE LOWER(equipment_name) = 'ice axe'),
        'AX-10002', '2023-03-15', '2025-01-10', 'Excellent', TRUE),
       ((SELECT equipment_id FROM equipment WHERE LOWER(equipment_name) = 'crampons'),
        'CR-20001', '2023-04-20', '2025-01-15', 'Good', TRUE),
       ((SELECT equipment_id FROM equipment WHERE LOWER(equipment_name) = 'helmet'),
        'HM-30001', '2023-05-10', '2025-02-05', 'Fair', TRUE),
       ((SELECT equipment_id FROM equipment WHERE LOWER(equipment_name) = 'down jacket'),
        'DJ-40001', '2024-01-05', NULL, 'Excellent', TRUE),
       ((SELECT equipment_id FROM equipment WHERE LOWER(equipment_name) = 'tent'),
        'TN-50001', '2024-02-10', '2025-03-01', 'Good', TRUE)
ON CONFLICT ON CONSTRAINT unique_equipment_serial DO NOTHING;

-- CREATE INDEX IF NOT EXISTSes for inventory
CREATE INDEX IF NOT EXISTS idx_inventory_equipment ON equipment_inventory (equipment_id);
CREATE INDEX IF NOT EXISTS idx_inventory_available ON equipment_inventory (available);

-- Populate equipment_requirement table (requires difficulty_level and equipment to exist)
INSERT INTO equipment_requirement (difficulty_level_id, equipment_id, is_mandatory, quantity_required)
VALUES ((SELECT difficulty_level_id FROM difficulty_level WHERE LOWER(difficulty_name) = 'difficult'),
        (SELECT equipment_id FROM equipment WHERE LOWER(equipment_name) = 'ice axe'),
        TRUE, 1), -- Ice axe for difficult routes
       ((SELECT difficulty_level_id FROM difficulty_level WHERE LOWER(difficulty_name) = 'difficult'),
        (SELECT equipment_id FROM equipment WHERE LOWER(equipment_name) = 'crampons'),
        TRUE, 1), -- Crampons for difficult routes
       ((SELECT difficulty_level_id FROM difficulty_level WHERE LOWER(difficulty_name) = 'difficult'),
        (SELECT equipment_id FROM equipment WHERE LOWER(equipment_name) = 'helmet'),
        TRUE, 1), -- Helmet for difficult routes
       ((SELECT difficulty_level_id FROM difficulty_level WHERE LOWER(difficulty_name) = 'moderate'),
        (SELECT equipment_id FROM equipment WHERE LOWER(equipment_name) = 'helmet'),
        TRUE, 1), -- Helmet for moderate routes
       ((SELECT difficulty_level_id FROM difficulty_level WHERE LOWER(difficulty_name) = 'very difficult'),
        (SELECT equipment_id FROM equipment WHERE LOWER(equipment_name) = 'ice axe'),
        TRUE, 1), -- Ice axe for very difficult routes
       ((SELECT difficulty_level_id FROM difficulty_level WHERE LOWER(difficulty_name) = 'very difficult'),
        (SELECT equipment_id FROM equipment WHERE LOWER(equipment_name) = 'crampons'),
        TRUE, 1) -- Crampons for very difficult routes
ON CONFLICT ON CONSTRAINT unique_equipment_requirement DO NOTHING;

-- CREATE INDEX IF NOT EXISTSes for equipment requirements
CREATE INDEX IF NOT EXISTS idx_requirement_difficulty ON equipment_requirement (difficulty_level_id);
CREATE INDEX IF NOT EXISTS idx_requirement_equipment ON equipment_requirement (equipment_id);


-- Populate insurance_level table
INSERT INTO insurance_level (insurance_name, coverage_details, min_coverage_amount, search_rescue_coverage,
                             helicopter_evacuation_covered, medical_repatriation_covered, third_party_liability)
VALUES ('Basic', 'Covers basic medical expenses', 50000.00, 10000.00, FALSE, FALSE, FALSE),
       ('Standard', 'Covers medical expenses and basic rescue', 100000.00, 25000.00, TRUE, FALSE, TRUE),
       ('Premium', 'Comprehensive coverage for all risks', 250000.00, 50000.00, TRUE, TRUE, TRUE)
ON CONFLICT (insurance_name) DO NOTHING;

-- Populate climb table (requires route and insurance_level to exist)
INSERT INTO climb (start_date, end_date, route_id, status, insurance_level_id, max_participants, total_cost,
                   is_club_sponsored, registration_deadline, briefing_datetime)
VALUES ('2025-07-10', '2025-07-13',
        (SELECT route_id FROM route WHERE LOWER(route_name) = 'hörnli ridge' AND
         mountain_id = (SELECT mountain_id FROM mountain WHERE LOWER(mountain_name) = 'matterhorn')),
        'Planned',
        (SELECT insurance_level_id FROM insurance_level WHERE LOWER(insurance_name) = 'premium'),
        8, 1500.00, TRUE, '2025-06-15', '2025-07-09 18:00:00'),
       ('2025-07-20', '2025-07-22',
        (SELECT route_id FROM route WHERE LOWER(route_name) = 'normal route' AND
         mountain_id = (SELECT mountain_id FROM mountain WHERE LOWER(mountain_name) = 'tre cime di lavaredo')),
        'Planned',
        (SELECT insurance_level_id FROM insurance_level WHERE LOWER(insurance_name) = 'standard'),
        12, 800.00, TRUE, '2025-06-25', '2025-07-19 17:00:00'),
       ('2025-08-05', '2025-08-08',
        (SELECT route_id FROM route WHERE LOWER(route_name) = 'disappointment cleaver' AND
         mountain_id = (SELECT mountain_id FROM mountain WHERE LOWER(mountain_name) = 'mount rainier')),
        'Planned',
        (SELECT insurance_level_id FROM insurance_level WHERE LOWER(insurance_name) = 'premium'),
        10, 2000.00, FALSE, '2025-07-15', '2025-08-04 16:00:00')
ON CONFLICT DO NOTHING;

-- CREATE INDEX IF NOT EXISTSes for climbs
CREATE INDEX IF NOT EXISTS idx_climb_route ON climb (route_id);
CREATE INDEX IF NOT EXISTS idx_climb_dates ON climb (start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_climb_status ON climb (status);
CREATE INDEX IF NOT EXISTS idx_climb_insurance ON climb (insurance_level_id);

-- Populate climber_insurance table (requires climber to exist)
INSERT INTO climber_insurance (climber_id, policy_number, start_date, end_date, coverage_amount, verified)
VALUES ((SELECT climber_id FROM climber WHERE LOWER(email) = 'alex@example.com'),
        'INS-10001', '2025-01-01', '2025-12-31', 200000.00, TRUE),
       ((SELECT climber_id FROM climber WHERE LOWER(email) = 'maria@example.com'),
        'INS-10002', '2025-01-15', '2025-12-31', 300000.00, TRUE),
       ((SELECT climber_id FROM climber WHERE LOWER(email) = 'hiroshi@example.com'),
        'INS-10003', '2025-02-01', '2025-12-31', 100000.00, TRUE)
ON CONFLICT ON CONSTRAINT unique_climber_policy DO NOTHING;

-- CREATE INDEX IF NOT EXISTSes for climber insurance
CREATE INDEX IF NOT EXISTS idx_climber_insurance_climber ON climber_insurance (climber_id);
CREATE INDEX IF NOT EXISTS idx_climber_insurance_dates ON climber_insurance (end_date);

-- Populate climb_participant table (requires climb and climber to exist)
INSERT INTO climb_participant (climb_id, climber_id, waiver_signed, signed_date, has_required_insurance,
                              attendance_confirmed)
WITH climb_data AS (
    SELECT
        (SELECT climb_id FROM climb WHERE start_date = '2025-07-10' AND
         route_id = (SELECT route_id FROM route WHERE LOWER(route_name) = 'hörnli ridge' AND
                    mountain_id = (SELECT mountain_id FROM mountain WHERE LOWER(mountain_name) = 'matterhorn'))) AS climb1,
        (SELECT climb_id FROM climb WHERE start_date = '2025-07-20' AND
         route_id = (SELECT route_id FROM route WHERE LOWER(route_name) = 'normal route' AND
                    mountain_id = (SELECT mountain_id FROM mountain WHERE LOWER(mountain_name) = 'tre cime di lavaredo'))) AS climb2,
        (SELECT climb_id FROM climb WHERE start_date = '2025-08-05' AND
         route_id = (SELECT route_id FROM route WHERE LOWER(route_name) = 'disappointment cleaver' AND
                    mountain_id = (SELECT mountain_id FROM mountain WHERE LOWER(mountain_name) = 'mount rainier'))) AS climb3,
        (SELECT climber_id FROM climber WHERE LOWER(email) = 'alex@example.com') AS climber1,
        (SELECT climber_id FROM climber WHERE LOWER(email) = 'maria@example.com') AS climber2,
        (SELECT climber_id FROM climber WHERE LOWER(email) = 'hiroshi@example.com') AS climber3
)
SELECT
    climb1, climber1, TRUE, '2025-06-01', TRUE, TRUE
FROM climb_data
UNION ALL
SELECT
    climb1, climber2, TRUE, '2025-06-02', TRUE, TRUE
FROM climb_data
UNION ALL
SELECT
    climb2, climber3, TRUE, '2025-06-15', TRUE, FALSE
FROM climb_data
UNION ALL
SELECT
    climb3, climber1, TRUE, '2025-06-20', TRUE, FALSE
FROM climb_data
UNION ALL
SELECT
    climb3, climber2, TRUE, '2025-06-21', TRUE, FALSE
FROM climb_data
ON CONFLICT ON CONSTRAINT unique_climber_per_climb DO NOTHING;

-- CREATE INDEX IF NOT EXISTSes for climb participants
CREATE INDEX IF NOT EXISTS idx_participant_climb ON climb_participant (climb_id);
CREATE INDEX IF NOT EXISTS idx_participant_climber ON climb_participant (climber_id);

-- Populate invoice table (requires climb and climber to exist)
INSERT INTO invoice (climb_id, climber_id, invoice_date, due_date, total_amount, status, tax_rate, tax_amount)
WITH climb_data AS (
    SELECT
        (SELECT climb_id FROM climb WHERE start_date = '2025-07-10' AND
         route_id = (SELECT route_id FROM route WHERE LOWER(route_name) = 'hörnli ridge' AND
                    mountain_id = (SELECT mountain_id FROM mountain WHERE LOWER(mountain_name) = 'matterhorn'))) AS climb1,
        (SELECT climb_id FROM climb WHERE start_date = '2025-07-20' AND
         route_id = (SELECT route_id FROM route WHERE LOWER(route_name) = 'normal route' AND
                    mountain_id = (SELECT mountain_id FROM mountain WHERE LOWER(mountain_name) = 'tre cime di lavaredo'))) AS climb2,
        (SELECT climb_id FROM climb WHERE start_date = '2025-08-05' AND
         route_id = (SELECT route_id FROM route WHERE LOWER(route_name) = 'disappointment cleaver' AND
                    mountain_id = (SELECT mountain_id FROM mountain WHERE LOWER(mountain_name) = 'mount rainier'))) AS climb3,
        (SELECT climber_id FROM climber WHERE LOWER(email) = 'alex@example.com') AS climber1,
        (SELECT climber_id FROM climber WHERE LOWER(email) = 'maria@example.com') AS climber2,
        (SELECT climber_id FROM climber WHERE LOWER(email) = 'hiroshi@example.com') AS climber3
)
SELECT
    climb1, climber1, '2025-06-05', '2025-06-25', 1500.00, 'Paid', 7.50, 112.50
FROM climb_data
UNION ALL
SELECT
    climb1, climber2, '2025-06-05', '2025-06-25', 1500.00, 'Paid', 7.50, 112.50
FROM climb_data
UNION ALL
SELECT
    climb2, climber3, '2025-06-20', '2025-07-10', 800.00, 'Unpaid', 7.50, 60.00
FROM climb_data
UNION ALL
SELECT
    climb3, climber1, '2025-06-25', '2025-07-15', 2000.00, 'Partial', 7.50, 150.00
FROM climb_data
UNION ALL
SELECT
    climb3, climber2, '2025-06-25', '2025-07-15', 2000.00, 'Unpaid', 7.50, 150.00
FROM climb_data
ON CONFLICT DO NOTHING;

-- CREATE INDEX IF NOT EXISTSes for invoices
CREATE INDEX IF NOT EXISTS idx_invoice_climb ON invoice (climb_id);
CREATE INDEX IF NOT EXISTS idx_invoice_climber ON invoice (climber_id);
CREATE INDEX IF NOT EXISTS idx_invoice_status ON invoice (status);
CREATE INDEX IF NOT EXISTS idx_invoice_due_date ON invoice (due_date);

-- Populate payment table with rerunnable inserts and subqueries
INSERT INTO payment (climb_id, climber_id, amount, payment_date, payment_method, payment_status, transaction_ref, invoice_id)
WITH data AS (
    SELECT
        c.climb_id,
        cl.climber_id,
        i.invoice_id
    FROM
        climb c,
        climber cl,
        invoice i
    WHERE
        i.climb_id = c.climb_id AND
        i.climber_id = cl.climber_id
)
SELECT
    d.climb_id,
    d.climber_id,
    1500.00,
    '2025-06-10',
    'Credit Card',
    'Completed',
    'TRX-10001',
    d.invoice_id
FROM
    data d
    JOIN climber cl ON d.climber_id = cl.climber_id
    JOIN climb c ON d.climb_id = c.climb_id
WHERE
    LOWER(cl.email) = 'alex@example.com' AND
    c.start_date = '2025-07-10'
UNION ALL
SELECT
    d.climb_id,
    d.climber_id,
    1500.00,
    '2025-06-12',
    'Credit Card',
    'Completed',
    'TRX-10002',
    d.invoice_id
FROM
    data d
    JOIN climber cl ON d.climber_id = cl.climber_id
    JOIN climb c ON d.climb_id = c.climb_id
WHERE
    LOWER(cl.email) = 'maria@example.com' AND
    c.start_date = '2025-07-10'
UNION ALL
SELECT
    d.climb_id,
    d.climber_id,
    1000.00,
    '2025-07-01',
    'Bank Transfer',
    'Completed',
    'TRX-10003',
    d.invoice_id
FROM
    data d
    JOIN climber cl ON d.climber_id = cl.climber_id
    JOIN climb c ON d.climb_id = c.climb_id
WHERE
    LOWER(cl.email) = 'alex@example.com' AND
    c.start_date = '2025-08-05'
ON CONFLICT (transaction_ref) DO NOTHING;

-- CREATE INDEX IF NOT EXISTSes for payments
CREATE INDEX IF NOT EXISTS idx_payment_climb ON payment (climb_id);
CREATE INDEX IF NOT EXISTS idx_payment_climber ON payment (climber_id);
CREATE INDEX IF NOT EXISTS idx_payment_status ON payment (payment_status);
CREATE INDEX IF NOT EXISTS idx_payment_invoice ON payment (invoice_id);

-- Populate equipment_rental table (requires inventory, climber, and climb to exist)
INSERT INTO equipment_rental (inventory_id, climber_id, climb_id, rental_start, rental_end, deposit_amount, rental_fee)
WITH data AS (
    SELECT
        (SELECT inventory_id FROM equipment_inventory ei
         JOIN equipment e ON ei.equipment_id = e.equipment_id
         WHERE LOWER(e.equipment_name) = 'ice axe' AND ei.serial_number = 'AX-10001') AS inv1,
        (SELECT inventory_id FROM equipment_inventory ei
         JOIN equipment e ON ei.equipment_id = e.equipment_id
         WHERE LOWER(e.equipment_name) = 'ice axe' AND ei.serial_number = 'AX-10002') AS inv2,
        (SELECT inventory_id FROM equipment_inventory ei
         JOIN equipment e ON ei.equipment_id = e.equipment_id
         WHERE LOWER(e.equipment_name) = 'crampons' AND ei.serial_number = 'CR-20001') AS inv3,
        (SELECT inventory_id FROM equipment_inventory ei
         JOIN equipment e ON ei.equipment_id = e.equipment_id
         WHERE LOWER(e.equipment_name) = 'helmet' AND ei.serial_number = 'HM-30001') AS inv4,
        (SELECT climber_id FROM climber WHERE LOWER(email) = 'alex@example.com') AS climber1,
        (SELECT climber_id FROM climber WHERE LOWER(email) = 'maria@example.com') AS climber2,
        (SELECT climber_id FROM climber WHERE LOWER(email) = 'hiroshi@example.com') AS climber3,
        (SELECT climb_id FROM climb WHERE start_date = '2025-07-10' AND
         route_id = (SELECT route_id FROM route WHERE LOWER(route_name) = 'hörnli ridge')) AS climb1,
        (SELECT climb_id FROM climb WHERE start_date = '2025-07-20' AND
         route_id = (SELECT route_id FROM route WHERE LOWER(route_name) = 'normal route')) AS climb2
)
SELECT
    inv1, climber1, climb1, '2025-07-09', '2025-07-14', 50.00, 50.00
FROM data
UNION ALL
SELECT
    inv3, climber1, climb1, '2025-07-09', '2025-07-14', 75.00, 75.00
FROM data
UNION ALL
SELECT
    inv2, climber2, climb1, '2025-07-09', '2025-07-14', 50.00, 75.00
FROM data
UNION ALL
SELECT
    inv4, climber3, climb2, '2025-07-19', '2025-07-23', 40.00, 32.00
FROM data
ON CONFLICT DO NOTHING;

-- CREATE INDEX IF NOT EXISTSes for equipment rentals
CREATE INDEX IF NOT EXISTS idx_rental_inventory ON equipment_rental (inventory_id);
CREATE INDEX IF NOT EXISTS idx_rental_climber ON equipment_rental (climber_id);
CREATE INDEX IF NOT EXISTS idx_rental_climb ON equipment_rental (climb_id);
CREATE INDEX IF NOT EXISTS idx_rental_dates ON equipment_rental (rental_start, rental_end);

-- Populate payment_rate table (requires difficulty_level to exist)
INSERT INTO payment_rate (difficulty_level_id, base_fee, effective_date, equipment_rental_surcharge,
                          guide_fee_percentage, peak_season_surcharge)
VALUES ((SELECT difficulty_level_id FROM difficulty_level WHERE LOWER(difficulty_name) = 'easy'),
        200.00, '2025-01-01', 10.00, 15.00, 50.00),
       ((SELECT difficulty_level_id FROM difficulty_level WHERE LOWER(difficulty_name) = 'moderate'),
        350.00, '2025-01-01', 15.00, 18.00, 75.00),
       ((SELECT difficulty_level_id FROM difficulty_level WHERE LOWER(difficulty_name) = 'difficult'),
        500.00, '2025-01-01', 20.00, 20.00, 100.00),
       ((SELECT difficulty_level_id FROM difficulty_level WHERE LOWER(difficulty_name) = 'very difficult'),
        750.00, '2025-01-01', 25.00, 25.00, 150.00)
ON CONFLICT ON CONSTRAINT unique_difficulty_effective_date DO NOTHING;


-- CREATE INDEX IF NOT EXISTSes for payment rates
CREATE INDEX IF NOT EXISTS idx_payment_rate_difficulty ON payment_rate (difficulty_level_id);
CREATE INDEX IF NOT EXISTS idx_payment_rate_dates ON payment_rate (effective_date, end_date);


-- Add record_ts column to all tables

-- Experience level table
ALTER TABLE experience_level DROP COLUMN IF EXISTS record_ts;
ALTER TABLE experience_level
    ADD COLUMN record_ts TIMESTAMP GENERATED ALWAYS AS (CURRENT_TIMESTAMP) STORED;
SELECT COUNT(*) AS "experience_level_rows_with_timestamp"
FROM experience_level
WHERE record_ts IS NOT NULL;

-- Peak type table
ALTER TABLE peak_type DROP COLUMN IF EXISTS record_ts;
ALTER TABLE peak_type
    ADD COLUMN record_ts TIMESTAMP GENERATED ALWAYS AS (CURRENT_TIMESTAMP) STORED;
SELECT COUNT(*) AS "peak_type_rows_with_timestamp"
FROM peak_type
WHERE record_ts IS NOT NULL;

-- Area table
ALTER TABLE area DROP COLUMN IF EXISTS record_ts;
ALTER TABLE area
    ADD COLUMN record_ts TIMESTAMP GENERATED ALWAYS AS (CURRENT_TIMESTAMP) STORED;
SELECT COUNT(*) AS "area_rows_with_timestamp"
FROM area
WHERE record_ts IS NOT NULL;

-- Climber table
ALTER TABLE climber DROP COLUMN IF EXISTS record_ts;
ALTER TABLE climber
    ADD COLUMN record_ts TIMESTAMP GENERATED ALWAYS AS (CURRENT_TIMESTAMP) STORED;
SELECT COUNT(*) AS "climber_rows_with_timestamp"
FROM climber
WHERE record_ts IS NOT NULL;

-- Mountain table
ALTER TABLE mountain DROP COLUMN IF EXISTS record_ts;
ALTER TABLE mountain
    ADD COLUMN record_ts TIMESTAMP GENERATED ALWAYS AS (CURRENT_TIMESTAMP) STORED;
SELECT COUNT(*) AS "mountain_rows_with_timestamp"
FROM mountain
WHERE record_ts IS NOT NULL;

-- Risk level table
ALTER TABLE risk_level DROP COLUMN IF EXISTS record_ts;
ALTER TABLE risk_level
    ADD COLUMN record_ts TIMESTAMP GENERATED ALWAYS AS (CURRENT_TIMESTAMP) STORED;
SELECT COUNT(*) AS "risk_level_rows_with_timestamp"
FROM risk_level
WHERE record_ts IS NOT NULL;

-- Difficulty level table
ALTER TABLE difficulty_level DROP COLUMN IF EXISTS record_ts;
ALTER TABLE difficulty_level
    ADD COLUMN record_ts TIMESTAMP GENERATED ALWAYS AS (CURRENT_TIMESTAMP) STORED;
SELECT COUNT(*) AS "difficulty_level_rows_with_timestamp"
FROM difficulty_level
WHERE record_ts IS NOT NULL;

-- Route table
ALTER TABLE route DROP COLUMN IF EXISTS record_ts;
ALTER TABLE route
    ADD COLUMN record_ts TIMESTAMP GENERATED ALWAYS AS (CURRENT_TIMESTAMP) STORED;
SELECT COUNT(*) AS "route_rows_with_timestamp"
FROM route
WHERE record_ts IS NOT NULL;

-- Base camp table
ALTER TABLE base_camp DROP COLUMN IF EXISTS record_ts;
ALTER TABLE base_camp
    ADD COLUMN record_ts TIMESTAMP GENERATED ALWAYS AS (CURRENT_TIMESTAMP) STORED;
SELECT COUNT(*) AS "base_camp_rows_with_timestamp"
FROM base_camp
WHERE record_ts IS NOT NULL;

-- Equipment category table
ALTER TABLE equipment_category DROP COLUMN IF EXISTS record_ts;
ALTER TABLE equipment_category
    ADD COLUMN record_ts TIMESTAMP GENERATED ALWAYS AS (CURRENT_TIMESTAMP) STORED;
SELECT COUNT(*) AS "equipment_category_rows_with_timestamp"
FROM equipment_category
WHERE record_ts IS NOT NULL;

-- Equipment table
ALTER TABLE equipment DROP COLUMN IF EXISTS record_ts;
ALTER TABLE equipment
    ADD COLUMN record_ts TIMESTAMP GENERATED ALWAYS AS (CURRENT_TIMESTAMP) STORED;
SELECT COUNT(*) AS "equipment_rows_with_timestamp"
FROM equipment
WHERE record_ts IS NOT NULL;

-- Equipment inventory table
ALTER TABLE equipment_inventory DROP COLUMN IF EXISTS record_ts;
ALTER TABLE equipment_inventory
    ADD COLUMN record_ts TIMESTAMP GENERATED ALWAYS AS (CURRENT_TIMESTAMP) STORED;
SELECT COUNT(*) AS "equipment_inventory_rows_with_timestamp"
FROM equipment_inventory
WHERE record_ts IS NOT NULL;

-- Equipment requirement table
ALTER TABLE equipment_requirement DROP COLUMN IF EXISTS record_ts;
ALTER TABLE equipment_requirement
    ADD COLUMN record_ts TIMESTAMP GENERATED ALWAYS AS (CURRENT_TIMESTAMP) STORED;
SELECT COUNT(*) AS "equipment_requirement_rows_with_timestamp"
FROM equipment_requirement
WHERE record_ts IS NOT NULL;

-- Insurance level table
ALTER TABLE insurance_level DROP COLUMN IF EXISTS record_ts;
ALTER TABLE insurance_level
    ADD COLUMN record_ts TIMESTAMP GENERATED ALWAYS AS (CURRENT_TIMESTAMP) STORED;
SELECT COUNT(*) AS "insurance_level_rows_with_timestamp"
FROM insurance_level
WHERE record_ts IS NOT NULL;

-- Climb table
ALTER TABLE climb DROP COLUMN IF EXISTS record_ts;
ALTER TABLE climb
    ADD COLUMN record_ts TIMESTAMP GENERATED ALWAYS AS (CURRENT_TIMESTAMP) STORED;
SELECT COUNT(*) AS "climb_rows_with_timestamp"
FROM climb
WHERE record_ts IS NOT NULL;

-- Climber insurance table
ALTER TABLE climber_insurance DROP COLUMN IF EXISTS record_ts;
ALTER TABLE climber_insurance
    ADD COLUMN record_ts TIMESTAMP GENERATED ALWAYS AS (CURRENT_TIMESTAMP) STORED;
SELECT COUNT(*) AS "climber_insurance_rows_with_timestamp"
FROM climber_insurance
WHERE record_ts IS NOT NULL;

-- Climb participant table
ALTER TABLE climb_participant DROP COLUMN IF EXISTS record_ts;
ALTER TABLE climb_participant
    ADD COLUMN record_ts TIMESTAMP GENERATED ALWAYS AS (CURRENT_TIMESTAMP) STORED;
SELECT COUNT(*) AS "climb_participant_rows_with_timestamp"
FROM climb_participant
WHERE record_ts IS NOT NULL;

-- Invoice table
ALTER TABLE invoice DROP COLUMN IF EXISTS record_ts;
ALTER TABLE invoice
    ADD COLUMN record_ts TIMESTAMP GENERATED ALWAYS AS (CURRENT_TIMESTAMP) STORED;
SELECT COUNT(*) AS "invoice_rows_with_timestamp"
FROM invoice
WHERE record_ts IS NOT NULL;

-- Payment table
ALTER TABLE payment DROP COLUMN IF EXISTS record_ts;
ALTER TABLE payment
    ADD COLUMN record_ts TIMESTAMP GENERATED ALWAYS AS ((CURRENT_TIMESTAMP) STORED;
SELECT COUNT(*) AS "payment_rows_with_timestamp"
FROM payment
WHERE record_ts IS NOT NULL;

-- Equipment rental table
ALTER TABLE equipment_rental DROP COLUMN IF EXISTS record_ts;
ALTER TABLE equipment_rental
    ADD COLUMN record_ts TIMESTAMP GENERATED ALWAYS AS (CURRENT_TIMESTAMP) STORED;
SELECT COUNT(*) AS "equipment_rental_rows_with_timestamp"
FROM equipment_rental
WHERE record_ts IS NOT NULL;

-- Payment rate table
ALTER TABLE payment_rate DROP COLUMN IF EXISTS record_ts;
ALTER TABLE payment_rate
    ADD COLUMN record_ts TIMESTAMP GENERATED ALWAYS AS (CURRENT_TIMESTAMP) STORED;
SELECT COUNT(*) AS "payment_rate_rows_with_timestamp"
FROM payment_rate
WHERE record_ts IS NOT NULL;