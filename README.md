# Production-Grade Data Pipeline  
### AWS Glue → Amazon S3 → Snowflake → dbt (Dev & Prod)

## Executive Summary
This project demonstrates the design, implementation, and production deployment of a modern batch data pipeline using AWS, Snowflake, and dbt. The pipeline ingests semi-structured JSON data from a public GitHub repository, lands it in Amazon S3 via AWS Glue, loads it into Snowflake using a secure storage integration and external stage, and transforms the data through a layered dbt modeling approach (RAW → TRANSFORM → MART).

The project emphasizes **real-world data engineering best practices**, including IAM role isolation, external data access patterns, dbt macros, testing, environment separation, and production validation.

All infrastructure was intentionally **validated and then torn down** to avoid ongoing cloud costs. This repository serves as the permanent artifact proving implementation, correctness, and engineering decision-making.

---

## Architecture Overview
**High-level flow:**
1. AWS Glue ingests JSON data from GitHub
2. Data is written to Amazon S3
3. Snowflake reads data via Storage Integration and External Stage
4. dbt performs transformations and testing
5. Models are promoted to a production database

This architecture mirrors patterns commonly used in production analytics and data warehousing environments.

---

## Table of Contents
- [Technology Stack](#technology-stack)
- [Security & IAM Design](#security--iam-design)
- [Data Ingestion (AWS Glue)](#data-ingestion-aws-glue)
- [Snowflake External Data Access](#snowflake-external-data-access)
- [dbt Project Design](#dbt-project-design)
- [Transformation Layers](#transformation-layers)
- [Testing & Data Quality](#testing--data-quality)
- [Production Deployment](#production-deployment)
- [Validation & Verification](#validation--verification)
- [Repository Contents](#repository-contents)
- [Infrastructure Teardown](#infrastructure-teardown)

---

## Technology Stack
- **AWS Glue** – Serverless batch ingestion
- **Amazon S3** – Object storage / data lake
- **Snowflake** – Cloud data warehouse
- **dbt Core & dbt Cloud** – Transformations, testing, orchestration
- **Python** – Glue ETL logic
- **SQL** – Snowflake objects and dbt models

---

## Security & IAM Design
Two distinct IAM roles were created to enforce separation of concerns and least-privilege access.

### Glue Service Role
- Trusted by the AWS Glue service
- Permissions:
  - Read/write access to the S3 data bucket
  - CloudWatch Logs access for job monitoring

### Snowflake Storage Integration Role
- Trusted by Snowflake via External ID
- Read-only access to the S3 `/data` prefix
- Used exclusively for Snowflake external data access

This design reflects production-grade security practices.

---

## Data Ingestion (AWS Glue)
- Implemented a Python-based AWS Glue job
- Pulls JSON data from a public GitHub repository
- Writes raw data directly to Amazon S3
- Job executed manually for validation

**Verification steps:**
- Successful Glue job execution
- Confirmed data landed in the S3 `/data` directory
- Reviewed CloudWatch logs for errors

---

## Snowflake External Data Access
Snowflake was configured to read data directly from S3 using native integrations.

Steps performed:
1. Created a dedicated Snowflake database for the project
2. Created a Storage Integration referencing:
   - IAM role ARN
   - S3 bucket and data prefix
3. Retrieved Snowflake AWS User ARN and External ID
4. Updated IAM trust relationship
5. Created an External Stage pointing to S3
6. Validated access using:
   ls @GLUE_S3_STAGE;  
7. Created a RAW table with a single VARIANT column

This approach avoids unnecessary data movement and follows Snowflake best practices.

---

## dbt Project Design
The dbt project was initialized using a Snowflake partner connection and structured for scalability and maintainability.

### Key design decisions:
- Separate development and production environments
- Explicit schemas per transformation layer
- Reusable macros for ingestion logic
- Model-level documentation and testing

---

## Transformation Layers

### RAW Layer
- Loads data from the Snowflake external stage into Snowflake-managed table (the copy table)
- Uses a custom dbt macro to ensure idempotent batch loads:
  - Deletes existing records in the copy table
  - Reloads fresh data from the external stage on each run
- Performs an initial `LATERAL FLATTEN` on the JSON payload
- Adds an ingestion timestamp column (`insert_dts`)
- Loads data into the RAW table

This layer preserves the original structure while making the data queryable and traceable.

---

### TRANSFORM Layer
- Fully flattens remaining nested JSON structures
- Standardizes and cleans fields
- Produces analysis-ready intermediate table

---

### MART Layer
- Final analytics-ready models
- Data grouped by continent
- Optimized for downstream reporting and consumption

---

## Testing & Data Quality
All dbt models include built-in tests to enforce data integrity and reliability.

**Tests applied across layers:**
- `unique`
- `not_null`

Test definitions are maintained alongside models using schema YAML files:
- `raw.yml`
- `transform.yml`
- `mart.yml`

All tests passed successfully in both development and production environments.

---

## Production Deployment
A dedicated production database was created in Snowflake to mirror real-world deployment practices.

**Deployment steps:**
1. Created a new production environment in dbt
2. Pointed the production environment to a separate Snowflake database
3. Created a dbt Cloud job configured to run:
   dbt build
4. Executed all models and tests end-to-end in production

This ensured that transformations, tests, and dependencies ran successfully in a production context.

---

## Validation and Verification

### Post-deployment validation steps included:
- Confirming RAW, TRANSFORM, and MART schemas were created in the production database
- Verifying all expected tables existed within each schema
- Querying Snowflake’s information schema to confirm record counts
- Spot-checking table contents for correctness and completeness

These steps confirmed both structural and data-level correctness.

---

## Repository Contents

### This repository includes all artifacts required to review and understand the pipeline:
- AWS Glue ETL scripts
- Snowflake SQL for integrations, stages, and databases
- Complete dbt project (models, macros, and tests)
- Architecture diagrams
- Execution and validation screenshots
- Infrastructure teardown documentation

The repository serves as a permanent record of the project after cloud resources were removed.

---

## Infrastructure Teardown

All AWS and Snowflake resources were intentionally deleted after successful validation to avoid ongoing cloud costs.

### This repository remains as proof of:
- End-to-end pipeline ownership
- Secure cloud configuration
- Production deployment practices
- Data quality enforcement
