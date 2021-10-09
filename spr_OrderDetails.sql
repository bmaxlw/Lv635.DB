USE Lv635_OnlineStore;

SELECT * FROM OrderDetails;
SELECT * FROM Products ORDER BY PriceUnit DESC;
SELECT TOP 10 * FROM Orders;
SELECT * FROM Discounts;
EXEC sp_help OrderDetails;
EXEC sp_help Products;
DROP PROCEDURE spr_NewOrderDetails;
DROP TRIGGER trg_DiscountAssignation_INS;
TRUNCATE TABLE OrderDetails;
EXEC spr_NewOrderDetails 6, 777, 15; -- OrderID, ProdID, Qt


-- spr_NewOrderDetails 
CREATE PROCEDURE spr_NewOrderDetails 
				@OrderID INT,  
				@ProdID INT, 
				@Qt INT
AS
BEGIN TRY
	IF (SELECT QtInStock FROM Products WHERE ProdID = @ProdID) > @Qt
		BEGIN
-- Insert new order details
			INSERT INTO OrderDetails(OrderID, ProdID, Quantity, VAT, TotalPrice)
				VALUES 
					(@OrderID, @ProdID, @Qt,
					((SELECT PriceUnit FROM Products
				WHERE ProdID = @ProdID) * 0.2) * @Qt, 
					(SELECT PriceUnit FROM Products
				WHERE ProdID = @ProdID) * @Qt);
-- Update QT in Products
			UPDATE Products SET QtInStock = QtInStock - @Qt 
				WHERE ProdID = @ProdID;
		END
-- If Products.QtInStock < OrderDetails.Qt
	ELSE
		BEGIN
			PRINT 'ERROR! Not enough products available in stock!';
		END
END TRY
BEGIN CATCH
	BEGIN
		PRINT 'FATAL ERROR!'
	END
END CATCH;

-- trg_DiscountAssignation_INS => Sets DiscountID due to the TotalPrice After INSERT into OrderDetails 
CREATE TRIGGER trg_DiscountAssignation_INS ON 
OrderDetails AFTER INSERT AS
BEGIN TRY
-- 1 DiscountID
	IF (SELECT TotalPrice FROM inserted) < 
		(SELECT UpperLimit FROM Discounts WHERE DiscountID = 1)
		BEGIN
			UPDATE OrderDetails SET DiscountID = 1 
		WHERE OrderDetailsID = (SELECT OrderDetailsID FROM inserted);
		END
-- 2 DiscountID
	ELSE IF (SELECT TotalPrice FROM inserted) > 
		(SELECT LowerLimit FROM Discounts WHERE DiscountID = 2)
		AND (SELECT TotalPrice FROM inserted) <
		(SELECT UpperLimit FROM Discounts WHERE DiscountID = 2)
		BEGIN
			UPDATE OrderDetails SET DiscountID = 2 
		WHERE OrderDetailsID = (SELECT OrderDetailsID FROM inserted);
		END
-- 3 DiscountID
	ELSE IF (SELECT TotalPrice FROM inserted) > 
		(SELECT LowerLimit FROM Discounts WHERE DiscountID = 3)
		AND (SELECT TotalPrice FROM inserted) <
		(SELECT UpperLimit FROM Discounts WHERE DiscountID = 3)
		BEGIN
			UPDATE OrderDetails SET DiscountID = 3 
		WHERE OrderDetailsID = (SELECT OrderDetailsID FROM inserted);
		END
-- 4 DiscountID
	ELSE IF (SELECT TotalPrice FROM inserted) > 
		(SELECT LowerLimit FROM Discounts WHERE DiscountID = 4)
		AND (SELECT TotalPrice FROM inserted) <
		(SELECT UpperLimit FROM Discounts WHERE DiscountID = 4)
		BEGIN
			UPDATE OrderDetails SET DiscountID = 4 
		WHERE OrderDetailsID = (SELECT OrderDetailsID FROM inserted);
		END
-- 5 DiscountID
	ELSE IF (SELECT TotalPrice FROM inserted) > 
		(SELECT LowerLimit FROM Discounts WHERE DiscountID = 5)
		AND (SELECT TotalPrice FROM inserted) <
		(SELECT UpperLimit FROM Discounts WHERE DiscountID = 5)
		BEGIN
			UPDATE OrderDetails SET DiscountID = 5 
		WHERE OrderDetailsID = (SELECT OrderDetailsID FROM inserted);
		END
-- 6 DiscountID
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


