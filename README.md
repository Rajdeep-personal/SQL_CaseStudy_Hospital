# SQL_CaseStudy_Hospital
This case study shows some practice and data exploration for a few business questions where the concepts of Join, CTE, SubQuery, Window Function, case statement along with data cleaning have been implemented. The Platform which has been used here is MySQL Workbench. There are total 7 tables used in this case study.
The ER Diagram has been kept inside the repository for reference.

The entire operation includes creation of tables, insertion of data into those along with data cleaning followed by the data exploration for a few business questions.

# The cleaning operation includes:

  **1. Patient Table:**
  
    a. Remove patient rows where FirstName is missing
  
    b. Standardize First Name and Last Name to Proper Case and create a fullname column
  
    c. Gender Values should be either Male or Female
  
    d. Split CityStateCountry into City, State and Country Columns

  **2. Department Table:**
  
    a. Remove Departments where Department category is missing
  
    b. Drop HOD and DepartmentName Columns
  
    c. Use specialization as DepartmentName column
 

  **3. PatienVisits Table:**
  
    a. Merge all yearly visit tables (2020-2025) into one consolidated Patientvisits table

  Total 3 .sql notebooks are present in this repository - 
  
     1. For Table Creation and Data Insertion
     
     2. For Data Cleaning
     
     3. For Data Exploration

# There are total 10 business questions which have been answered using the concepts of JOIN, CTE, Window Function, Date Function, Substring function etc and a few of which have been answered by different alternatives for future reference.

The Business Questions are as follows:

**Q1. For each doctor, count how many distinct patients they have treated.**

**Q2. Show the revenue split by each payment method, along with total visits.**

**Q3. Categorize patients into groups and calculate the average bill amount for each age band.(Assume age at time of visit based on VisitDate)**

**Q4. Find Total revenue and number of visits for each department.**

**Q5. Rank Departments based on their total revenue within each department category.**

**Q6. For each department, find the average satisfaction score and average wait time.**

**Q7. Compare the total number of hospital visits on weekdays vs weekends.**

**Q8. For each Month, calculate total visits and a running cumulative total of visits.**

**Q9. Find the doctors with the highest average satisfaction score (minimum 100 visits)**

**Q10. Identify the most commonly prescribed treatment for each diagnosis.**
