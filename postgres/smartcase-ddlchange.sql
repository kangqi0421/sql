DO $$
    BEGIN
    IF NOT EXISTS(SELECT *
        FROM information_schema.columns
        WHERE table_schema='riskengine' and table_name='case_mgmt_issues' and column_name='fraud_classification')
        THEN
        ALTER TABLE case_mgmt_issues RENAME COLUMN "fraud_clasification" TO "fraud_classification";
    END IF;
END $$;

DO $$
    BEGIN
    IF EXISTS(SELECT *
        FROM information_schema.columns
        where table_schema = 'riskengine' and column_name='id' and table_name='case_mgmt_issues' and data_type='bigint')
        THEN
        ALTER TABLE case_mgmt_issues
        ALTER COLUMN id TYPE VARCHAR(20);
    END IF;
END $$;