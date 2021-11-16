-- =================================================================================================
-- Author:			Maksym Bondaruk
-- Creation date:	14.11.2021
-- Description:		Third part of [spr_CleanStgOrders]. Discards incorrect values from the raw data.
-- =================================================================================================

CREATE PROCEDURE spr_DiscardIncorrectValues_Orders
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
    SELECT '[spr_DiscardIncorrectValuesByLimits_Orders]: Formatting limit(s) violated',
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
     WHERE OrderDate            < '2014-01-01'
        OR ShippingDate         < '2014-01-01'
        OR LEN(VAT)             > 19
        OR LEN(TotalPrice)      > 19
        OR LEN(ShippingAddress) > 140
        OR LEN(PaymentMethod)   > 100
        OR WarrantyStartDate    < '2014-01-01'
        OR WarrantyExpDate      < '2014-01-01';

    DELETE FROM stg.FactOrders
     WHERE OrderDate            < '2014-01-01'
        OR ShippingDate         < '2014-01-01'
        OR LEN(VAT)             > 19
        OR LEN(TotalPrice)      > 19
        OR LEN(ShippingAddress) > 140
        OR LEN(PaymentMethod)   > 100
        OR WarrantyStartDate    < '2014-01-01'
        OR WarrantyExpDate      < '2014-01-01';
END TRY
BEGIN CATCH
    INSERT INTO [stg].ErrorOrders (ErrorDescription)
    VALUES (ERROR_MESSAGE())
END CATCH