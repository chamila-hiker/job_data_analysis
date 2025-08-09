SELECT job_posted_date FROM job_postings_fact
LIMIT 10;

SELECT '2023-02-19' ::DATE;

SELECT job_title_short, job_location,
job_posted_date::DATE as date FROM 
job_postings_fact;

SELECT job_title_short, job_location,
job_posted_date::DATE,
EXTRACT(MONTH FROM job_posted_date) as date_month
FROM job_postings_fact LIMIT 5; 

SELECT count(job_postings_fact.job_id),
EXTRACT(MONTH FROM job_posted_date) as date_month 
FROM job_postings_fact 
WHERE job_title_short='Data Analyst' 
GROUP BY date_month
ORDER BY date_month ASC;

SELECT job_schedule_type, AVG(salary_year_avg) AS yearly_avg,
AVG(salary_hour_avg) AS hourly_avg
FROM job_postings_fact WHERE
EXTRACT(MONTH FROM job_posted_date) >5
GROUP BY job_schedule_type;

SELECT company_dim.name FROM job_postings_fact
LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
WHERE job_postings_fact.job_health_insurance = TRUE AND 
EXTRACT(MONTH FROM job_posted_date) BETWEEN 4 AND 6;

CREATE TABLE january_jobs AS
SELECT * 
FROM job_postings_fact
WHERE EXTRACT(MONTH FROM job_posted_date) = 1;

CREATE TABLE february_jobs AS
SELECT * 
FROM job_postings_fact
WHERE EXTRACT(MONTH FROM job_posted_date) = 2;

CREATE TABLE march_jobs AS
SELECT * 
FROM job_postings_fact
WHERE EXTRACT(MONTH FROM job_posted_date) = 3;

SELECT COUNT(job_id) AS number_of_jobs,
CASE
    WHEN job_location = 'Anywhere' THEN 'Remote'
    WHEN job_location = 'New York, NY' THEN 'Local'
    ELSE 'Onsite'
END AS location_category
FROM job_postings_fact
GROUP BY location_category;

SELECT job_title,
CASE
    WHEN AVG(salary_year_avg) > 150000 THEN 'High'
    WHEN AVG(salary_year_avg ) > 100000 THEN 'Standard'
    ELSE 'Low'
END AS salry_category
FROM job_postings_fact
WHERE job_title LIKE '%Data%Analyst%'
GROUP BY job_title
ORDER BY salry_category;

SELECT
    company_id,
    name AS company_name
FROM 
    company_dim
WHERE company_id IN (
    SELECT
        company_id
    FROM
        job_postings_fact
    WHERE
        job_no_degree_mention = TRUE
    ORDER BY
        company_id
);

WITH company_job_count AS (
    SELECT company_id, COUNT(*)
    FROM job_postings_fact
    GROUP BY company_id

)

SELECT * FROM company_job_count;

SELECT 
    job_title_short,
    company_id,
    job_location
FROM 
    january_jobs

UNION

SELECT
    job_title_short,
    company_id,
    job_location
FROM 
    february_jobs;

SELECT 
    quater_job_postings.job_title_short,
    quater_job_postings.job_location,
    quater_job_postings.job_via,
    quater_job_postings.job_posted_date::DATE,
    quater_job_postings.salary_year_avg
FROM (
    SELECT *
    FROM 
        january_jobs

    UNION ALL

    SELECT *
    FROM 
        february_jobs

    UNION ALL

    SELECT *
    FROM 
        march_jobs

) AS quater_job_postings
WHERE quater_job_postings.salary_year_avg > 70000 AND 
quater_job_postings.job_title_short = 'Data Analyst'
ORDER BY quater_job_postings.salary_year_avg ASC;


    


