/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'silver' schema from 'bronze'. 
    It performs the following actions:
    - Truncates the silver tables before loading data.
    - Uses `INSERT` command to load data from 'Bronze' Layer to Silver tables.

Usage Example:
    EXEC silver.load_silver;
===============================================================================
*/
Create or Alter Procedure silver.load_silver As
Begin
	DECLARE @start_time DATETIME, @end_time DATETIME, @silver_layer_start_time DATETIME, @silver_layer_end_time DATETIME;
	Begin Try
		print '=======================================================';
		print 'Loading silver layer';
		print '=======================================================';
		SET @silver_layer_start_time = GETDATE();
		print '-------------------------------------------------------';
		print 'Loading CRM table';
		print '-------------------------------------------------------';
		SET @start_time = GETDATE();
		print '>> Truncating Table: silver.crm_cust_info'
		Truncate Table silver.crm_cust_info 
		print '>> Inserting Data Into silver.crm_cust_info'
		Insert Into silver.crm_cust_info(
			cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date
		)
		select 
		cst_id, cst_key,
		TRIM(cst_firstname) as cst_firstname,
		TRIM(cst_lastname) as cst_lastname,
		CASE upper(Trim(cst_material_status))
			when 'S' then 'Single'
			when 'M' then 'Married'
			else 'n/a'
		END cst_marital_status,
		CASE when upper(Trim(cst_gndr)) = 'F' then 'Female'
			when upper(Trim(cst_gndr)) = 'M' then 'Male'
			else 'n/a'
		END cst_gndr,
		cst_create_date
		FROM(
		select * from
		(select *,
		Row_Number() OVER (partition by cst_id order by cst_create_date desc) flag_last
		from bronze.crm_cust_info
		where cst_id is not null
		)t where flag_last = 1)AS final
		SET @end_time = GETDATE();
		print '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) as NVARCHAR) + ' seconds'
		print '>> -------------'
		--------------------------
		--------------------------
		--------------------------
		--------------------------
		--------------------------
		--------------------------
		-- silver.crm_prd_info:
		SET @start_time = GETDATE();
		print '>> Truncating Table: silver.crm_prd_info'
		Truncate Table silver.crm_prd_info 
		print '>> Inserting Data Into: silver.crm_prd_info'
		Insert Into silver.crm_prd_info(prd_id, cat_id, prd_key, prd_nm, prd_line, prd_cost, prd_start_dt, prd_end_dt
		)
		SELECT 
			prd_id,
			REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
			SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
			prd_nm, 
			CASE upper(Trim(prd_line))
				when 'M' then 'Mountain' 
				when 'R' then 'Road'
				when 'S' then 'Other Sales'
				when 'T' then 'Touring'
				else 'n/a'
			END prd_line,
			ISNULL(prd_cost, 0) prd_cost,
			prd_start_dt, 
			DATEADD(DAY, -1, LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)) AS prd_end_dt
		FROM bronze.crm_prd_info
		SET @end_time = GETDATE();
		print '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) as NVARCHAR) + ' seconds'
		print '>> -------------'
		--------------------------
		--------------------------
		--------------------------
		--------------------------
		--------------------------
		--------------------------
		-- silver.crm_sales_details:
		SET @start_time = GETDATE();
		print '>> Truncating Table: silver.crm_sales_details'
		Truncate Table silver.crm_sales_details 
		print '>> Inserting Data Into: silver.crm_sales_details'
		Insert Into silver.crm_sales_details(sls_ord_num, sls_prd_key, sls_cust_id,
				sls_order_dt, sls_ship_dt, sls_due_dt, sls_quantity, sls_sales, sls_price)
		select
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			Case when len(sls_order_dt) != 8 OR sls_order_dt = 0 then NULL
				else cast(cast(sls_order_dt as varchar) as DATE)
			END as sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_quantity,
			Case when sls_sales is null OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
				then sls_quantity * ABS(sls_price)
				else sls_sales
			END sls_sales,
			Case when sls_price is null OR sls_price <= 0
				then sls_sales/NULLIF(sls_quantity, 0)
				else sls_price
			END sls_price
		from bronze.crm_sales_details
		SET @end_time = GETDATE();
		print '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) as NVARCHAR) + ' seconds'
		print '>> -------------'
		--------------------------
		--------------------------
		--------------------------
		--------------------------
		--------------------------
		--------------------------
		-- ERP:
		-- silver.erp_cust_az12:
		print '-------------------------------------------------------';
		print 'Loading ERP table';
		print '-------------------------------------------------------';
		SET @start_time = GETDATE();
		print '>> Truncating Table: silver.erp_cust_az12'
		Truncate Table silver.erp_cust_az12 
		print '>> Inserting Data Into: silver.erp_cust_az12'
		Insert Into silver.erp_cust_az12(CID, bdate, gen)
		select
			CASE when cid like 'NAS%' then SUBSTRING(cid, 4, len(cid))
			else cid
		END CID,
			CASE 
				when bdate > getdate() then NULL
				else bdate
		End bdate,
			CASE when UPPER(TRIM(gen)) IN ('F', 'FEMALE') then 'Female'
				when UPPER(TRIM(gen)) IN ('M', 'MALE') then 'Male'
				else 'n/a'        
		END AS gen
		from bronze.erp_cust_az12
		SET @end_time = GETDATE();
		print '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) as NVARCHAR) + ' seconds'
		print '>> -------------'
		--------------------------
		--------------------------
		--------------------------
		--------------------------
		--------------------------
		--------------------------
		-- silver.erp_loc_a101:
		SET @start_time = GETDATE();
		print '>> Truncating Table: silver.erp_loc_a101'
		Truncate Table silver.erp_loc_a101 
		print '>> Inserting Data Into: silver.erp_loc_a101'
		insert into silver.erp_loc_a101 (CID, CNTRY)
		select REPLACE(CID, '-', '') AS CID,
			Case 
				when TRIM(CNTRY) = 'DE' then 'Germany'
				when TRIM(CNTRY) is null OR CNTRY = ' ' then 'n/a'
				when TRIM(CNTRY) in ('US', 'USA') then 'United States'
				else TRIM(CNTRY)
		END as CNTRY
		from bronze.erp_loc_a101
		SET @end_time = GETDATE();
		print '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) as NVARCHAR) + ' seconds'
		print '>> -------------'
		--------------------------
		--------------------------
		--------------------------
		--------------------------
		--------------------------
		--------------------------
		-- silver.erp_px_cat_g1v2
		SET @start_time = GETDATE();
		print '>> Truncating Table: silver.erp_px_cat_g1v2'
		Truncate Table silver.erp_px_cat_g1v2 
		print '>> Inserting Data Into: silver.erp_px_cat_g1v2'
		insert into silver.erp_px_cat_g1v2 (ID, CAT, SUBCAT, MAINTENANCE)
		select * from  bronze.erp_px_cat_g1v2
		SET @end_time = GETDATE();
		print '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) as NVARCHAR) + ' seconds'
		print '>> ==========================================================='
		SET @silver_layer_end_time = GETDATE();
		print '>> Silver Layer Complete Load Duration: ' + CAST(DATEDIFF(second, @silver_layer_start_time, @silver_layer_end_time) as NVARCHAR) + ' seconds'
		print '>> -------------'
	End Try
	Begin Catch
		print '=======================================================';
		print 'ERROR OCCURED DURING LOADING SILVER LAYER';
		print 'Error message' + ERROR_MESSAGE();
		print 'Error number' + CAST(ERROR_NUMBER() as NVARCHAR);
		print 'Error state' + CAST(ERROR_STATE() as NVARCHAR);
		print '=======================================================';
	End Catch
End
