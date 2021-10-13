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