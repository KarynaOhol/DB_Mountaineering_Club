# Mountain Climbing Management System

## Project Overview

The Mountain Climbing Management System is a comprehensive database solution designed to facilitate the organization and management of mountain climbing expeditions. This system tracks climbers, mountains, routes, equipment, payments, and other essential components needed for safe and efficient climbing operations.

## Database Documentation

- [ER diagram.mmd](Climbs_for_a_Mountraineering_Club_ER_diagram.mmd) - Visual representation of entity relationships
- [ER Diagram.png](Climbs_for_a_Mountraineering_Club_ERD.png)
- [Logical model.mmd](Climbs_for_a_Mountraineering_Club_Logical_diagram.mmd) - Detailed logical data model
- [Logical model.png](Climbs_for_a_Mountraineering_Club_diagram.png)
- [Database Creation Script](create.sql) - SQL script to create database schema
- [Data Insertion Script](insert.sql) - SQL script to populate database with initial data
- [Query Examples](queries.sql) - Common queries for data retrieval and analysis

## System Workflow

1. **Climber Registration**
   - Climbers register with personal details, emergency contacts, and experience level
   - System validates and stores climber information

2. **Expedition Planning**
   - Admin creates climbing expeditions with routes, dates, and requirements
   - System validates route difficulty against climber experience
   - Equipment requirements are determined based on route difficulty

3. **Participant Registration**
   - Climbers sign up for specific expeditions
   - System validates insurance requirements and experience level
   - Waivers are recorded when signed

4. **Equipment Management**
   - Climbers can rent required equipment
   - System tracks inventory and maintenance status
   - Equipment is assigned to specific expeditions

5. **Payment Processing**
   - Invoices are generated based on climb difficulty and additional services
   - Payments are recorded and tracked
   - Deposits and full payments are managed separately

6. **Expedition Execution and Completion**
   - Attendance confirmation and gear checks before departure
   - Completion status updated after expedition
   - Equipment return and condition assessment

## Business Rules and Constraints

### Climber Management
- Each climber must have a unique email address
- Climbers must provide emergency contact information
- Experience levels determine which routes a climber can attempt

### Route and Mountain Management
- Mountains are categorized by peak type and geographical area
- Routes have specified difficulty levels, risk assessments, and length
- Base camps are associated with specific mountains

### Equipment Rules
- Equipment is categorized and tracked through inventory
- Certain equipment is mandatory based on route difficulty
- Equipment maintenance and condition are tracked

### Expedition Rules
- Maximum participant limits are enforced per expedition
- Registration deadlines must be met
- Proper insurance coverage is required for participation
- Waivers must be signed before participation
- Expedition status tracks the full lifecycle (Planned, Active, Completed, Cancelled)

### Financial Rules
- Payment rates vary by difficulty level
- Deposits are required for registration
- Group discounts apply when participant thresholds are met
- Equipment rental has separate fee structures

## Entity Relationships

### Primary Entities

**Climber**
- Represents individuals participating in climbs
- Connected to experience levels, insurance, and payments
- Participates in climbs through the CLIMB_PARTICIPANT junction

**Mountain**
- Central entity for geographical climbing locations
- Contains routes and base camps
- Categorized by peak type and area

**Route**
- Specific paths on mountains
- Classified by difficulty and risk levels
- Used in climb planning

**Climb**
- Represents specific climbing expeditions
- Connected to routes, participants, and payments
- Has specific insurance requirements

**Equipment**
- Gear needed for climbing
- Tracked through inventory
- Linked to specific difficulty levels through requirements

### Relationship Details

1. **Climber to Experience Level** (Many-to-One)
   - Each climber has one experience level
   - Experience levels can be shared by many climbers

2. **Mountain to Area** (Many-to-One)
   - Each mountain belongs to one geographical area
   - Areas can contain multiple mountains

3. **Route to Mountain** (Many-to-One)
   - Each route belongs to one mountain
   - Mountains can have multiple routes

4. **Climb to Route** (Many-to-One)
   - Each climb follows one specific route
   - Routes can be used for multiple climbs

5. **Climber to Climb** (Many-to-Many through CLIMB_PARTICIPANT)
   - Climbers can participate in multiple climbs
   - Climbs can have multiple participants

6. **Equipment to Difficulty Level** (Many-to-Many through EQUIPMENT_REQUIREMENT)
   - Different difficulty levels require different equipment
   - Equipment can be required for multiple difficulty levels

7. **Payment to Climb and Climber** (Many-to-One)
   - Payments are associated with specific climbers and climbs
   - Climbs and climbers can have multiple payments

## Database Schema Overview

The database consists of 21 tables organized into several functional areas:

1. **Climber Management**
   - CLIMBER, EXPERIENCE_LEVEL, CLIMBER_INSURANCE

2. **Geographic Information**
   - MOUNTAIN, AREA, PEAK_TYPE, BASE_CAMP

3. **Route Information**
   - ROUTE, DIFFICULTY_LEVEL, RISK_LEVEL

4. **Equipment Management**
   - EQUIPMENT, EQUIPMENT_CATEGORY, EQUIPMENT_INVENTORY, 
   - EQUIPMENT_REQUIREMENT, EQUIPMENT_RENTAL

5. **Expedition Management**
   - CLIMB, CLIMB_PARTICIPANT, INSURANCE_LEVEL

6. **Financial Management**
   - PAYMENT, INVOICE, PAYMENT_RATE

## Database Integrity and Performance Features

### Constraints and Checks

1. **Unique Constraints**
   - `unique_area_country`: Ensures each area name is unique within a country
   - `unique_mountain_in_area`: Prevents duplicate mountain names within the same area
   - `unique_camp_on_mountain`: Ensures base camp names are unique per mountain
   - `unique_route_on_mountain`: Prevents duplicate route names on the same mountain
   - `unique_equipment_in_category`: Ensures equipment names are unique within categories
   - `unique_equipment_serial`: Prevents duplicate serial numbers for the same equipment type
   - `unique_equipment_requirement`: Ensures each equipment is only required once per difficulty level
   - `unique_climber_policy`: Prevents duplicate insurance policies for a climber
   - `unique_climber_per_climb`: Ensures a climber can only be registered once for each climb
   - `unique_difficulty_effective_date`: Prevents overlapping payment rates for the same difficulty level

2. **Check Constraints**
   - `check_climb_dates`: Ensures the end date is not before the start date for climbs
   - `check_registration_deadline`: Ensures registration deadlines are before climb start dates
   - `check_insurance_dates`: Validates that insurance end dates are after start dates
   - `check_invoice_dates`: Ensures invoice due dates are not before invoice dates
   - `check_rental_dates`: Validates that equipment rental end dates are not before start dates
   - `check_payment_rate_dates`: Ensures payment rate end dates are after effective dates

### Indexes

1. **Primary Purpose Indexes**
   - All tables have indexes on their primary keys by default
   - Foreign key indexes improve join performance across related tables

2. **Filtering Indexes**
   - `idx_area_country`: Speeds up queries that filter areas by country
   - `idx_climber_experience_level`: Optimizes queries filtering climbers by experience level
   - `idx_mountain_height`: Accelerates queries that filter or sort mountains by height
   - `idx_mountain_peak_type`: Improves queries filtering mountains by peak type
   - `idx_basecamp_height`: Speeds up queries filtering base camps by elevation
   - `idx_inventory_available`: Optimizes equipment availability searches
   - `idx_climb_status`: Accelerates filtering climbs by their status
   - `idx_payment_status`: Speeds up queries filtering payments by status
   - `idx_invoice_status`: Optimizes filtering of invoices by payment status
   - `idx_invoice_due_date`: Speeds up queries for upcoming or overdue invoices

3. **Join Performance Indexes**
   - `idx_mountain_area`: Improves joins between mountains and their areas
   - `idx_difficulty_experience`: Optimizes joins between difficulty levels and experience levels
   - `idx_route_mountain`: Improves joins between routes and mountains
   - `idx_route_difficulty`: Optimizes joins between routes and difficulty levels
   - `idx_route_risk`: Improves joins between routes and risk levels
   - `idx_basecamp_mountain`: Optimizes joins between base camps and mountains
   - `idx_equipment_category`: Speeds up joins between equipment and categories
   - `idx_requirement_difficulty`: Improves joins for equipment requirements by difficulty
   - `idx_requirement_equipment`: Optimizes finding requirements for specific equipment
   - `idx_climb_route`: Improves joins between climbs and routes
   - `idx_climb_insurance`: Optimizes joins between climbs and insurance levels
   - `idx_participant_climb`: Speeds up queries linking participants to climbs
   - `idx_participant_climber`: Improves finding all climbs for a specific climber
   - `idx_rental_inventory`, `idx_rental_climber`, `idx_rental_climb`: Optimize rental queries
   - `idx_payment_rate_difficulty`: Improves finding payment rates for specific difficulty levels

4. **Date Range Indexes**
   - `idx_climb_dates`: Optimizes queries for climbs within specific date ranges
   - `idx_climber_insurance_dates`: Improves queries for valid insurance during specific dates
   - `idx_rental_dates`: Speeds up queries for equipment availability during date ranges
   - `idx_payment_rate_dates`: Optimizes finding valid payment rates for specific dates

### Implementation Benefits

- **Data Integrity**: Constraints and checks ensure data consistency and prevent invalid entries
- **Query Performance**: Strategic indexes improve query response times for common operations
- **Referential Integrity**: Foreign key constraints maintain relationships between tables
- **Default Values**: Sensible defaults simplify data entry for common scenarios
- **Status Tracking**: Enumerated status fields provide consistent workflow states
- **Business Rule Enforcement**: Database-level checks enforce critical business rules

## Future Enhancements

- Weather condition tracking integration
- Guide assignment and scheduling
- Automated risk assessment based on conditions
- Mobile application for field data collection
- Performance analytics for climbers and routes