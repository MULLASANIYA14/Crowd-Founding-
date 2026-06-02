Create database kick;
use kick;
select * from projects;
select * from category;
select * from location;
select * from creator;
select * from calendar;


----------------------------------- Convert Epoch Time to Natural Date--------------------------------
select
    ProjectID,
    FROM_UNIXTIME(created_at) AS created_date,
    FROM_UNIXTIME(deadline) AS deadline_date,
    FROM_UNIXTIME(updated_at) AS updated_date
FROM PROJECTS;

----------------------------------- Creating calender table----------------------------------------------------------------

CREATE TABLE calendar (
    created_date DATE,
    year INT,
    month_no INT,
    month_fullname VARCHAR(20),
    quarter VARCHAR(5),
    yearmonth VARCHAR(10),
    weekday_no INT,
    weekday_name VARCHAR(10)
);
INSERT INTO calendar
SELECT 
    DATE(FROM_UNIXTIME(created_at)) AS created_date,
    YEAR(FROM_UNIXTIME(created_at)) AS year,
    MONTH(FROM_UNIXTIME(created_at)) AS month_no,
    MONTHNAME(FROM_UNIXTIME(created_at)) AS month_fullname,
    
    CONCAT('Q', QUARTER(FROM_UNIXTIME(created_at))) AS quarter,
    
    DATE_FORMAT(FROM_UNIXTIME(created_at),'%Y-%b') AS yearmonth,
    
    DAYOFWEEK(FROM_UNIXTIME(created_at)) AS weekday_no,
    
    DAYNAME(FROM_UNIXTIME(created_at)) AS weekday_name
FROM projects;

------------------------------ Convert  goal to USD---------------------------

ALTER TABLE projects
ADD goal_usd DECIMAL(10,2);

SET SQL_SAFE_UPDATES = 0;
UPDATE projects
SET goal_usd = goal / 75;


----------------------------------- Total Number of Project -----------------------------------------------
select count(projectid) as total_projects from projects;


----------------------------------- Average Number of Backers ----------------------------------------------
SELECT AVG(backers_count) AS avg_backers
FROM projects;

-------------------------------------- Success Rate of Projects -------------------------------------------------------------
SELECT 
    COUNT(CASE WHEN state = 'successful' THEN 1 END) * 100.0 / COUNT(*) AS success_rate
FROM projects;

-------------------------------------- Total Projects by Category------------------------------------------------------------
SELECT 
    c.name,
    COUNT(p.category_id) AS total_projects
FROM Projects p
JOIN category c 
ON p.category_id = c.id
GROUP BY c.name
ORDER BY total_projects DESC;


-- -----------------------------Top 10 Projects by Backers-------------------------------------------------------------------
SELECT 
    name,
    backers_count as backers
FROM projects
ORDER BY backers_count DESC
LIMIT 10;

-------------------------------- Projects by Goal Range---------------------------------------------------------------------
SELECT 
    CASE
        WHEN goal < 10000 THEN '<$10K'
        WHEN goal BETWEEN 10000 AND 100000 THEN '$10K-$100K'
        WHEN goal BETWEEN 100000 AND 1000000 THEN '$100K-$1M'
        ELSE '>$M'
    END AS goal_range,
    COUNT(*) AS projects
FROM projects
GROUP BY goal_range;

-------------------------------------- Funding Trend by Year-------------------------------------
SELECT 
    YEAR(FROM_UNIXTIME(created_at)) AS year,
    SUM(goal_usd) AS total_funding
FROM projects
GROUP BY year
ORDER BY year;

------------------------------------------ Number of Projects by State ------------------------------
SELECT 
    state,
    COUNT(*) AS total_projects
FROM projects
GROUP BY state;

----------------------------------- Successful Projects by Goal Range-----------------------------------------
SELECT 
    CASE
        WHEN goal < 10000 THEN '<$10K'
        WHEN goal BETWEEN 10000 AND 100000 THEN '$10K-$100K'
        WHEN goal BETWEEN 100000 AND 1000000 THEN '$100K-$1M'
        ELSE '>$1M'
    END AS goal_range,
    COUNT(*) AS successful_projects
FROM projects
WHERE state = 'successful'
GROUP BY goal_range;
