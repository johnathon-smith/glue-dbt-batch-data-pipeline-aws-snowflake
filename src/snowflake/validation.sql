-- Validate that each table in the production database has data in it after the dbt job run
SELECT 
    table_name, 
    row_count
FROM
    information_schema.tables 
WHERE 
    table_catalog = 'GLUE_DB_PRODUCTION'
    AND table_type = 'BASE TABLE'
ORDER BY 
    table_name;
