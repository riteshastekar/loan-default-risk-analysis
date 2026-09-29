CREATE OR ALTER PROCEDURE load_data AS
BEGIN
    DECLARE @start_time DATETIME,@end_time DATETIME,@batch_start_time DATETIME,@batch_end_time DATETIME;
    BEGIN TRY
    SET @batch_start_time = GETDATE();
    print'====================================================';
	print'loading data into the table';
	print'====================================================';
        SET @start_time = GETDATE();
        print'>>Truncating table :loans_staging';
	    TRUNCATE TABLE loans_staging;
        BULK INSERT loans_staging
        FROM 'D:\loans.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',   
            CODEPAGE = '65001',       
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT'>>LOAD DURATION:' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'sec';
        
        DELETE FROM loans_staging WHERE loan_status IS NULL
        
        
    print'============================================================================================';


    print'====================================================';
	print'Mapping values to different labels Ex:tx->Texas';
	print'====================================================';

        SET @start_time = GETDATE();
        UPDATE loans_staging
        SET addr_state = CASE addr_state
            WHEN 'TX' THEN 'Texas'
            WHEN 'KS' THEN 'Kansas'
            WHEN 'PA' THEN 'Pennsylvania'
            WHEN 'WI' THEN 'Wisconsin'
            WHEN 'DE' THEN 'Delaware'
            WHEN 'IN' THEN 'Indiana'
            WHEN 'IL' THEN 'Illinois'
            WHEN 'NH' THEN 'New Hampshire'
            WHEN 'MD' THEN 'Maryland'
            WHEN 'CO' THEN 'Colorado'
            WHEN 'DC' THEN 'District of Columbia'
            WHEN 'MI' THEN 'Michigan'
            WHEN 'VA' THEN 'Virginia'
            WHEN 'ME' THEN 'Maine'
            WHEN 'AK' THEN 'Alaska'
            WHEN 'SC' THEN 'South Carolina'
            WHEN 'RI' THEN 'Rhode Island'
            WHEN 'WA' THEN 'Washington'
            WHEN 'MA' THEN 'Massachusetts'
            WHEN 'NV' THEN 'Nevada'
            WHEN 'NY' THEN 'New York'
            WHEN 'OH' THEN 'Ohio'
            WHEN 'SD' THEN 'South Dakota'
            WHEN 'CT' THEN 'Connecticut'
            WHEN 'LA' THEN 'Louisiana'
            WHEN 'NJ' THEN 'New Jersey'
            WHEN 'MO' THEN 'Missouri'
            WHEN 'CA' THEN 'California'
            WHEN 'OR' THEN 'Oregon'
            WHEN 'MN' THEN 'Minnesota'
            WHEN 'MT' THEN 'Montana'
            WHEN 'OK' THEN 'Oklahoma'
            WHEN 'FL' THEN 'Florida'
            WHEN 'AR' THEN 'Arkansas'
            WHEN 'IA' THEN 'Iowa'
            WHEN 'VT' THEN 'Vermont'
            WHEN 'AL' THEN 'Alabama'
            WHEN 'ND' THEN 'North Dakota'
            WHEN 'ID' THEN 'Idaho'
            WHEN 'GA' THEN 'Georgia'
            WHEN 'AZ' THEN 'Arizona'
            WHEN 'MS' THEN 'Mississippi'
            WHEN 'TN' THEN 'Tennessee'
            WHEN 'NC' THEN 'North Carolina'
            WHEN 'NE' THEN 'Nebraska'
            WHEN 'WV' THEN 'West Virginia'
            WHEN 'WY' THEN 'Wyoming'
            WHEN 'HI' THEN 'Hawaii'
            WHEN 'NM' THEN 'New Mexico'
            WHEN 'KY' THEN 'Kentucky'
            WHEN 'UT' THEN 'Utah'
            ELSE addr_state   
        END
        SET @end_time = GETDATE();
        PRINT'>>LOAD DURATION:' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'sec';


    print'============================================================================================';


    print'====================================================';
	print'Creating Income Bracket Column';
	print'====================================================';

        SET @start_time = GETDATE();
        UPDATE loans_staging
        SET income_bracket = CASE
            WHEN annual_inc IS NULL              THEN 'Unknown'
            WHEN annual_inc <= 25000             THEN '0 - 25K'
            WHEN annual_inc <= 75000             THEN '25K - 75K'
            WHEN annual_inc <= 150000            THEN '75K - 150K'
            WHEN annual_inc <= 500000            THEN '150K - 500K'
            WHEN annual_inc <= 1000000           THEN '500K - 1M'
            WHEN annual_inc <= 10000000          THEN '1M - 10M'
            ELSE                                      '10M+'
        END
        SET @end_time = GETDATE();
        PRINT'>>LOAD DURATION:' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'sec';
        SET @batch_end_time = GETDATE();
    PRINT'======================================';
	    PRINT'DONE';
	    PRINT'>>DURATION OF TASK:' +CAST(DATEDIFF(minute,@batch_start_time,@batch_end_time)AS NVARCHAR)+ 'min';
	PRINT'======================================';
    END TRY
    BEGIN CATCH
        PRINT'=======================================================';
		PRINT'ERROR MESSAGE OCCURED DURING LOADING';
		PRINT'ERROR MESSAGE:' + ERROR_MESSAGE();
		PRINT'ERROR MESSAGE:' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT'ERROR MESSAGE:' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT'=======================================================';
    END CATCH
       
END;


