\connect mountaineering_club

-- Query 1.1: Find all climbers with advanced or expert experience level
SELECT
    c.climber_id,
    c.first_name,
    c.last_name,
    e.level_name AS experience_level
FROM
    climber c
JOIN
    experience_level e ON c.experience_level_id = e.experience_level_id
WHERE
    e.level_name IN ('Advanced', 'Expert')
ORDER BY
    e.level_name, c.last_name, c.first_name;

-- Query 1.2: Find routes with their mountains and difficulty levels
SELECT
    r.route_id,
    r.route_name,
    m.mountain_name,
    m.height_meters AS mountain_height,
    r.length_meters AS route_length,
    d.difficulty_name,
    ROUND((r.length_meters / m.height_meters) * 100, 2) AS percentage_of_mountain_height,
    CASE
        WHEN r.is_seasonal = TRUE THEN 'Seasonal: ' || COALESCE(r.best_season, 'Not specified')
        ELSE 'Year-round'
    END AS availability
FROM
    route r
JOIN
    mountain m ON r.mountain_id = m.mountain_id
JOIN
    difficulty_level d ON r.difficulty_level_id = d.difficulty_level_id
ORDER BY
    d.difficulty_level_id, m.height_meters DESC;

