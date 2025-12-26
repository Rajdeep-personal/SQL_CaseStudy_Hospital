CREATE DATABASE IF NOT EXISTS SQL_Case_Studies;

use sql_case_studies;

-- Data Cleaning (Patient Table)
-- ------ Remove patient rows where FirstName is missing
-- ------ Standardize First Name and Last Name to Proper Case and create a fullname column
-- ------ Gender Values should be either Male or Female
-- ------ Split CityStateCountry into City, State and Country Columns

select * from dim_patient;

select distinct Gender from dim_patient;

CREATE TABLE dim_patient_clean(
PatientID varchar(20) Primary Key,
FullName varchar(120),
Gender varchar(10),
DOB date,
City varchar(50),
State varchar(50),
Country varchar(50)
);

INSERT INTO dim_patient_clean(
PatientID, FullName, Gender, DOB, City, State, Country)
select 
p.PatientID,
concat(
	concat(UPPER(LEFT(LTRIM(RTRIM(p.FirstName)),1)),Lower(substring(LTRIM(RTRIM(p.FirstName)),2,LENGTH(LTRIM(RTRIM(p.FirstName)))))),
    ' ',
    concat(UPPER(LEFT(LTRIM(RTRIM(p.LastName)),1)),Lower(substring(LTRIM(RTRIM(p.LastName)),2,LENGTH(LTRIM(RTRIM(p.LastName))))))
    ) as Full_Name,    
case when p.Gender = 'M' then 'Male'
	 When p.Gender = 'F' then 'Female'
     Else p.Gender
End as Gender,
p.DOB,
TRIM(substring_index(p.CityStateCountry,',',1)) as City,
TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(p.CityStateCountry, ',', 2), ',', -1)) AS State,
TRIM(SUBSTRING_INDEX(p.CityStateCountry, ',', -1)) AS Country
FROM Dim_Patient p
where p.FirstName is not null;



-- ---------------------------------- Trimming The First Name & Last Name ------------------------------------------------------------------------------------------
select concat(UPPER(LEFT(LTRIM(RTRIM(p.FirstName)),1)),Lower(substring(LTRIM(RTRIM(p.FirstName)),2,LENGTH(LTRIM(RTRIM(p.FirstName)))))) as first_name
from dim_patient p;
select concat(UPPER(LEFT(LTRIM(RTRIM(p.LastName)),1)),Lower(substring(LTRIM(RTRIM(p.LastName)),2,LENGTH(LTRIM(RTRIM(p.LastName)))))) as Last_name
from dim_patient p;
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ---------------------------------- Making Full Name using First Name and Last Name -------------------------------------------------------------------------------
select concat(
	concat(UPPER(LEFT(LTRIM(RTRIM(p.FirstName)),1)),Lower(substring(LTRIM(RTRIM(p.FirstName)),2,LENGTH(LTRIM(RTRIM(p.FirstName)))))),
    ' ',
    concat(UPPER(LEFT(LTRIM(RTRIM(p.LastName)),1)),Lower(substring(LTRIM(RTRIM(p.LastName)),2,LENGTH(LTRIM(RTRIM(p.LastName))))))
    ) as Full_Name from dim_patient p;
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- --------- Full Query with Trimmed First Name, Last Name, corrected Gender, DOB and extraction of City, State & Country from the respective column ----------------
select 
p.PatientID,
concat(
	concat(UPPER(LEFT(LTRIM(RTRIM(p.FirstName)),1)),Lower(substring(LTRIM(RTRIM(p.FirstName)),2,LENGTH(LTRIM(RTRIM(p.FirstName)))))),
    ' ',
    concat(UPPER(LEFT(LTRIM(RTRIM(p.LastName)),1)),Lower(substring(LTRIM(RTRIM(p.LastName)),2,LENGTH(LTRIM(RTRIM(p.LastName))))))
    ) as Full_Name,    
case when p.Gender = 'M' then 'Male'
	 When p.Gender = 'F' then 'Female'
     Else p.Gender
End as Gender,
p.DOB,
TRIM(substring_index(p.CityStateCountry,',',1)) as City,
TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(p.CityStateCountry, ',', 2), ',', -1)) AS State,
TRIM(SUBSTRING_INDEX(p.CityStateCountry, ',', -1)) AS Country
FROM Dim_Patient p
where p.FirstName is not null;
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Data Cleaning (Department Table)
-- ------ Remove Departments where Department category is missing
-- ------ Drop HOD and DepartmentName Columns
-- ------ Use specialization as DepartmentName column.

select * from dim_department;

create table DIM_Department_Clean(
	DepartmentID varchar(20) primary key,
    DepartmentName varchar(100),
    DepartmentCategory varchar(100)
);
Insert into DIM_Department_Clean(
	DepartmentID, DepartmentName, DepartmentCategory)
select d.DepartmentID, d.Specialization as DepartmentName, d.DepartmentCategory
from Dim_Department d
where d.DepartmentCategory IS NOT NULL;
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Data Cleaning (Patient Visits Table)
-- ------ Merge all yearly visit tables (2020-2025) into one consolidated Patientvisits table

-- -------------------------- Creating a new Patients Table ---------------------------------------------------------------------------------------------------------
CREATE TABLE PatientVisits (
  VisitID varchar(20) PRIMARY KEY,
  PatientID varchar(20),
  DoctorID varchar(20),
  DepartmentID varchar(20),
  DiagnosisID varchar(20),
  TreatmentID varchar(20),
  PaymentMethodID varchar(20),
  VisitDate date,
  VisitTime time,
  DischargeDate date,
  BillAmount decimal(18,2),
  InsuranceAmount decimal(18,2),
  SatisfactionScore integer,
  WaitTimeMinutes integer,
FOREIGN KEY (PatientID) REFERENCES Dim_Patient_clean(PatientID),
FOREIGN KEY (DoctorID) REFERENCES Dim_Doctor(DoctorID),
FOREIGN KEY (DepartmentID) REFERENCES Dim_Department_clean(DepartmentID),
FOREIGN KEY (DiagnosisID) REFERENCES Dim_Diagnosis(DiagnosisID),
FOREIGN KEY (TreatmentID) REFERENCES Dim_Treatment(TreatmentID),
FOREIGN KEY (PaymentMethodID) REFERENCES Dim_PaymentMethod(PaymentMethodID)
);

-- ------------------------------- Merging all Patients' table data in a single table -------------------------------------------------------------------------------
Insert into PatientVisits(
VisitID, PatientID, DoctorID, DepartmentID, DiagnosisID, TreatmentID,
PaymentMethodID, VisitDate, VisitTime, DischargeDate, BillAmount, InsuranceAmount, SatisfactionScore, WaitTimeMinutes)

Select 
VisitID, PatientID, DoctorID, DepartmentID, DiagnosisID, TreatmentID,
PaymentMethodID, VisitDate, VisitTime, DischargeDate, BillAmount, InsuranceAmount, SatisfactionScore, WaitTimeMinutes
FROM PatientVisits_2020_2021

Union All

Select 
VisitID, PatientID, DoctorID, DepartmentID, DiagnosisID, TreatmentID,
PaymentMethodID, VisitDate, VisitTime, DischargeDate, BillAmount, InsuranceAmount, SatisfactionScore, WaitTimeMinutes
FROM PatientVisits_2022_2023

Union All

Select 
VisitID, PatientID, DoctorID, DepartmentID, DiagnosisID, TreatmentID,
PaymentMethodID, VisitDate, VisitTime, DischargeDate, BillAmount, InsuranceAmount, SatisfactionScore, WaitTimeMinutes
FROM PatientVisits_2024

Union All

Select 
VisitID, PatientID, DoctorID, DepartmentID, DiagnosisID, TreatmentID,
PaymentMethodID, VisitDate, VisitTime, DischargeDate, BillAmount, InsuranceAmount, SatisfactionScore, WaitTimeMinutes
FROM PatientVisits_2025;

