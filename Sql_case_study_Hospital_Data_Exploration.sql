CREATE DATABASE IF NOT EXISTS SQL_Case_Studies;

use sql_case_studies;

## Q1. For each doctor, count how many distinct patients they have treated. #############################################################################

SELECT 
    d.doctorid AS DoctorID,
    CONCAT(d.FirstName, ' ', d.LastName) AS DoctorName,
    COUNT(DISTINCT p.PatientID) AS Distinct_Patient_Count
FROM
    dim_doctor d
        LEFT JOIN
    patientvisits p ON d.DoctorID = p.DoctorID
GROUP BY d.DoctorID , d.FirstName , d.LastName
ORDER BY Distinct_Patient_Count DESC;
-- ------------------------------------------------------------------------------------------------------------------------------------------------------

## Q2. Show the revenue split by each payment method, along with total visits. ##########################################################################

-- ------------------------------------ Total Visist and Revenue by each Payment Method -----------------------------------------------------------------
SELECT 
    p.paymentmethodID,
    COUNT(pt.VisitID) AS Total_Visits,
    SUM(pt.BillAmount) AS Revenue
FROM
    dim_paymentmethod p
        JOIN
    patientvisits pt ON p.paymentmethodID = pt.paymentmethodID
GROUP BY p.paymentmethodID;
-- ------------------------------------------------------------------------------------------------------------------------------------------------------
-- ------------------------ Total Visit, Revenue per group as well as grand total visit and grand total revenue -----------------------------------------
-- ------------------------ Using Window Function and Join ----------------------------------------------------------------------------------------------
SELECT 
    p.paymentmethodID, COUNT(pt.VisitID) as Total_Visits, SUM(pt.BillAmount) as Revenue,
    sum(count(pt.VisitID)) over() as Grand_Total_Visists,
    sum(sum(pt.BillAmount)) over() as Grand_Total_Revenue
FROM
    dim_paymentmethod p
        JOIN
    patientvisits pt ON p.paymentmethodID = pt.paymentmethodID
GROUP BY p.paymentmethodID;
-- ------------------------------------------------------------------------------------------------------------------------------------------------------
-- select sum(pt.BillAmount) as Full_Revenue, count(pt.VisitID) as final_Visit 
-- from dim_paymentmethod p join patientvisits pt ON p.paymentmethodID = pt.paymentmethodID;
-- ------------------------ Using CTE and Join ----------------------------------------------------------------------------------------------------------
WITH cte AS (
    SELECT 
        SUM(BillAmount) AS Full_Revenue,
        COUNT(VisitID) AS Total_Visit
    FROM patientvisits
)
SELECT 
    p.paymentmethodID,
    COUNT(pt.VisitID) AS PaymentMethod_wise_visit,
    SUM(pt.BillAmount) AS PaymentMethod_wise_Revenue,
    c.Total_Visit,
    c.Full_Revenue
FROM dim_paymentmethod p
JOIN patientvisits pt 
    ON p.paymentmethodID = pt.paymentmethodID
CROSS JOIN cte c
GROUP BY p.paymentmethodID,c.Full_Revenue,c.Total_Visit;
-- ------------------------------------------------------------------------------------------------------------------------------------------------------
-- ------------------------ Using CTE and Cross Join but now Window Function ----------------------------------------------------------------------------
WITH CTE_group as (
	select 
		p.paymentmethodID,
		count(pt.VisitID) as PaymentMethod_wise_visit,
		sum(pt.BillAmount) as PaymentMethod_wise_Revenue
	from dim_paymentmethod p 
	join patientvisits pt 
	on p.PaymentmethodID = pt.paymentmethodID
	group by p.paymentmethodID),
CTE_Total as(
	select 
		count(pt.VisitID) as Total_Visit,
		sum(pt.BillAmount) as Total_Revenue
	from patientvisits pt)
select * from CTE_group cross join CTE_Total;
-- ------------------------------------------------------------------------------------------------------------------------------------------------------
## Q3. Categorize patients into groups and calculate the average bill amount for each age band.(Assume age at time of visit based on VisitDate)  ########

-- ----------------------------------------------------- Using Timestampdiff function -------------------------------------------------------------------
with cte as (
select p.patientID, pt.BillAmount,
Timestampdiff(year,p.DOB,pt.VisitDate) as age,
case
	when Timestampdiff(year,p.DOB,pt.VisitDate) < 18 then '0-17'
    when Timestampdiff(year,p.DOB,pt.VisitDate) BETWEEN 18 and 35 then '18-35'
    when Timestampdiff(year,p.DOB,pt.VisitDate) BETWEEN 36 and 55 then '36-55'
    else '56+'
end as Age_Group
from dim_patient_clean p
join patientvisits pt
on p.patientID = pt.PatientID)
select cte.Age_Group, count(*) as VisitCount, round(avg(cte.BillAmount),2) as Avg_Bill
 from cte group by cte.age_group
 order by 
 case age_group
 When 0-17 then 1
 when 18-35 then 2
 when 36-55 then 3
 when '56+' then 4
 end;
-- ------------------------------------------------------------------------------------------------------------------------------------------------------
-- ----------------------------------------------------- Using Datediff function -------------------------------------------------------------------
with cte as (
select p.patientID, pt.BillAmount,
Datediff(pt.VisitDate,p.DOB)/365 as age,
case
	when Datediff(pt.VisitDate,p.DOB)/365 < 18 then '0-17'
    when Datediff(pt.VisitDate,p.DOB)/365 BETWEEN 18 and 35 then '18-35'
    when Datediff(pt.VisitDate,p.DOB)/365 BETWEEN 36 and 55 then '36-55'
    else '56+'
end as Age_Group
from dim_patient_clean p
join patientvisits pt
on p.patientID = pt.PatientID)
select cte.Age_Group, count(*) as VisitCount, round(avg(cte.BillAmount),2) as Avg_Bill
 from cte group by cte.Age_Group
 order by 
 case Age_Group
 When 0-17 then 1
 when 18-35 then 2
 when 36-55 then 3
 when '56+' then 4
 end;
-- ------------------------------------------------------------------------------------------------------------------------------------------------------
## Q4. Find Total revenue and number of visits for each department.  ####################################################################################

select distinct d.DepartmentName from dim_department d;

SELECT 
    d.DepartmentID,
    -- substring(d.DepartmentName,7) as Department_Name,
    d.DepartmentName,
    COUNT(pt.VisitID) AS Number_of_Visits,
    SUM(pt.BillAmount) AS Total_Revenue
FROM
    dim_department_clean d
        JOIN
    patientvisits pt ON d.DepartmentID = pt.DepartmentID
GROUP BY d.DepartmentID , d.departmentName
ORDER BY Total_Revenue  DESC;
-- ------------------------------------------------------------------------------------------------------------------------------------------------------
## Q5. Rank Departments based on their total revenue within each department category. ###################################################################

select 
	d.DepartmentCategory, 
	d.DepartmentName, 
	sum(pt.BillAmount) as revenue,
	rank() over(partition by d.DepartmentCategory order by sum(pt.BillAmount) desc) as revenue_rank
from 
	dim_department_clean d 
		join 
	patientvisits pt on d.departmentID = pt.departmentID
group by d.DepartmentCategory, d.DepartmentName;
-- ------------------------------------------------------------------------------------------------------------------------------------------------------
## Q6. For each department, find the average satisfaction score and average wait time. ##################################################################

select
	d.DepartmentName,
    round(avg(pt.SatisfactionScore),2) as average_satisfaction_score,
    round(avg(pt.WaitTimeMinutes),2) as average_wait_time
from 
	dim_department_clean d 
		join
	patientvisits pt on d.departmentID = pt.departmentID
group by d.DepartmentName
order by average_satisfaction_score desc;
-- ------------------------------------------------------------------------------------------------------------------------------------------------------
## Q7. Compare the total number of hospital visits on weekdays vs weekends. #############################################################################

select * from patientvisits;
-- ----------------------------------------Using CTE ----------------------------------------------------------------------------------------------------
with cte as(select dayname(visitdate) as day, visitdate,
case when
	dayname(visitdate) in ('Monday','Tuesday','Wednesday','Thursday','Friday') then 'Weekday'
    else 'Weekend' end 
    as Day_Type
 from patientvisits)
select Day_Type, count(*) as hospital_visit from cte group by Day_Type;
-- ------------------------------------------------------------------------------------------------------------------------------------------------------
-- ----------------------------------------Without Using CTE --------------------------------------------------------------------------------------------
SELECT 
    CASE
        WHEN DAYOFWEEK(visitdate) IN (2 , 3, 4, 5, 6) THEN 'Weekday'
        ELSE 'Weekend'
    END AS Day_Type,
    COUNT(*) AS Hospital_Visit
FROM
    patientvisits
GROUP BY Day_Type;
-- ------------------------------------------------------------------------------------------------------------------------------------------------------
## Q8. For each Month, calculate total visits and a running cumulative total of visits. #################################################################

-- --------------------------- Getting the first day of every month of every year -----------------------------------------------------------------------
SELECT 
    DATE_FORMAT(visitdate, '%Y-%m-01') AS starting_day_month,
    visitdate
FROM
    patientvisits
GROUP BY starting_day_month , visitdate
ORDER BY starting_day_month;
-- ------------------------------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------ using CTE -------------------------------------------------------------------------------------------------
with
	cte as(select DATE_Format(visitdate, '%Y-%m-01') as starting_day_month, 
    count(*) as Total_Visit_by_Month
 from 
	patientvisits p 
group by starting_day_month 
order by starting_day_month)
select 
starting_day_month, 
Total_Visit_by_Month, 
sum(Total_Visit_by_Month) 
	over(order by starting_day_month rows between unbounded preceding and current row) as cumulative_visit
from cte;
-- -------------------------------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------ using Subquery ---------------------------------------------------------------------------------------------
select 
	s.starting_day_month, 
    s.Total_visit_by_month, 
    sum(s.total_visit_by_month) over(order by starting_day_month rows between unbounded preceding and current row) as cumulative_visit
from
(select 
	DATE_Format(visitdate, '%Y-%m-01') as starting_day_month, 
	count(*) as Total_Visit_by_Month
 from 
	patientvisits p 
group by starting_day_month 
order by starting_day_month) s;
-- ------------------------------------------------------------------------------------------------------------------------------------------------------
## Q9. Find the doctors with the highest average satisfaction score (minimum 100 visits) ################################################################

select * from dim_doctor;
SELECT 
    d.doctorid,
    CONCAT(d.FirstName, ' ', d.LastName) AS Full_Name,
    COUNT(pt.visitid) AS visits,
    AVG(pt.satisfactionscore) AS Avg_Satisfaction_Score
FROM
    dim_doctor d
        JOIN
    patientvisits pt ON d.DoctorID = pt.DoctorID
GROUP BY d.doctorid , Full_Name
HAVING visits >= 100;
-- ------------------------------------------------------------------------------------------------------------------------------------------------------
## Q10. Identify the most commonly prescribed treatment for each diagnosis. #############################################################################

-- ------------------------------------------ using CTE -------------------------------------------------------------------------------------------------
with cte as(
	select 
		d.DiagnosisName, 
        t.TreatmentName, 
        count(t.TreatmentID) as treatment_frequency,
		rank() over(partition by DiagnosisName order by count(t.TreatmentID) desc) as rnk
	from 
		dim_diagnosis d 
			join 
		patientvisits pt on d.diagnosisID = pt.diagnosisID
			join 
		dim_treatment t on pt.treatmentid = t.treatmentid
	group by d.DiagnosisName, t.TreatmentName)
select DiagnosisName, TreatmentName, Treatment_Frequency from cte where rnk=1;
-- ------------------------------------------ using Subquery -------------------------------------------------------------------------------------------------
select s.DiagnosisName, s.TreatmentName, s.Treatment_frequency from
(select
	d.DiagnosisName,
    t.TreatmentName,
    count(t.TreatmentID) as treatment_frequency,
    rank() over(partition by DiagnosisName order by count(t.TreatmentID) desc) as rnk
from
	dim_diagnosis d
		join
	patientvisits pt on d.diagnosisID = pt.diagnosisID
		join
	dim_treatment t on pt.treatmentid = t.treatmentid
group by d.DiagnosisName, t.TreatmentName) s;
-- ------------------------------------------------------------------------------------------------------------------------------------------------------
