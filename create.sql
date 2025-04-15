-- Mountaineering Club Database Creation Script
-- This script creates a physical database for a mountaineering club in PostgreSQL

-- Create database
DROP DATABASE IF EXISTS mountaineering_club;
CREATE DATABASE mountaineering_club;

-- Connect to the database
\c mountaineering_club

-- Create schema
CREATE SCHEMA IF NOT EXISTS mountaineering;

-- Set search path
SET search_path TO mountaineering, public;

-- Drop existing tables in the correct order (to avoid foreign key constraint issues)
DROP TABLE IF EXISTS payment_rate CASCADE;
DROP TABLE IF EXISTS equipment_rental CASCADE;
DROP TABLE IF EXISTS payment CASCADE;
DROP TABLE IF EXISTS invoice CASCADE;
DROP TABLE IF EXISTS climb_participant CASCADE;
DROP TABLE IF EXISTS climber_insurance CASCADE;
DROP TABLE IF EXISTS climb CASCADE;
DROP TABLE IF EXISTS insurance_level CASCADE;
DROP TABLE IF EXISTS equipment_requirement CASCADE;
DROP TABLE IF EXISTS equipment_inventory CASCADE;
DROP TABLE IF EXISTS equipment CASCADE;
DROP TABLE IF EXISTS equipment_category CASCADE;
DROP TABLE IF EXISTS base_camp CASCADE;
DROP TABLE IF EXISTS route CASCADE;
DROP TABLE IF EXISTS difficulty_level CASCADE;
DROP TABLE IF EXISTS risk_level CASCADE;
DROP TABLE IF EXISTS mountain CASCADE;
DROP TABLE IF EXISTS climber CASCADE;
DROP TABLE IF EXISTS area CASCADE;
DROP TABLE IF EXISTS peak_type CASCADE;
DROP TABLE IF EXISTS experience_level CASCADE;

-- Drop existing sequences
DROP SEQUENCE IF EXISTS experience_level_id_seq CASCADE;
DROP SEQUENCE IF EXISTS climber_id_seq CASCADE;
DROP SEQUENCE IF EXISTS peak_type_id_seq CASCADE;
DROP SEQUENCE IF EXISTS area_id_seq CASCADE;
DROP SEQUENCE IF EXISTS mountain_id_seq CASCADE;
DROP SEQUENCE IF EXISTS risk_level_id_seq CASCADE;
DROP SEQUENCE IF EXISTS difficulty_level_id_seq CASCADE;
DROP SEQUENCE IF EXISTS route_id_seq CASCADE;
DROP SEQUENCE IF EXISTS base_camp_id_seq CASCADE;
DROP SEQUENCE IF EXISTS equipment_category_id_seq CASCADE;
DROP SEQUENCE IF EXISTS equipment_id_seq CASCADE;
DROP SEQUENCE IF EXISTS inventory_id_seq CASCADE;
DROP SEQUENCE IF EXISTS requirement_id_seq CASCADE;
DROP SEQUENCE IF EXISTS insurance_level_id_seq CASCADE;
DROP SEQUENCE IF EXISTS climb_id_seq CASCADE;
DROP SEQUENCE IF EXISTS climber_insurance_id_seq CASCADE;
DROP SEQUENCE IF EXISTS participant_id_seq CASCADE;
DROP SEQUENCE IF EXISTS invoice_id_seq CASCADE;
DROP SEQUENCE IF EXISTS payment_id_seq CASCADE;
DROP SEQUENCE IF EXISTS rental_id_seq CASCADE;
DROP SEQUENCE IF EXISTS rate_id_seq CASCADE;

-- Create sequences for auto-incrementing IDs
CREATE SEQUENCE experience_level_id_seq;
CREATE SEQUENCE climber_id_seq;
CREATE SEQUENCE peak_type_id_seq;
CREATE SEQUENCE area_id_seq;
CREATE SEQUENCE mountain_id_seq;
CREATE SEQUENCE risk_level_id_seq;
CREATE SEQUENCE difficulty_level_id_seq;
CREATE SEQUENCE route_id_seq;
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

-- Add comments to the database
COMMENT ON DATABASE mountaineering_club IS 'Database for tracking mountaineering club activities, climbs, and equipment';

-- Experience Level table
CREATE TABLE IF NOT EXISTS experience_level
(
    experience_level_id  INTEGER PRIMARY KEY  DEFAULT nextval('experience_level_id_seq'),
    level_name           VARCHAR(50) NOT NULL UNIQUE,
    min_climbs_required  INTEGER     NOT NULL DEFAULT 0 CHECK (min_climbs_required >= 0),
    min_years_experience INTEGER     NOT NULL DEFAULT 0 CHECK (min_years_experience >= 0)
);

-- Peak Type table
CREATE TABLE IF NOT EXISTS peak_type
(
    peak_type_id INTEGER PRIMARY KEY DEFAULT nextval('peak_type_id_seq'),
    type_name    VARCHAR(50) NOT NULL UNIQUE
);

-- Area table
CREATE TABLE IF NOT EXISTS area
(
    area_id                         INTEGER PRIMARY KEY DEFAULT nextval('area_id_seq'),
    area_name                       VARCHAR(100)   NOT NULL,
    country                         VARCHAR(100)   NOT NULL,
    latitude                        DECIMAL(10, 6) NOT NULL CHECK (latitude BETWEEN -90 AND 90),
    longitude                       DECIMAL(10, 6) NOT NULL CHECK (longitude BETWEEN -180 AND 180),
    local_authority                 VARCHAR(100),
    permit_requirements             VARCHAR(250),
    access_restrictions             VARCHAR(250),
    nearest_city                    VARCHAR(100),
    distance_to_nearest_hospital_km DECIMAL(10, 2) CHECK (distance_to_nearest_hospital_km > 0),
    CONSTRAINT unique_area_country UNIQUE (area_name, country)
);


-- Climber table
CREATE TABLE IF NOT EXISTS climber
(
    climber_id              INTEGER PRIMARY KEY DEFAULT nextval('climber_id_seq'),
    first_name              VARCHAR(100) NOT NULL,
    last_name               VARCHAR(100) NOT NULL,
    birth_date              DATE         NOT NULL CHECK (birth_date > '2000-01-01'),                              -- CONSTRAINT #1: Date after Jan 1, 2000
    address_line1           VARCHAR(200) NOT NULL,
    city                    VARCHAR(100) NOT NULL,
    postal_code             VARCHAR(50)  NOT NULL,
    country                 VARCHAR(50)  NOT NULL,
    email                   VARCHAR(100) NOT NULL UNIQUE,
    phone                   VARCHAR(50)  NOT NULL,
    experience_level_id     INTEGER      NOT NULL,
    is_active               BOOLEAN             DEFAULT TRUE,
    emergency_contact_name  VARCHAR(100) NOT NULL,
    emergency_contact_phone VARCHAR(50)  NOT NULL,
    blood_type              VARCHAR(50) CHECK (blood_type IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')), -- CONSTRAINT #3: Specific values only
    FOREIGN KEY (experience_level_id) REFERENCES experience_level (experience_level_id)
);


-- Mountain table
CREATE TABLE IF NOT EXISTS mountain
(
    mountain_id           INTEGER PRIMARY KEY DEFAULT nextval('mountain_id_seq'),
    mountain_name         VARCHAR(100)   NOT NULL,
    height_meters         DECIMAL(10, 2) NOT NULL CHECK (height_meters > 0),             -- CONSTRAINT #2: Positive values only
    area_id               INTEGER        NOT NULL,
    mountain_range        VARCHAR(50),
    climbing_season_start DATE,
    climbing_season_end   DATE,
    permits_required      BOOLEAN             DEFAULT FALSE,
    peak_type_id          INTEGER,
    FOREIGN KEY (area_id) REFERENCES area (area_id),
    FOREIGN KEY (peak_type_id) REFERENCES peak_type (peak_type_id),
    CONSTRAINT unique_mountain_in_area UNIQUE (mountain_name, area_id),
    CONSTRAINT valid_climbing_season CHECK (climbing_season_end > climbing_season_start) -- Additional constraint
);


-- Risk Level table
CREATE TABLE IF NOT EXISTS risk_level
(
    risk_level_id              INTEGER PRIMARY KEY DEFAULT nextval('risk_level_id_seq'),
    risk_name                  VARCHAR(50) NOT NULL UNIQUE, -- CONSTRAINT #4: Unique
    requires_special_insurance BOOLEAN             DEFAULT FALSE,
    requires_special_training  BOOLEAN             DEFAULT FALSE
);

-- Difficulty Level table
CREATE TABLE IF NOT EXISTS difficulty_level
(
    difficulty_level_id     INTEGER PRIMARY KEY DEFAULT nextval('difficulty_level_id_seq'),
    difficulty_name         VARCHAR(50) NOT NULL UNIQUE,
    min_experience_level_id INTEGER     NOT NULL,
    technical_grade         VARCHAR(50),
    commitment_grade        VARCHAR(50),
    altitude_grade          VARCHAR(50),
    FOREIGN KEY (min_experience_level_id) REFERENCES experience_level (experience_level_id)
);


-- Route table
CREATE TABLE IF NOT EXISTS route
(
    route_id                    INTEGER PRIMARY KEY DEFAULT nextval('route_id_seq'),
    mountain_id                 INTEGER        NOT NULL,
    route_name                  VARCHAR(100)   NOT NULL,
    difficulty_level_id         INTEGER        NOT NULL,
    length_meters               DECIMAL(10, 2) NOT NULL CHECK (length_meters > 0),
    is_seasonal                 BOOLEAN             DEFAULT FALSE,
    best_season                 VARCHAR(50),
    avg_completion_days         DECIMAL(5, 2) CHECK (avg_completion_days > 0),
    technical_climbing_required BOOLEAN             DEFAULT FALSE,
    risk_level_id               INTEGER        NOT NULL,
    FOREIGN KEY (mountain_id) REFERENCES mountain (mountain_id),
    FOREIGN KEY (difficulty_level_id) REFERENCES difficulty_level (difficulty_level_id),
    FOREIGN KEY (risk_level_id) REFERENCES risk_level (risk_level_id),
    CONSTRAINT unique_route_on_mountain UNIQUE (mountain_id, route_name)
);


-- Base Camp table
CREATE TABLE IF NOT EXISTS base_camp
(
    base_camp_id         INTEGER PRIMARY KEY DEFAULT nextval('base_camp_id_seq'),
    mountain_id          INTEGER        NOT NULL,
    camp_name            VARCHAR(100)   NOT NULL,
    height_meters        DECIMAL(10, 2) NOT NULL CHECK (height_meters > 0),
    max_capacity         INTEGER             DEFAULT 0 CHECK (max_capacity >= 0),
    has_medical_facility BOOLEAN             DEFAULT FALSE,
    latitude             DECIMAL(10, 6) NOT NULL CHECK (latitude BETWEEN -90 AND 90),
    longitude            DECIMAL(10, 6) NOT NULL CHECK (longitude BETWEEN -180 AND 180),
    has_wifi             BOOLEAN             DEFAULT FALSE,
    has_electricity      BOOLEAN             DEFAULT FALSE,
    has_water_source     BOOLEAN             DEFAULT FALSE,
    FOREIGN KEY (mountain_id) REFERENCES mountain (mountain_id),
    CONSTRAINT unique_camp_on_mountain UNIQUE (mountain_id, camp_name)
);


-- Equipment Category table
CREATE TABLE IF NOT EXISTS equipment_category
(
    equipment_category_id INTEGER PRIMARY KEY DEFAULT nextval('equipment_category_id_seq'),
    category_name         VARCHAR(50) NOT NULL UNIQUE
);

-- Equipment table
CREATE TABLE IF NOT EXISTS equipment
(
    equipment_id          INTEGER PRIMARY KEY DEFAULT nextval('equipment_id_seq'),
    equipment_name        VARCHAR(100) NOT NULL,
    weight_kg             DECIMAL(6, 2) CHECK (weight_kg > 0),
    is_technical          BOOLEAN             DEFAULT FALSE,
    is_safety             BOOLEAN             DEFAULT FALSE,
    is_rental_available   BOOLEAN             DEFAULT FALSE,
    rental_cost_per_day   DECIMAL(10, 2) CHECK (rental_cost_per_day >= 0),
    equipment_category_id INTEGER      NOT NULL,
    lifespan_years        INTEGER CHECK (lifespan_years > 0),
    FOREIGN KEY (equipment_category_id) REFERENCES equipment_category (equipment_category_id),
    CONSTRAINT unique_equipment_in_category UNIQUE (equipment_name, equipment_category_id)
);


-- Equipment Inventory table
CREATE TABLE IF NOT EXISTS equipment_inventory
(
    inventory_id        INTEGER PRIMARY KEY  DEFAULT nextval('inventory_id_seq'),
    equipment_id        INTEGER     NOT NULL,
    serial_number       VARCHAR(50) NOT NULL, -- CONSTRAINT #5: NOT NULL
    purchase_date       DATE        NOT NULL CHECK (purchase_date > '2000-01-01'),
    last_maintenance    DATE,
    condition           VARCHAR(50) NOT NULL DEFAULT 'New',
    available           BOOLEAN              DEFAULT TRUE,
    current_location_id INTEGER,
    FOREIGN KEY (equipment_id) REFERENCES equipment (equipment_id),
    CONSTRAINT unique_equipment_serial UNIQUE (equipment_id, serial_number)
);


-- Equipment Requirement table
CREATE TABLE IF NOT EXISTS equipment_requirement
(
    requirement_id      INTEGER PRIMARY KEY DEFAULT nextval('requirement_id_seq'),
    difficulty_level_id INTEGER NOT NULL,
    equipment_id        INTEGER NOT NULL,
    is_mandatory        BOOLEAN             DEFAULT TRUE,
    quantity_required   INTEGER             DEFAULT 1 CHECK (quantity_required > 0),
    FOREIGN KEY (difficulty_level_id) REFERENCES difficulty_level (difficulty_level_id),
    FOREIGN KEY (equipment_id) REFERENCES equipment (equipment_id),
    CONSTRAINT unique_equipment_requirement UNIQUE (difficulty_level_id, equipment_id)
);


-- Insurance Level table
CREATE TABLE IF NOT EXISTS insurance_level
(
    insurance_level_id            INTEGER PRIMARY KEY DEFAULT nextval('insurance_level_id_seq'),
    insurance_name                VARCHAR(100)   NOT NULL UNIQUE,
    coverage_details              VARCHAR(250),
    min_coverage_amount           DECIMAL(12, 2) NOT NULL CHECK (min_coverage_amount > 0),
    search_rescue_coverage        DECIMAL(12, 2) CHECK (search_rescue_coverage > 0),
    helicopter_evacuation_covered BOOLEAN             DEFAULT FALSE,
    medical_repatriation_covered  BOOLEAN             DEFAULT FALSE,
    third_party_liability         BOOLEAN             DEFAULT FALSE
);

-- Climb table
CREATE TABLE IF NOT EXISTS climb
(
    climb_id              INTEGER PRIMARY KEY     DEFAULT nextval('climb_id_seq'),
    start_date            DATE           NOT NULL CHECK (start_date > '2000-01-01'),
    end_date              DATE           NOT NULL,
    route_id              INTEGER        NOT NULL,
    status                VARCHAR(50)    NOT NULL DEFAULT 'Planned' CHECK (status IN ('Planned', 'Active', 'Completed', 'Cancelled')),
    insurance_level_id    INTEGER        NOT NULL,
    max_participants      INTEGER                 DEFAULT 10 CHECK (max_participants > 0),
    total_cost            DECIMAL(12, 2) NOT NULL CHECK (total_cost > 0),
    is_club_sponsored     BOOLEAN                 DEFAULT FALSE,
    special_requirements  VARCHAR(250),
    registration_deadline DATE           NOT NULL,
    briefing_datetime     TIMESTAMP,
    cancellation_policy   VARCHAR(250),
    FOREIGN KEY (route_id) REFERENCES route (route_id),
    FOREIGN KEY (insurance_level_id) REFERENCES insurance_level (insurance_level_id),
    CONSTRAINT check_climb_dates CHECK (end_date >= start_date),
    CONSTRAINT check_registration_deadline CHECK (registration_deadline <= start_date)
);


-- Climber Insurance table
CREATE TABLE IF NOT EXISTS climber_insurance
(
    climber_insurance_id INTEGER PRIMARY KEY DEFAULT nextval('climber_insurance_id_seq'),
    climber_id           INTEGER        NOT NULL,
    policy_number        VARCHAR(100)   NOT NULL,
    start_date           DATE           NOT NULL CHECK (start_date > '2000-01-01'),
    end_date             DATE           NOT NULL,
    coverage_amount      DECIMAL(12, 2) NOT NULL CHECK (coverage_amount > 0),
    verified             BOOLEAN             DEFAULT FALSE,
    FOREIGN KEY (climber_id) REFERENCES climber (climber_id),
    CONSTRAINT unique_climber_policy UNIQUE (climber_id, policy_number),
    CONSTRAINT check_insurance_dates CHECK (end_date > start_date)
);

-- Climb Participant table
CREATE TABLE IF NOT EXISTS climb_participant
(
    participant_id         INTEGER PRIMARY KEY DEFAULT nextval('participant_id_seq'),
    climb_id               INTEGER NOT NULL,
    climber_id             INTEGER NOT NULL,
    waiver_signed          BOOLEAN             DEFAULT FALSE,
    signed_date            DATE,
    has_required_insurance BOOLEAN             DEFAULT FALSE,
    completed_climb        BOOLEAN             DEFAULT FALSE,
    attendance_confirmed   BOOLEAN             DEFAULT FALSE,
    gear_checked           BOOLEAN             DEFAULT FALSE,
    FOREIGN KEY (climb_id) REFERENCES climb (climb_id),
    FOREIGN KEY (climber_id) REFERENCES climber (climber_id),
    CONSTRAINT unique_climber_per_climb UNIQUE (climb_id, climber_id)
);


-- Invoice table
CREATE TABLE IF NOT EXISTS invoice
(
    invoice_id      INTEGER PRIMARY KEY     DEFAULT nextval('invoice_id_seq'),
    climb_id        INTEGER        NOT NULL,
    climber_id      INTEGER        NOT NULL,
    invoice_date    DATE           NOT NULL CHECK (invoice_date > '2000-01-01'),
    due_date        DATE           NOT NULL,
    total_amount    DECIMAL(12, 2) NOT NULL CHECK (total_amount > 0),
    status          VARCHAR(50)    NOT NULL DEFAULT 'Unpaid' CHECK (status IN ('Unpaid', 'Partial', 'Paid', 'Cancelled')),
    tax_rate        DECIMAL(5, 2)           DEFAULT 0 CHECK (tax_rate >= 0),
    tax_amount      DECIMAL(12, 2)          DEFAULT 0 CHECK (tax_amount >= 0),
    discount_amount DECIMAL(12, 2)          DEFAULT 0 CHECK (discount_amount >= 0),
    FOREIGN KEY (climb_id) REFERENCES climb (climb_id),
    FOREIGN KEY (climber_id) REFERENCES climber (climber_id),
    CONSTRAINT check_invoice_dates CHECK (due_date >= invoice_date)
);


-- Payment table
CREATE TABLE IF NOT EXISTS payment
(
    payment_id      INTEGER PRIMARY KEY     DEFAULT nextval('payment_id_seq'),
    climb_id        INTEGER        NOT NULL,
    climber_id      INTEGER        NOT NULL,
    amount          DECIMAL(12, 2) NOT NULL CHECK (amount > 0),
    payment_date    DATE           NOT NULL CHECK (payment_date > '2000-01-01'),
    payment_method  VARCHAR(50)    NOT NULL,
    payment_status  VARCHAR(50)    NOT NULL DEFAULT 'Pending' CHECK (payment_status IN
                                                                     ('Pending', 'Processing', 'Completed', 'Failed',
                                                                      'Refunded')),
    transaction_ref VARCHAR(100) UNIQUE,
    deposit_amount  DECIMAL(12, 2)          DEFAULT 0 CHECK (deposit_amount >= 0),
    deposit_date    DATE CHECK (deposit_date > '2000-01-01' OR deposit_date IS NULL),
    invoice_id      INTEGER,
    FOREIGN KEY (climb_id) REFERENCES climb (climb_id),
    FOREIGN KEY (climber_id) REFERENCES climber (climber_id),
    FOREIGN KEY (invoice_id) REFERENCES invoice (invoice_id)
);

-- Equipment Rental table
CREATE TABLE IF NOT EXISTS equipment_rental
(
    rental_id           INTEGER PRIMARY KEY DEFAULT nextval('rental_id_seq'),
    inventory_id        INTEGER        NOT NULL,
    climber_id          INTEGER        NOT NULL,
    climb_id            INTEGER        NOT NULL,
    rental_start        DATE           NOT NULL CHECK (rental_start > '2000-01-01'),
    rental_end          DATE           NOT NULL,
    deposit_amount      DECIMAL(12, 2) NOT NULL CHECK (deposit_amount >= 0),
    rental_fee          DECIMAL(12, 2) NOT NULL CHECK (rental_fee >= 0),
    condition_on_return VARCHAR(50),
    returned            BOOLEAN             DEFAULT FALSE,
    FOREIGN KEY (inventory_id) REFERENCES equipment_inventory (inventory_id),
    FOREIGN KEY (climber_id) REFERENCES climber (climber_id),
    FOREIGN KEY (climb_id) REFERENCES climb (climb_id),
    CONSTRAINT check_rental_dates CHECK (rental_end >= rental_start)
);

-- Payment Rate table
CREATE TABLE IF NOT EXISTS payment_rate
(
    rate_id                    INTEGER PRIMARY KEY DEFAULT nextval('rate_id_seq'),
    difficulty_level_id        INTEGER        NOT NULL,
    base_fee                   DECIMAL(12, 2) NOT NULL CHECK (base_fee > 0),
    effective_date             DATE           NOT NULL CHECK (effective_date > '2000-01-01'),
    end_date                   DATE,
    equipment_rental_surcharge DECIMAL(5, 2)       DEFAULT 0 CHECK (equipment_rental_surcharge >= 0),
    guide_fee_percentage       DECIMAL(5, 2)       DEFAULT 0 CHECK (guide_fee_percentage >= 0),
    peak_season_surcharge      DECIMAL(12, 2)      DEFAULT 0 CHECK (peak_season_surcharge >= 0),
    group_discount_threshold   DECIMAL(12, 2) CHECK (group_discount_threshold > 0 OR group_discount_threshold IS NULL),
    group_discount_percentage  DECIMAL(5, 2)       DEFAULT 0 CHECK (group_discount_percentage >= 0),
    FOREIGN KEY (difficulty_level_id) REFERENCES difficulty_level (difficulty_level_id),
    CONSTRAINT unique_difficulty_effective_date UNIQUE (difficulty_level_id, effective_date),
    CONSTRAINT check_payment_rate_dates CHECK (end_date IS NULL OR end_date > effective_date)
);

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

