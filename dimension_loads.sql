-- CREATING 1ST TABLE - DIM_DATE

CREATE or REPLACE TABLE dim_date (
	DimDateID				INTEGER PRIMARY KEY NOT NULL,
	FullDate				date not null,
	DayNumberOfWeek			number(1) not null,
    DayName                 varchar(10) not null,
	DayNumberOfMonth		number(2) not null,
	MonthName				varchar(10) not null,
    MonthNumberOfYear		number(2) not null,
    DayNumberOfYear			number(3) not null,
	YearMonth				varchar(10) not null,
	Quarter					number(1) not null,
	YearQuarter				varchar(10) not null,
	CalendarYear			number(5) not null
)
comment = 'Type 0 Dimension Table Housing Calendar and Fiscal Year Date Attributes'; 

INSERT INTO dim_date
SELECT  DimDateID,
		FullDate,
		DayNumberOfWeek,
        DayName,
		DayNumberOfMonth,
		MonthName,
        MonthNumberOfYear,
        DayNumberOfYear,
		YearMonth,
		Quarter,
        YearQuarter,
		CalendarYear
	
FROM 

( select to_date('2012-12-31 23:59:59','YYYY-MM-DD HH24:MI:SS') as DD,
			seq1() as Sl,row_number() over (order by Sl) as row_numbers,
			dateadd(day,row_numbers,DD) as V_DATE,
			case when date_part(dd, V_DATE) < 10 and date_part(mm, V_DATE) > 9 then
				date_part(year, V_DATE)||date_part(mm, V_DATE)||'0'||date_part(dd, V_DATE)
				 when date_part(dd, V_DATE) < 10 and  date_part(mm, V_DATE) < 10 then 
				 date_part(year, V_DATE)||'0'||date_part(mm, V_DATE)||'0'||date_part(dd, V_DATE)
				 when date_part(dd, V_DATE) > 9 and  date_part(mm, V_DATE) < 10 then
				 date_part(year, V_DATE)||'0'||date_part(mm, V_DATE)||date_part(dd, V_DATE)
				 when date_part(dd, V_DATE) > 9 and  date_part(mm, V_DATE) > 9 then
				 date_part(year, V_DATE)||date_part(mm, V_DATE)||date_part(dd, V_DATE) end as DimDateID,
			V_DATE as FullDate,
			dayname(dateadd(day,row_numbers,DD)) as DAY_NAME_1,
			case 
				when dayname(dateadd(day,row_numbers,DD)) = 'Mon' then 'Monday'
				when dayname(dateadd(day,row_numbers,DD)) = 'Tue' then 'Tuesday'
				when dayname(dateadd(day,row_numbers,DD)) = 'Wed' then 'Wednesday'
				when dayname(dateadd(day,row_numbers,DD)) = 'Thu' then 'Thursday'
				when dayname(dateadd(day,row_numbers,DD)) = 'Fri' then 'Friday'
				when dayname(dateadd(day,row_numbers,DD)) = 'Sat' then 'Saturday'
				when dayname(dateadd(day,row_numbers,DD)) = 'Sun' then 'Sunday' end ||', '||
			case when monthname(dateadd(day,row_numbers,DD)) ='Jan' then 'January'
				   when monthname(dateadd(day,row_numbers,DD)) ='Feb' then 'February'
				   when monthname(dateadd(day,row_numbers,DD)) ='Mar' then 'March'
				   when monthname(dateadd(day,row_numbers,DD)) ='Apr' then 'April'
				   when monthname(dateadd(day,row_numbers,DD)) ='May' then 'May'
				   when monthname(dateadd(day,row_numbers,DD)) ='Jun' then 'June'
				   when monthname(dateadd(day,row_numbers,DD)) ='Jul' then 'July'
				   when monthname(dateadd(day,row_numbers,DD)) ='Aug' then 'August'
				   when monthname(dateadd(day,row_numbers,DD)) ='Sep' then 'September'
				   when monthname(dateadd(day,row_numbers,DD)) ='Oct' then 'October'
				   when monthname(dateadd(day,row_numbers,DD)) ='Nov' then 'November'
				   when monthname(dateadd(day,row_numbers,DD)) ='Dec' then 'December' end
				   ||' '|| to_varchar(dateadd(day,row_numbers,DD), ' dd, yyyy') as FULL_DATE_DESC,
			dateadd(day,row_numbers,DD) as V_DATE_1,
			dayofweek(V_DATE_1)+1 as DayNumberOfWeek,
			Date_part(dd,V_DATE_1) as DayNumberOfMonth,
			dayofyear(V_DATE_1) as DayNumberOfYear,
			case 
				when dayname(V_DATE_1) = 'Mon' then 'Monday'
				when dayname(V_DATE_1) = 'Tue' then 'Tuesday'
				when dayname(V_DATE_1) = 'Wed' then 'Wednesday'
				when dayname(V_DATE_1) = 'Thu' then 'Thursday'
				when dayname(V_DATE_1) = 'Fri' then 'Friday'
				when dayname(V_DATE_1) = 'Sat' then 'Saturday'
				when dayname(V_DATE_1) = 'Sun' then 'Sunday' end as	DayName,
			dayname(dateadd(day,row_numbers,DD)) as DAY_ABBREV,
			case  
				when dayname(V_DATE_1) = 'Sun' and dayname(V_DATE_1) = 'Sat' then 
                 'Not-Weekday'
				else 'Weekday' end as WEEKDAY_IND,
			 case 
				when (DimDateID = date_part(year, V_DATE)||'0101' or DimDateID = date_part(year, V_DATE)||'0704' or
				DimDateID = date_part(year, V_DATE)||'1225' or DimDateID = date_part(year, V_DATE)||'1226') then  
				'Holiday' 
				when monthname(V_DATE_1) ='May' and dayname(last_day(V_DATE_1)) = 'Wed' 
				and dateadd(day,-2,last_day(V_DATE_1)) = V_DATE_1  then
				'Holiday'
				when monthname(V_DATE_1) ='May' and dayname(last_day(V_DATE_1)) = 'Thu' 
				and dateadd(day,-3,last_day(V_DATE_1)) = V_DATE_1  then
				'Holiday'
				when monthname(V_DATE_1) ='May' and dayname(last_day(V_DATE_1)) = 'Fri' 
				and dateadd(day,-4,last_day(V_DATE_1)) = V_DATE_1 then
				'Holiday'
				when monthname(V_DATE_1) ='May' and dayname(last_day(V_DATE_1)) = 'Sat' 
				and dateadd(day,-5,last_day(V_DATE_1)) = V_DATE_1  then
				'Holiday'
				when monthname(V_DATE_1) ='May' and dayname(last_day(V_DATE_1)) = 'Sun' 
				and dateadd(day,-6,last_day(V_DATE_1)) = V_DATE_1 then
				'Holiday'
				when monthname(V_DATE_1) ='May' and dayname(last_day(V_DATE_1)) = 'Mon' 
				and last_day(V_DATE_1) = V_DATE_1 then
				'Holiday'
				when monthname(V_DATE_1) ='May' and dayname(last_day(V_DATE_1)) = 'Tue' 
				and dateadd(day,-1 ,last_day(V_DATE_1)) = V_DATE_1  then
				'Holiday'
				when monthname(V_DATE_1) ='Sep' and dayname(date_part(year, V_DATE_1)||'-09-01') = 'Wed' 
				and dateadd(day,5,(date_part(year, V_DATE_1)||'-09-01')) = V_DATE_1  then
				'Holiday' 
				when monthname(V_DATE_1) ='Sep' and dayname(date_part(year, V_DATE_1)||'-09-01') = 'Thu' 
				and dateadd(day,4,(date_part(year, V_DATE_1)||'-09-01')) = V_DATE_1  then
				'Holiday' 
				when monthname(V_DATE_1) ='Sep' and dayname(date_part(year, V_DATE_1)||'-09-01') = 'Fri' 
				and dateadd(day,3,(date_part(year, V_DATE_1)||'-09-01')) = V_DATE_1 then
				'Holiday' 
				when monthname(V_DATE_1) ='Sep' and dayname(date_part(year, V_DATE_1)||'-09-01') = 'Sat' 
				and dateadd(day,2,(date_part(year, V_DATE_1)||'-09-01')) = V_DATE_1  then
				'Holiday' 
				when monthname(V_DATE_1) ='Sep' and dayname(date_part(year, V_DATE_1)||'-09-01') = 'Sun' 
				and dateadd(day,1,(date_part(year, V_DATE_1)||'-09-01')) = V_DATE_1 then
				'Holiday' 
				when monthname(V_DATE_1) ='Sep' and dayname(date_part(year, V_DATE_1)||'-09-01') = 'Mon' 
				and date_part(year, V_DATE_1)||'-09-01' = V_DATE_1 then
				'Holiday' 
				when monthname(V_DATE_1) ='Sep' and dayname(date_part(year, V_DATE_1)||'-09-01') = 'Tue' 
				and dateadd(day,6 ,(date_part(year, V_DATE_1)||'-09-01')) = V_DATE_1  then
				'Holiday' 
				when monthname(V_DATE_1) ='Nov' and dayname(date_part(year, V_DATE_1)||'-11-01') = 'Wed' 
				and (dateadd(day,23,(date_part(year, V_DATE_1)||'-11-01')) = V_DATE_1  or 
					 dateadd(day,22,(date_part(year, V_DATE_1)||'-11-01')) = V_DATE_1 ) then
				'Holiday'
				when monthname(V_DATE_1) ='Nov' and dayname(date_part(year, V_DATE_1)||'-11-01') = 'Thu' 
				and ( dateadd(day,22,(date_part(year, V_DATE_1)||'-11-01')) = V_DATE_1 or 
					 dateadd(day,21,(date_part(year, V_DATE_1)||'-11-01')) = V_DATE_1 ) then
				'Holiday'
				when monthname(V_DATE_1) ='Nov' and dayname(date_part(year, V_DATE_1)||'-11-01') = 'Fri' 
				and ( dateadd(day,21,(date_part(year, V_DATE_1)||'-11-01')) = V_DATE_1 or 
					 dateadd(day,20,(date_part(year, V_DATE_1)||'-11-01')) = V_DATE_1 ) then
				 'Holiday'
				when monthname(V_DATE_1) ='Nov' and dayname(date_part(year, V_DATE_1)||'-11-01') = 'Sat' 
				and ( dateadd(day,27,(date_part(year, V_DATE_1)||'-11-01')) = V_DATE_1 or 
					 dateadd(day,26,(date_part(year, V_DATE_1)||'-11-01')) = V_DATE_1 ) then
				'Holiday'
				when monthname(V_DATE_1) ='Nov' and dayname(date_part(year, V_DATE_1)||'-11-01') = 'Sun' 
				and ( dateadd(day,26,(date_part(year, V_DATE_1)||'-11-01')) = V_DATE_1 or 
					 dateadd(day,25,(date_part(year, V_DATE_1)||'-11-01')) = V_DATE_1 ) then
				'Holiday'
				when monthname(V_DATE_1) ='Nov' and dayname(date_part(year, V_DATE_1)||'-11-01') = 'Mon' 
				and (dateadd(day,25,(date_part(year, V_DATE_1)||'-11-01')) = V_DATE_1 or 
					 dateadd(day,24,(date_part(year, V_DATE_1)||'-11-01')) = V_DATE_1 ) then
				'Holiday'
				when monthname(V_DATE_1) ='Nov' and dayname(date_part(year, V_DATE_1)||'-11-01') = 'Tue' 
				and (dateadd(day,24,(date_part(year, V_DATE_1)||'-11-01')) = V_DATE_1 or 
					 dateadd(day,23,(date_part(year, V_DATE_1)||'-11-01')) = V_DATE_1 ) then
				 'Holiday'    
				else
				'Not-Holiday' end as US_HOLIDAY_IND,
			/*Modify the following for Company Specific Holidays*/
			case 
				when (DimDateID = date_part(year, V_DATE)||'0101' or DimDateID = date_part(year, V_DATE)||'0219'
				or DimDateID = date_part(year, V_DATE)||'0528' or DimDateID = date_part(year, V_DATE)||'0704' 
				or DimDateID = date_part(year, V_DATE)||'1225' )then 
				'Holiday'               
                when monthname(V_DATE_1) ='Mar' and dayname(last_day(V_DATE_1)) = 'Fri' 
				and last_day(V_DATE_1) = V_DATE_1 then
				'Holiday'
				when monthname(V_DATE_1) ='Mar' and dayname(last_day(V_DATE_1)) = 'Sat' 
				and dateadd(day,-1,last_day(V_DATE_1)) = V_DATE_1  then
				'Holiday'
				when monthname(V_DATE_1) ='Mar' and dayname(last_day(V_DATE_1)) = 'Sun' 
				and dateadd(day,-2,last_day(V_DATE_1)) = V_DATE_1 then
				'Holiday'
				when monthname(V_DATE_1) ='Apr' and dayname(date_part(year, V_DATE_1)||'-04-01') = 'Tue'
                and dateadd(day,3,(date_part(year, V_DATE_1)||'-04-01')) = V_DATE_1 then
				'Holiday'
				when monthname(V_DATE_1) ='Apr' and dayname(date_part(year, V_DATE_1)||'-04-01') = 'Wed' 
				and dateadd(day,2,(date_part(year, V_DATE_1)||'-04-01')) = V_DATE_1 then
				'Holiday'
				when monthname(V_DATE_1) ='Apr' and dayname(date_part(year, V_DATE_1)||'-04-01') = 'Thu'
                and dateadd(day,1,(date_part(year, V_DATE_1)||'-04-01')) = V_DATE_1 then
				'Holiday'
				when monthname(V_DATE_1) ='Apr' and dayname(date_part(year, V_DATE_1)||'-04-01') = 'Fri' 
				and date_part(year, V_DATE_1)||'-04-01' = V_DATE_1 then
				'Holiday'
                when monthname(V_DATE_1) ='Apr' and dayname(date_part(year, V_DATE_1)||'-04-01') = 'Wed' 
				and dateadd(day,5,(date_part(year, V_DATE_1)||'-04-01')) = V_DATE_1  then
				'Holiday' 
				when monthname(V_DATE_1) ='Apr' and dayname(date_part(year, V_DATE_1)||'-04-01') = 'Thu' 
				and dateadd(day,4,(date_part(year, V_DATE_1)||'-04-01')) = V_DATE_1  then
				'Holiday' 
				when monthname(V_DATE_1) ='Apr' and dayname(date_part(year, V_DATE_1)||'-04-01') = 'Fri' 
				and dateadd(day,3,(date_part(year, V_DATE_1)||'-04-01')) = V_DATE_1 then
				'Holiday' 
				when monthname(V_DATE_1) ='Apr' and dayname(date_part(year, V_DATE_1)||'-04-01') = 'Sat' 
				and dateadd(day,2,(date_part(year, V_DATE_1)||'-04-01')) = V_DATE_1  then
				'Holiday' 
				when monthname(V_DATE_1) ='Apr' and dayname(date_part(year, V_DATE_1)||'-04-01') = 'Sun' 
				and dateadd(day,1,(date_part(year, V_DATE_1)||'-04-01')) = V_DATE_1 then
				'Holiday' 
				when monthname(V_DATE_1) ='Apr' and dayname(date_part(year, V_DATE_1)||'-04-01') = 'Mon' 
                and date_part(year, V_DATE_1)||'-04-01'= V_DATE_1 then
				'Holiday' 
				when monthname(V_DATE_1) ='Apr' and dayname(date_part(year, V_DATE_1)||'-04-01') = 'Tue' 
				and dateadd(day,6 ,(date_part(year, V_DATE_1)||'-04-01')) = V_DATE_1  then
				'Holiday'   
				when monthname(V_DATE_1) ='Sep' and dayname(date_part(year, V_DATE_1)||'-09-01') = 'Wed' 
				and dateadd(day,5,(date_part(year, V_DATE_1)||'-09-01')) = V_DATE_1  then
				'Holiday' 
				when monthname(V_DATE_1) ='Sep' and dayname(date_part(year, V_DATE_1)||'-09-01') = 'Thu' 
				and dateadd(day,4,(date_part(year, V_DATE_1)||'-09-01')) = V_DATE_1  then
				'Holiday' 
				when monthname(V_DATE_1) ='Sep' and dayname(date_part(year, V_DATE_1)||'-09-01') = 'Fri' 
				and dateadd(day,3,(date_part(year, V_DATE_1)||'-09-01')) = V_DATE_1 then
				'Holiday' 
				when monthname(V_DATE_1) ='Sep' and dayname(date_part(year, V_DATE_1)||'-09-01') = 'Sat' 
				and dateadd(day,2,(date_part(year, V_DATE_1)||'-09-01')) = V_DATE_1  then
				'Holiday' 
				when monthname(V_DATE_1) ='Sep' and dayname(date_part(year, V_DATE_1)||'-09-01') = 'Sun' 
				and dateadd(day,1,(date_part(year, V_DATE_1)||'-09-01')) = V_DATE_1 then
				'Holiday' 
				when monthname(V_DATE_1) ='Sep' and dayname(date_part(year, V_DATE_1)||'-09-01') = 'Mon' 
                and date_part(year, V_DATE_1)||'-09-01' = V_DATE_1 then
				'Holiday' 
				when monthname(V_DATE_1) ='Sep' and dayname(date_part(year, V_DATE_1)||'-09-01') = 'Tue' 
				and dateadd(day,6 ,(date_part(year, V_DATE_1)||'-09-01')) = V_DATE_1  then
				'Holiday' 
				when monthname(V_DATE_1) ='Nov' and dayname(date_part(year, V_DATE_1)||'-11-01') = 'Wed' 
				and dateadd(day,23,(date_part(year, V_DATE_1)||'-11-01')) = V_DATE_1 then
				'Holiday'
				when monthname(V_DATE_1) ='Nov' and dayname(date_part(year, V_DATE_1)||'-11-01') = 'Thu' 
				and dateadd(day,22,(date_part(year, V_DATE_1)||'-11-01')) = V_DATE_1 then
				'Holiday'
				when monthname(V_DATE_1) ='Nov' and dayname(date_part(year, V_DATE_1)||'-11-01') = 'Fri' 
				and dateadd(day,21,(date_part(year, V_DATE_1)||'-11-01')) = V_DATE_1  then
				 'Holiday'
				when monthname(V_DATE_1) ='Nov' and dayname(date_part(year, V_DATE_1)||'-11-01') = 'Sat' 
				and dateadd(day,27,(date_part(year, V_DATE_1)||'-11-01')) = V_DATE_1 then
				'Holiday'
				when monthname(V_DATE_1) ='Nov' and dayname(date_part(year, V_DATE_1)||'-11-01') = 'Sun' 
				and dateadd(day,26,(date_part(year, V_DATE_1)||'-11-01')) = V_DATE_1 then
				'Holiday'
				when monthname(V_DATE_1) ='Nov' and dayname(date_part(year, V_DATE_1)||'-11-01') = 'Mon' 
				and dateadd(day,25,(date_part(year, V_DATE_1)||'-11-01')) = V_DATE_1 then
				'Holiday'
				when monthname(V_DATE_1) ='Nov' and dayname(date_part(year, V_DATE_1)||'-11-01') = 'Tue' 
				and dateadd(day,24,(date_part(year, V_DATE_1)||'-11-01')) = V_DATE_1  then
				 'Holiday'     
				else
				'Not-Holiday' end as COMPANY_HOLIDAY_IND,
			case                                           
				when last_day(V_DATE_1) = V_DATE_1 then 
				'Month-end'
				else 'Not-Month-end' end as MONTH_END_IND,
					
			case when date_part(mm,date_trunc('week',V_DATE_1)) < 10 and date_part(dd,date_trunc('week',V_DATE_1)) < 10 then
					  date_part(yyyy,date_trunc('week',V_DATE_1))||'0'||
					  date_part(mm,date_trunc('week',V_DATE_1))||'0'||
					  date_part(dd,date_trunc('week',V_DATE_1))  
				 when date_part(mm,date_trunc('week',V_DATE_1)) < 10 and date_part(dd,date_trunc('week',V_DATE_1)) > 9 then
						date_part(yyyy,date_trunc('week',V_DATE_1))||'0'||
						date_part(mm,date_trunc('week',V_DATE_1))||date_part(dd,date_trunc('week',V_DATE_1))    
				 when date_part(mm,date_trunc('week',V_DATE_1)) > 9 and date_part(dd,date_trunc('week',V_DATE_1)) < 10 then
						date_part(yyyy,date_trunc('week',V_DATE_1))||date_part(mm,date_trunc('week',V_DATE_1))||
						'0'||date_part(dd,date_trunc('week',V_DATE_1))    
				when date_part(mm,date_trunc('week',V_DATE_1)) > 9 and date_part(dd,date_trunc('week',V_DATE_1)) > 9 then
						date_part(yyyy,date_trunc('week',V_DATE_1))||
						date_part(mm,date_trunc('week',V_DATE_1))||
						date_part(dd,date_trunc('week',V_DATE_1)) end as WEEK_BEGIN_DATE_NKEY,
			date_trunc('week',V_DATE_1) as WEEK_BEGIN_DATE,

			case when  date_part(mm,last_day(V_DATE_1,'week')) < 10 and date_part(dd,last_day(V_DATE_1,'week')) < 10 then
					  date_part(yyyy,last_day(V_DATE_1,'week'))||'0'||
					  date_part(mm,last_day(V_DATE_1,'week'))||'0'||
					  date_part(dd,last_day(V_DATE_1,'week')) 
				 when  date_part(mm,last_day(V_DATE_1,'week')) < 10 and date_part(dd,last_day(V_DATE_1,'week')) > 9 then
					  date_part(yyyy,last_day(V_DATE_1,'week'))||'0'||
					  date_part(mm,last_day(V_DATE_1,'week'))||date_part(dd,last_day(V_DATE_1,'week'))   
				 when  date_part(mm,last_day(V_DATE_1,'week')) > 9 and date_part(dd,last_day(V_DATE_1,'week')) < 10  then
					  date_part(yyyy,last_day(V_DATE_1,'week'))||date_part(mm,last_day(V_DATE_1,'week'))||'0'||
					  date_part(dd,last_day(V_DATE_1,'week'))   
				 when  date_part(mm,last_day(V_DATE_1,'week')) > 9 and date_part(dd,last_day(V_DATE_1,'week')) > 9 then
					  date_part(yyyy,last_day(V_DATE_1,'week'))||
					  date_part(mm,last_day(V_DATE_1,'week'))||
					  date_part(dd,last_day(V_DATE_1,'week')) end as WEEK_END_DATE_NKEY,
			last_day(V_DATE_1,'week') as WEEK_END_DATE,
			week(V_DATE_1) as WEEK_NUM_IN_YEAR,
			case when monthname(V_DATE_1) ='Jan' then 'January'
				   when monthname(V_DATE_1) ='Feb' then 'February'
				   when monthname(V_DATE_1) ='Mar' then 'March'
				   when monthname(V_DATE_1) ='Apr' then 'April'
				   when monthname(V_DATE_1) ='May' then 'May'
				   when monthname(V_DATE_1) ='Jun' then 'June'
				   when monthname(V_DATE_1) ='Jul' then 'July'
				   when monthname(V_DATE_1) ='Aug' then 'August'
				   when monthname(V_DATE_1) ='Sep' then 'September'
				   when monthname(V_DATE_1) ='Oct' then 'October'
				   when monthname(V_DATE_1) ='Nov' then 'November'
				   when monthname(V_DATE_1) ='Dec' then 'December' end as MonthName,
			monthname(V_DATE_1) as MONTH_ABBREV,
			month(V_DATE_1) as MonthNumberOfYear,
			case when month(V_DATE_1) < 10 then 
			year(V_DATE_1)||'-0'||month(V_DATE_1)   
			else year(V_DATE_1)||'-'||month(V_DATE_1) end as YearMonth,
			quarter(V_DATE_1) as Quarter,
			year(V_DATE_1)||'-0'||quarter(V_DATE_1) as YearQuarter,
			year(V_DATE_1) as CalendarYear
	        from table(generator(rowcount => 730))
    )v;


-- CREATING 2ND TABLE - DIM_PRODUCT

CREATE OR REPLACE TABLE dim_product
(
	DimProductID			                 INTEGER IDENTITY(1,1) PRIMARY KEY,
	ProductID				                 INTEGER NOT NULL,
	ProductTypeID			                 INTEGER NOT NULL,
	ProductCategoryID		                 INTEGER NOT NULL,
	ProductName			                     VARCHAR(255) NOT NULL,
	ProductType				                 VARCHAR(255) NOT NULL,
	ProductCategory		                     VARCHAR(255) NOT NULL,
	ProductRetailPrice		                 FLOAT NOT NULL,
	ProductWholesalePrice	                 FLOAT NOT NULL,
	ProductCost				                 FLOAT NOT NULL,
	ProductRetailProfit		                 FLOAT NOT NULL,
    ProductWholesaleUnitProfit               FLOAT NOT NULL,
    ProductProfitMarginUnitPercentRetail     FLOAT NOT NULL,
    ProductProfitMarginUnitPercentWholesale  FLOAT NOT NULL
); 

INSERT INTO dim_product
(
    DimProductID,
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
)
VALUES
(
    -1,
    -1,
    -1,
    -1,
    'UNKNOWN',
    'UNKNOWN',
    'UNKNOWN',
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1
);

INSERT INTO dim_product
(
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
)
SELECT  ProductID,
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
FROM
(
    SELECT  p.PRODUCTID                                 AS ProductID,
            pt.PRODUCTTYPEID                            AS ProductTypeID,
            pc.PRODUCTCATEGORYID                        AS ProductCategoryID,
            p.PRODUCT                                   AS ProductName,
            pt.PRODUCTTYPE                              AS ProductType,
            pc.PRODUCTCATEGORY                          AS ProductCategory,
            p.PRICE                                     AS ProductRetailPrice,
            p.WHOLESALEPRICE                            AS ProductWholesalePrice,
            p.COST                                      AS ProductCost,
            (p.PRICE - p.COST)                          AS ProductRetailProfit,
            (p.WHOLESALEPRICE - p.COST)                 AS ProductWholesaleUnitProfit,
            (ProductRetailProfit/p.Price)*100           AS ProductProfitMarginUnitPercentRetail,
            (ProductRetailProfit/p.WHOLESALEPRICE)*100  AS ProductProfitMarginUnitPercentWholesale
    FROM STAGE_PRODUCT p
    LEFT JOIN STAGE_PRODUCTTYPE pt ON p.PRODUCTTYPEID = pt.PRODUCTTYPEID
    LEFT JOIN STAGE_PRODUCTCATEGORY pc ON pt.PRODUCTCATEGORYID = pc.PRODUCTCATEGORYID
);

-- CREATING 3RD TABLE - DIM_CHANNEL

CREATE OR REPLACE TABLE dim_channel
(
	DimChannelID           INTEGER IDENTITY(1,1) PRIMARY KEY,
	ChannelID			   INTEGER NOT NULL,
	ChannelCategoryID	   INTEGER NOT NULL,
	ChannelName		       VARCHAR(255) NOT NULL,
	ChannelCategory		   VARCHAR(255) NOT NULL
); 

INSERT INTO dim_channel
(
	DimChannelID,
    ChannelID,
	ChannelCategoryID,
	ChannelName,
	ChannelCategory
)
VALUES
(
    -1,
    -1,
    -1,
    'UNKNOWN',
    'UNKNOWN'
);

INSERT INTO dim_channel
(
	ChannelID,
	ChannelCategoryID,
	ChannelName,
	ChannelCategory
)
SELECT  ChannelID,
		ChannelCategoryID,
		ChannelName,
		ChannelCategory
FROM
(
    SELECT  c.CHANNELID                 AS ChannelID,
            cc.CHANNELCATEGORYID        AS ChannelCategoryID,
            CASE WHEN c.CHANNEL IN ('On-line') THEN 'Online' ELSE c.CHANNEL END AS ChannelName,
            cc.CHANNELCATEGORY          AS ChannelCategory
    FROM STAGE_CHANNEL c
    LEFT JOIN STAGE_CHANNELCATEGORY cc ON c.CHANNELCATEGORYID = cc.CHANNELCATEGORYID
);

-- CREATING 4th TABLE - DIM_LOCATION

CREATE OR REPLACE TABLE dim_location 
(
	DimLocationID         INTEGER IDENTITY (1,1) PRIMARY KEY,
	Address			      VARCHAR(255) NOT NULL,
	City	              VARCHAR(255) NOT NULL,
	PostalCode		      VARCHAR(255) NOT NULL,
	State_Province		  VARCHAR(255) NOT NULL,
    Country               VARCHAR(255) NOT NULL    
); 

INSERT INTO dim_location 
(
    Address,
    City,
    PostalCode,
    State_Province,
    Country
)
SELECT  Address,
		City,
		PostalCode,
		State_Province,
        Country
FROM
(
    SELECT  s.ADDRESS           AS Address,
            s.CITY              AS City,
            s.POSTALCODE        AS PostalCode,
            s.STATEPROVINCE     AS State_Province,
            s.COUNTRY           AS Country,
    FROM STAGE_STORE s

    UNION ALL

    SELECT  r.ADDRESS           AS Address,
            r.CITY              AS City,
            r.POSTALCODE        AS PostalCode,
            r.STATEPROVINCE     AS State_Province,
            r.COUNTRY           AS Country,
    FROM STAGE_RESELLER r

    UNION ALL

    SELECT  c.ADDRESS           AS Address,
            c.CITY              AS City,
            c.POSTALCODE        AS PostalCode,
            c.STATEPROVINCE     AS State_Province,
            c.COUNTRY           AS Country,
    FROM STAGE_CUSTOMER c
);

-- CREATING 5th TABLE - DIM_STORE

CREATE OR REPLACE TABLE dim_store 
(
	DimStoreID            INTEGER IDENTITY (1,1) PRIMARY KEY,
    DimLocationID         INTEGER NOT NULL,
	SourceStoreID	      INTEGER NOT NULL,
	StoreName	          VARCHAR(255) NOT NULL,
	StoreNumber		      INTEGER NOT NULL,
	StoreManager		  VARCHAR(255) NOT NULL,
    FOREIGN KEY (DimLocationID) REFERENCES dim_location(DimLocationID)
); 

INSERT INTO dim_store 
(
    DimStoreID,
    DimLocationID,
    SourceStoreID,
    StoreName,
    StoreNumber,
    StoreManager
)
VALUES
(
    -1,
    -1,
    -1,
    'UNKNOWN',
    -1,
    'UNKNOWN'
);

INSERT INTO dim_store 
(
    DimLocationID,
    SourceStoreID,
    StoreName,
    StoreNumber,
    StoreManager
)
SELECT  DimLocationID,
		SourceStoreID,
		StoreName,
		StoreNumber,
        StoreManager
FROM
(
    SELECT  l.DimLocationID                         AS DimLocationID,
            s.STOREID                               AS SourceStoreID,
            CONCAT('Store Number ', s.STORENUMBER)  AS StoreName,
            s.STORENUMBER                           AS StoreNumber,
            s.STOREMANAGER                          AS StoreManager
    FROM STAGE_STORE s
    LEFT JOIN dim_location l 
        ON s.ADDRESS = l.Address
);

-- CREATING 6th TABLE - DIM_RESELLER

CREATE OR REPLACE TABLE dim_reseller 
(
	DimResellerID      INTEGER IDENTITY (1,1) PRIMARY KEY,
    DimLocationID      INTEGER NOT NULL,
	ResellerID	       VARCHAR(255) NOT NULL,
    ResellerName	   VARCHAR(255) NOT NULL,
	ContactName		   VARCHAR(255) NOT NULL,
	PhoneNumber        VARCHAR(255) NOT NULL,
    Email              VARCHAR(255) NOT NULL,   
    FOREIGN KEY (DimLocationID) REFERENCES dim_location(DimLocationID)
); 

INSERT INTO dim_reseller 
(
    DimResellerID,
    DimLocationID,
    ResellerID,
    ResellerName,
    ContactName,
    PhoneNumber,
    Email
)
VALUES
(
    -1,
    -1,
    'UNKNOWN',
    'UNKNOWN',
    'UNKNOWN',
    'UNKNOWN',
    'UNKNOWN'
);

INSERT INTO dim_reseller 
(
    DimLocationID,
    ResellerID,
    ResellerName,
    ContactName,
    PhoneNumber,
    Email
)
SELECT  DimLocationID,
		ResellerID,
        ResellerName,
		ContactName,
		PhoneNumber,
        Email
FROM
(
    SELECT  l.DimLocationID     AS DimLocationID,
            r.RESELLERID        AS ResellerID,
            r.RESELLERNAME      AS ResellerName,
            r.CONTACT           AS ContactName,
            r.PHONENUMBER       AS PhoneNumber,
            r.EMAILADDRESS      AS Email
    FROM STAGE_RESELLER r
    LEFT JOIN dim_location l 
        ON r.ADDRESS = l.Address
);

-- CREATING 7th TABLE - DIM_CUSTOMER

CREATE OR REPLACE TABLE dim_customer 
(
	DimCustomerID           INTEGER IDENTITY (1,1) PRIMARY KEY,
    DimLocationID           INTEGER NOT NULL,
	CustomerID	            VARCHAR(255) NOT NULL,
	CustomerFullName        VARCHAR(255) NOT NULL,
	CustomerFirstName       VARCHAR(255) NOT NULL,
    CustomerLastName        VARCHAR(255) NOT NULL,
    CustomerPhoneNumber     VARCHAR(255) NOT NULL,  
    CustomerEmail           VARCHAR(255) NOT NULL,
    CustomerGender          VARCHAR(255) NOT NULL,
    FOREIGN KEY (DimLocationID) REFERENCES dim_location(DimLocationID)
); 

INSERT INTO dim_customer 
(
    DimCustomerID,
    DimLocationID,
    CustomerID,
    CustomerFullName,
    CustomerFirstName,
    CustomerLastName,
    CustomerPhoneNumber,
    CustomerEmail,
    CustomerGender
)
VALUES
(
    -1,
    -1,
    'UNKNOWN',
    'UNKNOWN',
    'UNKNOWN',
    'UNKNOWN',
    'UNKNOWN',
    'UNKNOWN',
    'UNKNOWN'
);

INSERT INTO dim_customer 
(
    DimLocationID,
    CustomerID,
    CustomerFullName,
    CustomerFirstName,
    CustomerLastName,
    CustomerPhoneNumber,
    CustomerEmail,
    CustomerGender
)
SELECT  DimLocationID,
		CustomerID,
		CustomerFullName,
        CustomerFirstName,
		CustomerLastName,
        CustomerPhoneNumber,
        CustomerEmail,
        CustomerGender
FROM
(
    SELECT  l.DimLocationID                         AS DimLocationID,
            c.CUSTOMERID                            AS CustomerID,
            CONCAT(c.FIRSTNAME, ' ', c.LASTNAME)    AS CustomerFullName,
            c.FIRSTNAME                             AS CustomerFirstName,
            c.LASTNAME                              AS CustomerLastName,
            c.PHONENUMBER                           AS CustomerPhoneNumber,
            c.EMAILADDRESS                          AS CustomerEmail,
            c.GENDER                                AS CustomerGender
    FROM STAGE_CUSTOMER c
    LEFT JOIN dim_location l 
        ON c.ADDRESS = l.Address
);