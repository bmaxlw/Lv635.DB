-- =================================================================================================
-- Author:			Maksym Bondaruk
-- Creation date:	16.11.2021
-- Last update:		16.11.2021
-- Description:		Migration of clean data to DWH with merging
-- =================================================================================================
CREATE PROCEDURE spr_OrdersMigrationDWH
AS
BEGIN TRY
    EXEC [Lv635_OnlineStore].[dbo].[spr_LogProc] @ProcessName = '[MBLV635DB]: spr_OrdersMigrationDWH',
                                                 @LevelProcedure = 'START'
    SET NOCOUNT ON;
    SET ANSI_WARNINGS OFF;
    MERGE INTO [Lv635_DataWarehouse].dbo.FactOrders DST
    USING [Lv635_Staging].dbo.FactOrders SRC
       ON (   SRC.OrderID = DST.OrderID
        AND   SRC.OrderDetailsID = DST.OrderDetailsID)
     WHEN MATCHED THEN UPDATE SET DST.OrderID = SRC.OrderID,
                                  DST.OrderDetailsID = SRC.OrderDetailsID,
                                  OrderDate = SRC.OrderDate,
                                  ShippingDate = SRC.ShippingDate,
                                  CustomerID = SRC.CustomerID,
                                  ProdID = SRC.ProdID,
                                  Quantity = SRC.Quantity,
                                  VAT = SRC.VAT,
                                  TotalPrice = SRC.TotalPrice,
                                  ShippingAddress = SRC.ShippingAddress,
                                  ShippingID = SRC.ShippingID,
                                  DiscountID = SRC.DiscountID,
                                  PaymentMethod = SRC.PaymentMethod,
                                  WarrantyStartDate = SRC.WarrantyStartDate,
                                  WarrantyExpDate = SRC.WarrantyExpDate,
                                  AssignedTo = SRC.AssignedTo
     WHEN NOT MATCHED THEN
        INSERT (OrderID,
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
        VALUES (SRC.OrderID,
                SRC.OrderDetailsID,
                SRC.OrderDate,
                SRC.ShippingDate,
                SRC.CustomerID,
                SRC.ProdID,
                SRC.Quantity,
                SRC.VAT,
                SRC.TotalPrice,
                SRC.ShippingAddress,
                SRC.ShippingID,
                SRC.DiscountID,
                SRC.PaymentMethod,
                SRC.WarrantyStartDate,
                SRC.WarrantyExpDate,
                SRC.AssignedTo);
    EXEC [Lv635_OnlineStore].[dbo].[spr_LogProc] @ProcessName = '[MBLV635DB]: spr_OrdersMigrationDWH',
                                                 @LevelProcedure = 'STOP'
END TRY
BEGIN CATCH
    DECLARE @Error_message NVARCHAR(100)
    SET @Error_message = (SELECT ERROR_MESSAGE())
    EXEC [Lv635_OnlineStore].[dbo].[spr_LogProc] @ProcessName = '[MBLV635DB]: spr_OrdersMigrationDWH',
                                                 @LevelProcedure = 'FATAL',
                                                 @Context = @Error_message
END CATCH;