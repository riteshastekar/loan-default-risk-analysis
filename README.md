# Loan Default Risk Analysis

End-to-end data analytics project that cleans and models 2.26M+ loan records in **SQL Server**, then visualizes risk in an interactive **Power BI** dashboard — built to identify which customer segments carry the highest default risk and which applications a credit team should manually review.

![Portfolio Overview](screenshots/01_portfolio_overview.png)

---

## Business Question

> **Which customer segments have the highest loan default probability, and which applications should the credit team manually review?**

Lenders can't manually review every application. This project builds a data-driven view of *where* risk concentrates in the loan portfolio, and a rule-based scoring system to flag the applications most worth a human's attention — balancing risk coverage against the credit team's review capacity.

---

## Dataset

- **Source:** LendingClub consumer loan data (`accepted_2007_to_2018Q4.csv`, public, anonymized)
- **Raw size:** 150+ columns; reduced in `python/01_select_columns.py` to the 36 relevant to default-risk analysis
- **Size after cleaning:** 2,260,668 loan records
- **Fields used:** loan amount, grade, purpose, term, interest rate, borrower income, DTI, FICO score range, revolving utilization, credit inquiries, delinquency history, employment length, state, verification status, and final loan outcome (`loan_status`)

---

## Tools & Tech Stack

| Stage | Tool |
|---|---|
| Column selection / pre-processing | Python (pandas) |
| Data staging & cleaning | SQL Server (T-SQL, stored procedures) |
| Bulk ingestion | `BULK INSERT` |
| Transformation & recoding | `UPDATE` / `CASE WHEN` (state names, income brackets) |
| Risk-flag logic | SQL `VIEW` (`app_review`) |
| Dashboard & visualization | Power BI (DAX measures) |

---

## Pipeline Overview

```
accepted_2007_to_2018Q4.csv (raw LendingClub file, 150+ columns)
   │
   ▼
01_select_columns.py       → pandas: selects the 36 relevant columns → loans.csv
   │
   ▼
01_create_table.sql        → creates loan_data_analysis DB + loans_staging table
   │
   ▼
02_clean_and_transform.sql → stored procedure: bulk load loans.csv, drop NULL status rows,
   │                          recode state codes → full names, bucket income brackets
   ▼
03_kpi_queries.sql         → default-rate KPIs by segment + app_review scoring view
   │
   ▼
Power BI (.pbix)           → DAX measures, risk dashboard, drill-through detail page
```

### 1. Column selection (`01_select_columns.py`)
The raw LendingClub export (`accepted_2007_to_2018Q4.csv`) has 150+ columns, most of which aren't needed for this analysis. A short pandas script loads the full file, selects the 36 columns relevant to default-risk analysis (loan terms, borrower profile, credit history, and outcome), and writes them out to `loans.csv` — the file the SQL pipeline bulk-loads from.

### 2. Table creation (`01_create_table.sql`)
Drops and recreates the `loan_data_analysis` database, then builds `loans_staging` with explicit data types set at creation (numeric columns like `loan_amnt`, `annual_inc`, `Debt_to_income_ratio`, `fico_range_low`, `delinq_2yrs`, `inq_last_6mths`, `pub_rec`, `revol_util` typed directly, rather than loaded as text) to avoid downstream casting errors.

### 3. Cleaning & transformation (`02_clean_and_transform.sql`)
A stored procedure (`load_data`) that:
- Truncates and bulk-loads `loans.csv` with logged step timings
- Removes rows with a NULL `loan_status` (incomplete/corrupt records)
- Recodes `addr_state` abbreviations into full state names
- Buckets `annual_inc` into `income_bracket` ranges (`0–25K`, `25K–75K`, `75K–150K`, `150K–500K`, `500K–1M`, `1M–10M`, `10M+`)
- Wraps everything in `TRY...CATCH` with error logging (`ERROR_MESSAGE`, `ERROR_NUMBER`, `ERROR_STATE`)

### 4. KPI & scoring logic (`03_kpi_queries.sql`)
- Default probability calculated as `Charged Off + Default` ÷ loans with a **known outcome** (excludes Current, Late, and In Grace Period loans, since their outcome isn't final yet)
- Segmented by **geography, loan purpose, employment length, income bracket, and grade**
- `app_review` view: a 6-factor rule engine that flags an application for manual review if it trips any of:
  - Debt-to-income ratio > 30
  - FICO score < 660
  - Revolving utilization > 80%
  - 3+ credit inquiries in the last 6 months
  - 1+ delinquency, public record, or bankruptcy
  - Unverified income on a loan over $20,000

### 5. Power BI dashboard
DAX measures (see `dax_measures.txt`) calculate default rate, manual review rate, and a **portfolio-average lift** so each segment chart shows a dashed reference line — segments above the average are automatically colored red.

---

## Dashboard

**4 pages:** Portfolio Overview → Risk by Segment → Manual Review Queue → Risk Score Detail (drill-through)

### Portfolio Overview
![Portfolio Overview](screenshots/01_portfolio_overview.png)

2,260,668 total loans worth **$34.02B**, with an overall **default probability of 19.98%**. Loan status is split across Fully Paid (47.6%), Current (38.9%), and Charged Off (11.9%), with a visible default-rate spike around 2008–2010 (financial crisis) tapering through later years.

### Risk by Segment
![Risk by Segment](screenshots/02_risk_by_segment.png)

Each chart carries a dashed line at the 19.98% portfolio average, with bars above it colored red:
- **Purpose:** `small_business` loans default most (~30%); `wedding` loans least (~12%)
- **Income bracket:** borrowers earning **$0–25K** default at ~24%, roughly double the rate of borrowers earning $500K–$1M (~13%)
- **Employment history:** borrowers who didn't provide employment length default highest (~27%); 10+ year tenure is the safest group (~19%)
- **Geography:** default rate by state, mapped — concentrated in parts of the South and Midwest

### Manual Review Queue
![Manual Review Queue](screenshots/03_manual_review_queue.png)

**1,201,868 applications (53.16%)** trip at least one review rule. The flag-count distribution shows most flagged loans trip only 1–2 rules, with a small tail of severe cases (728 loans trip 4 rules, 1 loan trips all 5 risk categories).

### Risk Score Detail (drill-through)
![Risk Score Detail](screenshots/04_risk_score_detail_drillthrough.png)

Clicking any flagged loan ID opens a detail card showing exactly why it was flagged — DTI, revolving utilization, FICO, delinquency count, and recent inquiries — so the credit team can see the reasoning behind each review, not just the decision.

---

## Key Findings

- **Overall portfolio default rate: 19.98%** across 2.26M loans with a known outcome.
- **`small_business`** is the single riskiest loan purpose (~30% default), roughly **2.5× riskier** than `wedding` loans (~12%).
- Borrowers earning **under $25K** default at roughly **double the rate** of borrowers earning $500K–$1M.
- **53.16%** of all applications trip at least one manual-review rule, but the risk is concentrated: 79% of flagged loans trip only 1 rule, while a small group of 729 loans trip 4 or more — these are the highest-priority cases for the credit team.

---

## Repository Structure

```
loan-default-risk-analysis/
├── README.md
├── PYTHON/
│   └── 01_select_columns.py
├── SQL/
│   ├── 01_create_table.sql
│   ├── 02_clean_and_transform.sql
│   └── 03_kpi_queries.sql
├── Power Bi/
    └── dax_measures.txt
    └── screenshots/
        ├── 01_portfolio_overview.png
        ├── 02_risk_by_segment.png
        ├── 03_manual_review_queue.png
        └── 04_risk_score_detail_drillthrough.png
```

> The `.pbix` file isn't included directly due to GitHub's file-size limits on large datasets. [Add your published Power BI link here] once published, or request the file directly.

---

## How to Reproduce

1. Download the raw LendingClub dataset (`accepted_2007_to_2018Q4.csv`) and update the file path in `python/01_select_columns.py`, then run it to produce `loans.csv` with only the 36 relevant columns.
2. Run `sql/01_create_table.sql` in SQL Server Management Studio to create the database and staging table.
3. Update the file path in `sql/02_clean_and_transform.sql` to point to your local `loans.csv`, then run it — this executes the `load_data` stored procedure (bulk load, cleaning, recoding).
4. Run `sql/03_kpi_queries.sql` to generate the segment KPIs and create the `app_review` scoring view.
5. In Power BI Desktop, connect to the `loan_data_analysis` database (SQL Server connector), import `loans_staging` and the `app_review` view, then add the DAX measures from `dax/dax_measures.txt`.

---

## Author

**Ritesh Astekar**
Entry-level Data Analyst | SQL, Power BI, Python, Excel
[LinkedIn] · [GitHub] · riteshastekar40@gmail.com
