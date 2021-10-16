USE Lv635_OnlineStore;
SELECT * FROM vw_Customer_Analysis;
SELECT * FROM vw_CustomerRegDate_Counter;
SELECT * FROM vw_Orders_Counter;

CREATE PROCEDURE spr_EmailNotification 
AS
DECLARE @id INT = 1;
WHILE @id <> (SELECT MAX(CustomerID) FROM vw_Customer_Analysis)
DECLARE @day_checker NVARCHAR(MAX);
SET @day_checker = (SELECT Days FROM vw_Customer_Analysis WHERE CustomerID = @id)
IF @day_checker = 365
PRINT CONCAT('Customer with id ', @id, ' recieves 1-year greeting and a 1% coupon');
ELSE IF @day_checker = 365 * 2
PRINT CONCAT('Customer with id ', @id, ' recieves 2-year greeting and a 5% coupon');
ELSE IF @day_checker = 365 * 3
PRINT CONCAT('Customer with id ', @id, ' recieves 3-year greeting and a 7% coupon');
ELSE IF @day_checker = 365 * 4
PRINT CONCAT('Customer with id ', @id, ' recieves 4-year greeting and a 10% coupon');
ELSE IF @day_checker = 365 * 5
PRINT CONCAT('Customer with id ', @id, ' recieves 5-year greeting and a 12% coupon');
ELSE IF @day_checker = 365 * 10
PRINT CONCAT('Customer with id ', @id, ' recieves 10-year greeting and a 15% coupon');
SET @id = @id + 1

