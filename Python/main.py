# Getting Necessary Data From The CSV
import pandas as pd 

#Paste you file fath 
df = pd.read_csv("D:/accepted_2007_to_2018q4.csv/accepted_2007_to_2018Q4.csv")


important_columns = [ "id",
    "loan_status",
    "loan_amnt",
    "funded_amnt",
    "term",
    "int_rate",
    "installment",
    "grade",
    "sub_grade",
    "purpose",
    "annual_inc",
    "emp_length",
    "home_ownership",
    "verification_status",
    "issue_d",
    "addr_state",
    "dti",
    "fico_range_low",
    "fico_range_high",
    "earliest_cr_line",
    "delinq_2yrs",
    "inq_last_6mths",
    "open_acc",
    "total_acc",
    "pub_rec",
    "pub_rec_bankruptcies",
    "revol_bal",
    "revol_util",
    "mths_since_last_delinq",
    "tot_cur_bal",
    "total_rev_hi_lim",
    "mo_sin_old_rev_tl_op",
    "mort_acc",
    "num_actv_bc_tl",
    "num_actv_rev_tl",
    "bc_util",
    "pct_tl_nvr_dlq"
]

df = df[important_columns]

df.to_csv('D:/loans.csv', index = False)
