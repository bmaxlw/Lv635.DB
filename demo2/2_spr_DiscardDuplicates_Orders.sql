-- =================================================================================================
-- Author:			Maksym Bondaruk
-- Creation date:	14.11.2021
-- Description:		Second part of [spr_CleanStgOrders]. Discards duplicates from the raw data.
-- =================================================================================================

CREATE PROCEDURE spr_DiscardDuplicates_Orders
AS
BEGIN TRY
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
    SELECT '[spr_DiscardDuplicates_Orders]: Duplicated values assigned for PKEYs',
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
      FROM stg.FactOrders
     WHERE OrderID IN (   SELECT OrderID
                            FROM stg.FactOrders
                           GROUP BY OrderID
                          HAVING COUNT(OrderID) > 1 );

    DELETE FROM stg.FactOrders
     WHERE OrderID IN (   SELECT OrderID
                            FROM stg.FactOrders
                           GROUP BY OrderID
                          HAVING COUNT(OrderID) > 1 );

END TRY
BEGIN CATCH
    INSERT INTO [stg].ErrorOrders (ErrorDescription)
    VALUES (ERROR_MESSAGE())
END CATCH