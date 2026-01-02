-- Create the database for this project
CREATE OR REPLACE DATABASE GLUE_DB;

-- Create the storage integration with S3 now
CREATE OR REPLACE STORAGE INTEGRATION GLUE_S3_INT
TYPE = EXTERNAL_STAGE
STORAGE_PROVIDER = 'S3'
ENABLED = TRUE
STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::778277577883:role/dea-dbtglueproject-snowflake-role'
STORAGE_ALLOWED_LOCATIONS = ('s3://dea-dbtglueproject-data-bucket-001/data/');

-- Describe the newly created integration to get the needed AWS User ARN and External ID for the trusted relationship
DESC INTEGRATION GLUE_S3_INT;

-- Now create the stage with the storage integration
CREATE OR REPLACE STAGE GLUE_DB.PUBLIC.GLUE_S3_STAGE
STORAGE_INTEGRATION = GLUE_S3_INT
URL = 's3://dea-dbtglueproject-data-bucket-001/data/';

-- Verify connection established
ls @GLUE_DB.PUBLIC.GLUE_S3_STAGE;

-- Now create a copy table for the raw data
CREATE OR REPLACE TABLE GLUE_DB.PUBLIC.COUNTRY_DETAILS_CP
(
    DATA VARIANT
);
