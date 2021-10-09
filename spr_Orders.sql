USE Lv635_OnlineStore;
EXEC sp_help Orders;
SELECT COUNT(*) FROM Orders;
SELECT TOP 10 * FROM Orders;
SELECT TOP 25000 * FROM Orders;
SELECT * FROM Orders ORDER BY OrderID OFFSET 4999990 ROWS;
SELECT * FROM Customers;


DECLARE @var INT = 219808
WHILE @var <> 4999999
BEGIN
UPDATE Orders SET ShippingDate = DATEADD(Day, 4, 
(SELECT OrderDate FROM Orders WHERE OrderID = @var)) WHERE OrderID = @var;
SET @var = @var + 1
END

UPDATE Orders SET ShippingDate = DATEADD(Day, 4, 
(SELECT OrderDate FROM Orders WHERE OrderID = 5000000)) WHERE OrderID = 5000000;

-- stp_AddNewOrder
CREATE PROCEDURE stp_AddNewOrder @CustomerID INT, 
@ShippingAddress NVARCHAR(100), @ShippingID INT, @PaymentID INT AS
INSERT INTO Orders(AssignedTo, 
CustomerID, ShippingAddress, 
ShippingID, PaymentID, ShippingDate) 
VALUES((SELECT ABS(CHECKSUM(NEWID()) % 6) + 1),
@CustomerID,
@ShippingAddress, 
@ShippingID,
@PaymentID,
(DATEADD(DAY, 4, GETDATE())));

DROP PROCEDURE stp_AddNewOrder;

EXEC stp_AddNewOrder 26, 'Sureram591@hngat.net', 1, 1;

