USE Lv635_OnlineStore;

-- trg_NewOrderToOrderDetails_INS
EXEC spr_GenerateNewOrder
SELECT TOP 5 OrderID, OrderDate, CustomerID, ShippingAddress, ShippingDate 
FROM Orders ORDER BY OrderID DESC;
SELECT TOP 5 * FROM OrderDetails ORDER BY OrderDetailsID DESC;

-- spr_NewOrderDetails
SELECT TOP 5 * FROM Products ORDER BY QtInStock DESC;
EXEC spr_NewOrderDetails 4999985, 532, 2;   
SELECT TOP 5 * FROM OrderDetails ORDER BY OrderDetailsID DESC;
SELECT (227378.68 * 2)
SELECT (227378.68 * 2) * 0.2

EXEC spr_NewOrderDetails 4999985, 532, 999;   
SELECT TOP 5 * FROM OrderDetails ORDER BY OrderDetailsID DESC;

-- trg_DiscountAssignation_INS
SELECT * FROM Discounts;
SELECT TOP 5 * FROM OrderDetails ORDER BY OrderDetailsID DESC;

-- spr_ShowProfits
EXEC spr_ShowProfits '2021-10-25', '2021-10-26';
SELECT OrderID, OrderDate FROM Orders WHERE OrderDate IN ('2021-10-25', '2021-10-26');

-- fn_QtChecker
SELECT * FROM fn_QtChecker(0, 1);

-- vw_Orders_Counter + vw_CustomerRegDate_Counter + 
SELECT * FROM vw_Orders_Counter;
SELECT * FROM vw_CustomerRegDate_Counter;
SELECT * FROM vw_Customer_Analysis ORDER BY CustomerID ASC;
