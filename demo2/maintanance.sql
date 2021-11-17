USE Lv635_Staging;


SELECT COUNT(*) FROM stg.FactOrders;
SELECT * FROM dbo.FactOrders;
SELECT * FROM stg.ErrorOrders;

EXEC sp_help FactOrders;

TRUNCATE TABLE stg.FactOrders;
TRUNCATE TABLE dbo.FactOrders;
TRUNCATE TABLE stg.ErrorOrders;

INSERT INTO stg.FactOrders VALUES('1', '1', '2021-01-01', '2021-01-01', '1', '1', '1', '1.00', '1.00', 'Street', '1', '1', 'Cash', '2021-01-01', '2021-01-01', '1');
INSERT INTO stg.FactOrders VALUES('1', '1', '2021-01-01', '2021-01-01', '1', '1', '1', '1.00', '1.00', 'Street', '1', '1', 'Cash', '2021-01-01', '2021-01-01', '1');
INSERT INTO stg.FactOrders VALUES('1', '2', '2021-01-01', '2021-01-01', '1', '1', '1', '1.00', '1.00', 'Street', '1', '1', 'Cash', '2021-01-01', '2021-01-01', '1');
INSERT INTO stg.FactOrders VALUES('1', '3', '2021-01-01', '2021-01-01', '1', '1', '1', '1.00', '1.00', 'Street', '1', '1', 'Cash', '2021-01-01', '2021-01-01', '1');
INSERT INTO stg.FactOrders VALUES('2', '1', '2021-01-01', '2021-01-01', '1', '1', '1', '1.00', '1.00', 'Street', '1', '1', 'Cash', '2021-01-01', '2021-01-01', '1');
INSERT INTO stg.FactOrders VALUES('2', '2', '2021-01-01', '2021-01-01', '1', '1', '1', '1.00', '1.00', 'Street', '1', '1', 'Cash', '2021-01-01', '2021-01-01', '1');
INSERT INTO stg.FactOrders VALUES('2', '2', '2021-01-01', '2021-01-01', '1', '1', '1', '1.00', '1.00', 'Street', '1', '1', 'Cash', '2021-01-01', '2021-01-01', '1');
INSERT INTO stg.FactOrders VALUES('2', '3', '2021-01-01', '2021-01-01', '1', '1', '1', '1.00', '1.00', 'Street', '1', '1', 'Cash', '2021-01-01', '2021-01-01', '1');
INSERT INTO stg.FactOrders VALUES('2', '3', '2021-01-01', '2021-01-01', '1', '1', '1', '1.00', '1.00', 'Street', '1', '1', 'Cash', '2021-01-01', '2021-01-01', '1');

INSERT INTO stg.FactOrders VALUES('2', '1', '2021-01-01', '2021-01-01', '1', '1', '1', '1.00', '1.00', 'Street', '1', '1', 'Cash', '2021-01-01', '2021-01-01', '1');
INSERT INTO stg.FactOrders VALUES('1', '1', '2021-01-01', '2021-01-01', '1', '1', '1', '1.00', '1.00', 'Street', '1', '1', 'Cash', '2021-01-01', '2021-01-01', '1');
INSERT INTO stg.FactOrders VALUES('xx', '1', '2021-01-01', '2021-01-01', '1', '1', '1', '1.00', '1.00', 'Street', '1', '1', 'Cash', '2021-01-01', '2021-01-01', '1');
INSERT INTO stg.FactOrders VALUES('3', '1', '2013-01-01', '2021-01-01', '1', '1', '1', '1.00', '1.00', 'Street', '1', '1', 'Cash', '2021-01-01', '2021-01-01', '1');
INSERT INTO stg.FactOrders VALUES('4', '1', '2021-01-01', '2021-01-01', '1', '1', '1', '1.00', '1.00', 'Street', '1', '2147483648', 'Cash', '2021-01-01', '2021-01-01', '1');

DROP PROC spr_DiscardConversionIssues_Orders; --> FIRST
DROP PROC spr_DiscardDuplicates_Orders; --> SECOND
DROP PROC spr_DiscardIncorrectValues_Orders; --> THIRD
DROP PROC spr_Conversion_Orders; --> FOURTH;
DROP PROC spr_CleanStgOrders;


EXEC spr_OrdersCleaning

SELECT * FROM [Lv635_Staging].stg.FactOrders;
SELECT * FROM [Lv635_Staging].dbo.FactOrders;
SELECT * FROM [Lv635_Staging].stg.ErrorOrders;

SELECT TOP 10 * FROM [Lv635_DataWarehouse].dbo.FactOrders;
SELECT * FROM Lv635_OnlineStore.dbo.LogTable

TRUNCATE TABLE [Lv635_Staging].dbo.FactOrders;
TRUNCATE TABLE [Lv635_Staging].stg.FactOrders;
TRUNCATE TABLE [Lv635_DataWarehouse].dbo.FactOrders;
TRUNCATE TABLE [Lv635_Staging].stg.ErrorOrders;


BEGIN
CREATE TABLE ##Composite(
Identificator INT IDENTITY(1, 1),
CompositeKey INT,
OrderID INT NOT NULL,
OrderDetailsID INT NOT NULL,
OrderDate DATE,
ShippingDate DATE,
CustomerID INT,
ProdID INT,
Quantity INT,
VAT NUMERIC(19, 2),
TotalPrice NUMERIC(19, 2),
ShippingAddress NVARCHAR(70),
ShippingID INT,
DiscountID INT,
PaymentMethod NVARCHAR(70),
WarrantyStartDate DATE,
WarrantyExpDate DATE,
AssignedTo INT);

INSERT INTO ##Composite(
									   CompositeKey,
                                       OrderID,
                                       OrderDetailsID,
                                       OrderDate,
                                       ShippingDate,
                                       CustomerID,
                                       ProdID,
                                       Quantity,
                                       VAT,
                                       TotalPrice,
                                       ShippingAddress,
                                       ShippingID,
                                       DiscountID,
                                       PaymentMethod,
                                       WarrantyStartDate,
                                       WarrantyExpDate,
                                       AssignedTo)
        SELECT 
			   CAST(CONCAT(OrderID, OrderDetailsID) AS INT),
               CAST(OrderID AS INT),
               CAST(OrderDetailsID AS INT),
               CAST(OrderDate AS DATE),
               CAST(ShippingDate AS DATE),
               CAST(CustomerID AS INT),
               CAST(ProdID AS INT),
               CAST(Quantity AS INT),
               CAST(VAT AS NUMERIC(19,2)),
               CAST(TotalPrice AS NUMERIC(19,2)),
               CAST(ShippingAddress AS NVARCHAR(70)),
               CAST(ShippingID AS INT),
               CAST(DiscountID AS INT), 
               CAST(PaymentMethod AS NVARCHAR(50)),
               CAST(WarrantyStartDate AS DATE),
               CAST(WarrantyExpDate AS DATE),
               AssignedTo
          FROM stg.FactOrders
         WHERE OrderID IN (   SELECT OrderID
                                FROM stg.FactOrders
                               GROUP BY OrderID
                              HAVING COUNT(OrderID) > 1 );


WHILE ((SELECT MIN(Identificator) FROM ##Composite) IS NOT NULL)
BEGIN
DECLARE @Ckey INT = (SELECT MIN(CompositeKey) FROM ##Composite);
DECLARE @MinID INT = (SELECT MIN(Identificator) FROM ##Composite WHERE CompositeKey = @Ckey);
DECLARE @MaxID INT = (SELECT MAX(Identificator) FROM ##Composite WHERE CompositeKey = @Ckey);

INSERT INTO [dbo].FactOrders (OrderID,
                                      OrderDetailsID,
                                      OrderDate,
                                      ShippingDate,
                                      CustomerID,
                                      ProdID,
                                      Quantity,
                                      VAT,
                                      TotalPrice,
                                      ShippingAddress,
                                      ShippingID,
                                      DiscountID,
                                      PaymentMethod,
                                      WarrantyStartDate,
                                      WarrantyExpDate,
                                      AssignedTo)
SELECT OrderID, OrderDetailsID, OrderDate, ShippingDate, CustomerID, ProdID, Quantity,
                                      VAT,
                                      TotalPrice,
                                      ShippingAddress,
                                      ShippingID,
                                      DiscountID,
                                      PaymentMethod,
                                      WarrantyStartDate,
                                      WarrantyExpDate,
                                      AssignedTo FROM ##Composite 
WHERE CompositeKey = @Ckey AND Identificator = @MinID;

DELETE FROM ##Composite WHERE CompositeKey = @Ckey AND Identificator = @MinID;

INSERT INTO [stg].ErrorOrders (ErrorDescription,
                                       OrderID,
                                       OrderDetailsID,
                                       OrderDate,
                                       ShippingDate,
                                       CustomerID,
                                       ProdID,
                                       Quantity,
                                       VAT,
                                       TotalPrice,
                                       ShippingAddress,
                                       ShippingID,
                                       DiscountID,
                                       PaymentMethod,
                                       WarrantyStartDate,
                                       WarrantyExpDate,
                                       AssignedTo)
        SELECT 'Duplicated values assigned for PKEYs',
               OrderID,
               OrderDetailsID,
               OrderDate,
               ShippingDate,
               CustomerID,
               ProdID,
               Quantity,
               VAT,
               TotalPrice,
               ShippingAddress,
               ShippingID,
               DiscountID,
               PaymentMethod,
               WarrantyStartDate,
               WarrantyExpDate,
               AssignedTo 
		FROM ##Composite
		where CompositeKey = @Ckey;

DELETE FROM ##Composite WHERE CompositeKey = @Ckey;
		
		END
DROP TABLE ##Composite
END
