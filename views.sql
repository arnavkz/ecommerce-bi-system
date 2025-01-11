-- PASS THROUGH VIEWS
-- CREATE CHANNEL DIMENSION VIEW

CREATE OR REPLACE SECURE VIEW dim_channel_view AS
SELECT  DimChannelID,
        ChannelID,
        ChannelCategoryID,
        ChannelName
        ChannelCategory
FROM dim_channel;

-- CREATE CUSTOMER DIMENSION VIEW

CREATE OR REPLACE SECURE VIEW dim_customer_view AS
SELECT  DimCustomerID,
        DimLocationID,
        CustomerID,
        CustomerFullName,
        CustomerFirstName,
        CustomerLastName,
        CustomerPhoneNumber,
        CustomerEmail,
        CustomerGender
FROM dim_customer; 

-- CREATE DATE DIMENSION VIEW

CREATE OR REPLACE SECURE VIEW dim_date_view AS
SELECT  DimDateID,
        FullDate,
        DayNumberofWeek,
        DayName,
        DayNumberofMonth,
        DayNumberofYear,
        MonthName,
        MonthNumberofYear,
        YearMonth,
        Quarter,
        YearQuarter,
        CalendarYear
FROM dim_date;

-- CREATE LOCATION DIMENSION VIEW

CREATE OR REPLACE SECURE VIEW dim_location_view AS
SELECT  DimLocationID,
        Address,
        City,
        PostalCode,
        State_Province,
        Country
FROM dim_location;

-- CREATE PRODUCT DIMENSION VIEW

CREATE OR REPLACE SECURE VIEW dim_product_view AS
SELECT  DimProductID,
        ProductID,
        ProductTypeID,
        ProductCategoryID,
        ProductName,
        ProductType,
        ProductCategory,
        ProductRetailPrice,
        ProductWholesalePrice,
        ProductCost,
        ProductRetailProfit,
        ProductWholesaleUnitProfit,
        ProductProfitMarginUnitPercentRetail,
        ProductProfitMarginUnitPercentWholesale
FROM dim_product;


-- CREATE RESELLER DIMENSION VIEW

CREATE OR REPLACE SECURE VIEW dim_reseller_view AS
SELECT  DimResellerID,
        DimLocationID,
        ResellerID,
        ResellerName,
        ContactName,
        PhoneNumber,
        Email
FROM dim_reseller;

-- CREATE STORE DIMENSION VIEW

CREATE OR REPLACE SECURE VIEW dim_store_view AS
SELECT  DimStoreID,
        DimLocationID,
        SourceStoreID,
        StoreName,
        StoreNumber,
        StoreManager
FROM dim_store;

-- CREATE PRODUCT SALES TARGET FACT VIEW

CREATE OR REPLACE SECURE VIEW fact_productsalestarget_view AS
SELECT  DimProductID,
        DimDateID,
        ProductTargetSalesQuantity
FROM fact_productsalestarget;

-- CREATE SALES ACTUAL FACT VIEW

CREATE OR REPLACE SECURE VIEW fact_sales_actual_view AS
SELECT  DimProductID,
        DimStoreID,
        DimResellerID,
        DimCustomerID,
        DimChannelID,
        DimDateID,
        DimLocationID,
        SalesHeaderID,
        SalesDetailID,
        SaleAmount,
        SaleQuantity,
        SaleUnitPrice,
        SaleExtendedCost,
        SaleTotalProfit
FROM fact_sales_actual;

-- CREATE SOURCE SALES TARGET FACT VIEW

CREATE OR REPLACE SECURE VIEW fact_srcsalestarget_view AS
SELECT  DimStoreID,
        DimResellerID,
        DimChannelID,
        DimDateID,
        SalesTargetAmount
FROM fact_srcsalestarget;


-- CUSTOM VIEWS
-- 1. DAILY STORE LEVEL SALES PERFORMANCE

CREATE OR REPLACE SECURE VIEW daily_store_sales_view AS
SELECT  a.Date,
        a.StoreName,
        a.City,
        a.State_Province,
        a.Total_Sales,
        a.Total_Sale_Quantity,
        a.Total_Sale_Extended_Cost,
        a.Total_Sale_Profit,
        st.SalesTargetAmount   AS Total_Sales_Target
FROM
(
    SELECT  sa.DimStoreID,
            s.StoreName,
            sa.DimDateID,
            d.FullDate                  AS Date,
            l.City,
            l.State_Province,
            SUM(sa.SaleAmount)          AS Total_Sales,
            SUM(sa.SaleQuantity)        AS Total_Sale_Quantity,
            SUM(sa.SaleExtendedCost)    AS Total_Sale_Extended_Cost,
            SUM(sa.SaleTotalProfit)     AS Total_Sale_Profit, 
    FROM fact_sales_actual_view sa
    LEFT JOIN
        dim_date_view d ON sa.DimDateID = d.DimDateID
    LEFT JOIN
        dim_product_view p ON sa.DimProductID = p.DimProductID
    LEFT JOIN 
        dim_store_view s ON sa.DimStoreID = s.DimStoreID
    LEFT JOIN
        dim_location_view l ON sa.DimLocationID = l.DimLocationID
    WHERE s.StoreNumber IN (10, 21)
    GROUP BY 1,2,3,4,5,6
) a
LEFT JOIN 
    fact_srcsalestarget_view st ON a.DimStoreID = st.DimStoreID AND a.DimDateID = st.DimDateID
ORDER BY 1,2,3,4;


-- 2. MONTHLY STORE LEVEL SALES PERFORMANCE

CREATE OR REPLACE SECURE VIEW monthly_store_sales_view AS
SELECT  a.Year,
        a.Month,
        a.MonthNumber,
        a.StoreName,
        a.City,
        a.State_Province,
        a.Total_Sales,
        a.Total_Sale_Quantity,
        a.Total_Sale_Extended_Cost,
        a.Total_Sale_Profit,
        b.Total_Target_Sales
FROM
(
    SELECT  sa.DimStoreID,
            s.StoreName,
            d.CalendarYear              AS Year,
            d.MonthName                 AS Month,
            d.MonthNumberofYear         AS MonthNumber,
            l.City,
            l.State_Province,
            SUM(sa.SaleAmount)          AS Total_Sales,
            SUM(sa.SaleQuantity)        AS Total_Sale_Quantity,
            SUM(sa.SaleExtendedCost)    AS Total_Sale_Extended_Cost,
            SUM(sa.SaleTotalProfit)     AS Total_Sale_Profit, 
    FROM fact_sales_actual_view sa
    LEFT JOIN
        dim_date_view d ON sa.DimDateID = d.DimDateID
    LEFT JOIN
        dim_product_view p ON sa.DimProductID = p.DimProductID
    LEFT JOIN 
        dim_store_view s ON sa.DimStoreID = s.DimStoreID
    LEFT JOIN
        dim_location_view l ON sa.DimLocationID = l.DimLocationID
    WHERE s.StoreNumber IN (10, 21)
    GROUP BY 1,2,3,4,5,6,7
) a
LEFT JOIN 
    (
        SELECT  st.DimStoreID,
                d.CalendarYear            AS Year,
                d.MonthNumberOfYear       AS MonthNumber,
                SUM(st.SalesTargetAmount) AS Total_Target_Sales 
        FROM fact_srcsalestarget_view st
        LEFT JOIN
            dim_date_view d ON st.DimDateID = d.DimDateID
        WHERE DimStoreID != -1
        GROUP BY 1,2,3
    ) b ON a.DimStoreID = b.DimStoreID AND a.Year = b.Year AND a.MonthNumber = b.MonthNumber
ORDER BY 1,3,4,5,6;


-- 3. DAILY PRODUCT LEVEL SALES PERFORMANCE

CREATE OR REPLACE SECURE VIEW daily_product_sales_view AS
SELECT  a.Date,
        a.ProductName,
        a.ProductType,
        a.ProductCategory,
        a.Total_Sales,
        a.Total_Sale_Quantity,
        a.Total_Sale_Extended_Cost,
        a.Total_Sale_Profit,
        st.ProductTargetSalesQuantity  AS Total_Product_Sales_Target_Quantity
FROM
(
    SELECT  p.dimproductid,
            p.ProductName,
            p.ProductType,
            p.ProductCategory,
            d.DimDateID,
            d.FullDate                  AS Date,
            SUM(sa.SaleAmount)          AS Total_Sales,
            SUM(sa.SaleQuantity)        AS Total_Sale_Quantity,
            SUM(sa.SaleExtendedCost)    AS Total_Sale_Extended_Cost,
            SUM(sa.SaleTotalProfit)     AS Total_Sale_Profit 
    FROM fact_sales_actual_view sa
    LEFT JOIN
        dim_date_view d ON sa.DimDateID = d.DimDateID
    LEFT JOIN
        dim_product_view p ON sa.DimProductID = p.DimProductID
    LEFT JOIN 
        dim_store_view s ON sa.DimStoreID = s.DimStoreID
    LEFT JOIN
        dim_location_view l ON sa.DimLocationID = l.DimLocationID
    GROUP BY 1,2,3,4,5,6
) a
LEFT JOIN 
    fact_productsalestarget_view st ON a.DimProductID = st.DimProductID AND a.DimDateID = st.DimDateID
ORDER BY 1,2,3,4;


-- 4. MONTHLY PRODUCT LEVEL SALES PERFORMANCE

CREATE OR REPLACE SECURE VIEW monthly_product_sales_view AS
SELECT  a.Year,
        a.Month,
        a.MonthNumber,
        a.ProductName,
        a.ProductType,
        a.ProductCategory,
        a.Total_Sales,
        a.Total_Sale_Quantity,
        a.Total_Sale_Extended_Cost,
        a.Total_Sale_Profit,
        b.Product_Target_Sales_Quantity
FROM
(
    SELECT  p.dimproductid,
            p.ProductName,
            p.ProductType,
            p.ProductCategory,
            d.CalendarYear              AS Year,
            d.MonthName                 AS Month,
            d.MonthNumberofYear         AS MonthNumber,
            SUM(sa.SaleAmount)          AS Total_Sales,
            SUM(sa.SaleQuantity)        AS Total_Sale_Quantity,
            SUM(sa.SaleExtendedCost)    AS Total_Sale_Extended_Cost,
            SUM(sa.SaleTotalProfit)     AS Total_Sale_Profit 
    FROM fact_sales_actual_view sa
    LEFT JOIN
        dim_date_view d ON sa.DimDateID = d.DimDateID
    LEFT JOIN
        dim_product_view p ON sa.DimProductID = p.DimProductID
    LEFT JOIN 
        dim_store_view s ON sa.DimStoreID = s.DimStoreID
    LEFT JOIN
        dim_location_view l ON sa.DimLocationID = l.DimLocationID
    GROUP BY 1,2,3,4,5,6,7
) a
LEFT JOIN 
    (
        SELECT  st.DimProductID,
                d.CalendarYear            AS Year,
                d.MonthNumberOfYear       AS MonthNumber,
                SUM(st.ProductTargetSalesQuantity) AS Product_Target_Sales_Quantity
        FROM fact_productsalestarget_view st
        LEFT JOIN
            dim_date_view d ON st.DimDateID = d.DimDateID
        GROUP BY 1,2,3
    ) b ON a.DimProductID = b.DimProductID AND a.Year = b.Year AND a.MonthNumber = b.MonthNumber
ORDER BY 1,3,4,5,6;


-- 5.PRODUCT SALES BY DAY OF THE WEEK

CREATE OR REPLACE SECURE VIEW product_sales_by_day_view AS
SELECT  s.StoreName,
        d.DayNumberOfWeek,
        d.DayName,
        p.ProductName,
        p.ProductType,
        p.ProductCategory,
        SUM(sa.SaleAmount)          AS Total_Sales,
        SUM(sa.SaleQuantity)        AS Total_Sale_Quantity,
        SUM(sa.SaleExtendedCost)    AS Total_Sale_Extended_Cost,
        SUM(sa.SaleTotalProfit)     AS Total_Sale_Profit 
FROM fact_sales_actual_view sa
LEFT JOIN
    dim_date_view d ON sa.DimDateID = d.DimDateID
LEFT JOIN
    dim_product_view p ON sa.DimProductID = p.DimProductID
LEFT JOIN 
    dim_store_view s ON sa.DimStoreID = s.DimStoreID
LEFT JOIN
    dim_location_view l ON sa.DimLocationID = l.DimLocationID
WHERE s.StoreNumber IN (10, 21)
GROUP BY 1,2,3,4,5,6
ORDER BY 1,2,3,4,5,6;


-- 6.BONUS AMOUNTS BY STORE

CREATE OR REPLACE SECURE VIEW bonus_by_store_view AS

WITH CTE_1 AS
(
    SELECT  a.StoreName,
            a.StoreManager,
            a.Total_Sales,
            b.Total_Target_Sales,
            (CAST(a.Total_Sales AS FLOAT) / CAST(b.Total_Target_Sales AS FLOAT)*100) AS Pct_Target_Achieved,
            (CAST(a.Total_Sales AS FLOAT) / CAST((SELECT SUM(Total_Sales) FROM monthly_store_sales_view WHERE year = 2013) AS FLOAT)*100) AS Pct_Sales_Contribution,
            ((0.5*pct_target_achieved) + (0.5*pct_sales_contribution)) AS Total_Weighted_Avg
    FROM
    (
        SELECT  sa.DimStoreID,
                s.StoreName,
                s.StoreManager,
                SUM(sa.SaleAmount)          AS Total_Sales
        FROM fact_sales_actual_view sa
        LEFT JOIN
            dim_date_view d ON sa.DimDateID = d.DimDateID
        LEFT JOIN
            dim_product_view p ON sa.DimProductID = p.DimProductID
        LEFT JOIN 
            dim_store_view s ON sa.DimStoreID = s.DimStoreID
        LEFT JOIN
            dim_location_view l ON sa.DimLocationID = l.DimLocationID
        WHERE s.StoreNumber IN (10, 21)
        AND d.CalendarYear = 2013
        GROUP BY 1,2,3
    ) a
    LEFT JOIN
        (
            SELECT  st.DimStoreID,
                    SUM(st.SalesTargetAmount) AS Total_Target_Sales 
            FROM fact_srcsalestarget_view st
            LEFT JOIN
                dim_date_view d ON st.DimDateID = d.DimDateID
            WHERE DimStoreID != -1
            AND d.CalendarYear = 2013
            GROUP BY 1
        ) b ON a.DimStoreID = b.DimStoreID
    ORDER BY 1,2
)

SELECT  x.StoreName,
        x.StoreManager,
        x.Total_Sales,
        x.Total_Target_Sales,
        x.Pct_Target_Achieved,
        x.Pct_Sales_Contribution,
        (CAST(x.Total_Weighted_Avg AS FLOAT) / CAST((SELECT SUM(Total_Weighted_Avg) FROM CTE_1) AS FLOAT))*2000000 AS bonus
FROM CTE_1 AS x;


-- 7. DAILY STORE PRODUCT SALES PERFORMANCE

CREATE OR REPLACE SECURE VIEW daily_store_product_sales_view AS
SELECT  d.FullDate                  AS Date,
        s.StoreName,
        p.ProductName,
        p.ProductType,
        p.ProductCategory,
        SUM(sa.SaleAmount)          AS Total_Sales,
        SUM(sa.SaleQuantity)        AS Total_Sale_Quantity,
        SUM(sa.SaleExtendedCost)    AS Total_Sale_Extended_Cost,
        SUM(sa.SaleTotalProfit)     AS Total_Sale_Profit,
        l.City,
        l.State_Province
FROM fact_sales_actual_view sa
LEFT JOIN
    dim_date_view d ON sa.DimDateID = d.DimDateID
LEFT JOIN
    dim_product_view p ON sa.DimProductID = p.DimProductID
LEFT JOIN 
    dim_store_view s ON sa.DimStoreID = s.DimStoreID
LEFT JOIN
    dim_location_view l ON sa.DimLocationID = l.DimLocationID
WHERE s.StoreNumber IN (10, 21)
GROUP BY 1,2,3,4,5,10,11
ORDER BY 1,2,3,4,5;


-- 8. MONTHLY STORE PRODUCT SALES PERFORMANCE

CREATE OR REPLACE SECURE VIEW monthly_store_product_sales_view AS
SELECT  d.CalendarYear              AS Year,
        d.MonthName                 AS Month,
        d.MonthNumberofYear         AS MonthNumber,
        s.StoreName,
        p.ProductName,
        p.ProductType,
        p.ProductCategory,
        SUM(sa.SaleAmount)          AS Total_Sales,
        SUM(sa.SaleQuantity)        AS Total_Sale_Quantity,
        SUM(sa.SaleExtendedCost)    AS Total_Sale_Extended_Cost,
        SUM(sa.SaleTotalProfit)     AS Total_Sale_Profit,
        l.City,
        l.State_Province
FROM fact_sales_actual_view sa
LEFT JOIN
    dim_date_view d ON sa.DimDateID = d.DimDateID
LEFT JOIN
    dim_product_view p ON sa.DimProductID = p.DimProductID
LEFT JOIN 
    dim_store_view s ON sa.DimStoreID = s.DimStoreID
LEFT JOIN
    dim_location_view l ON sa.DimLocationID = l.DimLocationID
WHERE s.StoreNumber IN (10, 21)
GROUP BY 1,2,3,4,5,6,7,12,13
ORDER BY 1,3,4,5,6,7;


-- 9. TARGET OVERALL

CREATE OR REPLACE SECURE VIEW store_targets_view AS
SELECT  d.CalendarYear              AS Year,
        d.MonthName                 AS Month,
        d.MonthNumberofYear         AS MonthNumber,
        s.StoreName,
        SUM(SalesTargetAmount)      AS Total_Sales_Target
FROM fact_srcsalestarget_view t
LEFT JOIN
    dim_date_view d ON t.DimDateID = d.DimDateID
LEFT JOIN 
    dim_store_view s ON t.DimStoreID = s.DimStoreID 
WHERE StoreNumber IN (10,21)
GROUP BY 1,2,3,4
ORDER BY 1,3,4;

-- 10. TARGET OVERALL DAY LEVEL

CREATE OR REPLACE SECURE VIEW store_targets_day_view AS
SELECT  d.FullDate                  AS Date,
        s.StoreName,
        SUM(SalesTargetAmount)      AS Total_Sales_Target
FROM fact_srcsalestarget_view t
LEFT JOIN
    dim_date_view d ON t.DimDateID = d.DimDateID
LEFT JOIN 
    dim_store_view s ON t.DimStoreID = s.DimStoreID 
WHERE StoreNumber IN (10,21)
GROUP BY 1,2
ORDER BY 1,2;

-- 7. DAILY STORE PRODUCT SALES PERFORMANCE ALL STORES

CREATE OR REPLACE SECURE VIEW daily_store_product_sales_all_stores_view AS
SELECT  d.FullDate                  AS Date,
        s.StoreName,
        p.ProductName,
        p.ProductType,
        p.ProductCategory,
        SUM(sa.SaleAmount)          AS Total_Sales,
        SUM(sa.SaleQuantity)        AS Total_Sale_Quantity,
        SUM(sa.SaleExtendedCost)    AS Total_Sale_Extended_Cost,
        SUM(sa.SaleTotalProfit)     AS Total_Sale_Profit,
        l.City,
        l.State_Province
FROM fact_sales_actual_view sa
LEFT JOIN
    dim_date_view d ON sa.DimDateID = d.DimDateID
LEFT JOIN
    dim_product_view p ON sa.DimProductID = p.DimProductID
LEFT JOIN 
    dim_store_view s ON sa.DimStoreID = s.DimStoreID
LEFT JOIN
    dim_location_view l ON sa.DimLocationID = l.DimLocationID
WHERE sa.DimStoreID != -1
GROUP BY 1,2,3,4,5,10,11
ORDER BY 1,2,3,4,5;
