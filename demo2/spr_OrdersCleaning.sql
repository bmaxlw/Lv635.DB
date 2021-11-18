-- =================================================================================================
-- Author:			Maksym Bondaruk
-- Creation date:	14.11.2021
-- Last update:		16.11.2021
-- Description:		Cleaning and migration from stg.FactOrders to dbo.FactOrders
-- =================================================================================================

-- STAGE 1/3. Discard conversion issues from the raw data
CREATE PROCEDURE spr_OrdersCleaning
AS
SET NOCOUNT ON;
SET ANSI_WARNINGS OFF;
BEGIN TRY
    BEGIN
        EXEC [Lv635_OnlineStore].[dbo].[spr_LogProc] @ProcessName = '[spr_OrdersCleaning]: MAIN',
                                                     @LevelProcedure = 'START';
        EXEC [Lv635_OnlineStore].[dbo].[spr_LogProc] @ProcessName = '[spr_OrdersCleaning]: DISCARDING CONVERSION ISSUES',
                                                     @LevelProcedure = 'START';
        INSERT INTO [stg].ErrorOrders
        (
            ErrorDescription,
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
        )
        SELECT '[Error 1]: Conversion failed',
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
        WHERE OrderID IN (
                             SELECT OrderID FROM stg.ErrorOrders
                         );
        EXEC [Lv635_OnlineStore].[dbo].[spr_LogProc] @ProcessName = '[spr_OrdersCleaning]: DISCARDING CONVERSION ISSUES',
                                                     @LevelProcedure = 'STOP';
    END


    -- STAGE 2/3. Discards incorrect values from the raw data.
    BEGIN
        EXEC [Lv635_OnlineStore].[dbo].[spr_LogProc] @ProcessName = '[spr_OrdersCleaning]: DISCARDING INCORRECT VALUES',
                                                     @LevelProcedure = 'START';
        DECLARE @LenShippingAddress INT = (
                                              SELECT CHARACTER_MAXIMUM_LENGTH
                                              FROM INFORMATION_SCHEMA.COLUMNS
                                              WHERE TABLE_SCHEMA = 'dbo'
                                                    AND TABLE_NAME = 'FactOrders'
                                                    AND COLUMN_NAME = 'ShippingAddress'
                                          );
        DECLARE @LenPaymentMethod INT = (
                                            SELECT CHARACTER_MAXIMUM_LENGTH
                                            FROM INFORMATION_SCHEMA.COLUMNS
                                            WHERE TABLE_SCHEMA = 'dbo'
                                                  AND TABLE_NAME = 'FactOrders'
                                                  AND COLUMN_NAME = 'PaymentMethod'
                                        );
        DECLARE @LenVAT INT = (
                                  SELECT NUMERIC_PRECISION
                                  FROM INFORMATION_SCHEMA.COLUMNS
                                  WHERE TABLE_SCHEMA = 'dbo'
                                        AND TABLE_NAME = 'FactOrders'
                                        AND COLUMN_NAME = 'VAT'
                              );
        DECLARE @LenTotalPrice INT = (
                                         SELECT NUMERIC_PRECISION
                                         FROM INFORMATION_SCHEMA.COLUMNS
                                         WHERE TABLE_SCHEMA = 'dbo'
                                               AND TABLE_NAME = 'FactOrders'
                                               AND COLUMN_NAME = 'TotalPrice'
                                     );
        INSERT INTO [stg].ErrorOrders
        (
            ErrorDescription,
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
        )
        SELECT '[Error 2]: DATE formatting and/or value length violated',
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
        WHERE OrderDate < '2014-01-01'
              OR ShippingDate < '2014-01-01'
              OR LEN(VAT) > @LenVAT
              OR LEN(TotalPrice) > @LenTotalPrice
              OR LEN(ShippingAddress) > @LenShippingAddress
              OR LEN(PaymentMethod) > @LenPaymentMethod
              OR WarrantyStartDate < '2014-01-01'
              OR WarrantyExpDate < '2014-01-01';
        DELETE FROM stg.FactOrders
        WHERE OrderID IN (
                             SELECT OrderID FROM stg.ErrorOrders
                         );
        EXEC [Lv635_OnlineStore].[dbo].[spr_LogProc] @ProcessName = '[spr_OrdersCleaning]: DISCARDING INCORRECT VALUES',
                                                     @LevelProcedure = 'STOP';
    END

    -- STAGE 3/3. DISCARD DUPLICATES ASSIGNED TO COMPOSITE PRIMARY KEYS AND MAINTAIN FINAL CONVERSION WITH MIGRATION OF CLEAN DATA
    BEGIN
        EXEC [Lv635_OnlineStore].[dbo].[spr_LogProc] @ProcessName = '[spr_OrdersCleaning]: DISCARDING DUPLICATES, MIGRATING',
                                                     @LevelProcedure = 'START';
        WITH ClnCTE (Rnk, Ckey, OrderID, OrderDetailsID, OrderDate, ShippingDate, CustomerID, ProdID, Quantity, VAT,
                     TotalPrice, ShippingAddress, ShippingID, DiscountID, PaymentMethod, WarrantyStartDate,
                     WarrantyExpDate, AssignedTo
                    )
        AS (SELECT ROW_NUMBER() OVER (PARTITION BY (OrderID + OrderDetailsID) ORDER BY OrderID) Rnk,
                   (OrderID + OrderDetailsID) Ckey,
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
           )
        INSERT INTO dbo.FactOrders
        (
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
        )
        SELECT TRY_CAST(OrderID AS INT),
               TRY_CAST(OrderDetailsID AS INT),
               TRY_CAST(OrderDate AS DATE),
               TRY_CAST(ShippingDate AS DATE),
               TRY_CAST(CustomerID AS INT),
               TRY_CAST(ProdID AS INT),
               TRY_CAST(Quantity AS INT),
               TRY_CAST(VAT AS NUMERIC(19, 2)),
               TRY_CAST(TotalPrice AS NUMERIC(19, 2)),
               TRY_CAST(ShippingAddress AS NVARCHAR(100)),
               TRY_CAST(ShippingID AS INT),
               TRY_CAST(DiscountID AS INT),
               TRY_CAST(PaymentMethod AS NVARCHAR(50)),
               TRY_CAST(WarrantyStartDate AS DATE),
               TRY_CAST(WarrantyExpDate AS DATE),
               TRY_CAST(AssignedTo AS INT)
        FROM ClnCTE
        WHERE Rnk = 1;

        WITH ErrCTE (Rnk, Ckey, OrderID, OrderDetailsID, OrderDate, ShippingDate, CustomerID, ProdID, Quantity, VAT,
                     TotalPrice, ShippingAddress, ShippingID, DiscountID, PaymentMethod, WarrantyStartDate,
                     WarrantyExpDate, AssignedTo
                    )
        AS (SELECT ROW_NUMBER() OVER (PARTITION BY (OrderID + OrderDetailsID) ORDER BY OrderID) Rnk,
                   (OrderID + OrderDetailsID) Ckey,
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
           )
        INSERT INTO stg.ErrorOrders
        (
            ErrorDescription,
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
        )
        SELECT '[Error 3]: Duplicates assigned for Primary keys',
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
        FROM ErrCTE
        WHERE Rnk > 1;
        EXEC [Lv635_OnlineStore].[dbo].[spr_LogProc] @ProcessName = '[spr_OrdersCleaning]: DISCARDING DUPLICATES, MIGRATING',
                                                     @LevelProcedure = 'STOP';
    END
    EXEC [Lv635_OnlineStore].[dbo].[spr_LogProc] @ProcessName = '[spr_OrdersCleaning]: MAIN',
                                                 @LevelProcedure = 'STOP'
END TRY
BEGIN CATCH
    INSERT INTO [stg].ErrorOrders
    (
        ErrorDescription
    )
    VALUES (ERROR_MESSAGE())
    DECLARE @Error_message NVARCHAR(100)
    SET @Error_message =
    (
        SELECT ERROR_MESSAGE()
    )
    EXEC [Lv635_OnlineStore].[dbo].[spr_LogProc] @ProcessName = '[spr_OrdersCleaning]: MAIN',
                                                 @LevelProcedure = 'FATAL',
                                                 @Context = @Error_message
END CATCH