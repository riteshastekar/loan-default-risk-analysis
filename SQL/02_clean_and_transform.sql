--Inserting The Data Into The Table
BULK INSERT loans_staging
FROM 'D:\loans.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',   
    CODEPAGE = '65001',       
    TABLOCK
);

--Handling Nulls
DELETE FROM loans_staging
WHERE loan_status IS NULL
  
--Changing Column Name
EXEC sp_rename 'loans_staging.Debt-to-income ratio','Debt_to_income_ratio','COLUMN'
