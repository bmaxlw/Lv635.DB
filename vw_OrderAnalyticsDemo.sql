USE Lv635_OnlineStore;

SELECT TOP 10 * FROM OrderDetails;
SELECT SUM(od.TotalPrice) FROM OrderDetails od JOIN Orders o ON od.OrderID = o.OrderID WHERE o.CustomerID = 100;
SELECT TOP 10 * FROM Customers;
SELECT * FROM Products WHERE ProdID = 769;
SELECT * FROM Discounts;

-- CustomerTotal
SELECT 
	o.CustomerID, 
	COUNT(od.OrderID) OrdersTotal, --> The total number of orders, made by one customer
	SUM(od.TotalPrice + od.VAT) CustomerTotal --> The total of money, spent by the definite customer (VAT included)
FROM OrderDetails od
JOIN Orders o ON od.OrderID = o.OrderID 
WHERE o.CustomerID > 0 
GROUP BY o.CustomerID 
ORDER BY o.CustomerID;

-- Discount is applied to TotalPrice + VAT
-- Final Price, to be paid by customer, is actually TotalPrice + VAT + Discount
-- Thus the discount also directly affects the VAT and seller is intrested in setting discounts
-- EXAMPLE
-- Total Price:		1000 UAH
-- VAT:				 200 UAH (1000 * 0.2)
-- Discount (5%):	  60 UAH (1200 * 0.05)
-- To be paid:		1140 UAH