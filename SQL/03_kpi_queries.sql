--Loan Default Probability By Geography
SELECT TOP 10 addr_state,
    COUNT(*) AS total_known_outcome,
    ROUND(100.0 * SUM(CASE WHEN loan_status IN ('Charged Off','Default',
        'Does not meet the credit policy. Status:Charged Off') THEN 1 ELSE 0 END)
        / COUNT(*), 2) AS default_probability
FROM loans_staging
WHERE loan_status IN ('Fully Paid','Charged Off','Default',
      'Does not meet the credit policy. Status:Fully Paid',
      'Does not meet the credit policy. Status:Charged Off')
GROUP BY addr_state
ORDER BY default_probability DESC



--Loan Default Probability By Loan Purpose
SELECT purpose,
    COUNT(*) AS total_known_outcome,
    ROUND(100.0 * SUM(CASE WHEN loan_status IN ('Charged Off','Default',
        'Does not meet the credit policy. Status:Charged Off') THEN 1 ELSE 0 END)
        / COUNT(*), 2) AS default_probability
FROM loans_staging
WHERE loan_status IN ('Fully Paid','Charged Off','Default',
      'Does not meet the credit policy. Status:Fully Paid',
      'Does not meet the credit policy. Status:Charged Off')
GROUP BY purpose
ORDER BY default_probability DESC


--Loan Default Probability By Employment History
SELECT emp_length,
    COUNT(*) AS total_known_outcome,
    ROUND(100.0 * SUM(CASE WHEN loan_status IN ('Charged Off','Default',
        'Does not meet the credit policy. Status:Charged Off') THEN 1 ELSE 0 END)
        / COUNT(*), 2) AS default_probability
FROM loans_staging
WHERE loan_status IN ('Fully Paid','Charged Off','Default',
      'Does not meet the credit policy. Status:Fully Paid',
      'Does not meet the credit policy. Status:Charged Off')
GROUP BY emp_length
ORDER BY default_probability DESC



--Loan Default Probability By Income Bracket
SELECT income_bracket,
    COUNT(*) AS total_known_outcome,
    ROUND(100.0 * SUM(CASE WHEN loan_status IN ('Charged Off','Default',
        'Does not meet the credit policy. Status:Charged Off') THEN 1 ELSE 0 END)
        / COUNT(*), 2) AS default_probability
FROM loans_staging
WHERE loan_status IN ('Fully Paid','Charged Off','Default',
      'Does not meet the credit policy. Status:Fully Paid',
      'Does not meet the credit policy. Status:Charged Off')
GROUP BY income_bracket
ORDER BY default_probability DESC



--Loan Default Probability By Grade
SELECT grade,
    COUNT(*) AS total_known_outcome,
    ROUND(100.0 * SUM(CASE WHEN loan_status IN ('Charged Off','Default',
        'Does not meet the credit policy. Status:Charged Off') THEN 1 ELSE 0 END)
        / COUNT(*), 2) AS default_probability
FROM loans_staging
WHERE loan_status IN ('Fully Paid','Charged Off','Default',
      'Does not meet the credit policy. Status:Fully Paid',
      'Does not meet the credit policy. Status:Charged Off')
GROUP BY grade
ORDER BY default_probability DESC


--Which Application Should Credit Team Manually Review
WITH flags AS (
    SELECT id, loan_amnt, grade, purpose,
        CASE WHEN Debt_to_income_ratio > 30 THEN 1 ELSE 0 END +
        CASE WHEN fico_range_low < 660 THEN 1 ELSE 0 END +
        CASE WHEN revol_util > 80 THEN 1 ELSE 0 END +
        CASE WHEN inq_last_6mths >= 3 THEN 1 ELSE 0 END +
        CASE WHEN delinq_2yrs >= 1 OR pub_rec >= 1 OR pub_rec_bankruptcies >= 1 THEN 1 ELSE 0 END +
        CASE WHEN verification_status = 'Not Verified' AND loan_amnt > 20000 THEN 1 ELSE 0 END
        AS flags_triggered
    FROM loans_staging
)
SELECT id, loan_amnt, grade, purpose, flags_triggered,
       CASE WHEN flags_triggered >= 1 THEN 'Manual Review' ELSE 'Standard' END AS review_decision
FROM flags
ORDER BY flags_triggered DESC;





