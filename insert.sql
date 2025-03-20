-- Sample data script for Mountaineering Club Database
-- This script adds sample data to each table

-- Clear existing data (if needed)
-- TRUNCATE TABLE payment_rate, equipment_rental, payment, invoice, climb_participant, climber_insurance,
--   climb, insurance_level, equipment_requirement, equipment_inventory, equipment, equipment_category,
--   base_camp, route, difficulty_level, risk_level, mountain, area, peak_type, climber, experience_level CASCADE;

-- Reset sequences (if needed)
-- ALTER SEQUENCE experience_level_id_seq RESTART WITH 1;
-- ALTER SEQUENCE climber_id_seq RESTART WITH 1;
-- [etc for all sequences]
\connect mountaineering_club
-- Add Experience Levels
INSERT INTO experience_level (experience_level_id, level_name, min_climbs_required, min_years_experience) VALUES
(1, 'Beginner', 0, 0),
(2, 'Novice', 3, 1),
(3, 'Intermediate', 8, 2),
(4, 'Advanced', 15, 3),
(5, 'Expert', 25, 5);

-- Add Peak Types
INSERT INTO peak_type (peak_type_id, type_name) VALUES
(1, 'Volcanic'),
(2, 'Granite'),
(3, 'Limestone'),
(4, 'Sandstone'),
(5, 'Quartzite');

-- Add Areas
INSERT INTO area (area_id, area_name, country, latitude, longitude, local_authority, permit_requirements, access_restrictions, nearest_city, distance_to_nearest_hospital_km) VALUES
(1, 'Alps', 'Switzerland', 46.5197, 8.0388, 'Swiss Alpine Club', 'None for most peaks', 'Some seasonal closures', 'Interlaken', 35.5),
(2, 'Dolomites', 'Italy', 46.4102, 11.8440, 'Italian Alpine Club', 'Required for certain peaks', 'Wildlife protection areas', 'Cortina d''Ampezzo', 28.3),
(3, 'Yosemite', 'USA', 37.8651, -119.5383, 'National Park Service', 'Climbing permits required', 'Some routes closed for nesting', 'Mariposa', 42.1),
(4, 'Himalayas', 'Nepal', 27.9881, 86.9250, 'Nepal Mountaineering Association', 'Permits required for all peaks', 'Seasonal access only', 'Kathmandu', 85.7),
(5, 'Andes', 'Argentina', -32.6532, -70.0109, 'Argentinian Mountain Association', 'Permits for major peaks', 'Winter closures', 'Mendoza', 67.2);

-- Add Climbers
INSERT INTO climber (climber_id, first_name, last_name, birth_date, address_line1, city, postal_code, country, email, phone, experience_level_id, is_active, emergency_contact_name, emergency_contact_phone, blood_type) VALUES
(1, 'John', 'Smith', '1985-05-15', '123 Alpine Way', 'Boulder', '80302', 'USA', 'john.smith@email.com', '555-1234', 4, TRUE, 'Jane Smith', '555-5678', 'O+'),
(2, 'Emma', 'Johnson', '1990-07-22', '456 Mountain View', 'Denver', '80201', 'USA', 'emma.j@email.com', '555-2345', 3, TRUE, 'Mike Johnson', '555-6789', 'A-'),
(3, 'Lukas', 'Weber', '1982-03-10', 'Bergstrasse 42', 'Zurich', '8001', 'Switzerland', 'lukas.w@email.com', '41-55-123456', 5, TRUE, 'Heidi Weber', '41-55-789012', 'B+'),
(4, 'Sofia', 'Garcia', '1988-11-18', 'Calle Montana 7', 'Barcelona', '08001', 'Spain', 'sofia.g@email.com', '34-555-4321', 2, TRUE, 'Carlos Garcia', '34-555-8765', 'AB+'),
(5, 'Akira', 'Tanaka', '1991-01-25', '3-7 Yama Street', 'Tokyo', '100-0001', 'Japan', 'akira.t@email.com', '81-3-1234-5678', 3, TRUE, 'Yuki Tanaka', '81-3-8765-4321', 'A+'),
(6, 'Maria', 'Schmidt', '1987-09-03', 'Alpenweg 12', 'Munich', '80331', 'Germany', 'maria.s@email.com', '49-89-12345678', 4, TRUE, 'Hans Schmidt', '49-89-87654321', 'O-'),
(7, 'David', 'Chen', '1993-06-12', '25 Summit Ave', 'Vancouver', 'V6B 1S5', 'Canada', 'david.c@email.com', '1-604-555-1234', 2, TRUE, 'Lisa Chen', '1-604-555-5678', 'B-'),
(8, 'Olivia', 'Martinez', '1984-04-28', '789 High Ridge', 'Seattle', '98101', 'USA', 'olivia.m@email.com', '555-3456', 3, TRUE, 'Miguel Martinez', '555-7890', 'O+'),
(9, 'James', 'Wilson', '1989-08-07', '42 Crag Lane', 'Portland', '97201', 'USA', 'james.w@email.com', '555-4567', 4, TRUE, 'Sarah Wilson', '555-8901', 'A+'),
(10, 'Elena', 'Rossi', '1986-12-14', 'Via Montagna 23', 'Milan', '20121', 'Italy', 'elena.r@email.com', '39-02-12345678', 3, TRUE, 'Marco Rossi', '39-02-87654321', 'AB-');

-- Add Mountains
INSERT INTO mountain (mountain_id, mountain_name, height_meters, area_id, mountain_range, permits_required, peak_type_id) VALUES
(1, 'Matterhorn', 4478.0, 1, 'Pennine Alps', TRUE, 2),
(2, 'Tre Cime di Lavaredo', 2999.0, 2, 'Eastern Dolomites', FALSE, 3),
(3, 'El Capitan', 2307.0, 3, 'Sierra Nevada', FALSE, 2),
(4, 'Mount Everest', 8848.86, 4, 'Mahalangur Himal', TRUE, 2),
(5, 'Aconcagua', 6960.8, 5, 'Principal Cordillera', TRUE, 1),
(6, 'Eiger', 3967.0, 1, 'Bernese Alps', TRUE, 2),
(7, 'Half Dome', 2695.0, 3, 'Sierra Nevada', TRUE, 2),
(8, 'Mont Blanc', 4809.0, 1, 'Graian Alps', TRUE, 2),
(9, 'Annapurna', 8091.0, 4, 'Annapurna Massif', TRUE, 2),
(10, 'Fitz Roy', 3405.0, 5, 'Patagonian Andes', FALSE, 2);

-- Add Risk Levels
INSERT INTO risk_level (risk_level_id, risk_name, requires_special_insurance, requires_special_training) VALUES
(1, 'Low', FALSE, FALSE),
(2, 'Moderate', FALSE, FALSE),
(3, 'Considerable', TRUE, FALSE),
(4, 'High', TRUE, TRUE),
(5, 'Extreme', TRUE, TRUE);

-- Add Difficulty Levels
INSERT INTO difficulty_level (difficulty_level_id, difficulty_name, min_experience_level_id, technical_grade, commitment_grade, altitude_grade) VALUES
(1, 'Easy', 1, 'F', 'I', 'A1'),
(2, 'Moderate', 2, 'PD', 'II', 'A2'),
(3, 'Challenging', 3, 'AD', 'III', 'A3'),
(4, 'Difficult', 4, 'D', 'IV', 'A4'),
(5, 'Very Difficult', 4, 'TD', 'V', 'A4'),
(6, 'Extremely Difficult', 5, 'ED', 'VI', 'A5'),
(7, 'Exceptionally Difficult', 5, 'ED+', 'VII', 'A5+');

-- Add Routes
INSERT INTO route (route_id, mountain_id, route_name, difficulty_level_id, length_meters, is_seasonal, best_season, avg_completion_days, technical_climbing_required, risk_level_id) VALUES
(1, 1, 'Hörnli Ridge', 4, 1200, TRUE, 'Summer', 1.5, TRUE, 3),
(2, 1, 'Zmutt Ridge', 5, 1350, TRUE, 'Summer', 2.0, TRUE, 4),
(3, 2, 'Normal Route', 3, 600, TRUE, 'Summer', 0.5, FALSE, 2),
(4, 3, 'The Nose', 6, 900, FALSE, 'Spring/Fall', 4.0, TRUE, 4),
(5, 3, 'Salathe Wall', 7, 870, FALSE, 'Spring/Fall', 5.0, TRUE, 4),
(6, 4, 'South Col Route', 5, 3500, TRUE, 'May/October', 7.0, TRUE, 5),
(7, 5, 'Normal Route', 4, 2800, TRUE, 'December-February', 12.0, FALSE, 4),
(8, 6, 'North Face', 6, 1800, TRUE, 'Summer', 3.0, TRUE, 5),
(9, 7, 'Cable Route', 3, 400, TRUE, 'Summer', 0.5, FALSE, 2),
(10, 8, 'Gouter Route', 4, 1500, TRUE, 'Summer', 2.0, TRUE, 3);

-- Add Base Camps
INSERT INTO base_camp (base_camp_id, mountain_id, camp_name, height_meters, max_capacity, has_medical_facility, latitude, longitude, has_wifi, has_electricity, has_water_source) VALUES
(1, 1, 'Hörnli Hut', 3260.0, 50, TRUE, 45.9764, 7.6586, TRUE, TRUE, TRUE),
(2, 4, 'Everest Base Camp', 5364.0, 200, TRUE, 28.0003, 86.8510, TRUE, TRUE, TRUE),
(3, 4, 'Camp 1', 6065.0, 80, FALSE, 28.0244, 86.8743, FALSE, FALSE, TRUE),
(4, 4, 'Camp 2', 6500.0, 60, FALSE, 28.0068, 86.8610, FALSE, FALSE, TRUE),
(5, 4, 'Camp 3', 7300.0, 40, FALSE, 27.9971, 86.9292, FALSE, FALSE, FALSE),
(6, 4, 'Camp 4', 8000.0, 30, FALSE, 27.9831, 86.9265, FALSE, FALSE, FALSE),
(7, 5, 'Plaza de Mulas', 4300.0, 150, TRUE, -32.6532, -70.0109, TRUE, TRUE, TRUE),
(8, 5, 'Nido de Cóndores', 5400.0, 50, FALSE, -32.6499, -70.0185, FALSE, FALSE, TRUE),
(9, 8, 'Gouter Hut', 3835.0, 60, TRUE, 45.8518, 6.8305, TRUE, TRUE, TRUE),
(10, 2, 'Auronzo Hut', 2320.0, 120, TRUE, 46.6146, 12.3026, TRUE, TRUE, TRUE);

-- Add Equipment Categories
INSERT INTO equipment_category (equipment_category_id, category_name) VALUES
(1, 'Technical Hardware'),
(2, 'Clothing'),
(3, 'Footwear'),
(4, 'Camping'),
(5, 'Safety');

-- Add Equipment
INSERT INTO equipment (equipment_id, equipment_name, weight_kg, is_technical, is_safety, is_rental_available, rental_cost_per_day, equipment_category_id, lifespan_years) VALUES
(1, 'Climbing Rope (60m)', 4.2, TRUE, TRUE, TRUE, 15.00, 1, 3),
(2, 'Crampons', 1.0, TRUE, TRUE, TRUE, 10.00, 1, 5),
(3, 'Ice Axe', 0.8, TRUE, TRUE, TRUE, 8.00, 1, 7),
(4, 'Harness', 0.5, TRUE, TRUE, TRUE, 7.00, 1, 4),
(5, 'Down Jacket', 0.9, FALSE, FALSE, TRUE, 12.00, 2, 5),
(6, 'Mountaineering Boots', 2.0, TRUE, TRUE, TRUE, 20.00, 3, 4),
(7, 'Helmet', 0.4, TRUE, TRUE, TRUE, 8.00, 5, 5),
(8, '4-Season Tent', 3.5, FALSE, FALSE, TRUE, 25.00, 4, 6),
(9, 'Sleeping Bag (-20°C)', 1.8, FALSE, FALSE, TRUE, 15.00, 4, 5),
(10, 'Avalanche Transceiver', 0.3, TRUE, TRUE, TRUE, 14.00, 5, 5);

-- Add Equipment Inventory
INSERT INTO equipment_inventory (inventory_id, equipment_id, serial_number, purchase_date, last_maintenance, condition, available, current_location_id) VALUES
(1, 1, 'R-2023-001', '2023-01-15', '2023-06-10', 'Good', TRUE, NULL),
(2, 1, 'R-2023-002', '2023-01-15', '2023-06-10', 'Good', TRUE, NULL),
(3, 2, 'C-2022-001', '2022-11-05', '2023-07-22', 'Excellent', TRUE, NULL),
(4, 2, 'C-2022-002', '2022-11-05', '2023-07-22', 'Good', TRUE, NULL),
(5, 3, 'IA-2022-001', '2022-10-20', '2023-08-15', 'Good', TRUE, NULL),
(6, 4, 'H-2023-001', '2023-02-28', '2023-08-01', 'Excellent', TRUE, NULL),
(7, 5, 'DJ-2021-001', '2021-09-15', '2023-05-10', 'Fair', TRUE, NULL),
(8, 6, 'MB-2022-001', '2022-08-10', '2023-06-15', 'Good', TRUE, NULL),
(9, 7, 'HM-2023-001', '2023-03-20', '2023-08-20', 'Excellent', TRUE, NULL),
(10, 8, 'T-2022-001', '2022-04-05', '2023-07-10', 'Good', TRUE, NULL);

-- Add Equipment Requirements
INSERT INTO equipment_requirement (requirement_id, difficulty_level_id, equipment_id, is_mandatory, quantity_required) VALUES
(1, 3, 1, TRUE, 1),
(2, 3, 4, TRUE, 1),
(3, 4, 1, TRUE, 1),
(4, 4, 2, TRUE, 1),
(5, 4, 3, TRUE, 1),
(6, 4, 4, TRUE, 1),
(7, 4, 7, TRUE, 1),
(8, 5, 1, TRUE, 1),
(9, 5, 2, TRUE, 1),
(10, 5, 3, TRUE, 1);

-- Add Insurance Levels
INSERT INTO insurance_level (insurance_level_id, insurance_name, coverage_details, min_coverage_amount, search_rescue_coverage, helicopter_evacuation_covered, medical_repatriation_covered, third_party_liability) VALUES
(1, 'Basic', 'Basic medical coverage only', 50000.00, 10000.00, FALSE, FALSE, FALSE),
(2, 'Standard', 'Standard coverage with some rescue', 100000.00, 25000.00, TRUE, FALSE, TRUE),
(3, 'Comprehensive', 'Full coverage for most climbs', 250000.00, 50000.00, TRUE, TRUE, TRUE),
(4, 'Expedition', 'High altitude coverage', 500000.00, 100000.00, TRUE, TRUE, TRUE),
(5, 'Ultimate', 'Maximum coverage for extreme climbs', 1000000.00, 250000.00, TRUE, TRUE, TRUE);

-- Add Climbs
INSERT INTO climb (climb_id, start_date, end_date, route_id, status, insurance_level_id, max_participants, total_cost, is_club_sponsored, special_requirements, registration_deadline) VALUES
(1, '2023-07-15', '2023-07-16', 1, 'Completed', 3, 8, 1200.00, TRUE, 'Experience with exposure required', '2023-06-15'),
(2, '2023-08-10', '2023-08-12', 8, 'Completed', 4, 6, 2500.00, FALSE, 'Previous North Face experience recommended', '2023-07-10'),
(3, '2023-09-05', '2023-09-09', 4, 'Cancelled', 3, 4, 3000.00, FALSE, 'Big wall experience required', '2023-08-05'),
(4, '2023-10-01', '2023-10-10', 7, 'Completed', 4, 10, 4500.00, TRUE, 'High altitude experience required', '2023-08-25'),
(5, '2023-05-01', '2023-05-14', 6, 'Completed', 5, 5, 45000.00, FALSE, 'Previous 8000m experience required', '2023-02-01'),
(6, '2024-01-10', '2024-01-25', 7, 'Planned', 4, 8, 5000.00, TRUE, 'Acclimatization required', '2023-11-15'),
(7, '2024-05-01', '2024-05-15', 6, 'Planned', 5, 6, 48000.00, FALSE, 'Previous 8000m experience required', '2024-01-15'),
(8, '2024-07-20', '2024-07-21', 9, 'Planned', 2, 12, 800.00, TRUE, 'Beginner-friendly route', '2024-06-20'),
(9, '2024-08-05', '2024-08-07', 10, 'Planned', 3, 10, 1800.00, TRUE, 'Good fitness level required', '2024-07-05'),
(10, '2024-09-15', '2024-09-16', 3, 'Planned', 2, 8, 1000.00, TRUE, 'Scenic route for intermediate climbers', '2024-08-15');

-- Add Climber Insurance
INSERT INTO climber_insurance (climber_insurance_id, climber_id, policy_number, start_date, end_date, coverage_amount, verified) VALUES
(1, 1, 'INS-2023-001', '2023-01-01', '2023-12-31', 300000.00, TRUE),
(2, 2, 'INS-2023-002', '2023-01-15', '2023-12-31', 150000.00, TRUE),
(3, 3, 'INS-2023-003', '2023-02-01', '2024-01-31', 500000.00, TRUE),
(4, 4, 'INS-2023-004', '2023-01-01', '2023-12-31', 100000.00, TRUE),
(5, 5, 'INS-2023-005', '2023-03-01', '2024-02-29', 250000.00, TRUE),
(6, 6, 'INS-2023-006', '2023-01-01', '2023-12-31', 300000.00, TRUE),
(7, 7, 'INS-2023-007', '2023-04-01', '2024-03-31', 150000.00, TRUE),
(8, 8, 'INS-2023-008', '2023-01-01', '2023-12-31', 200000.00, TRUE),
(9, 9, 'INS-2023-009', '2023-02-15', '2024-02-14', 350000.00, TRUE),
(10, 10, 'INS-2023-010', '2023-01-01', '2023-12-31', 250000.00, TRUE);

-- Add Climb Participants
INSERT INTO climb_participant (participant_id, climb_id, climber_id, waiver_signed, signed_date, has_required_insurance, completed_climb, attendance_confirmed, gear_checked) VALUES
(1, 1, 1, TRUE, '2023-06-20', TRUE, TRUE, TRUE, TRUE),
(2, 1, 3, TRUE, '2023-06-18', TRUE, TRUE, TRUE, TRUE),
(3, 1, 6, TRUE, '2023-06-22', TRUE, TRUE, TRUE, TRUE),
(4, 2, 3, TRUE, '2023-07-15', TRUE, TRUE, TRUE, TRUE),
(5, 2, 9, TRUE, '2023-07-16', TRUE, TRUE, TRUE, TRUE),
(6, 4, 3, TRUE, '2023-09-10', TRUE, TRUE, TRUE, TRUE),
(7, 4, 6, TRUE, '2023-09-12', TRUE, TRUE, TRUE, TRUE),
(8, 4, 9, TRUE, '2023-09-08', TRUE, TRUE, TRUE, TRUE),
(9, 5, 3, TRUE, '2023-04-01', TRUE, TRUE, TRUE, TRUE),
(10, 5, 6, TRUE, '2023-04-02', TRUE, TRUE, TRUE, TRUE);

-- Add Invoices
INSERT INTO invoice (invoice_id, climb_id, climber_id, invoice_date, due_date, total_amount, status, tax_rate, tax_amount, discount_amount) VALUES
(1, 1, 1, '2023-05-20', '2023-06-10', 1200.00, 'Paid', 8.00, 96.00, 0.00),
(2, 1, 3, '2023-05-20', '2023-06-10', 1200.00, 'Paid', 8.00, 96.00, 0.00),
(3, 1, 6, '2023-05-20', '2023-06-10', 1200.00, 'Paid', 8.00, 96.00, 0.00),
(4, 2, 3, '2023-06-15', '2023-07-15', 2500.00, 'Paid', 8.00, 200.00, 0.00),
(5, 2, 9, '2023-06-15', '2023-07-15', 2500.00, 'Paid', 8.00, 200.00, 0.00),
(6, 4, 3, '2023-08-10', '2023-09-10', 4500.00, 'Paid', 8.00, 360.00, 450.00),
(7, 4, 6, '2023-08-10', '2023-09-10', 4500.00, 'Paid', 8.00, 360.00, 0.00),
(8, 4, 9, '2023-08-10', '2023-09-10', 4500.00, 'Paid', 8.00, 360.00, 0.00),
(9, 5, 3, '2023-01-15', '2023-02-15', 45000.00, 'Paid', 8.00, 3600.00, 2000.00),
(10, 5, 6, '2023-01-15', '2023-02-15', 45000.00, 'Paid', 8.00, 3600.00, 0.00);

-- Add Payments
INSERT INTO payment (payment_id, climb_id, climber_id, amount, payment_date, payment_method, payment_status, transaction_ref, deposit_amount, deposit_date, invoice_id) VALUES
(1, 1, 1, 1200.00, '2023-06-05', 'Credit Card', 'Completed', 'TXN-2023-001', 500.00, '2023-05-25', 1),
(2, 1, 3, 1200.00, '2023-06-01', 'Bank Transfer', 'Completed', 'TXN-2023-002', 500.00, '2023-05-22', 2),
(3, 1, 6, 1200.00, '2023-06-08', 'Credit Card', 'Completed', 'TXN-2023-003', 500.00, '2023-05-24', 3),
(4, 2, 3, 2500.00, '2023-07-10', 'Credit Card', 'Completed', 'TXN-2023-004', 1000.00, '2023-06-20', 4),
(5, 2, 9, 2500.00, '2023-07-12', 'PayPal', 'Completed', 'TXN-2023-005', 1000.00, '2023-06-25', 5),
(6, 4, 3, 4050.00, '2023-09-05', 'Bank Transfer', 'Completed', 'TXN-2023-006', 2000.00, '2023-08-15', 6),
(7, 4, 6, 4500.00, '2023-09-01', 'Credit Card', 'Completed', 'TXN-2023-007', 2000.00, '2023-08-12', 7),
(8, 4, 9, 4500.00, '2023-09-08', 'PayPal', 'Completed', 'TXN-2023-008', 2000.00, '2023-08-18', 8),
(9, 5, 3, 43000.00, '2023-02-10', 'Bank Transfer', 'Completed', 'TXN-2023-009', 15000.00, '2023-01-20', 9),
(10, 5, 6, 45000.00, '2023-02-12', 'Credit Card', 'Completed', 'TXN-2023-010', 15000.00, '2023-01-25', 10);

-- Add Equipment Rentals
INSERT INTO equipment_rental (rental_id, inventory_id, climber_id, climb_id, rental_start, rental_end, deposit_amount, rental_fee, condition_on_return, returned) VALUES
(1, 2, 1, 1, '2023-07-14', '2023-07-17', 200.00, 45.00, 'Good', TRUE),
(2, 3, 1, 1, '2023-07-14', '2023-07-17', 150.00, 30.00, 'Good', TRUE),
(3, 4, 3, 2, '2023-08-09', '2023-08-13', 150.00, 40.00, 'Good', TRUE),
(4, 5, 3, 2, '2023-08-09', '2023-08-13', 120.00, 32.00, 'Good', TRUE),
(5, 6, 9, 2, '2023-08-09', '2023-08-13', 100.00, 28.00, 'Excellent', TRUE),
(6, 8, 3, 4, '2023-09-30', '2023-10-11', 300.00, 275.00, 'Good', TRUE),
(7, 9, 3, 4, '2023-09-30', '2023-10-11', 100.00, 88.00, 'Good', TRUE),
(8, 10, 6, 4, '2023-09-30', '2023-10-11', 300.00, 275.00, 'Good', TRUE),
(9, 1, 9, 4, '2023-09-30', '2023-10-11', 200.00, 165.00, 'Fair', TRUE),
(10, 7, 9, 4, '2023-09-30', '2023-10-11', 150.00, 132.00, 'Good', TRUE);

-- Add Payment Rates
INSERT INTO payment_rate (rate_id, difficulty_level_id, base_fee, effective_date, end_date, equipment_rental_surcharge, guide_fee_percentage, peak_season_surcharge, group_discount_threshold, group_discount_percentage) VALUES
(1, 1, 300.00, '2023-01-01', '2023-12-31', 10.00, 15.00, 50.00, 6, 10.00),
(2, 2, 600.00, '2023-01-01', '2023-12-31', 12.00, 15.00, 75.00, 6, 10.00),
(3, 3, 1000.00, '2023-01-01', '2023-12-31', 15.00, 18.00, 100.00, 6, 10.00),
(4, 4, 1500.00, '2023-01-01', '2023-12-31', 18.00, 20.00, 150.00, 5, 10.00),
(5, 5, 2500.00, '2023-01-01', '2023-12-30',19.00, 20.00, 150.00, 6, 10.00);