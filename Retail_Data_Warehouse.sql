create table S_Customer(
Customer_ID varchar(50) primary key,
Customer_Name varchar(50), 
Segment varchar(50)

);
INSERT INTO S_Customer(Customer_ID,Customer_Name,Segment)
select distinct
Customer_ID,
Customer_Name,
Segment
from Central_Superstore
Where Customer_ID is not null;


create table S_Product(
Product_ID varchar(50) primary key,
Product_Name varchar(255),
Category varchar(50),
Sub_Category varchar(50)
);
INSERT INTO S_Product(Product_ID,Product_Name,Category,Sub_Category)
select
Product_ID,max(Product_Name),max(Category),max([Sub_Category])
from Central_Superstore
Where Product_ID is not null
group by Product_ID;



create table S_Location(
Postal_Code varchar(100) primary key,
City varchar(100),
State varchar(100),
Country varchar(50),
Region varchar(50)
);
INSERT INTO S_Location(Postal_Code,City,State,Country,Region)
Select 
CAST(Postal_Code as varchar(20)),max(City),max(State),max(Country),max(Region)
from Central_Superstore
Where Postal_Code is not null
group by Postal_Code;

create table S_ShipMode(
Ship_Mode_ID int identity(1,1) Primary key,
Ship_Mode varchar (50)
);
INSERT INTO S_ShipMode(Ship_Mode)
select Distinct Ship_Mode
from Central_Superstore
Where Ship_Mode is not null;
create table Fact_Orders(
Row_ID int primary key,
Order_ID varchar(50) not null,
Order_Date Date,
Ship_Date Date,
Customer_ID varchar(50),
Product_ID varchar(50),
Postal_Code varchar(100),
Ship_Mode_ID int,
Sales float,
Quantity int,
Discount float,
Profit float,
CONSTRAINT FK_Orders_Customer FOREIGN KEY (Customer_ID) REFERENCES S_Customer(Customer_ID),
    CONSTRAINT FK_Orders_Product FOREIGN KEY (Product_ID) REFERENCES S_Product(Product_ID),
    CONSTRAINT FK_Orders_Location FOREIGN KEY (Postal_Code) REFERENCES S_Location(Postal_Code),
    CONSTRAINT FK_Orders_ShipMode FOREIGN KEY (Ship_Mode_ID) REFERENCES S_ShipMode(Ship_Mode_ID)
);
INSERT INTO Fact_Orders (Row_ID, Order_ID, Order_Date, Ship_Date,  Customer_ID, Product_ID, Postal_Code, Ship_Mode_ID, Sales, Quantity, Discount, Profit)
SELECT 
    r.Row_ID,
    r.Order_ID,
    DATEADD(day, r.Order_Date, '1899-12-30'),
    DATEADD(day, r.Ship_Date, '1899-12-30'),
    r.Customer_ID,
    r.Product_ID,
    r.Postal_Code,
    sm.Ship_Mode_ID,
    r.Sales,
    r.Quantity,
    r.Discount,
    r.Profit
FROM Central_Superstore as r
INNER JOIN S_ShipMode as sm 
    ON r.Ship_Mode = sm.Ship_Mode;
select count(distinct Order_ID) as Total_Orders,
count(Row_ID) as Total_Items_Sold,
sum(Sales) as Total_sales,
sum (Profit) as Total_Profit
from Fact_Orders;

select 
sum(f.Sales) as Total_sales,
sum (f.Profit) as Total_Profit,
sum(f.Quantity) as Total_quantity
from Fact_Orders as f
inner join S_Product as p 
on p.Product_ID= f.Product_ID
group by Category
order by Total_Profit desc;
select top 5
    c.Customer_Name,
    c.Segment,
    sum(f.Sales) as Total_Spent
from Fact_Orders f
JOIN S_Customer c on f.Customer_ID = c.Customer_ID
group by c.Customer_Name, c.Segment
order by Total_Spent desc;
select 
    l.State,
    sum(f.Sales) as Total_Sales,
   sum(f.Profit) as Total_Profit
from Fact_Orders as f
INNER JOIN S_Location as l 
    ON f.Postal_Code = l.Postal_Code
group by l.State
order by Total_Profit desc;

select 
    l.State,
    sum(f.Sales) as Total_Sales,
   sum(f.Profit) as Total_Profit
from Fact_Orders as f
INNER JOIN S_Location as l 
    ON f.Postal_Code = l.Postal_Code
group by l.State
order by Total_Profit asc;
select 
    sm.Ship_Mode,
    count(f.Order_ID) as Total_Orders,
    sum(f.Sales) as Total_Sales,
    sum(f.Profit) as Total_Profit
from Fact_Orders as f
inner join S_ShipMode as sm 
    on f.Ship_Mode_ID = sm.Ship_Mode_ID
group by sm.Ship_Mode
order by Total_Sales desc;

select
    l.State,
    sum(f.Sales) as Total_Sales,
    sum(f.Profit) as Total_Profit,
    avg(f.Discount) * 100 as Avg_Discount_Percentage
from Fact_Orders as f
INNER JOIN S_Location as l 
    on f.Postal_Code = l.Postal_Code
group by l.State
order by Total_Profit asc;
select
    p.Sub_Category,
    sum(f.Sales) as Total_Sales,
    sum(f.Profit) as Total_Profit,
    avg(f.Discount) * 100 as Avg_Discount_Percentage
from Fact_Orders as f
INNER JOIN S_Product as p 
    on f.Product_ID = p.Product_ID
group by p.Sub_Category
order by Total_Profit asc;
select 
    year(f.Order_Date) as Order_Year,
    count(DISTINCT f.Order_ID) as Total_Orders,
    sum(f.Sales)as Total_Sales,
    sum(f.Profit) as Total_Profit
from Fact_Orders as f
group by YEAR(f.Order_Date)
order by Order_Year asc;
create view View_State_Performance as
select 
    l.State,
    sum(f.Sales) as Total_Sales,
    sum(f.Profit) as Total_Profit,
    avg(f.Discount) * 100 as Avg_Discount_Percentage
from Fact_Orders as f
INNER JOIN S_Location as l 
    on f.Postal_Code = l.Postal_Code
group by l.State;
select * from View_State_Performance order by Total_Profit desc;


create procedure sp_Get_State___Report
    @StateName varchar(50)
as
begin
    select 
        l.State,
        count(DISTINCT f.Order_ID) as Total_Orders,
        sum(f.Sales) as Total_Sales,
        sum(f.Profit) as Total_Profit,
        avg(f.Discount) * 100 as Avg_Discount_Percentage
    from Fact_Orders as f
    INNER JOIN S_Location AS l 
        ON f.Postal_Code = l.Postal_Code
    WHERE l.State = @StateName
    GROUP BY l.State;
END;
EXEC sp_Get_State___Report @StateName = 'Michigan';


WITH Customer_Sales_CTE AS (
    SELECT 
        Customer_ID,
        SUM(Sales) AS Total_Spent
    FROM Fact_Orders
    GROUP BY Customer_ID
)
SELECT TOP 5 * 
FROM Customer_Sales_CTE
ORDER BY Total_Spent DESC;


WITH Profit_Status_CTE AS (
    SELECT 
        Order_ID,
        Profit,
        CASE 
            WHEN Profit > 0 THEN 'Profitable'
            ELSE 'Loss'
        END AS Status
    FROM Fact_Orders
)
SELECT 
    Status,
    COUNT(Order_ID) AS Total_Orders
FROM Profit_Status_CTE
GROUP BY Status;



SELECT 
    Order_ID, 
    Sales 
FROM Fact_Orders
WHERE Sales > (SELECT AVG(Sales) FROM Fact_Orders);
