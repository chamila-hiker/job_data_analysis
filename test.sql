/*----------------------------------------------------------
  1. Basic date selection
----------------------------------------------------------*/

-- Get the first 10 job posting dates
SELECT job_posted_date
FROM job_postings_fact
LIMIT 10;

-- Convert a string into a DATE type
SELECT '2023-02-19'::DATE;

-- Show job title, location, and posted date (cast to DATE)
SELECT
    job_title_short,
    job_location,
    job_posted_date::DATE AS date
FROM job_postings_fact;

-- Show job title, location, posted date, and extracted month
SELECT
    job_title_short,
    job_location,
    job_posted_date::DATE,
    EXTRACT(MONTH FROM job_posted_date) AS date_month
FROM job_postings_fact
LIMIT 5;


/*----------------------------------------------------------
  2. Aggregation by month and schedule type
----------------------------------------------------------*/

-- Count number of Data Analyst jobs per month
SELECT
    COUNT(job_postings_fact.job_id) AS total_jobs,
    EXTRACT(MONTH FROM job_posted_date) AS date_month
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst'
GROUP BY date_month
ORDER BY date_month ASC;

-- Average yearly & hourly salary for jobs posted after May
GROUP BY job schedule type
SELECT
    job_schedule_type,
    AVG(salary_year_avg) AS yearly_avg,
    AVG(salary_hour_avg) AS hourly_avg
FROM job_postings_fact
WHERE EXTRACT(MONTH FROM job_posted_date) > 5
GROUP BY job_schedule_type;


/*----------------------------------------------------------
  3. Filtering with JOINs and conditions
----------------------------------------------------------*/

-- Get company names offering health insurance between April and June
SELECT
    company_dim.name
FROM job_postings_fact
LEFT JOIN company_dim
    ON job_postings_fact.company_id = company_dim.company_id
WHERE job_postings_fact.job_health_insurance = TRUE
  AND EXTRACT(MONTH FROM job_posted_date) BETWEEN 4 AND 6;


/*----------------------------------------------------------
  4. Creating monthly job tables
----------------------------------------------------------*/

-- Create a table for January jobs
CREATE TABLE january_jobs AS
SELECT *
FROM job_postings_fact
WHERE EXTRACT(MONTH FROM job_posted_date) = 1;

-- Create a table for February jobs
CREATE TABLE february_jobs AS
SELECT *
FROM job_postings_fact
WHERE EXTRACT(MONTH FROM job_posted_date) = 2;

-- Create a table for March jobs
CREATE TABLE march_jobs AS
SELECT *
FROM job_postings_fact
WHERE EXTRACT(MONTH FROM job_posted_date) = 3;


/*----------------------------------------------------------
  5. Categorizing data using CASE
----------------------------------------------------------*/

-- Categorize jobs by location
SELECT
    COUNT(job_id) AS number_of_jobs,
    CASE
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE 'Onsite'
    END AS location_category
FROM job_postings_fact
GROUP BY location_category;

-- Categorize job titles by salary range
SELECT
    job_title,
    CASE
        WHEN AVG(salary_year_avg) > 150000 THEN 'High'
        WHEN AVG(salary_year_avg) > 100000 THEN 'Standard'
        ELSE 'Low'
    END AS salary_category
FROM job_postings_fact
WHERE job_title LIKE '%Data%Analyst%'
GROUP BY job_title
ORDER BY salary_category;


/*----------------------------------------------------------
  6. Subqueries & filtering
----------------------------------------------------------*/

-- Companies that offer jobs without requiring a degree
SELECT
    company_id,
    name AS company_name
FROM company_dim
WHERE company_id IN (
    SELECT
        company_id
    FROM job_postings_fact
    WHERE job_no_degree_mention = TRUE
    ORDER BY company_id
);


/*----------------------------------------------------------
  7. Common Table Expressions (CTE)
----------------------------------------------------------*/

-- Count the number of jobs per company using a CTE
WITH company_job_count AS (
    SELECT
        company_id,
        COUNT(*) AS job_count
    FROM job_postings_fact
    GROUP BY company_id
)
SELECT *
FROM company_job_count;


/*----------------------------------------------------------
  8. UNION and UNION ALL
----------------------------------------------------------*/

-- Combine January and February job listings
SELECT
    job_title_short,
    company_id,
    job_location
FROM january_jobs

UNION

SELECT
    job_title_short,
    company_id,
    job_location
FROM february_jobs;


-- Combine January, February, and March job listings
-- Filter by salary and title
SELECT
    quarter_job_postings.job_title_short,
    quarter_job_postings.job_location,
    quarter_job_postings.job_via,
    quarter_job_postings.job_posted_date::DATE,
    quarter_job_postings.salary_year_avg
FROM (
    SELECT * FROM january_jobs
    UNION ALL
    SELECT * FROM february_jobs
    UNION ALL
    SELECT * FROM march_jobs
) AS quarter_job_postings
WHERE quarter_job_postings.salary_year_avg > 70000
  AND quarter_job_postings.job_title_short = 'Data Analyst'
ORDER BY quarter_job_postings.salary_year_avg ASC;
