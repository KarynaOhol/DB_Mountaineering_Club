-- Create Mountaineering Club Database in PostgreSQL

---CREATE DATABASE mountaineering_club;
\connect mountaineering_club

-- Create sequences for auto-incrementing IDs
CREATE SEQUENCE experience_level_id_seq;
CREATE SEQUENCE climber_id_seq;
CREATE SEQUENCE peak_type_id_seq;
CREATE SEQUENCE area_id_seq;
CREATE SEQUENCE mountain_id_seq;
CREATE SEQUENCE risk_level_id_seq;
CREATE SEQUENCE difficulty_level_id_seq;
CREATE SEQUENCE base_camp_id_seq;
CREATE SEQUENCE equipment_category_id_seq;
CREATE SEQUENCE equipment_id_seq;
CREATE SEQUENCE inventory_id_seq;
CREATE SEQUENCE requirement_id_seq;
CREATE SEQUENCE insurance_level_id_seq;
CREATE SEQUENCE climb_id_seq;
CREATE SEQUENCE climber_insurance_id_seq;
CREATE SEQUENCE participant_id_seq;
CREATE SEQUENCE invoice_id_seq;
CREATE SEQUENCE payment_id_seq;
CREATE SEQUENCE rental_id_seq;
CREATE SEQUENCE rate_id_seq;

-- Experience Level table
CREATE TABLE experience_level (
    experience_level_id INTEGER PRIMARY KEY DEFAULT nextval('experience_level_id_seq'),
    level_name VARCHAR(50) NOT NULL UNIQUE,
    min_climbs_required INTEGER NOT NULL DEFAULT 0,
    min_years_experience INTEGER NOT NULL DEFAULT 0
);

-- Peak Type table
CREATE TABLE peak_type (
    peak_type_id INTEGER PRIMARY KEY DEFAULT nextval('peak_type_id_seq'),
    type_name VARCHAR(50) NOT NULL UNIQUE
);

-- Area table
CREATE TABLE area (
    area_id INTEGER PRIMARY KEY DEFAULT nextval('area_id_seq'),
    area_name VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    latitude DECIMAL(10,6) NOT NULL,
    longitude DECIMAL(10,6) NOT NULL,
    local_authority VARCHAR(100),
    permit_requirements VARCHAR(250),
    access_restrictions VARCHAR(250),
    nearest_city VARCHAR(100),
    distance_to_nearest_hospital_km DECIMAL(10,2),
    CONSTRAINT unique_area_country UNIQUE (area_name, country)
);

-- Create index on country for faster filtering by country
CREATE INDEX idx_area_country ON area(country);

-- Climber table
CREATE TABLE climber (
    climber_id INTEGER PRIMARY KEY DEFAULT nextval('climber_id_seq'),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    birth_date DATE NOT NULL,
    address_line1 VARCHAR(200) NOT NULL,
    city VARCHAR(100) NOT NULL,
    postal_code VARCHAR(50) NOT NULL,
    country VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(50) NOT NULL,
    experience_level_id INTEGER NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    emergency_contact_name VARCHAR(100) NOT NULL,
    emergency_contact_phone VARCHAR(50) NOT NULL,
    blood_type VARCHAR(50),
    FOREIGN KEY (experience_level_id) REFERENCES experience_level(experience_level_id)
);

-- Create index on experience_level_id for faster lookups
CREATE INDEX idx_climber_experience_level ON climber(experience_level_id);

-- Mountain table
CREATE TABLE mountain (
    mountain_id INTEGER PRIMARY KEY DEFAULT nextval('mountain_id_seq'),
    mountain_name VARCHAR(100) NOT NULL,
    height_meters DECIMAL(10,2) NOT NULL,
    area_id INTEGER NOT NULL,
    mountain_range VARCHAR(50),
    climbing_season DATE,
    permits_required BOOLEAN DEFAULT FALSE,
    peak_type_id INTEGER,
    FOREIGN KEY (area_id) REFERENCES area(area_id),
    FOREIGN KEY (peak_type_id) REFERENCES peak_type(peak_type_id),
    CONSTRAINT unique_mountain_in_area UNIQUE (mountain_name, area_id)
);

-- Create indexes for mountain
CREATE INDEX idx_mountain_area ON mountain(area_id);
CREATE INDEX idx_mountain_peak_type ON mountain(peak_type_id);
CREATE INDEX idx_mountain_height ON mountain(height_meters);

-- Risk Level table
CREATE TABLE risk_level (
    risk_level_id INTEGER PRIMARY KEY DEFAULT nextval('risk_level_id_seq'),
    risk_name VARCHAR(50) NOT NULL UNIQUE,
    requires_special_insurance BOOLEAN DEFAULT FALSE,
    requires_special_training BOOLEAN DEFAULT FALSE
);

-- Difficulty Level table
CREATE TABLE difficulty_level (
    difficulty_level_id INTEGER PRIMARY KEY DEFAULT nextval('difficulty_level_id_seq'),
    difficulty_name VARCHAR(50) NOT NULL UNIQUE,
    min_experience_level_id INTEGER NOT NULL,
    technical_grade VARCHAR(50),
    commitment_grade VARCHAR(50),
    altitude_grade VARCHAR(50),
    FOREIGN KEY (min_experience_level_id) REFERENCES experience_level(experience_level_id)
);

-- Create index on min_experience_level_id for faster joins
CREATE INDEX idx_difficulty_experience ON difficulty_level(min_experience_level_id);

-- Route table
CREATE TABLE route (
    route_id INTEGER PRIMARY KEY DEFAULT nextval('difficulty_level_id_seq'),
    mountain_id INTEGER NOT NULL,
    route_name VARCHAR(100) NOT NULL,
    difficulty_level_id INTEGER NOT NULL,
    length_meters DECIMAL(10,2) NOT NULL,
    is_seasonal BOOLEAN DEFAULT FALSE,
    best_season VARCHAR(50),
    avg_completion_days DECIMAL(5,2),
    technical_climbing_required BOOLEAN DEFAULT FALSE,
    risk_level_id INTEGER NOT NULL,
    FOREIGN KEY (mountain_id) REFERENCES mountain(mountain_id),
    FOREIGN KEY (difficulty_level_id) REFERENCES difficulty_level(difficulty_level_id),
    FOREIGN KEY (risk_level_id) REFERENCES risk_level(risk_level_id),
    CONSTRAINT unique_route_on_mountain UNIQUE (mountain_id, route_name)
);

-- Create indexes for routes
CREATE INDEX idx_route_mountain ON route(mountain_id);
CREATE INDEX idx_route_difficulty ON route(difficulty_level_id);
CREATE INDEX idx_route_risk ON route(risk_level_id);

-- Base Camp table
CREATE TABLE base_camp (
    base_camp_id INTEGER PRIMARY KEY DEFAULT nextval('base_camp_id_seq'),
    mountain_id INTEGER NOT NULL,
    camp_name VARCHAR(100) NOT NULL,
    height_meters DECIMAL(10,2) NOT NULL,
    max_capacity INTEGER DEFAULT 0,
    has_medical_facility BOOLEAN DEFAULT FALSE,
    latitude DECIMAL(10,6) NOT NULL,
    longitude DECIMAL(10,6) NOT NULL,
    has_wifi BOOLEAN DEFAULT FALSE,
    has_electricity BOOLEAN DEFAULT FALSE,
    has_water_source BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (mountain_id) REFERENCES mountain(mountain_id),
    CONSTRAINT unique_camp_on_mountain UNIQUE (mountain_id, camp_name)
);

-- Create indexes for base camps
CREATE INDEX idx_basecamp_mountain ON base_camp(mountain_id);
CREATE INDEX idx_basecamp_height ON base_camp(height_meters);

-- Equipment Category table
CREATE TABLE equipment_category (
    equipment_category_id INTEGER PRIMARY KEY DEFAULT nextval('equipment_category_id_seq'),
    category_name VARCHAR(50) NOT NULL UNIQUE
);

-- Equipment table
CREATE TABLE equipment (
    equipment_id INTEGER PRIMARY KEY DEFAULT nextval('equipment_id_seq'),
    equipment_name VARCHAR(100) NOT NULL,
    weight_kg DECIMAL(6,2),
    is_technical BOOLEAN DEFAULT FALSE,
    is_safety BOOLEAN DEFAULT FALSE,
    is_rental_available BOOLEAN DEFAULT FALSE,
    rental_cost_per_day DECIMAL(10,2),
    equipment_category_id INTEGER NOT NULL,
    lifespan_years INTEGER,
    FOREIGN KEY (equipment_category_id) REFERENCES equipment_category(equipment_category_id),
    CONSTRAINT unique_equipment_in_category UNIQUE (equipment_name, equipment_category_id)
);

-- Create index for equipment category
CREATE INDEX idx_equipment_category ON equipment(equipment_category_id);

-- Equipment Inventory table
CREATE TABLE equipment_inventory (
    inventory_id INTEGER PRIMARY KEY DEFAULT nextval('inventory_id_seq'),
    equipment_id INTEGER NOT NULL,
    serial_number VARCHAR(50) NOT NULL,
    purchase_date DATE NOT NULL,
    last_maintenance DATE,
    condition VARCHAR(50) NOT NULL DEFAULT 'New',
    available BOOLEAN DEFAULT TRUE,
    current_location_id INTEGER,
    FOREIGN KEY (equipment_id) REFERENCES equipment(equipment_id),
    CONSTRAINT unique_equipment_serial UNIQUE (equipment_id, serial_number)
);

-- Create indexes for inventory
CREATE INDEX idx_inventory_equipment ON equipment_inventory(equipment_id);
CREATE INDEX idx_inventory_available ON equipment_inventory(available);

-- Equipment Requirement table
CREATE TABLE equipment_requirement (
    requirement_id INTEGER PRIMARY KEY DEFAULT nextval('requirement_id_seq'),
    difficulty_level_id INTEGER NOT NULL,
    equipment_id INTEGER NOT NULL,
    is_mandatory BOOLEAN DEFAULT TRUE,
    quantity_required INTEGER DEFAULT 1,
    FOREIGN KEY (difficulty_level_id) REFERENCES difficulty_level(difficulty_level_id),
    FOREIGN KEY (equipment_id) REFERENCES equipment(equipment_id),
    CONSTRAINT unique_equipment_requirement UNIQUE (difficulty_level_id, equipment_id)
);

-- Create indexes for equipment requirements
CREATE INDEX idx_requirement_difficulty ON equipment_requirement(difficulty_level_id);
CREATE INDEX idx_requirement_equipment ON equipment_requirement(equipment_id);

-- Insurance Level table
CREATE TABLE insurance_level (
    insurance_level_id INTEGER PRIMARY KEY DEFAULT nextval('insurance_level_id_seq'),
    insurance_name VARCHAR(100) NOT NULL UNIQUE,
    coverage_details VARCHAR(250),
    min_coverage_amount DECIMAL(12,2) NOT NULL,
    search_rescue_coverage DECIMAL(12,2),
    helicopter_evacuation_covered BOOLEAN DEFAULT FALSE,
    medical_repatriation_covered BOOLEAN DEFAULT FALSE,
    third_party_liability BOOLEAN DEFAULT FALSE
);

-- Climb table
CREATE TABLE climb (
    climb_id INTEGER PRIMARY KEY DEFAULT nextval('climb_id_seq'),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    route_id INTEGER NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'Planned',
    insurance_level_id INTEGER NOT NULL,
    max_participants INTEGER DEFAULT 10,
    total_cost DECIMAL(12,2) NOT NULL,
    is_club_sponsored BOOLEAN DEFAULT FALSE,
    special_requirements VARCHAR(250),
    registration_deadline DATE NOT NULL,
    briefing_datetime TIMESTAMP,
    cancellation_policy VARCHAR(250),
    FOREIGN KEY (route_id) REFERENCES route(route_id),
    FOREIGN KEY (insurance_level_id) REFERENCES insurance_level(insurance_level_id),
    CONSTRAINT check_climb_dates CHECK (end_date >= start_date),
    CONSTRAINT check_registration_deadline CHECK (registration_deadline <= start_date)
);

-- Create indexes for climbs
CREATE INDEX idx_climb_route ON climb(route_id);
CREATE INDEX idx_climb_dates ON climb(start_date, end_date);
CREATE INDEX idx_climb_status ON climb(status);
CREATE INDEX idx_climb_insurance ON climb(insurance_level_id);

-- Climber Insurance table
CREATE TABLE climber_insurance (
    climber_insurance_id INTEGER PRIMARY KEY DEFAULT nextval('climber_insurance_id_seq'),
    climber_id INTEGER NOT NULL,
    policy_number VARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    coverage_amount DECIMAL(12,2) NOT NULL,
    verified BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (climber_id) REFERENCES climber(climber_id),
    CONSTRAINT unique_climber_policy UNIQUE (climber_id, policy_number),
    CONSTRAINT check_insurance_dates CHECK (end_date > start_date)
);

-- Create indexes for climber insurance
CREATE INDEX idx_climber_insurance_climber ON climber_insurance(climber_id);
CREATE INDEX idx_climber_insurance_dates ON climber_insurance(end_date);

-- Climb Participant table
CREATE TABLE climb_participant (
    participant_id INTEGER PRIMARY KEY DEFAULT nextval('participant_id_seq'),
    climb_id INTEGER NOT NULL,
    climber_id INTEGER NOT NULL,
    waiver_signed BOOLEAN DEFAULT FALSE,
    signed_date DATE,
    has_required_insurance BOOLEAN DEFAULT FALSE,
    completed_climb BOOLEAN DEFAULT FALSE,
    attendance_confirmed BOOLEAN DEFAULT FALSE,
    gear_checked BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (climb_id) REFERENCES climb(climb_id),
    FOREIGN KEY (climber_id) REFERENCES climber(climber_id),
    CONSTRAINT unique_climber_per_climb UNIQUE (climb_id, climber_id)
);

-- Create indexes for climb participants
CREATE INDEX idx_participant_climb ON climb_participant(climb_id);
CREATE INDEX idx_participant_climber ON climb_participant(climber_id);

-- Invoice table
CREATE TABLE invoice (
    invoice_id INTEGER PRIMARY KEY DEFAULT nextval('invoice_id_seq'),
    climb_id INTEGER NOT NULL,
    climber_id INTEGER NOT NULL,
    invoice_date DATE NOT NULL,
    due_date DATE NOT NULL,
    total_amount DECIMAL(12,2) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'Unpaid',
    tax_rate DECIMAL(5,2) DEFAULT 0,
    tax_amount DECIMAL(12,2) DEFAULT 0,
    discount_amount DECIMAL(12,2) DEFAULT 0,
    FOREIGN KEY (climb_id) REFERENCES climb(climb_id),
    FOREIGN KEY (climber_id) REFERENCES climber(climber_id),
    CONSTRAINT check_invoice_dates CHECK (due_date >= invoice_date)
);

-- Create indexes for invoices
CREATE INDEX idx_invoice_climb ON invoice(climb_id);
CREATE INDEX idx_invoice_climber ON invoice(climber_id);
CREATE INDEX idx_invoice_status ON invoice(status);
CREATE INDEX idx_invoice_due_date ON invoice(due_date);

-- Payment table
CREATE TABLE payment (
    payment_id INTEGER PRIMARY KEY DEFAULT nextval('payment_id_seq'),
    climb_id INTEGER NOT NULL,
    climber_id INTEGER NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    payment_date DATE NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    payment_status VARCHAR(50) NOT NULL DEFAULT 'Pending',
    transaction_ref VARCHAR(100) UNIQUE,
    deposit_amount DECIMAL(12,2) DEFAULT 0,
    deposit_date DATE,
    invoice_id INTEGER,
    FOREIGN KEY (climb_id) REFERENCES climb(climb_id),
    FOREIGN KEY (climber_id) REFERENCES climber(climber_id),
    FOREIGN KEY (invoice_id) REFERENCES invoice(invoice_id)
);

-- Create indexes for payments
CREATE INDEX idx_payment_climb ON payment(climb_id);
CREATE INDEX idx_payment_climber ON payment(climber_id);
CREATE INDEX idx_payment_status ON payment(payment_status);
CREATE INDEX idx_payment_invoice ON payment(invoice_id);

-- Equipment Rental table
CREATE TABLE equipment_rental (
    rental_id INTEGER PRIMARY KEY DEFAULT nextval('rental_id_seq'),
    inventory_id INTEGER NOT NULL,
    climber_id INTEGER NOT NULL,
    climb_id INTEGER NOT NULL,
    rental_start DATE NOT NULL,
    rental_end DATE NOT NULL,
    deposit_amount DECIMAL(12,2) NOT NULL,
    rental_fee DECIMAL(12,2) NOT NULL,
    condition_on_return VARCHAR(50),
    returned BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (inventory_id) REFERENCES equipment_inventory(inventory_id),
    FOREIGN KEY (climber_id) REFERENCES climber(climber_id),
    FOREIGN KEY (climb_id) REFERENCES climb(climb_id),
    CONSTRAINT check_rental_dates CHECK (rental_end >= rental_start)
);

-- Create indexes for equipment rentals
CREATE INDEX idx_rental_inventory ON equipment_rental(inventory_id);
CREATE INDEX idx_rental_climber ON equipment_rental(climber_id);
CREATE INDEX idx_rental_climb ON equipment_rental(climb_id);
CREATE INDEX idx_rental_dates ON equipment_rental(rental_start, rental_end);

-- Payment Rate table
CREATE TABLE payment_rate (
    rate_id INTEGER PRIMARY KEY DEFAULT nextval('rate_id_seq'),
    difficulty_level_id INTEGER NOT NULL,
    base_fee DECIMAL(12,2) NOT NULL,
    effective_date DATE NOT NULL,
    end_date DATE,
    equipment_rental_surcharge DECIMAL(5,2) DEFAULT 0,
    guide_fee_percentage DECIMAL(5,2) DEFAULT 0,
    peak_season_surcharge DECIMAL(12,2) DEFAULT 0,
    group_discount_threshold DECIMAL(12,2),
    group_discount_percentage DECIMAL(5,2) DEFAULT 0,
    FOREIGN KEY (difficulty_level_id) REFERENCES difficulty_level(difficulty_level_id),
    CONSTRAINT unique_difficulty_effective_date UNIQUE (difficulty_level_id, effective_date),
    CONSTRAINT check_payment_rate_dates CHECK (end_date IS NULL OR end_date > effective_date)
);

-- Create indexes for payment rates
CREATE INDEX idx_payment_rate_difficulty ON payment_rate(difficulty_level_id);
CREATE INDEX idx_payment_rate_dates ON payment_rate(effective_date, end_date);

-- Add comment to the database
COMMENT ON DATABASE mountaineering_club IS 'Database for tracking mountaineering club activities, climbs, and equipment';

-- Add comments to tables
COMMENT ON TABLE climber IS 'Stores information about mountaineering club members';
COMMENT ON TABLE experience_level IS 'Classifies climbers by experience level';
COMMENT ON TABLE mountain IS 'Information about mountains available for climbing';
COMMENT ON TABLE area IS 'Geographic areas where mountains are located';
COMMENT ON TABLE peak_type IS 'Classification of mountain peak types';
COMMENT ON TABLE route IS 'Specific climbing routes on mountains';
COMMENT ON TABLE difficulty_level IS 'Classification of route difficulty';
COMMENT ON TABLE risk_level IS 'Risk categorization for routes';
COMMENT ON TABLE base_camp IS 'Base camp information for mountains';
COMMENT ON TABLE equipment IS 'Climbing equipment types';
COMMENT ON TABLE equipment_category IS 'Categories of climbing equipment';
COMMENT ON TABLE equipment_inventory IS 'Inventory of specific equipment items';
COMMENT ON TABLE equipment_requirement IS 'Required equipment for specific difficulty levels';
COMMENT ON TABLE equipment_rental IS 'Records of equipment rentals';
COMMENT ON TABLE insurance_level IS 'Different levels of required insurance coverage';
COMMENT ON TABLE climber_insurance IS 'Insurance policies held by climbers';
COMMENT ON TABLE climb IS 'Scheduled or completed climbing expeditions';
COMMENT ON TABLE climb_participant IS 'Participants in specific climbs';
COMMENT ON TABLE payment IS 'Payment records';
COMMENT ON TABLE invoice IS 'Invoices issued to climbers';
COMMENT ON TABLE payment_rate IS 'Fee structure based on difficulty levels';