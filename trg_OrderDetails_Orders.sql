-- =================================================================================================
-- Author:			Maksym Bondaruk
-- Creation date:	13.10.2021
-- Description:		When new order details are added, trigger fires and fills in the correct
--					DiscountID from Discounts due to the TotalPrice of the Order.
--					Discounts, taken from Discounts table, are divided into 6 groups 
--					each of which is based on the definite price range.
-- =================================================================================================

CREATE TRIGGER trg_DiscountAssignation_INS ON 
OrderDetails AFTER INSERT AS
BEGIN TRY
-- 1st DiscountID
	IF (SELECT TotalPrice FROM inserted) < 
		(SELECT UpperLimit FROM Discounts WHERE DiscountID = 1)
		BEGIN
			UPDATE OrderDetails SET DiscountID = 1 
		WHERE OrderDetailsID = (SELECT OrderDetailsID FROM inserted);
		END
-- 2nd DiscountID
	ELSE IF (SELECT TotalPrice FROM inserted) > 
		(SELECT LowerLimit FROM Discounts WHERE DiscountID = 2)
		AND (SELECT TotalPrice FROM inserted) <
		(SELECT UpperLimit FROM Discounts WHERE DiscountID = 2)
		BEGIN
			UPDATE OrderDetails SET DiscountID = 2 
		WHERE OrderDetailsID = (SELECT OrderDetailsID FROM inserted);
		END
-- 3rd DiscountID
	ELSE IF (SELECT TotalPrice FROM inserted) > 
		(SELECT LowerLimit FROM Discounts WHERE DiscountID = 3)
		AND (SELECT TotalPrice FROM inserted) <
		(SELECT UpperLimit FROM Discounts WHERE DiscountID = 3)
		BEGIN
			UPDATE OrderDetails SET DiscountID = 3 
		WHERE OrderDetailsID = (SELECT OrderDetailsID FROM inserted);
		END
-- 4th DiscountID
	ELSE IF (SELECT TotalPrice FROM inserted) > 
		(SELECT LowerLimit FROM Discounts WHERE DiscountID = 4)
		AND (SELECT TotalPrice FROM inserted) <
		(SELECT UpperLimit FROM Discounts WHERE DiscountID = 4)
		BEGIN
			UPDATE OrderDetails SET DiscountID = 4 
		WHERE OrderDetailsID = (SELECT OrderDetailsID FROM inserted);
		END
-- 5th DiscountID
	ELSE IF (SELECT TotalPrice FROM inserted) > 
		(SELECT LowerLimit FROM Discounts WHERE DiscountID = 5)
		AND (SELECT TotalPrice FROM inserted) <
		(SELECT UpperLimit FROM Discounts WHERE DiscountID = 5)
		BEGIN
			UPDATE OrderDetails SET DiscountID = 5 
		WHERE OrderDetailsID = (SELECT OrderDetailsID FROM inserted);
		END
-- 6th DiscountID
	ELSE
		BEGIN
			UPDATE OrderDetails SET DiscountID = 6 
		WHERE OrderDetailsID = (SELECT OrderDetailsID FROM inserted);
		END
END TRY
BEGIN CATCH
	BEGIN
		PRINT 'FATAL ERROR!'
	END
END CATCH;

-- =================================================================================================
-- Author:			Maksym Bondaruk
-- Creation date:	14.10.2021
-- Description:		When new order is added into Orders, 
--					the trigger is fired to insert ...
--					1) ... the OrderID, taken from Orders' inserted.
--					2) ... the ProductID, chosen randomly on the basis of the MAX(ProdID).
--					3) ... the Qt, chosen randomly ...
--					... into OrderDetails
-- =================================================================================================

CREATE TRIGGER 
	trg_NewOrderToOrderDetails_INS 
	ON Orders AFTER INSERT AS
BEGIN TRY
	BEGIN
		DECLARE @NewOrderID INT 
			= (SELECT OrderID FROM inserted);
		DECLARE @NewProdID INT 
			= (FLOOR(RAND() * (SELECT MAX(ProdID) FROM Products)));
		DECLARE @NewQt INT 
			= (FLOOR(RAND() * 20));
		EXEC spr_NewOrderDetails @NewOrderID, @NewProdID, @NewQt;
	END;
END TRY
BEGIN CATCH
	BEGIN
		PRINT('FATAL ERROR!')
	END;
END CATCH;