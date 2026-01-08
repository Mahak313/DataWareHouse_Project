--CREATE DATABASE 'DATAWARE HOUSE'
USE master;   --(system database)
CREATE DATABASE DataWareHouse;
USE DataWareHouse;

--==============================*/
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'bronze')
BEGIN
    EXEC('CREATE SCHEMA bronze');
END
GO  --Seperater

--==============================*/
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'silver')
BEGIN
    EXEC('CREATE SCHEMA silver');
END
GO
--===============================
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'gold')
BEGIN
    EXEC('CREATE SCHEMA gold');
END
GO


-----------------------------------------------------------------------------------------------



--================================
--BRONZE TABLE
--=================================
-- Table create inside bronze schema 
IF OBJECT_ID ('bronze.crm_cust_info','U')IS NOT NULL
	DROP TABLE bronze.crm_cust_info
CREATE TABLE bronze.crm_cust_info(
cst_id INT,
cst_key NVARCHAR(50),
cst_fisrtname NVARCHAR(50),
cst_lastname NVARCHAR(50),
cst_material_status NVARCHAR(50),
cst_gndr NVARCHAR(50),
cst_create_date DATE
);
GO


--PRODUCT INFO
IF OBJECT_ID ('bronze.crm_prd_info','U')IS NOT NULL
	DROP TABLE bronze.crm_prd_info
CREATE TABLE bronze.crm_prd_info(
prd__id	INT,
prd_key	NVARCHAR(50),
prd_nm	NVARCHAR(50),
prd_cost	INT,
prd_line	NVARCHAR(50),
prd_start_dt	DATETIME,
prd_end_dt		DATETIME
);
GO



--SALES DETAILS
IF OBJECT_ID ('bronze.crm_sales_details','U')IS NOT NULL
	DROP TABLE bronze.crm_sales_details
CREATE TABLE bronze.crm_sales_details(
sls_ord_num NVARCHAR(50),
sls_prd_key	NVARCHAR(50),
sls_cust_id	INT,
sls_order_dt INT,
sls_ship_dt INT,
sls_due_dt INT,
sls_sales INT,   -- Sales amount
sls_quantity INT,
sls_price INT
);
GO



--ERP LOCATION
IF OBJECT_ID ('bronze.erp_loc_a101','U')IS NOT NULL
	DROP TABLE bronze.erp_loc_a101
CREATE TABLE bronze.erp_loc_a101(
cid NVARCHAR(50), -- Customer ID
cntry NVARCHAR(50)--Country
);
GO


--ERP CUSTOMER
IF OBJECT_ID ('bronze.erp_cust_az12','U')IS NOT NULL
	DROP TABLE bronze.erp_cust_az12
CREATE TABLE bronze.erp_cust_az12(
cid NVARCHAR(50),-- Customer ID
bdate DATE,	-- Birth date
gen NVARCHAR(50) -- Gender
);
GO


--ERP PRODUCTS CATEGORY
IF OBJECT_ID ('bronze.erp_px_cat_g1v2','U')IS NOT NULL
	DROP TABLE bronze.erp_px_cat_g1v2
CREATE TABLE bronze.erp_px_cat_g1v2(
id	NVARCHAR(50),  -- Product ID
cat	NVARCHAR(50),   -- Category
subcat	NVARCHAR(50), -- Sub-category
maintenance NVARCHAR(50)  --Maintenance flag
);



--==================================
--LOAD BRONZE PROCEDURE
--==================================
--BULK INSERT

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN


	DECLARE @start_time DATETIME,@end_time DATETIME,@batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time=GETDATE();
		PRINT '=====================================';
	    PRINT 'Loading Bronze Layer';
		PRINT '=====================================';


		PRINT'---------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT'---------------------------------------';

		SET @start_time=GETDATE();
		PRINT'>>Trunacting Table: bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;    --“Pehle purana data hatao, phir fresh CSV data load karo”(USE OF TRUNCATE)

		PRINT'>>Insering Data Into: bronze.crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		FROM 'D:\Data Analyst\SQL PROJECTS\f78e076e5b83435d84c6b6af75d8a679\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH (
		FIRSTROW=2,
		FIELDTERMINATOR =',',
		TABLOCK
		);

		SELECT * FROM bronze.crm_cust_info
		SELECT COUNT(*)FROM bronze.crm_cust_info

		SET @end_time=GETDATE();
		PRINT '>>Load Duration:'+  CAST (DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';
		PRINT '>>-------------------------------------------';
		--====================================================

		SET @start_time=GETDATE();
		PRINT'>>Trunacting Table: bronze.crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info;    --“Pehle purana data hatao, phir fresh CSV data load karo”(USE OF TRUNCATE)

		PRINT'>>Insering Data Into: bronze.crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		FROM 'D:\Data Analyst\SQL PROJECTS\f78e076e5b83435d84c6b6af75d8a679\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH (
		FIRSTROW=2,
		FIELDTERMINATOR =',',
		TABLOCK
		);

		SELECT * FROM bronze.crm_prd_info
		SELECT COUNT(*)FROM bronze.crm_prd_info

		
		SET @end_time=GETDATE();
		PRINT '>>Load Duration:'+  CAST (DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';
		PRINT '>>-------------------------------------------';
		--=================================================

		SET @start_time=GETDATE();
		PRINT'>>Trunacting Table: bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;    --“Pehle purana data hatao, phir fresh CSV data load karo”(USE OF TRUNCATE)

		PRINT'>>Insering Data Into:bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM 'D:\Data Analyst\SQL PROJECTS\f78e076e5b83435d84c6b6af75d8a679\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH (
		FIRSTROW=2,
		FIELDTERMINATOR =',',
		TABLOCK
		);

		SELECT * FROM bronze.crm_sales_details
		SELECT COUNT(*)FROM bronze.crm_sales_details

		
		SET @end_time=GETDATE();
		PRINT '>>Load Duration:'+  CAST (DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';
		PRINT '>>-------------------------------------------';

		--==================================================



		PRINT '------------------------------------------------';
		PRINT'Laoding ERP Tables';
		print'---------------------------------------------------';

		SET @start_time=GETDATE();
		PRINT'>>Trunacting Table: bronze.erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101    --“Pehle purana data hatao, phir fresh CSV data load karo”(USE OF TRUNCATE)

		PRINT'>>Insering Data Into: bronze.erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101
		FROM 'D:\Data Analyst\SQL PROJECTS\f78e076e5b83435d84c6b6af75d8a679\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
		WITH (
		FIRSTROW=2,
		FIELDTERMINATOR =',',
		TABLOCK
		);

		SELECT * FROM bronze.erp_loc_a101
		SELECT COUNT(*)FROM bronze.erp_loc_a101

		
		SET @end_time=GETDATE();
		PRINT '>>Load Duration:'+  CAST (DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';
		PRINT '>>-------------------------------------------';
		--===========================================

		SET @start_time=GETDATE();
		PRINT'>>Trunacting Table: bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12;    --“Pehle purana data hatao, phir fresh CSV data load karo”(USE OF TRUNCATE)

		PRINT'>>Insering Data Into: bronze.erp_cust_az12';
		BULK INSERT bronze.erp_cust_az12
		FROM 'D:\Data Analyst\SQL PROJECTS\f78e076e5b83435d84c6b6af75d8a679\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
		WITH (
		FIRSTROW=2,
		FIELDTERMINATOR =',',
		TABLOCK
		);

		SELECT * FROM bronze.erp_cust_az12
		SELECT COUNT(*)FROM bronze.erp_cust_az12

		
		SET @end_time=GETDATE();
		PRINT '>>Load Duration:'+  CAST (DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';
		PRINT '>>-------------------------------------------';

		--==============================================

		SET @start_time=GETDATE();
		PRINT'>>Trunacting Table: bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;   --“Pehle purana data hatao, phir fresh CSV data load karo”(USE OF TRUNCATE)

		PRINT'>>Insering Data Into: bronze.erp_px_cat_g1v2';
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'D:\Data Analyst\SQL PROJECTS\f78e076e5b83435d84c6b6af75d8a679\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
		WITH (
		FIRSTROW=2,
		FIELDTERMINATOR =',',
		TABLOCK
		);

		SELECT * FROM bronze.erp_px_cat_g1v2
		SELECT COUNT(*)FROM bronze.erp_px_cat_g1v2

		
		SET @end_time=GETDATE();
		PRINT '>>Load Duration:'+  CAST (DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';
		PRINT '>>-------------------------------------------';

		SET @batch_end_time =GETDATE();
		PRINT '==================================================';
		PRINT 'Loading Bronze Layer is Completed ';
		PRINT '   Total Load Duration :' + CAST(DATEDIFF (SECOND ,@batch_start_time,@batch_end_time)AS NVARCHAR )+ 'seconds';
		PRINT'====================================================';
		END TRY

		BEGIN CATCH
			PRINT '========================================';
			PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
			PRINT 'ERROR MESSAGE' + ERROR_MESSAGE();
			PRINT 'ERROR NUMBER' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
			PRINT 'ERROR STATE'+ CAST(ERROR_STATE()  AS NVARCHAR(10));
			PRINT '========================================';
		END CATCH
END

--execute(procedure)
EXEC bronze.load_bronze












