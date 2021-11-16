-- =================================================================================================
-- Author:			Maksym Bondaruk
-- Creation date:	14.11.2021
-- Description:		First part of [spr_CleanStgOrders]. Discards conversion issues from the raw data.
-- =================================================================================================

CREATE PROCEDURE spr_DiscardConversionIssues_Orders
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
    SELECT '[spr_DiscardConversionIssues_Orders]: Conversion failed',
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
     WHERE TRY_CAST(OrderID AS INT) IS NULL
        OR TRY_CAST(OrderDetailsID AS INT) IS NULL
        OR TRY_CAST(OrderDate AS DATE) IS NULL
        OR TRY_CAST(ShippingDate AS DATE) IS NULL
        OR TRY_CAST(CustomerID AS INT) IS NULL
        OR TRY_CAST(ProdID AS INT) IS NULL
        OR TRY_CAST(Quantity AS INT) IS NULL
        OR TRY_CAST(VAT AS NUMERIC(19, 2)) IS NULL
        OR TRY_CAST(TotalPrice AS NUMERIC(19, 2)) IS NULL
        OR TRY_CAST(ShippingAddress AS NVARCHAR(100)) IS NULL
        OR TRY_CAST(ShippingID AS INT) IS NULL
        OR TRY_CAST(DiscountID AS INT) IS NULL
        OR TRY_CAST(PaymentMethod AS NVARCHAR(50)) IS NULL
        OR TRY_CAST(WarrantyStartDate AS DATE) IS NULL
        OR TRY_CAST(WarrantyExpDate AS DATE) IS NULL
        OR TRY_CAST(AssignedTo AS INT) IS NULL
    DELETE FROM stg.FactOrders
     WHERE TRY_CAST(OrderID AS INT) IS NULL
        OR TRY_CAST(OrderDetailsID AS INT) IS NULL
        OR TRY_CAST(OrderDate AS DATE) IS NULL
        OR TRY_CAST(ShippingDate AS DATE) IS NULL
        OR TRY_CAST(CustomerID AS INT) IS NULL
        OR TRY_CAST(ProdID AS INT) IS NULL
        OR TRY_CAST(Quantity AS INT) IS NULL
        OR TRY_CAST(VAT AS NUMERIC(19, 2)) IS NULL
        OR TRY_CAST(TotalPrice AS NUMERIC(19, 2)) IS NULL
        OR TRY_CAST(ShippingAddress AS NVARCHAR(100)) IS NULL
        OR TRY_CAST(ShippingID AS INT) IS NULL
        OR TRY_CAST(DiscountID AS INT) IS NULL
        OR TRY_CAST(PaymentMethod AS NVARCHAR(50)) IS NULL
        OR TRY_CAST(WarrantyStartDate AS DATE) IS NULL
        OR TRY_CAST(WarrantyExpDate AS DATE) IS NULL
        OR TRY_CAST(AssignedTo AS INT) IS NULL;
END TRY
BEGIN CATCH
    INSERT INTO [stg].ErrorOrders (ErrorDescription)
    VALUES (ERROR_MESSAGE())
END CATCH