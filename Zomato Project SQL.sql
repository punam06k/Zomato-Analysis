create database zomato_analysis;

use zomato_analysis;

create table if not exists zomato(
`RestaurantID`  bigint not null unique,
`RestaurantName` varchar(250) not null,	
`CountryCode`  int not null,
`City` varchar(250) not null,	
`Address` varchar(250) not null,	
`Locality` varchar(250) not null,	
`LocalityVerbose` varchar(250) not null,
`Longitude`  double not null,
`Latitude`  double not null,	
`Cuisines` varchar(250) not null,	
`Currency` varchar(250) not null,	
`Has_Table_booking`  char(4),
`Has_Online_delivery`  char(4),	
`Is_delivering_now`  char(4),
`Switch_to_order_menu` char(4),	
`Price_range`  int not null,
`Votes` int not null,
`Average_Cost_for_two` int not null,	
`Rating` float,	
`Datekey_Opening` date not null,	
`Opening_date` date not null,
 primary key (`RestaurantID`)
 );
 
select * from zomato;

set session sql_mode = '';

load data infile
'C:/ZomataSql.csv'
into table zomato
CHARACTER SET latin1
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

# 1. Build a country Map Table
create table if not exists CountryMapTable(
`country_code` int,
`country_name` varchar(30)
);

insert  into CountryMapTable values(1, 'India'),(14, 'Australia'),(30, 'Brazil'),(37, 'Canada'),(94, 'Indonesia'),
(148, 'New Zealand'),(162, 'Philippines'),(166, 'Qatar'),(184, 'Singapore'),(189, 'South Africa'),(191, 'Shri Lanka'),
(208, 'Turkey'),(214,'United Arab Emirates'),(215, 'United Kingdom'),(216, 'United States');

select * from CountryMapTable;


#2. Build a Calendar Table using the Column Datekey
-- Year
select year(Opening_date) as `Year` from zomato;

-- MonthNo
select month(Opening_date) as MonthNo from zomato;

-- MonthName
select monthname(Opening_date) as MonthFullName from zomato;

-- Quarter
select concat('Q',ceil(month(Opening_date) / 3)) as `Quarter` from zomato;

-- YearMonth
select concat(YEAR(Opening_date), '-', DATE_FORMAT(Opening_date, '%b')) as YearMonth from zomato;

-- WeekdayNo
select weekday(Opening_date) as WeekdayNo from zomato;

-- WeekdayName
select dayname(Opening_date) as WeekdayName from zomato;

-- Financial Month
select  case 
 when month(Opening_date) = 4 then 'FM1'
 when month(Opening_date) = 5 then 'FM2'
 when month(Opening_date) = 6 then 'FM3'
 when month(Opening_date) = 7 then 'FM4'
 when month(Opening_date) = 8 then 'FM5'
 when month(Opening_date) = 9 then 'FM6'
 when month(Opening_date) = 10 then 'FM7'
 when month(Opening_date) = 11 then 'FM8'
 when month(Opening_date) = 12 then 'FM9'
 when month(Opening_date) = 1 then 'FM10'
 when month(Opening_date) = 2 then 'FM11'
 when month(Opening_date) = 3 then 'FM12'
 end as 'FinancialMonth'
 from zomato;

-- Financial Quarter
SELECT  
 case 
 when month(Opening_date) between 4 and 6 then 'FQ1'
 when month(Opening_date) between 7 and 9 then 'FQ2'
 when month(Opening_date) between 10 and 12 then 'FQ3' 
 when month(Opening_date) between 1 and 3 then 'FQ4'   
 end as FinancialQuarter from zomato;


CREATE TABLE if not exists calendar (
  `Opening_date` DATE NOT NULL,
  `Year` INT NOT NULL,
  `Monthno` INT NOT NULL,
  `Monthfullname` VARCHAR(20) NOT NULL,
  `Quarter` VARCHAR(20) NOT NULL,
  `YearMonth` VARCHAR(10) NOT NULL,
  `Weekdayno` INT NOT NULL,
  `Weekdayname` VARCHAR(20) NOT NULL
);

insert into calendar 
(`Opening_date`, `Year`, `MonthNo`, `MonthFullName`, `Quarter`, `YearMonth`, `WeekdayNo`, `WeekdayName`)
select `Opening_date`,
year(Opening_date) as `YEAR`,
month(Opening_date) as `MonthNo`,
monthname(Opening_date) as `MonthFullName`,
concat('Q',ceil(month(Opening_date) / 3)) as `Quarter`,
concat(YEAR(Opening_date), '-', DATE_FORMAT(Opening_date, '%b')) as `YearMonth`,
weekday(Opening_date) as `WeekdayNo`,
dayname(Opening_date) as `WeekdayName`
from zomato;
 
alter table calendar
add column `FinancialMonth` VARCHAR(5) NOT NULL,
add column `FinancialQuarter` VARCHAR(5) NOT NULL;

update calendar
set  `FinancialMonth` = case
 when month(Opening_date) = 4 then 'FM1'
 when month(Opening_date) = 5 then 'FM2'
 when month(Opening_date) = 6 then 'FM3'
 when month(Opening_date) = 7 then 'FM4'
 when month(Opening_date) = 8 then 'FM5'
 when month(Opening_date) = 9 then 'FM6'
 when month(Opening_date) = 10 then 'FM7'
 when month(Opening_date) = 11 then 'FM8'
 when month(Opening_date) = 12 then 'FM9'
 when month(Opening_date) = 1 then 'FM10'
 when month(Opening_date) = 2 then 'FM11'
 when month(Opening_date) = 3 then 'FM12'
 end;
 
 
update calendar 
 set `FinancialQuarter` = case      
 when month(Opening_date) between 4 and 6 then 'FQ1'
 when month(Opening_date) between 7 and 9 then 'FQ2'
 when month(Opening_date) between 10 and 12 then 'FQ3' 
 when month(Opening_date) between 1 and 3 then 'FQ4'   
 end;
 
select * from calendar;

# 3.Find the Numbers of Resturants based on City and Country.
select zomato.City, CountryMapTable.country_name, count(zomato.RestaurantID) as 'Number of Restaurants' 
from zomato, CountryMapTable where zomato.CountryCode = CountryMapTable.country_code
group by CountryMapTable.country_name, zomato.city
order by 3 desc;

# 4.Numbers of Resturants opening based on Year , Quarter , Month
select year(Opening_date) from zomato;



# 5. Count of Resturants based on Average Ratings
Select count(RestaurantID), avg(Rating) from zomato;


# 6. Create buckets based on Average Price of reasonable size and find out how many resturants falls in each buckets
select 
 case 
	when Average_Cost_for_two >= 0 and Average_Cost_for_two < 1000 then '0-1000'
	when Average_Cost_for_two >= 1000 and Average_Cost_for_two < 5000 then '1001-5000'
	when Average_Cost_for_two >= 5000 and Average_Cost_for_two < 10000 then '5001-10000'
	when Average_Cost_for_two >= 10000 and Average_Cost_for_two < 100000 then '10001-100000'
	when Average_Cost_for_two >= 100000 then 'above 100001'
	end as Bucket,
count(RestaurantID) as 'Number of Restaurants' from zomato group by
case 
	when Average_Cost_for_two >= 0 and Average_Cost_for_two < 1000 then '0-1000'
	when Average_Cost_for_two >= 1000 and Average_Cost_for_two < 5000 then '1001-5000'
	when Average_Cost_for_two >= 5000 and Average_Cost_for_two < 10000 then '5001-10000'
	when Average_Cost_for_two >= 10000 and Average_Cost_for_two < 100000 then '10001-100000'
	when Average_Cost_for_two >= 100000 then 'above 100001'
	end;


# 7.Percentage of Resturants based on "Has_Table_booking".
SELECT Has_Table_booking, 
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS percentage 
FROM 
    zomato
GROUP BY 
    Has_Table_booking;

# 8.Percentage of Resturants based on "Has_Online_delivery" 
SELECT Has_Online_delivery, 
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS percentage 
FROM 
    zomato
GROUP BY 
    Has_Online_delivery;
    
  
  
  
  
  
  
  
  
 SELECT Has_Table_booking, 
       COUNT(*) AS NumRestaurants, 
       ROUND(COUNT(*) / (SELECT COUNT(*) FROM zomatodata) * 100, 2) AS Percentage
FROM zomatodata
GROUP BY Has_Table_booking;   