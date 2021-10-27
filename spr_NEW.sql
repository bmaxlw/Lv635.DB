SELECT * FROM vw_Customer_Analysis;
SELECT * FROM Products;
SELECT * FROM Products WHERE ProdID = 530
SELECT TOP 10 * FROM Orders ORDER BY OrderID DESC;
SELECT * FROM Orders WHERE OrderID = 1201;
SELECT * FROM OrderDetails WHERE OrderID = 774;
SELECT TOP 10 * FROM OrderDetails Order BY OrderDetailsID DESC;
SELECT * FROM OrderDetails WHERE OrderID = 2;
SELECT * FROM Customers;


-- =================================================================================================
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


-- Maintanence
EXEC spr_ShowProfits '2021-10-25', '2021-10-25';
DROP PROCEDURE stp_ShowProfits;
EXEC spr_GenerateNewOrder;
