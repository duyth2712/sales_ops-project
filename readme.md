# Sales Operations Analytics Mini Project

This project simulates a Sales Operations data pipeline from raw CSV files to a clean analytical dataset and Power BI dashboard.

The goal is to:

* Build a staging → core (curated) data model
* Handle data quality issues (missing keys, inconsistent names)
* Ensure only valid leads are used for KPI reporting
* Produce operations-focused analytics for decision-makin

## Data Architecture

The project follows a layered data design:
1. Raw CSV
2. Staging (stag schema)
3. Core(dbo schema)
4. Analytics & Power BI Dashboard

### Schemas

* **stag:** Raw data loaded from CSV, no constraints
* **dbo:** Cleaned, deduplicated, relational tables with PK/FK

## ETL Flow

### 1. Staging

* Load raw CSV files using BULK INSERT
* No primary keys or foreign keys
* Data mirrors source exactly

### 2. Transform

* Insert new dimension records (accounts, products, sales agents)
* Resolve IDs via name matching
* Load only valid sales pipeline records
* Invalid records are written to a reject table

### 3. Validation & Reconciliation

* Compare row counts between staging and core
* Detect missing foreign keys
* Identify rejected records and data mismatches* 
* Ensure KPIs are calculated from valid data only

## Data Quality Handling

The project explicitly handles common Sales Ops issues:

* Missing account names
* Inconsistent product naming (e.g. GTXPro vs GTX Pro)
* Orphan pipeline records
Invalid records are stored in:
````
dbo.sales_pipeline_rejects
````

This ensures:

* No KPI distortion
* Full auditability
* Clear separation between valid and rejected leads

## Analytics & Dashboard
1. Key Metrics

* Pipeline by Deal Stage
* Revenue by Product
* Sales Agent Performance
* Won Deals vs Total Leads

2. Design Principles

* Only valid leads are used
* Dashboard updates automatically on database refresh
* Filters for Deal Stage, Product, Sales Agent, Close Date

## 🛠️ Tools Used

* MSSQL Server
* Power BI
* Excel
* Git

## Data Source

* CRM Sales Opportunities dataset: https://mavenanalytics.io/data-playground/crm-sales-opportunities
