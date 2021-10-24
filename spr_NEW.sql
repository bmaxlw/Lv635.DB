SELECT * FROM vw_Customer_Analysis;
SELECT * FROM Products;
SELECT * FROM Products WHERE ProdID = 237
SELECT TOP 10 * FROM Orders ORDER BY OrderID DESC;
SELECT * FROM Orders WHERE OrderID = 1201;
SELECT * FROM OrderDetails WHERE OrderID = 774;
SELECT TOP 10 * FROM OrderDetails Order BY OrderDetailsID DESC;
SELECT * FROM OrderDetails WHERE OrderID = 2;
SELECT * FROM Customers;

CREATE PROCEDURE stp_ShowProfits @From DATE, @To DATE AS
SELECT od.OrderID, od.ProdID, (p.CostUnit * od.Quantity) CostUnitPrice, od.TotalPrice,
od.TotalPrice - (p.CostUnit * od.Quantity) NetProfit, 
SUM(od.TotalPrice - (p.CostUnit * od.Quantity)) OVER(PARTITION BY @From) Totale
FROM Products p JOIN OrderDetails od ON p.ProdID = od.ProdID 
JOIN Orders o ON od.OrderID = o.OrderID
WHERE o.OrderDate BETWEEN @From AND @To;

SELECT * INTO ##Temp2 EXEC stp_ShowProfits '2021-10-24', '2021-10-24';

CREATE TABLE ##Temp2(Totale NUMERIC(19,2));
DROP TABLE ##Temp2

DROP PROCEDURE stp_ShowProfits;

CREATE FUNCTION fn_ReturnRange(@LowerLimit NUMERIC(19,2), @UpperLimit NUMERIC(19,2))
-- returns total from x-value to y-value