/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
===============================================================================
*/
Create or Alter Procedure bronze.load_bronze AS
Begin
	DECLARE @start_time DATETIME, @end_time DATETIME, @bronze_layer_start_time DATETIME, @bronze_layer_end_time DATETIME;
	Begin Try
		print '=======================================================';
		print 'Loading bronze layer';
		print '=======================================================';
		SET @bronze_layer_start_time = GETDATE();
		print '-------------------------------------------------------';
		print 'Loading CRM table';
		print '-------------------------------------------------------';
		SET @start_time = GETDATE();
		print '>> Truncating Table: bronze.crm_cust_info';
		Truncate Table bronze.crm_cust_info;
		print '>> Inserting Data Into: bronze.crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\97253\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK 
		);
		SET @end_time = GETDATE();
		print '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) as NVARCHAR) + ' seconds'
		print '>> -------------'
		----
		SET @start_time = GETDATE();
		print '>> Truncating Table: bronze.crm_prd_info';
		Truncate Table bronze.crm_prd_info;
		print '>> Inserting Data Into: bronze.crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\97253\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK 
		);
		SET @end_time = GETDATE();
		print '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) as NVARCHAR) + ' seconds'
		print '>> -------------'
		--
		SET @start_time = GETDATE();
		print '>> Truncating Table: bronze.crm_sales_details';
		Truncate Table bronze.crm_sales_details;
		print '>> Inserting Data Into: crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\97253\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK 
		);
		SET @end_time = GETDATE();
		print '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) as NVARCHAR) + ' seconds'
		print '>> -------------'

		--ALTER TABLE bronze.crm_sales_details
		--ALTER COLUMN sls_order_dt NVARCHAR(20);

		--
		print '-------------------------------------------------------';
		print 'Loading ERP table';
		print '-------------------------------------------------------';
		SET @start_time = GETDATE();
		print '>> Truncating Table: bronze.erp_cust_az12';
		Truncate Table bronze.erp_cust_az12;
		print '>> Inserting Data Into: bronze.erp_cust_az12';
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\97253\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK 
		);
		SET @end_time = GETDATE();
		print '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) as NVARCHAR) + ' seconds'
		print '>> -------------'
		--
		SET @start_time = GETDATE();
		print '>> Truncating Table: bronze.erp_loc_a101';
		Truncate Table bronze.erp_loc_a101;
		print '>> Inserting Data Into: bronze.erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\97253\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK 
		);
		SET @end_time = GETDATE();
		print '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) as NVARCHAR) + ' seconds'
		print '>> -------------'
		--
		SET @start_time = GETDATE();
		print '>> Truncating Table: bronze.erp_px_cat_g1v2';
		Truncate Table bronze.erp_px_cat_g1v2;
		print '>> Inserting Data Into: bronze.erp_px_cat_g1v2';
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\97253\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK 
		);
		SET @end_time = GETDATE();
		print '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) as NVARCHAR) + ' seconds'
		print '>> ==========================================================='
		SET @bronze_layer_end_time = GETDATE();
		print '>> Bronze Layer Complete Load Duration: ' + CAST(DATEDIFF(second, @bronze_layer_start_time, @bronze_layer_end_time) as NVARCHAR) + ' seconds'
		print '>> -------------'
	End Try
	Begin Catch
		print '=======================================================';
		print 'ERROR OCCURED DURING LOADING BRONZE LAYER';
		print 'Error message' + ERROR_MESSAGE();
		print 'Error number' + CAST(ERROR_NUMBER() as NVARCHAR);
		print 'Error state' + CAST(ERROR_STATE() as NVARCHAR);
		print '=======================================================';
	End Catch
End
