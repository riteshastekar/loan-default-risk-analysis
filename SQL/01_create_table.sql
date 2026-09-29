--Creating Database to Store the Data
CREATE DATABASE loan_data_analysis
GO
USE loan_data_analysis
GO
--Creating Table With Required Columns
CREATE TABLE loans_staging (
    id NVARCHAR(50), loan_status NVARCHAR(100), loan_amnt NVARCHAR(50),
    funded_amnt NVARCHAR(50), term NVARCHAR(50), int_rate NVARCHAR(50),
    installment NVARCHAR(50), grade NVARCHAR(50), sub_grade NVARCHAR(50),
    purpose NVARCHAR(100), annual_inc NVARCHAR(50), emp_length NVARCHAR(50),
    home_ownership NVARCHAR(50), verification_status NVARCHAR(50),
    addr_state NVARCHAR(50), dti NVARCHAR(50), fico_range_low NVARCHAR(50),
    fico_range_high NVARCHAR(50), earliest_cr_line NVARCHAR(50),
    delinq_2yrs NVARCHAR(50), inq_last_6mths NVARCHAR(50), open_acc NVARCHAR(50),
    total_acc NVARCHAR(50), pub_rec NVARCHAR(50), pub_rec_bankruptcies NVARCHAR(50),
    revol_bal NVARCHAR(50), revol_util NVARCHAR(50), mths_since_last_delinq NVARCHAR(50),
    tot_cur_bal NVARCHAR(50), total_rev_hi_lim NVARCHAR(50), mo_sin_old_rev_tl_op NVARCHAR(50),
    mort_acc NVARCHAR(50), num_actv_bc_tl NVARCHAR(50), num_actv_rev_tl NVARCHAR(50),
    bc_util NVARCHAR(50)
);
