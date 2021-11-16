-- =================================================================================================
-- Author:			Maksym Bondaruk
-- Creation date:	14.11.2021
-- Description:		Final of [spr_CleanStgOrders]. Evokes the batch of the stored procedures, represented previously.
-- =================================================================================================
CREATE PROCEDURE spr_CleanStgOrders
AS
SET NOCOUNT ON;
SET ANSI_WARNINGS OFF;
BEGIN TRY
    EXEC [Lv635_OnlineStore].[dbo].[spr_LogProc] @ProcessName = 'spr_CleanStgOrders',
                                                 @LevelProcedure = 'START'
    EXEC spr_DiscardConversionIssues_Orders;
    EXEC spr_DiscardDuplicates_Orders;
    EXEC spr_DiscardIncorrectValues_Orders;
    EXEC spr_Conversion_Orders;
    EXEC [Lv635_OnlineStore].[dbo].[spr_LogProc] @ProcessName = 'spr_CleanStgOrders',
                                                 @LevelProcedure = 'STOP'
END TRY
BEGIN CATCH
    INSERT INTO [stg].ErrorOrders (ErrorDescription)
    VALUES (ERROR_MESSAGE());
    DECLARE @Error_message NVARCHAR(100)
    SET @Error_message = (SELECT ERROR_MESSAGE())
    EXEC [Lv635_OnlineStore].[dbo].[spr_LogProc] @ProcessName = 'spr_CleanStgOrders',
                                                 @LevelProcedure = 'FATAL',
                                                 @Context = @Error_message
END CATCH;
