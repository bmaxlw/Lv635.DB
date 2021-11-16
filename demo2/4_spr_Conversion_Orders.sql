-- =================================================================================================
-- Author:			Maksym Bondaruk
-- Creation date:	14.11.2021
-- Description:		Fourth part of [spr_CleanStgOrders]. Maintains conversion.
-- =================================================================================================
CREATE PROCEDURE spr_Conversion_Orders
AS
BEGIN TRY
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
    SELECT CAST(OrderID AS INT),
           CAST(OrderDetailsID AS INT),
           CAST(OrderDate AS DATE),
           CAST(ShippingDate AS DATE),
           CAST(CustomerID AS INT),
           CAST(ProdID AS INT),
           CAST(Quantity AS INT),
           CAST(VAT AS NUMERIC(19, 2)),
           CAST(TotalPrice AS NUMERIC(19, 2)),
           CAST(ShippingAddress AS NVARCHAR(100)),
           CAST(ShippingID AS INT),
           CAST(DiscountID AS INT),
           CAST(PaymentMethod AS NVARCHAR(50)),
           CAST(WarrantyStartDate AS DATE),
           CAST(WarrantyExpDate AS DATE),
           CAST(AssignedTo AS INT)
      FROM stg.FactOrders;
    TRUNCATE TABLE stg.FactOrders;
END TRY
BEGIN CATCH
    INSERT INTO [stg].ErrorOrders (ErrorDescription)
    VALUES (ERROR_MESSAGE())
END CATCH;