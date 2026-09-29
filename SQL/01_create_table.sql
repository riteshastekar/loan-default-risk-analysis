USE master;
GO

-- Drop and recreate the 'DataWarehouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'loan_data_analysis')
BEGIN
    ALTER DATABASE loan_data_analysis SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE loan_data_analysis;
END;
GO

--Creating Database to Store the Data
CREATE DATABASE loan_data_analysis;
GO
USE loan_data_analysis;
GO
--Creating Table With Required Columns
IF OBJECT_ID('loans_staging','U') IS NOT NULL
	DROP TABLE loans_staging;
CREATE TABLE loans_staging (
    id NVARCHAR(50), loan_status NVARCHAR(100), loan_amnt DECIMAL(16,2),
    funded_amnt NVARCHAR(50), term NVARCHAR(50), int_rate NVARCHAR(50),
    installment NVARCHAR(50), grade NVARCHAR(50), sub_grade NVARCHAR(50),
    purpose NVARCHAR(100), annual_inc DECIMAL(20,2), emp_length NVARCHAR(50),
    home_ownership NVARCHAR(50), verification_status NVARCHAR(50),issue_d NVARCHAR(20),
    addr_state NVARCHAR(50), Debt_to_income_ratio DECIMAL(8,2), fico_range_low DECIMAL(6,2),
    fico_range_high NVARCHAR(50), earliest_cr_line NVARCHAR(50),
    delinq_2yrs DECIMAL(20,0), inq_last_6mths DECIMAL(20,0), open_acc NVARCHAR(50),
    total_acc NVARCHAR(50), pub_rec DECIMAL(20,0), pub_rec_bankruptcies DECIMAL(20,0),
    revol_bal NVARCHAR(50), revol_util DECIMAL(6,2), mths_since_last_delinq NVARCHAR(50),
    tot_cur_bal NVARCHAR(50), total_rev_hi_lim NVARCHAR(50), mo_sin_old_rev_tl_op NVARCHAR(50),
    mort_acc NVARCHAR(50), num_actv_bc_tl NVARCHAR(50), num_actv_rev_tl NVARCHAR(50),
    bc_util NVARCHAR(50)
);
