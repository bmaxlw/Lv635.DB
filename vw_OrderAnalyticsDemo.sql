USE Lv635_OnlineStore;

SELECT TOP 10 * FROM Orders;
SELECT TOP 10 * FROM OrderDetails;
SELECT TOP 10 * FROM Customers;
SELECT TOP 10 * FROM Products;

SELECT TOP 10 * FROM vw_ShowDetailedOrders;

drop view vw_ShowDetailedOrders;

CREATE VIEW vw_ShowDetailedOrders AS
SELECT 
	o.OrderID, od.OrderDetailsID,
	o.CustomerID, p.ProdName, 
	o.ShippingAddress, o.OrderDate, o.ShippingDate
FROM 
	Orders o
JOIN
	OrderDetails od ON
	o.OrderID = od.OrderID
JOIN
	Products p ON 
	od.ProdID = p.ProdID
JOIN 
	Customers c ON
	o.CustomerID = c.CustomersID;


-- CustomerTotal
SELECT o.CustomerID, 
SUM(od.TotalPrice) CustomerTotal
FROM OrderDetails od 
JOIN Orders o
ON od.OrderID = o.OrderID
GROUP BY o.CustomerID ORDER BY o.CustomerID;

SELECT od.OrderID, p.CostUnit * od.Quantity FROM Products p JOIN OrderDetails od ON p.ProdID = od.ProdID;



SELECT SUM(od.TotalPrice) FROM OrderDetails od JOIN Orders o ON od.OrderID = o.OrderID WHERE o.CustomerID = 1;
SELECT * FROM Orders WHERE CustomerID = 351;

SELECT TOP 10 * FROM Orders;
SELECT * FROM OrderDetails WHERE OrderID = 818;
SELECT * FROM Products WHERE ProdID = 559;
select (217609.70 * 20)
3956540.00
-- Totals

DECLARE @vw_Launcher NVARCHAR(MAX) = 'EXEC ';
