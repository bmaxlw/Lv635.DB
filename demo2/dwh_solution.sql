--USE Lv635_Staging

--WITH MergeCTE(
--OrderID,
--OrderDetailsID,
--OrderDate,
--ShippingDate,
--CustomerID,
--ProdID,
--Quantity,
--VAT,
--TotalPrice,
--ShippingAddress,
--ShippingID,
--DiscountID,
--PaymentMethod,
--WarrantyStartDate,
--WarrantyExpDate,
--AssignedTo) AS
--(SELECT 
--OrderID,
--OrderDetailsID,
--OrderDate,
--ShippingDate,
--CustomerID,
--ProdID,
--Quantity,
--VAT,
--TotalPrice,
--ShippingAddress,
--ShippingID,
--DiscountID,
--PaymentMethod,
--WarrantyStartDate,
--WarrantyExpDate,
--AssignedTo
--FROM 
--dbo.FactOrders AS src)
--MERGE [Lv635_DataWarehouse].dbo.FactOrders AS dst USING (dbo.FactOrders AS src) ON (src.OrderID = dst.OrderID)


MERGE INTO [Lv635_DataWarehouse].dbo.FactOrders DST
USING [Lv635_Staging].dbo.FactOrders SRC
ON (
       SRC.OrderID = DST.OrderID
       AND SRC.OrderDetailsID = DST.OrderDetailsID
       --OR SRC.OrderDate = DST.OrderDate
       --OR SRC.ShippingDate = DST.ShippingDate
       --OR SRC.CustomerID = DST.CustomerID
       --OR SRC.ProdID = DST.ProdID
       --OR SRC.Quantity = DST.Quantity
       --OR SRC.VAT = DST.VAT
       --OR SRC.TotalPrice = DST.TotalPrice
       --OR SRC.ShippingAddress = DST.ShippingAddress
       --OR SRC.ShippingID = DST.ShippingID
       --OR SRC.DiscountID = DST.DiscountID
       --OR SRC.PaymentMethod = DST.PaymentMethod
       --OR SRC.WarrantyStartDate = DST.WarrantyStartDate
       --OR SRC.WarrantyExpDate = DST.WarrantyExpDate
       --OR SRC.AssignedTo = DST.AssignedTo
   )
WHEN MATCHED THEN
    UPDATE SET DST.OrderID = SRC.OrderID,
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
    INSERT
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
    VALUES
    (SRC.OrderID,
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
     SRC.AssignedTo
    );
--WHEN NOT MATCHED BY SOURCE THEN
--	INSERT
--    (
--        OrderID,
--        OrderDetailsID,
--        OrderDate,
--        ShippingDate,
--        CustomerID,
--        ProdID,
--        Quantity,
--        VAT,
--        TotalPrice,
--        ShippingAddress,
--        ShippingID,
--        DiscountID,
--        PaymentMethod,
--        WarrantyStartDate,
--        WarrantyExpDate,
--        AssignedTo
--    )
--    VALUES
--    (SRC.OrderID,
--     SRC.OrderDetailsID,
--     SRC.OrderDate,
--     SRC.ShippingDate,
--     SRC.CustomerID,
--     SRC.ProdID,
--     SRC.Quantity,
--     SRC.VAT,
--     SRC.TotalPrice,
--     SRC.ShippingAddress,
--     SRC.ShippingID,
--     SRC.DiscountID,
--     SRC.PaymentMethod,
--     SRC.WarrantyStartDate,
--     SRC.WarrantyExpDate,
--     SRC.AssignedTo
--    );