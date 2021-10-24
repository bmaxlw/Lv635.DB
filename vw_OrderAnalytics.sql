USE Lv635_OnlineStore;
-- =================================================================================================
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