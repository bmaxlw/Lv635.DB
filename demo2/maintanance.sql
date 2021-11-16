USE Lv635_Staging;


SELECT * FROM stg.FactOrders;
SELECT * FROM dbo.FactOrders;
SELECT * FROM stg.ErrorOrders;

EXEC sp_help FactOrders;

TRUNCATE TABLE stg.FactOrders;
TRUNCATE TABLE dbo.FactOrders;
TRUNCATE TABLE stg.ErrorOrders;

INSERT INTO stg.FactOrders VALUES('1', '1', '2021-01-01', '2021-01-01', '1', '1', '1', '1.00', '1.00', 'Street', '1', '1', 'Cash', '2021-01-01', '2021-01-01', '1');
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

EXEC spr_CleanStpOrders;