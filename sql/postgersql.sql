-- Locations table
CREATE TABLE locations (
    location_id SERIAL PRIMARY KEY,
    city VARCHAR(100),
    country VARCHAR(50)
);
-- Skills table
CREATE TABLE skills (
    skill_id SERIAL PRIMARY KEY,
    skill_name VARCHAR(100)
);
-- Jobs table
CREATE TABLE jobs (
    job_id VARCHAR(20) PRIMARY KEY,
    job_title VARCHAR(100),
    job_category VARCHAR(50),
    experience_level VARCHAR(30),
    years_of_experience INTEGER,
    education_required VARCHAR(50),
    annual_salary_usd INTEGER,
    salary_min_usd INTEGER,
    salary_max_usd INTEGER,
    salary_tier VARCHAR(50),
    remote_work VARCHAR(20),
    company_size VARCHAR(50),
    industry VARCHAR(50),
    posting_year SMALLINT,
    posting_month SMALLINT,
    is_senior BOOLEAN,
    is_remote_friendly BOOLEAN,
    is_llm_role BOOLEAN,
    location_id INTEGER REFERENCES locations(location_id)
);
-- Demand metrics table
CREATE TABLE demand_metrics (
    job_id VARCHAR(20) PRIMARY KEY REFERENCES jobs(job_id),
    demand_score INTEGER,
    demand_growth_yoy_pct DECIMAL(10,2),
    benefits_score_10 DECIMAL(10,2),
    ai_salary_premium_pct DECIMAL(10,2)
);
-- Job-skills bridge table
CREATE TABLE job_skills (
    job_id VARCHAR(20) REFERENCES jobs(job_id),
    skill_id INTEGER REFERENCES skills(skill_id),
    PRIMARY KEY (job_id, skill_id)
);


SELECT current_database();
SELECT COUNT(*) FROM locations;
SELECT COUNT(*) FROM skills;
SELECT COUNT(*) FROM jobs;
SELECT COUNT(*) FROM demand_metrics;
SELECT COUNT(*) FROM job_skills;


--Total Number of Jobs
SELECT COUNT(DISTINCT job_id) FROM jobs;
--Total Cities
SELECT COUNT(DISTINCT city) FROM locations;
--Total Countries
SELECT COUNT(DISTINCT country)FROM locations;
--Average Annual Salary
SELECT ROUND(AVG(annual_salary_usd),2)as average_salary FROM jobs;
--Average Demand Score
SELECT round(AVG(demand_score),2) as average_demand_score from demand_metrics;
--Percentage of Fully Remote Jobs
SELECT round(avg(CASE WHEN remote_work= 'Fully Remote' then 1 else 0 end)*100,2)
AS remote_job_percentage
FROM jobs;
--Average AI Salary Premium
SELECT ROUND(AVG(ai_salary_premium_pct),2) AS average_ai_salary_premium
FROM demand_metrics;





--Industries Paying Above Market Average
SELECT industry ,round(avg(annual_salary_usd),2) as highest_avg_salary
from jobs
group by industry
having avg(annual_salary_usd)>
(select avg(annual_salary_usd) from jobs )
order by highest_avg_salary  desc;

--What is the distribution of remote work modes
SELECT remote_work,COUNT(*) AS total_jobs,
ROUND(COUNT(*) * 100.0 /(SELECT COUNT(*) FROM jobs),2) AS percentage
FROM jobs
GROUP BY remote_work
ORDER BY total_jobs DESC;

--How does salary vary by education level
SELECT education_required,  ROUND(AVG(annual_salary_usd),2) AS average_salary
FROM jobs
GROUP BY education_required
ORDER BY average_salary DESC;

--Highest Paying City in Each Country
WITH city_salary AS (
SELECT l.country,l.city,ROUND(AVG(j.annual_salary_usd), 2) AS avg_salary
FROM jobs j
JOIN locations l
ON j.location_id = l.location_id
GROUP BY l.country, l.city
),
ranked_city AS (
SELECT country,city,avg_salary,
 ROW_NUMBER() OVER (PARTITION BY country ORDER BY avg_salary DESC) AS rnk
FROM city_salary
)
SELECT country,city,avg_salary
FROM ranked_city
WHERE rnk = 1
ORDER BY avg_salary DESC;

--Highest Paying Skills
SELECT s.skill_name, ROUND(AVG(j.annual_salary_usd), 2) AS average_salary
FROM jobs j
JOIN job_skills js
    ON j.job_id = js.job_id
JOIN skills s
    ON js.skill_id = s.skill_id
GROUP BY s.skill_name
ORDER BY average_salary DESC
LIMIT 10;

--Which job categories have the highest number of openings
SELECT job_category, COUNT(*) AS total_jobs
FROM jobs
GROUP BY job_category
ORDER BY total_jobs DESC;

--Most In-Demand Skills
SELECT s.skill_name, count(*) as total_job_posting
FROM jobs j
JOIN job_skills js
    ON j.job_id = js.job_id
JOIN skills s
    ON js.skill_id = s.skill_id
GROUP BY s.skill_name
ORDER BY total_job_posting DESC
LIMIT 10;




--Top 3 Highest Paying Skills
WITH skill_salary AS (
SELECT s.skill_name, ROUND(AVG(j.annual_salary_usd), 2) AS average_salary
FROM jobs j
JOIN job_skills js
ON j.job_id = js.job_id
JOIN skills s
ON js.skill_id = s.skill_id
GROUP BY s.skill_name
)
SELECT skill_name, average_salary
FROM (
SELECT *,DENSE_RANK() OVER (ORDER BY average_salary DESC) AS rnk
FROM skill_salary
) ranked_skills
WHERE rnk <= 3;

--Top 3 Highest Paying Job Titles in Every Industry
WITH job_salary AS (
SELECT industry,job_title,ROUND(AVG(annual_salary_usd),2) AS average_salary
FROM jobs
GROUP BY industry, job_title
),
ranked_jobs AS (
SELECT industry, job_title,average_salary,
 DENSE_RANK() OVER( PARTITION BY industry ORDER BY average_salary DESC) AS rnk
FROM job_salary
)
SELECT industry,job_title,average_salary
FROM ranked_jobs
WHERE rnk <= 3
ORDER BY industry, average_salary DESC;

--Industries Paying High Salary but Having Low Demand
WITH industry_stats AS (
SELECT j.industry,ROUND(AVG(j.annual_salary_usd),2) AS average_salary,
   ROUND(AVG(d.demand_score),2) AS average_demand
fROM jobs j
JOIN demand_metrics d
ON j.job_id = d.job_id
GROUP BY j.industry
)
SELECT *
FROM industry_stats
WHERE average_salary >
      (SELECT AVG(annual_salary_usd) FROM jobs)
AND average_demand <
      (SELECT AVG(demand_score) FROM demand_metrics)
ORDER BY average_salary DESC,average_demand ASC;
		 
--Most Valuable Skills (High Salary + High Demand)
WITH skill_stats AS (
SELECT s.skill_name,ROUND(AVG(j.annual_salary_usd),2) AS average_salary,
  ROUND(AVG(d.demand_score),2) AS average_demand
FROM jobs j
JOIN job_skills js
ON j.job_id = js.job_id 
JOIN skills s
ON js.skill_id = s.skill_id
JOIN demand_metrics d
ON j.job_id = d.job_id
GROUP BY s.skill_name
)
SELECT *
FROM skill_stats
WHERE average_salary >
      (SELECT AVG(annual_salary_usd) FROM jobs)
AND average_demand >
      (SELECT AVG(demand_score) FROM demand_metrics)
ORDER BY average_salary DESC, average_demand DESC;
		 
--Most In-Demand Skill in Every Industry
WITH industry_skill AS
(
SELECT j.industry,s.skill_name,
COUNT(*) job_count
FROM jobs j
JOIN job_skills js
ON j.job_id=js.job_id
JOIN skills s
ON js.skill_id=s.skill_id
GROUP BY j.industry,s.skill_name
),
ranked AS
(
SELECT *,ROW_NUMBER() OVER(PARTITION BY industry ORDER BY job_count DESC) rnk
FROM industry_skill
)
SELECT *
FROM ranked
WHERE rnk=1;

--Skills with Highest AI Salary Premium
SELECT s.skill_name,
ROUND(AVG(d.ai_salary_premium_pct),2) AS average_ai_salary_premium
FROM jobs j
JOIN demand_metrics d
ON j.job_id=d.job_id
JOIN job_skills js
ON j.job_id=js.job_id
JOIN skills s
ON js.skill_id=s.skill_id
GROUP BY s.skill_name
ORDER BY average_ai_salary_premium DESC;

--Industries Hiring the Most Remote-Friendly LLM Roles
SELECT industry,COUNT(*) AS remote_llm_jobs
FROM jobs
WHERE is_llm_role= TRUE
AND is_remote_friendly= TRUE
GROUP BY industry
ORDER BY remote_llm_jobs DESC;





--Hiring Trend by Year
SELECT posting_year,COUNT(*) AS total_jobs
FROM jobs
GROUP BY posting_year
ORDER BY posting_year;

--Rank Jobs by Salary Within Each Industry
WITH ranked_jobs AS
(
SELECT industry,job_title,annual_salary_usd,
DENSE_RANK() OVER( PARTITION BY industry
ORDER BY annual_salary_usd DESC) AS salary_rank
FROM jobs
)
SELECT *
FROM ranked_jobs
ORDER BY industry,salary_rank;

-- salary based on skills
CREATE VIEW vw_skill_salary AS
SELECT s.skill_name,ROUND(AVG(j.annual_salary_usd),2) AS average_salary
FROM jobs j
JOIN job_skills js
ON j.job_id = js.job_id
JOIN skills s
ON js.skill_id = s.skill_id
GROUP BY s.skill_name;

SELECT *
FROM vw_skill_salary
ORDER BY average_salary DESC;

--How does each industry compare in salary, demand, and AI premium
CREATE VIEW vw_industry_summary AS

SELECT j.industry,COUNT(*) AS total_jobs,
ROUND(AVG(j.annual_salary_usd),2) AS average_salary,
ROUND(AVG(d.demand_score),2) AS average_demand_score,
ROUND(AVG(d.ai_salary_premium_pct),2) AS average_ai_salary_premium
FROM jobs j
JOIN demand_metrics d
    ON j.job_id = d.job_id
GROUP BY j.industry;

SELECT *
FROM vw_industry_summary
ORDER BY average_salary DESC;

--Rank Cities by Average Salary Within Each Country
WITH city_salary AS
(
SELECT l.country,l.city,ROUND(AVG(j.annual_salary_usd),2) AS average_salary
FROM jobs j
JOIN locations l
ON j.location_id = l.location_id
GROUP BY l.country,l.city
),
ranked_city AS
(
SELECT *,DENSE_RANK() OVER( PARTITION BY country
ORDER BY average_salary DESC) AS city_rank
FROM city_salary
)
SELECT *
FROM ranked_city
ORDER BY country,city_rank;

--Running Total of Job Postings by Month
WITH monthly_jobs AS
(
SELECT posting_month,COUNT(*) AS total_jobs
FROM jobs
GROUP BY posting_month
)
SELECT posting_month,total_jobs,
SUM(total_jobs) OVER( ORDER BY posting_month) AS cumulative_jobs
FROM monthly_jobs;

--Salary Percentile by Industry
SELECT industry,job_title,annual_salary_usd,
PERCENT_RANK() OVER( PARTITION BY industry
ORDER BY annual_salary_usd ) AS salary_percentile
FROM jobs;

--How did hiring change compared to the previous month?
WITH monthly_hiring AS
(
SELECT posting_month,
COUNT(*) total_jobs
FROM jobs
GROUP BY posting_month
)
SELECT posting_month,total_jobs,
LAG(total_jobs) OVER(ORDER BY posting_month) previous_month_jobs,
total_jobs - LAG(total_jobs) OVER(ORDER BY posting_month) AS difference
FROM monthly_hiring;

--Divide industries into four salary groups.
SELECT industry,ROUND(AVG(annual_salary_usd),2) average_salary,
NTILE(4) OVER(ORDER BY AVG(annual_salary_usd)) AS salary_quartile
FROM jobs
GROUP BY industry;
