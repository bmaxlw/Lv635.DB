USE Lv635_OnlineStore;

SELECT TOP 10 * FROM OrderDetails ORDER BY OrderDetailsID DESC;
SELECT * FROM Products ORDER BY PriceUnit DESC;
SELECT TOP 10 * FROM Orders ORDER BY OrderID DESC;
SELECT * FROM Discounts;
EXEC sp_help OrderDetails;
EXEC sp_help Products;
DROP PROCEDURE spr_NewOrderDetails;
DROP TRIGGER trg_DiscountAssignation_INS;
TRUNCATE TABLE OrderDetails;
EXEC spr_NewOrderDetails 5000013, 777, 2; -- OrderID, ProdID, Qt


-- =================================================================================================
-- Author:			Maksym Bondaruk
-- Creation date:	13.10.2021
-- Description:		When new order is added into Orders, trigger is evoked to run the procedure
--					and fill in the new order details. 
--					Procedure calculates the ... 
--						1) ... total order price (on the basis of the Qt and PriceUnit).
--						2) ... decrementation of the goods in the warehouse 
--							(after the new order details were added).
--						3) ... the inconsistency of data in case when 
--							QtInStock < Qt in OrderDetails (the warning is evoked
--							and the procedure is stopped).
--						4) ... VAT value on the basis of the TotalPrice of the order.
-- =================================================================================================

CREATE PROCEDURE spr_NewOrderDetails 
				@OrderID INT,  
				@ProdID INT, 
				@Qt INT
AS
BEGIN TRY
	IF (SELECT QtInStock FROM Products WHERE ProdID = @ProdID) > @Qt
		BEGIN
-- Insert new order details:
			INSERT INTO OrderDetails(OrderID, ProdID, Quantity, VAT, TotalPrice)
				VALUES 
					(@OrderID, @ProdID, @Qt,
					((SELECT PriceUnit FROM Products
				WHERE ProdID = @ProdID) * 0.2) * @Qt, 
					(SELECT PriceUnit FROM Products
				WHERE ProdID = @ProdID) * @Qt);
-- Update quantity in stock in Products:
			UPDATE Products SET QtInStock = QtInStock - @Qt 
				WHERE ProdID = @ProdID;
		END
-- If QtInStock < Qt in OrderDetails - fire an error message: 
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



