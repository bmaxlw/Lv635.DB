-- =================================================================================================
-- Author:			Maksym Bondaruk
-- Creation date:	14.11.2021
-- Last update:		16.11.2021
-- Description:		Cleaning and migration from stg.FactOrders to dbo.FactOrders
-- =================================================================================================

-- STAGE 1/4. Discard conversion issues from the raw data
CREATE PROCEDURE spr_OrdersCleaning
AS
SET NOCOUNT ON;
SET ANSI_WARNINGS OFF;
BEGIN TRY
    BEGIN
        EXEC [Lv635_OnlineStore].[dbo].[spr_LogProc] @ProcessName = '[MBLV635DB]: spr_OrdersCleaning',
                                                     @LevelProcedure = 'START'
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
         WHERE OrderID IN ( SELECT OrderID FROM stg.ErrorOrders );
    END

    -- STAGE 2/4. Discard duplicates from the raw data.
    BEGIN
        CREATE TABLE ##Composite (
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

        INSERT INTO ##Composite (CompositeKey,
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
        SELECT CAST(CONCAT(OrderID, OrderDetailsID) AS INT),
               CAST(OrderID AS INT),
               CAST(OrderDetailsID AS INT),
               CAST(OrderDate AS DATE),
               CAST(ShippingDate AS DATE),
               CAST(CustomerID AS INT),
               CAST(ProdID AS INT),
               CAST(Quantity AS INT),
               CAST(VAT AS NUMERIC(19, 2)),
               CAST(TotalPrice AS NUMERIC(19, 2)),
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
            SELECT OrderID,
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
             WHERE CompositeKey  = @Ckey
               AND Identificator = @MinID;

            DELETE FROM ##Composite
             WHERE CompositeKey  = @Ckey
               AND Identificator = @MinID;

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
            SELECT '[Error 2]: Duplicated values assigned for PKEYs',
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

            DELETE FROM ##Composite
             WHERE CompositeKey = @Ckey;

        END
        DROP TABLE ##Composite
    END

    -- STAGE 3/4. Discards incorrect values from the raw data.
    BEGIN
        DECLARE @LenShippingAddress INT = (   SELECT CHARACTER_MAXIMUM_LENGTH
                                                FROM INFORMATION_SCHEMA.COLUMNS
                                               WHERE TABLE_SCHEMA = 'dbo'
                                                 AND TABLE_NAME   = 'FactOrders'
                                                 AND COLUMN_NAME  = 'ShippingAddress');
        DECLARE @LenPaymentMethod INT = (   SELECT CHARACTER_MAXIMUM_LENGTH
                                              FROM INFORMATION_SCHEMA.COLUMNS
                                             WHERE TABLE_SCHEMA = 'dbo'
                                               AND TABLE_NAME   = 'FactOrders'
                                               AND COLUMN_NAME  = 'PaymentMethod');
        DECLARE @LenVAT INT = (   SELECT NUMERIC_PRECISION
                                    FROM INFORMATION_SCHEMA.COLUMNS
                                   WHERE TABLE_SCHEMA = 'dbo'
                                     AND TABLE_NAME   = 'FactOrders'
                                     AND COLUMN_NAME  = 'VAT');
        DECLARE @LenTotalPrice INT = (   SELECT NUMERIC_PRECISION
                                           FROM INFORMATION_SCHEMA.COLUMNS
                                          WHERE TABLE_SCHEMA = 'dbo'
                                            AND TABLE_NAME   = 'FactOrders'
                                            AND COLUMN_NAME  = 'TotalPrice');
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
        SELECT '[Error 3]: Date/Length Formatting violated',
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
            OR LEN(VAT)             > @LenVAT
            OR LEN(TotalPrice)      > @LenTotalPrice
            OR LEN(ShippingAddress) > @LenShippingAddress
            OR LEN(PaymentMethod)   > @LenPaymentMethod
            OR WarrantyStartDate    < '2014-01-01'
            OR WarrantyExpDate      < '2014-01-01';
        DELETE FROM stg.FactOrders
         WHERE OrderID IN ( SELECT OrderID FROM stg.ErrorOrders );
    END

    -- STAGE 4/4. Maintain conversion.
    BEGIN
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
    END
    EXEC [Lv635_OnlineStore].[dbo].[spr_LogProc] @ProcessName = '[MBLV635DB]: spr_OrdersCleaning',
                                                 @LevelProcedure = 'STOP'
END TRY
BEGIN CATCH
    INSERT INTO [stg].ErrorOrders (ErrorDescription)
    VALUES (ERROR_MESSAGE())
    DECLARE @Error_message NVARCHAR(100)
    SET @Error_message = (SELECT ERROR_MESSAGE())
    EXEC [Lv635_OnlineStore].[dbo].[spr_LogProc] @ProcessName = '[MBLV635DB]: spr_OrdersCleaning',
                                                 @LevelProcedure = 'FATAL',
                                                 @Context = @Error_message
END CATCH