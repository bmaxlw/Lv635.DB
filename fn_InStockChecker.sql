-- =================================================================================================
-- Author:			Maksym Bondaruk
-- Creation date:	18.10.2021
-- Description:		The current inline table-valued FUNCTION returns the values of the QtInStock, 
--					predefined by the upper and lower limits, stated in the FUNCTION parameters.
--					With the QtInStock results, the contacts of the product's supplier and
--					the warehouse managers, in whose warehouses the products are stored, are returned.
-- =================================================================================================
CREATE FUNCTION fn_QtChecker (@lower_limit INT, @upper_limit INT)
	RETURNS TABLE AS RETURN
		SELECT p.ProdID, p.ProdName, p.QtInStock 'InStock', p.CostUnit,
			   s.SupplierName, s.SupplierPhone, s.SupplierEmail, 
			   w.WarehouseManager 'WhMgr', 
			   e.EmpPhone 'WhMgrPhone', e.EmpEmail 'WhMgrEmail'
		FROM Products p 
			JOIN Suppliers s ON p.Supplier = s.SupplierID
			JOIN Warehouses w ON p.Warehouse = w.WarehouseID
			JOIN Employees e ON w.WarehouseManager = e.EmpID
		WHERE
			(QtInStock <= @upper_limit OR @upper_limit IS NULL) AND
			(QtInStock >= @lower_limit OR @lower_limit IS NULL);