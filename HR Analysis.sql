-- Add Age_Group Column
ALTER TABLE hrdata ADD age_group VARCHAR(10);

UPDATE hrdata
SET age_group = 
    CASE
        WHEN age BETWEEN 15 AND 25 THEN '15-25'
        WHEN age BETWEEN 25 AND 45 THEN '25-45'
        WHEN age BETWEEN 45 AND 65 THEN '45-65'
        WHEN age BETWEEN 65 AND 80 THEN '65-80'
        ELSE 'Unknown'
    END;

select * from hrdata

select "age_band",
round(cast(count("attrition") as numeric) / (select count("attrition") from hrdata where "attrition" = 'Yes')*100,2) as pct_attrition
from hrdata
where "attrition" = 'Yes' 
group by "age_band"
order by pct_attrition desc



-- Basic Level  
-- 1. Retrieve all records from the dataset.
select * from hrdata

-- 2. Get the count of all employees.

SELECT COUNT(emp_no) AS total_employees FROM hrdata;


-- 3. List all distinct job roles in the dataset.

select distinct "job_role" from hrdata



-- 4. Find the total number of active employees.

SELECT COUNT("emp_no") AS active_employees 
FROM hrdata  
WHERE "active_employee" = 1;



-- 5. Show the average age of employees.

select round(avg("age"),2) as avg_age from hrdata



-- Intermediate Level

-- 6. Get the count of employees by gender.

select "gender" as gender, count("emp_no") as no_emp from hrdata
group by "gender"

select distinct "attrition" from hrdata

-- 7. Find the number of employees who have left the company.
select count("emp_no") from hrdata where "attrition" = 'Yes'


-- 8. List departments with their total employees.

SELECT department, COUNT(emp_no) AS total_employees
FROM hrdata
GROUP BY department
ORDER BY total_employees DESC;



-- 9. Retrieve the average job satisfaction for each department.

select "department" as department, round(avg("job_satisfaction"),2) as avg_job_satisfaction
from hrdata
group by "department"
order by avg_job_satisfaction
 

-- 10. Find the percentage of employees who travel for business.

select round((cast(count("emp_no")as numeric)/ (select count("emp_no") from hrdata))*100,2) as pct_business_travel
from hrdata
where "business_travel" in ('Travel_Frequently','Travel_Rarely')


-- Advanced Level

-- 11. Identify the top 3 departments with the highest attrition rate.

SELECT 
    department,
    ROUND(
        (CAST(COUNT(attrition) AS NUMERIC) * 100.0) /
        (SELECT COUNT(*) FROM hrdata WHERE attrition = 'Yes'),
        2
    ) AS attrition_rate
FROM hrdata
WHERE attrition = 'Yes'
GROUP BY department
ORDER BY attrition_rate DESC
LIMIT 3;



-- 12. Find the age group (age_band) with the highest job satisfaction.

SELECT 
    age_band, 
    round(AVG(job_satisfaction),2) AS avg_job_satisfaction
FROM hrdata
GROUP BY age_band
ORDER BY avg_job_satisfaction DESC
LIMIT 1;

-- 13. Calculate the attrition rate for each job role.

SELECT 
    job_role,
    ROUND(
        (CAST(COUNT(attrition) AS NUMERIC) * 100.0) /
        (SELECT COUNT(*) FROM hrdata WHERE attrition = 'Yes'),
        2
    ) AS attrition_rate
FROM hrdata
WHERE attrition = 'Yes'
GROUP BY job_role
ORDER BY attrition_rate DESC;



-- 14. Determine the average age of employees by marital status and gender.

SELECT 
    marital_status,
    gender,
    ROUND(AVG(age), 0) AS avg_age
FROM hrdata
GROUP BY marital_status, gender;

-- 15. Rank departments based on the average job satisfaction of their employees.

-- Step 1: Create a view to calculate the average job satisfaction for each department
CREATE VIEW avg_jobSatisfaction AS
SELECT 
    department,
    ROUND(AVG(job_satisfaction), 2) AS avg_jobSatisfaction
FROM hrdata
GROUP BY department;

-- Step 2: Rank the departments based on the average job satisfaction
SELECT 
    department, 
    avg_jobSatisfaction,
    DENSE_RANK() OVER (ORDER BY avg_jobSatisfaction DESC) AS rank
FROM avg_jobSatisfaction;



-- 16. Find the correlation between attrition and job satisfaction.
WITH data AS (
    SELECT 
        CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END AS attrition_numeric,
        job_satisfaction
    FROM hrdata
),
stats AS (
    SELECT 
        AVG(attrition_numeric) AS avg_attrition,
        AVG(job_satisfaction) AS avg_job_satisfaction,
        STDDEV(attrition_numeric) AS stddev_attrition,
        STDDEV(job_satisfaction) AS stddev_job_satisfaction
    FROM data
),
covariance AS (
    SELECT 
        AVG((attrition_numeric - (SELECT avg_attrition FROM stats)) * 
            (job_satisfaction - (SELECT avg_job_satisfaction FROM stats))) AS covar
    FROM data
)
SELECT 
    (SELECT covar FROM covariance) /
    ((SELECT stddev_attrition FROM stats) * (SELECT stddev_job_satisfaction FROM stats)) AS correlation
;



-- 17. Identify the education fields with the highest proportion of employees in senior job roles.


WITH senior_roles AS (
    SELECT 
        education_field,
        COUNT(*) AS senior_count
    FROM hrdata
    WHERE job_role IN ('Manager', 'Manufacturing Director', 'Research Director')
    GROUP BY education_field
),
total_roles AS (
    SELECT 
        education_field,
        COUNT(*) AS total_count
    FROM hrdata
    GROUP BY education_field
)
SELECT 
    sr.education_field,
    ROUND(CAST(sr.senior_count AS NUMERIC) * 100.0 / tr.total_count, 2) AS senior_proportion
FROM senior_roles sr
JOIN total_roles tr ON sr.education_field = tr.education_field
ORDER BY senior_proportion DESC;

-- 18. Retrieve the department with the highest number of employees eligible for retirement (e.g., age >= 60).

SELECT 
    department,
    COUNT(emp_no) AS retirement_eligible_count
FROM hrdata
WHERE age >= 60
GROUP BY department
ORDER BY retirement_eligible_count DESC
LIMIT 1;

-- 19. Analyze the attrition rate across different education levels and fields.

SELECT 
    education, 
    education_field,
    ROUND(
        CAST(COUNT(attrition) AS NUMERIC) * 100.0 / 
        (SELECT COUNT(*) FROM hrdata WHERE attrition = 'Yes'),
        2
    ) AS attrition_rate
FROM hrdata
WHERE attrition = 'Yes'
GROUP BY education, education_field
ORDER BY attrition_rate DESC;

-- 20. Create a summary report showing the total employees, attrition count, and active employee count for each department.

SELECT 
    department,
    COUNT(emp_no) AS total_employees,
    COUNT(CASE WHEN attrition = 'Yes' THEN 1 END) AS attrition_count,
    COUNT(CASE WHEN attrition = 'No' THEN 1 END) AS active_employee_count
FROM hrdata
GROUP BY department
ORDER BY department;

