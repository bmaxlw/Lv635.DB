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
