--                        CASE STUDY (RETAIL DATA ANALYSIS)
Create Database Retail_Data;
use Retail_Data

--                DATA PREPARATION AND UNDERSTANDING.
--Q1 What is the total number of rows in each of the 3 tables in the database?
select count(*) from [dbo].[Customer]
-- 5647 rows
select count(*) from [dbo].[prod_cat_info]
-- 23 rows
select count(*) from [dbo].[Transactions]
-- 23053 rows
--Q2 What is the total number of transactions that have a return?
select count(total_amt) from [dbo].[Transactions]
where Qty < 0
-- 2177 rows
-- Q3
select CONVERT(DATE,DOB,105) AS DATES FROM [dbo].[Customer]
select CONVERT(DATE,TRAN_DATE,105) AS TRANS_DATE FROM [dbo].[Transactions]
--Q4 

select DATEDIFF(DAY, MIN(CONVERT(DATE, TRAN_DATE,105)), MAX(CONVERT(DATE, TRAN_DATE,105))) AS DAYS,
DATEDIFF(MONTH, MIN(CONVERT(DATE, TRAN_DATE,105)), MAX(CONVERT(DATE, TRAN_DATE,105))) AS MONTHS,
DATEDIFF(YEAR, MIN(CONVERT(DATE, TRAN_DATE,105)), MAX(CONVERT(DATE, TRAN_DATE,105))) AS YEARS
FROM [dbo].[Transactions]



--Q5 Which product category does the sub-category "DIY" belong to?
SELECT prod_cat from [dbo].[prod_cat_info]
where prod_subcat = 'DIY'



--                   DATA ANALYSIS
--Q1 Which channel is most frequently used for transactions?

select TOP 1
STORE_TYPE, COUNT(TRANSACTION_ID) AS COUNT__ FROM [dbo].[Transactions]
GROUP BY STORE_TYPE
ORDER BY COUNT(TRANSACTION_ID) DESC

--Q2 What is the count of Male and Female customers in the database?

select GENDER, COUNT(CUSTOMER_ID) AS COUNT_G FROM [dbo].[Customer]
GROUP BY GENDER
HAVING GENDER= 'M'OR GENDER= 'F'

--Q3 From which city do we have the maximum number of customers and how many?

select TOP 1 CITY_CODE, COUNT(CUSTOMER_ID) AS CUST_CNT FROM[dbo].[Customer]
GROUP BY CITY_CODE
ORDER BY CUST_CNT DESC

--Q4 How many sub-categories are there under the Books category?
Select prod_cat,
COUNT(prod_subcat) as Prod_subcat
FROM [dbo].[prod_cat_info]
WHERE prod_cat = 'Books'
GROUP BY prod_cat


--Q5 What is the maximum quantity of the products ever ordered?

select Top 1 QTY AS Max_qty
FROM [dbo].[Transactions]
ORDER BY QTY DESC

--Q6 What is the net total revenue generated in categories Electronics and Books?


select SUM(CONVERT(NUMERIC,total_amt)) as AMOUNT
FROM [dbo].[Transactions] t
INNER JOIN [dbo].[prod_cat_info] p on t.prod_cat_code= p.prod_cat_code
AND t.prod_subcat_code= p.prod_sub_cat_code
WHERE p.prod_cat in ('Electronics','Books')

--Q7 How many customers have >10 tansactions with us, excluding return?

select COUNT (cust_id) as trans_count
FROM( select cust_id, count(transaction_id) as trans
FROM [dbo].[Transactions] 
WHERE qty>0
GROUP BY cust_id) a
WHERE trans>10
 --Q8  
 select SUM(CONVERT(NUMERIC ,total_amt)) as AMOUNT FROM [dbo].[Transactions] t
 INNER JOIN [dbo].[prod_cat_info] p ON t.prod_cat_code= p.prod_cat_code
 AND t.prod_subcat_code= p.prod_sub_cat_code
 where prod_cat in ('Clothing', 'Electronics') AND Store_type = 'Flagship Store'


 --Q9
 select PROD_SUBCAT, SUM(CONVERT(NUMERIC, total_amt)) REVENUE
 FROM [dbo].[Transactions] t
 LEFT JOIN [dbo].[Customer] c ON t.cust_id= c.customer_Id
 LEFT JOIN [dbo].[prod_cat_info] P ON t.prod_subcat_code= p.prod_sub_cat_code AND t.prod_cat_code= p.prod_cat_code
 WHERE prod_cat = 'Electronics' AND GENDER = 'M'
 GROUP BY prod_subcat

 --Q10
 SELECT TOP 5
 prod_subcat, (sum(convert(numeric,total_amt))/(select sum(convert(numeric,total_amt)) from[dbo].[Transactions]))*100 as PERCENTAGE_OF_SALES,
 (count(case when qty <0 then qty else null end)/ sum(convert(numeric,qty)))*100 AS PERCENTAGE_OF_RETURN
 FROM [dbo].[Transactions] t
 inner join [dbo].[prod_cat_info] p on t.prod_cat_code= p.prod_cat_code and t.prod_subcat_code= p.prod_sub_cat_code
 group by prod_subcat
 order by sum(convert(numeric,total_amt))desc

 --Q11
 SELECT CUST_ID,SUM(CONVERT(NUMERIC,TOTAL_AMT)) AS REVENUE FROM [dbo].[Transactions]
 WHERE CUST_ID IN
 (SELECT CUSTOMER_ID FROM [dbo].[Customer]
   WHERE DATEDIFF(YEAR,CONVERT(DATE,DOB,103),GETDATE()) BETWEEN 25 AND 35)
   AND CONVERT(DATE,TRAN_DATE,103) BETWEEN DATEADD(DAY,-30,(SELECT MAX(CONVERT(DATE,TRAN_DATE,103)) FROM [dbo].[Transactions]))
   AND (SELECT MAX (CONVERT(DATE,TRAN_DATE,103)) FROM [dbo].[Transactions])
   GROUP BY CUST_ID


 --Q12
 select TOP 1 prod_cat, SUM(CONVERT(NUMERIC,TOTAL_AMT)) revenue_return from [dbo].[Transactions]t
 INNER JOIN [dbo].[prod_cat_info]p on t.prod_cat_code= p.prod_cat_code AND t.prod_subcat_code= p.prod_sub_cat_code
 WHERE convert(NUMERIC,total_amt) < 0 AND
 CONVERT(DATE, TRAN_DATE,103) BETWEEN DATEADD(MONTH,-3,(SELECT MAX(CONVERT(DATE,TRAN_DATE,103)) FROM [dbo].[Transactions]))
         AND (SELECT MAX (CONVERT(DATE,TRAN_DATE,103)) FROM [dbo].[Transactions]) 
		 GROUP BY prod_cat

--Q13
SELECT STORE_TYPE,SUM(CONVERT(NUMERIC,TOTAL_AMT)) AS TOTAL_SALES, SUM(CONVERT(NUMERIC,QTY)) AS TOTAL_QUANTITY FROM[dbo].[Transactions]
GROUP BY Store_type
HAVING SUM(CONVERT(NUMERIC,TOTAL_AMT)) >= ALL (SELECT SUM(CONVERT(NUMERIC,TOTAL_AMT)) FROM [dbo].[Transactions] GROUP BY Store_type)
AND SUM(CONVERT(NUMERIC,QTY))>= ALL (SELECT SUM(CONVERT(NUMERIC,QTY)) FROM [dbo].[Transactions] GROUP BY Store_type)

--Q14
SELECT prod_cat, AVG(CONVERT(NUMERIC,TOTAL_AMT))AS AVERAGE FROM [dbo].[Transactions]t
INNER JOIN [dbo].[prod_cat_info]p on t.prod_cat_code = p.prod_cat_code AND p.prod_sub_cat_code = t.prod_subcat_code
group by prod_cat
having AVG(CONVERT(NUMERIC,TOTAL_AMT)) > (SELECT AVG(CONVERT(NUMERIC,TOTAL_AMT))FROM [dbo].[Transactions])

--Q15

SELECT PROD_CAT,PROD_SUBCAT, AVG(CONVERT(NUMERIC,TOTAL_AMT))AS AVERAGE_REVENUE, SUM(CONVERT(NUMERIC,TOTAL_AMT)) AS TOTAL_REVENUE
FROM[dbo].[Transactions]t
INNER JOIN[dbo].[prod_cat_info]p  on t.prod_cat_code= p.prod_cat_code AND t.prod_subcat_code= p.prod_sub_cat_code
where prod_cat in

(
SELECT TOP 5 prod_cat FROM [dbo].[Transactions]t
INNER JOIN [dbo].[prod_cat_info]p  ON t.prod_cat_code=p.prod_cat_code AND t.prod_subcat_code= p.prod_sub_cat_code
group by prod_cat
ORDER BY SUM(CONVERT(NUMERIC,TOTAL_AMT)) DESC
)
group by prod_cat, prod_subcat
