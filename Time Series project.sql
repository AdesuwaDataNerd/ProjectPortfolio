Create database SuperStore;
use SuperStore;


#CREATING THE TABLE
create table superstore_test(Row_ID int, Order_ID varchar(50),OrderDate date,ShipDate date,ShipMode varchar(20),
CustomerID varchar(20),CustomerName varchar(20),Segment varchar(20),Country varchar(20), City varchar(20),
State varchar(20), PostalCode int,Region varchar(20),ProductID varchar(20),Category varchar(20),Sub_Category varchar(20),
ProductName varchar(50), Sales float, Quantity int,Discount float);

#IMPORTING THE DATA
Load data infile "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\superstore_test.csv" into table superstoretests
fields terminated by','
enclosed by ''''
lines terminated by '\r\n'
ignore 1 lines
(Row_ID, Order_ID, OrderDate, ShipDate, ShipMode, CustomerID, CustomerName, Segment, Country, City, State, PostalCode, Region, ProductID, Category, Sub_Category, ProductName, Sales, Quantity, Discount);
select @@sql_mode;
set SQL_MODE='';
set global interactive_timeout=6000;
show global variables like'read_only';
show global variables like 'local_infile';
show variables like 'secure_file_priv';
set global local_infile=true;

select * from superstore_test;
#Comparison between a row and the previous one using the lead window function
Select sales,lead(sales) over() as Sales_next from superstore_test;

#Using Lag window function
select sales, lag(sales) over() as Sales_Previous from superstore_test;

#Ranking the data

select *,rank() over(order by sales desc) as Sales_Rank from  superstore_test;

#Average monthly sales
select * from superstore_test;
select monthname(orderdate),round(avg(sales)) as AverageMonthlySales from superstore_test
group by monthname(orderdate)
order by monthname(orderdate)desc;

#Average daily sales
select dayname(orderdate),avg(sales) from superstore_test
group by dayname(orderdate)
order by dayname(orderdate);

#Using CTE to analyze the discount on two consecutive days
with cte as(
		select orderdate,discount,  row_number() over (order by orderdate) days,
        row_number() over (partition by discount) dayss from superstore_test)
select * from cte order by orderdate;

#Evaluating moving average using windows function
select *, case when row_number() over(order by orderdate) >=2 then
 avg(sales) over(order by orderdate
					rows between 2 preceding and current row)
else null
end as avg
from superstore_test
order by orderdate;











