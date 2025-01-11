-- CREATE 1ST FACT TABLE - FACT_SALESACTUAL

CREATE OR REPLACE TABLE fact_sales_actual
(
	DimProductID           INTEGER,
	DimStoreID			   INTEGER,
	DimResellerID		   INTEGER,
	DimCustomerID		   INTEGER,
	DimChannelID		   INTEGER,
	DimDateID			   INTEGER,
    DimLocationID          INTEGER,
	SalesHeaderID		   INTEGER,
	SalesDetailID	       INTEGER,
	SaleAmount			   FLOAT,
	SaleQuantity		   INTEGER,
    SaleUnitPrice          FLOAT,
    SaleExtendedCost       FLOAT,
    SaleTotalProfit        FLOAT,
    FOREIGN KEY (DimProductID)  REFERENCES dim_product(DimProductID),
    FOREIGN KEY (DimStoreID)    REFERENCES dim_store(DimStoreID),
    FOREIGN KEY (DimResellerID) REFERENCES dim_reseller(DimResellerID),
    FOREIGN KEY (DimCustomerID) REFERENCES dim_customer(DimCustomerID),
    FOREIGN KEY (DimChannelID)  REFERENCES dim_channel(DimChannelID),
    FOREIGN KEY (DimDateID)     REFERENCES dim_date(DimDateID),
    FOREIGN KEY (DimLocationID) REFERENCES dim_location(DimLocationID)
);

INSERT INTO fact_sales_actual
(
	DimProductID,
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
)
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
FROM
(
    SELECT  p.DIMPRODUCTID                      AS DimProductID,
            NVL(s.DIMSTOREID, -1)               AS DimStoreID,
            NVL(r.DIMRESELLERID, -1)            AS DimResellerID,
            NVL(c.DIMCUSTOMERID, -1)            AS DimCustomerID,
            ch.DIMCHANNELID                     AS DimChannelID,
            d.DIMDATEID                         AS DimDateID,
            l.DIMLOCATIONID                     AS DimLocationID,
            sd.SALESHEADERID                    AS SalesHeaderID,
            sd.SALESDETAILID                    AS SalesDetailID,
            sd.SALESAMOUNT                      AS SaleAmount,
            sd.SALESQUANTITY                    AS SaleQuantity,
            CASE WHEN (sd.SALESAMOUNT/sd.SALESQUANTITY) = p.PRODUCTRETAILPRICE THEN p.PRODUCTRETAILPRICE ELSE p.PRODUCTWHOLESALEPRICE END AS SaleUnitPrice,
            (p.PRODUCTCOST * sd.SALESQUANTITY)  AS SaleExtendedCost,
            CASE WHEN (sd.SALESAMOUNT/sd.SALESQUANTITY) = p.PRODUCTRETAILPRICE THEN (p.PRODUCTRETAILPROFIT*sd.SALESQUANTITY) ELSE (p.PRODUCTWHOLESALEUNITPROFIT*sd.SALESQUANTITY) END AS SaleTotalProfit
    FROM STAGE_SALESDETAIL sd
    INNER JOIN STAGE_SALESHEADER_NEW sh 
        ON sd.SALESHEADERID = sh.SALESHEADERID
    INNER JOIN DIM_PRODUCT p
        ON sd.PRODUCTID = p.PRODUCTID
    LEFT JOIN DIM_STORE s
        ON sh.STOREID = s.SOURCESTOREID
    LEFT JOIN DIM_RESELLER r
        ON sh.RESELLERID = r.RESELLERID
    LEFT JOIN DIM_CUSTOMER c
        ON sh.CUSTOMERID = c.CUSTOMERID
    INNER JOIN DIM_CHANNEL ch
        ON sh.CHANNELID = ch.CHANNELID
    LEFT JOIN DIM_LOCATION l
    ON CASE
        WHEN r.DIMRESELLERID IS NULL AND c.DIMCUSTOMERID IS NULL THEN l.DIMLOCATIONID = s.DIMLOCATIONID
        WHEN r.DIMRESELLERID IS NULL AND s.DIMSTOREID IS NULL THEN l.DIMLOCATIONID = c.DIMLOCATIONID
        WHEN s.DIMSTOREID IS NULL AND c.DIMCUSTOMERID IS NULL THEN l.DIMLOCATIONID = r.DIMLOCATIONID
    END
    INNER JOIN dim_date d 
        ON d.FULLDATE = sh.DATE
);

-- CREATE 2ND FACT TABLE - FACT_SRCSALESTARGET

CREATE OR REPLACE TABLE fact_srcsalestarget
(
	DimStoreID			   INTEGER,
	DimResellerID		   INTEGER,
	DimChannelID		   INTEGER,
	DimDateID			   INTEGER,
    SalesTargetAmount      FLOAT,
    FOREIGN KEY (DimStoreID)    REFERENCES dim_store(DimStoreID),
    FOREIGN KEY (DimResellerID) REFERENCES dim_reseller(DimResellerID),
    FOREIGN KEY (DimChannelID)  REFERENCES dim_channel(DimChannelID),
    FOREIGN KEY (DimDateID)     REFERENCES dim_date(DimDateID)
);

INSERT INTO fact_srcsalestarget
(
	DimStoreID,
	DimResellerID,
	DimChannelID,
	DimDateID,
    SalesTargetAmount
)
SELECT  DimStoreID,
        DimResellerID,
        DimChannelID,
        DimDateID,
        SalesTargetAmount
FROM
(
    SELECT  NVL(s.DIMSTOREID, -1)    AS DimStoreID,
            NVL(r.DIMRESELLERID, -1) AS DimResellerID,
            NVL(c.DIMCHANNELID, -1)  AS DimChannelID,
            NVL(d.DIMDATEID, -1)     AS DimDateID,
            (CAST(TARGETSALESAMOUNT AS FLOAT) / CAST(DATEDIFF('DAY', DATE_FROM_PARTS(d.CALENDARYEAR, 1, 1), DATE_FROM_PARTS(d.CALENDARYEAR, 12, 31)) + 1 AS FLOAT))  AS SalesTargetAmount
            
    FROM STAGE_TARGETDATA_CHANNELRESELLERANDSTORE tc
    LEFT JOIN DIM_DATE d
        ON d.CALENDARYEAR = tc.YEAR
    LEFT JOIN DIM_STORE s
        ON tc.TARGETNAME = s.STORENAME
    LEFT JOIN DIM_RESELLER r
        ON tc.TARGETNAME = r.RESELLERNAME
    LEFT JOIN DIM_CHANNEL c
        ON tc.CHANNELNAME = c.CHANNELNAME
);

-- CREATE 3RD FACT TABLE - FACT_PRODUCTSALESTARGET

CREATE OR REPLACE TABLE fact_productsalestarget
(
	DimProductID		        INTEGER,
	DimDateID			        INTEGER,
    ProductTargetSalesQuantity  FLOAT,
    FOREIGN KEY (DimProductID)  REFERENCES dim_product(DimProductID),
    FOREIGN KEY (DimDateID)     REFERENCES dim_date(DimDateID)
);

INSERT INTO fact_productsalestarget
(
	DimProductID,
	DimDateID,
    ProductTargetSalesQuantity
)
SELECT  DimProductID,
        DimDateID,
        ProductTargetSalesQuantity
FROM
(
    SELECT  NVL(p.DIMPRODUCTID, -1)  AS DimProductID,
            NVL(d.DIMDATEID, -1)     AS DimDateID,
            CAST(SALESQUANTITYTARGET AS FLOAT) / CAST(DATEDIFF('DAY', DATE_FROM_PARTS(d.CALENDARYEAR, 1, 1), DATE_FROM_PARTS(d.CALENDARYEAR, 12, 31)) + 1 AS FLOAT)  AS ProductTargetSalesQuantity
            
    FROM STAGE_TARGETDATA_PRODUCT tp
    LEFT JOIN DIM_DATE d
        ON d.CALENDARYEAR = tp.YEAR
    LEFT JOIN DIM_PRODUCT p
        ON tp.PRODUCTID = p.PRODUCTID
);

SELECT *
FROM fact_srcsalestarget;

SELECT *
FROM fact_productsalestarget;

select *
from dim_store;
