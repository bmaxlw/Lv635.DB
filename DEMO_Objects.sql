-- =================================================================================================
-- Object:          trg_NewOrderToOrderDetails_INS 
-- Author:			Maksym Bondaruk
-- Creation date:	14.10.2021
-- Description:		When new order is added into Orders, 
--					the trigger is fired to insert ...
--					1) ... the OrderID, taken from Orders' inserted.
--					2) ... the ProductID, chosen randomly on the basis of the MAX(ProdID).
--					3) ... the Qt, chosen randomly ...
--					... into OrderDetails
-- =================================================================================================

CREATE TRIGGER 
	trg_NewOrderToOrderDetails_INS 
	ON Orders AFTER INSERT AS
BEGIN TRY
	BEGIN
		DECLARE @NewOrderID INT 
			= (SELECT OrderID FROM inserted); 
		DECLARE @NewProdID INT 
			= (FLOOR(RAND() * (SELECT MAX(ProdID) FROM Products)));
		DECLARE @NewQt INT 
			= (FLOOR(RAND() * 10) + 1);
		EXEC spr_NewOrderDetails @NewOrderID, @NewProdID, @NewQt;
	END;
END TRY
BEGIN CATCH
	BEGIN
		PRINT('FATAL ERROR!')
	END;
END CATCH;

-- =================================================================================================
-- Object:          spr_NewOrderDetails
-- Author:			Maksym Bondaruk
-- Creation date:	13.10.2021
-- Description:		When new order is added into Orders, trigger is evoked to run the procedure
--					and fill in the new order details. 
--					Procedure calculates the ... 
--						1) ... total order price (on the basis of the Qt and PriceUnit).
--						2) ... decrementation of the goods in the warehouse 
--							(after the new order details were added).
--						3) ... the inconsistency of data in case when 
--							QtInStock < Qt in OrderDetails (the warning is evoked
--							and the procedure is stopped).
--						4) ... VAT value on the basis of the TotalPrice of the order.
-- =================================================================================================

CREATE PROCEDURE spr_NewOrderDetails 
				@OrderID INT,  
				@ProdID INT, 
				@Qt INT
AS
BEGIN TRY
	IF (SELECT QtInStock FROM Products WHERE ProdID = @ProdID) > @Qt
		BEGIN
-- Insert new order details:
			INSERT INTO OrderDetails(OrderID, ProdID, Quantity, VAT, TotalPrice)
				VALUES 
					(@OrderID, @ProdID, @Qt,
					((SELECT PriceUnit FROM Products
				WHERE ProdID = @ProdID) * 0.2) * @Qt, 
					(SELECT PriceUnit FROM Products
				WHERE ProdID = @ProdID) * @Qt);
-- Update quantity in stock in Products:
			UPDATE Products SET QtInStock = QtInStock - @Qt 
				WHERE ProdID = @ProdID;
		END
-- If QtInStock < Qt in OrderDetails - fire an error message: 
	ELSE
		BEGIN
			PRINT 'ERROR! Not enough products available in stock!';
		END
END TRY
BEGIN CATCH
	BEGIN
		PRINT 'FATAL ERROR!'
	END
END CATCH;

-- =================================================================================================
-- Object:          trg_DiscountAssignation_INS
-- Author:			Maksym Bondaruk
-- Creation date:	13.10.2021
-- Description:		When new order details are added, trigger fires and fills in the correct
--					DiscountID from Discounts due to the TotalPrice of the Order.
--					Discounts, taken from Discounts table, are divided into 6 groups 
--					each of which is based on the definite price range.
-- =================================================================================================

CREATE TRIGGER trg_DiscountAssignation_INS ON 
OrderDetails AFTER INSERT AS
BEGIN TRY
-- 1st DiscountID
	IF (SELECT TotalPrice + VAT FROM inserted) < 
		(SELECT UpperLimit FROM Discounts WHERE DiscountID = 1)
		BEGIN
			UPDATE OrderDetails SET DiscountID = 1 
		WHERE OrderDetailsID = (SELECT OrderDetailsID FROM inserted);
		END
-- 2nd DiscountID
	ELSE IF (SELECT TotalPrice + VAT FROM inserted) > 
		(SELECT LowerLimit FROM Discounts WHERE DiscountID = 2)
		AND (SELECT TotalPrice + VAT FROM inserted) <
		(SELECT UpperLimit FROM Discounts WHERE DiscountID = 2)
		BEGIN
			UPDATE OrderDetails SET DiscountID = 2 
		WHERE OrderDetailsID = (SELECT OrderDetailsID FROM inserted);
		END
-- 3rd DiscountID
	ELSE IF (SELECT TotalPrice + VAT FROM inserted) > 
		(SELECT LowerLimit FROM Discounts WHERE DiscountID = 3)
		AND (SELECT TotalPrice + VAT FROM inserted) <
		(SELECT UpperLimit FROM Discounts WHERE DiscountID = 3)
		BEGIN
			UPDATE OrderDetails SET DiscountID = 3 
		WHERE OrderDetailsID = (SELECT OrderDetailsID FROM inserted);
		END
-- 4th DiscountID
	ELSE IF (SELECT TotalPrice + VAT FROM inserted) > 
		(SELECT LowerLimit FROM Discounts WHERE DiscountID = 4)
		AND (SELECT TotalPrice + VAT FROM inserted) <
		(SELECT UpperLimit FROM Discounts WHERE DiscountID = 4)
		BEGIN
			UPDATE OrderDetails SET DiscountID = 4 
		WHERE OrderDetailsID = (SELECT OrderDetailsID FROM inserted);
		END
-- 5th DiscountID
	ELSE IF (SELECT TotalPrice + VAT FROM inserted) > 
		(SELECT LowerLimit FROM Discounts WHERE DiscountID = 5)
		AND (SELECT TotalPrice + VAT FROM inserted) <
		(SELECT UpperLimit FROM Discounts WHERE DiscountID = 5)
		BEGIN
			UPDATE OrderDetails SET DiscountID = 5 
		WHERE OrderDetailsID = (SELECT OrderDetailsID FROM inserted);
		END
-- 6th DiscountID
	ELSE
		BEGIN
			UPDATE OrderDetails SET DiscountID = 6 
		WHERE OrderDetailsID = (SELECT OrderDetailsID FROM inserted);
		END
END TRY
BEGIN CATCH
	BEGIN
		PRINT 'FATAL ERROR!'
	END
END CATCH;

-- =================================================================================================
-- Object:          spr_ShowProfits
-- Author:			Maksym Bondaruk
-- Creation date:	26.10.2021
-- Description:		Procedure presents the net profits per order per predefined date range, including
--                  the total net income for the selected dates.
-- =================================================================================================
CREATE PROCEDURE spr_ShowProfits
    @From DATE,
    @To DATE
AS
SELECT od.OrderID,
       od.ProdID,
	   od.Quantity,
       (p.CostUnit * od.Quantity) OrderPurchasePrice,
       od.TotalPrice,
       od.TotalPrice - (p.CostUnit * od.Quantity) OrderNetProfit,
       SUM(od.TotalPrice - (p.CostUnit * od.Quantity)) OVER (PARTITION BY @From) TotalNetProfit
FROM Products p
    JOIN OrderDetails od
        ON p.ProdID = od.ProdID
    JOIN Orders o
        ON od.OrderID = o.OrderID
WHERE o.OrderDate
BETWEEN @From AND @To;

-- =================================================================================================
-- Object:          fn_QtChecker
-- Author:			Maksym Bondaruk
-- Creation date:	18.10.2021
-- Description:		The current inline table-valued FUNCTION returns the values of the QtInStock, 
--					predefined by the upper and lower limits, stated in the FUNCTION parameters.
--					With the QtInStock results, the contacts of the product's supplier and
--					the warehouse managers, in whose warehouses the products are stored, are returned.
-- =================================================================================================
CREATE FUNCTION fn_QtChecker (@lower_limit INT, @upper_limit INT)
	RETURNS TABLE AS RETURN
		SELECT p.ProdID, p.ProdName, p.QtInStock 'InStock', p.CostUnit,
			   s.SupplierName, s.SupplierPhone, s.SupplierEmail, 
			   w.WarehouseManager 'WhMgr', 
			   e.EmpPhone 'WhMgrPhone', e.EmpEmail 'WhMgrEmail'
		FROM Products p 
			JOIN Suppliers s ON p.Supplier = s.SupplierID
			JOIN Warehouses w ON p.Warehouse = w.WarehouseID
			JOIN Employees e ON w.WarehouseManager = e.EmpID
		WHERE
			(QtInStock <= @upper_limit OR @upper_limit IS NULL) AND
			(QtInStock >= @lower_limit OR @lower_limit IS NULL);

-- =================================================================================================
-- Object:          vw_Orders_Counter
-- Author:			Maksym Bondaruk
-- Creation date:	15.10.2021
-- Description:		VIEW represents the number of orders made by the definite customer 
--					as well as the number of money spent per capita
-- =================================================================================================

CREATE VIEW vw_Orders_Counter AS
	SELECT 
		c.CustomersID,
		COUNT(o.OrderID) NumberOfOrders, 
		SUM(od.TotalPrice) + SUM(od.VAT) SpentPerCapita
	FROM Customers c 
		JOIN Orders o ON c.CustomersID = o.CustomerID 
		JOIN OrderDetails od ON o.OrderID = od.OrderID
	GROUP BY c.CustomersID;

-- =================================================================================================
-- Object:          vw_CustomerRegDate_Counter
-- Author:			Maksym Bondaruk
-- Creation date:	15.10.2021
-- Description:		VIEW represents the number of days, the customer is registered in our database
-- =================================================================================================

CREATE VIEW vw_CustomerRegDate_Counter AS
	SELECT CustomersID, CustomerRegDate, 
	DATEDIFF(day, CustomerRegDate, GETDATE()) DaysAsCustomer,
	DATEDIFF(month, CustomerRegDate, GETDATE()) MonthsAsCustomer,
	DATEDIFF(year, CustomerRegDate, GETDATE()) YearsAsCustomer
	FROM Customers;

-- =================================================================================================
-- Object:          vw_Customer_Analysis
-- Author:			Maksym Bondaruk
-- Creation date:	15.10.2021
-- Description:		VIEW represents brief overview on the customers' activity in the online shop. 
--					- Columns Days/Months/Years represent the number of days/months/years after RegDate
--					- Columns OrdersPerMonth/OrdersPerYear show the avg of orders per a certain period of time
--					- Columns SpentPerMonth/SpentPerYear show the number of money spent by a definite customer 
--						per a certain period of time
--					- TotalSpent shows how much money has the definite customer spent since the RegDate
-- =================================================================================================
CREATE VIEW vw_Customer_Analysis AS
SELECT 
	vwa.CustomersID CustomerID, 
	CONCAT(c.CustomerFirstName, ' ', c.CustomerLastName) CustomerName,
	c.CustomerEmail Email,
	vwb.CustomerRegDate RegDate,
	vwb.DaysAsCustomer [Days],
	vwb.MonthsAsCustomer [Months],
	vwb.YearsAsCustomer [Years],
	vwa.NumberOfOrders Orders,
	vwa.NumberOfOrders / NULLIF(vwb.MonthsAsCustomer, 0) OrdersPerMonth,
	vwa.NumberOfOrders / NULLIF(vwb.YearsAsCustomer, 0) OrdersPerYear,
	ROUND((vwa.SpentPerCapita / NULLIF(MonthsAsCustomer, 0)), 2) SpentPerMonth,
	ROUND((vwa.SpentPerCapita / NULLIF(YearsAsCustomer, 0)), 2) SpentPerYear,
	vwa.SpentPerCapita TotalSpent
FROM vw_Orders_Counter vwa 
	JOIN vw_CustomerRegDate_Counter vwb ON vwa.CustomersID = vwb.CustomersID
	JOIN Customers c ON vwa.CustomersID = c.CustomersID;