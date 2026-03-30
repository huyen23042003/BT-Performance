IF NOT EXISTS (
	SELECT * FROM sys.databases 
	WHERE name = 'BT_Performance'
) 
BEGIN
	CREATE DATABASE BT_Performance
END

USE BT_Performance
GO


IF NOT EXISTS (
	SELECT * FROM sys.objects 
	WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[PRODUCT]') AND TYPE IN (N'U')
)
BEGIN
	CREATE TABLE [dbo].[PRODUCT](
	[ProductID] [VARCHAR] (20) NOT NULL ,
	[ProductName] [NVARCHAR] (200) NOT NULL,
	[Price] [DECIMAL] (18,2) DEFAULT 0,	
	CONSTRAINT PK_ProductID PRIMARY KEY(ProductID)
	)
END

IF NOT EXISTS (
	SELECT * FROM sys.objects 
	WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[CUSTOMER]') AND TYPE IN (N'U')
)
BEGIN 
	CREATE TABLE [dbo].[CUSTOMER] (
		[CustomerID] [VARCHAR] (20) NOT NULL ,
		[CustomerName] [NVARCHAR] (255) NOT NULL,
		[Phone] [VARCHAR] (10) NOT NULL,
		CONSTRAINT PK_CustomerID PRIMARY KEY (CustomerID)
	)
END

IF NOT EXISTS (
	SELECT * FROM sys.objects 
	WHERE OBJECT_ID = OBJECT_ID(N'INVOICE') AND TYPE IN (N'U')
)
BEGIN 
	CREATE TABLE [dbo].[INVOICE](
	[InvoiceID] [VARCHAR] (20) NOT NULL,
	[CustomerID] [VARCHAR] (20) NOT NULL,
	[InvoiceDate] Date NOT NULL,
	[TotalPrice] [DECIMAL] (18,2) NOT NULL DEFAULT 0,
	CONSTRAINT PK_InvoiceID PRIMARY KEY (InvoiceID),
	CONSTRAINT FK_CUSTOMER_CustomerID_INVOICE_InvoiceID FOREIGN KEY (CustomerID) REFERENCES CUSTOMER(CustomerID)
	)
END


IF NOT EXISTS (
	SELECT * FROM sys.objects 
	WHERE OBJECT_ID = OBJECT_ID(N'INVOICEDETAILS') AND TYPE IN (N'U')
)
BEGIN
	CREATE TABLE [dbo].[INVOICEDETAILS] (
		InvoiceDetailID [INT] NOT NULL,
		[InvoiceID] [VARCHAR] (20) NOT NULL,
		[ProductID] [VARCHAR] (20) NOT NULL,
		[Quantity] [INT] NOT NULL DEFAULT 0,
		[TotalPrice] [DECIMAL] (18,2) NOT NULL DEFAULT 0,

		CONSTRAINT PK_INVOICEDETAILSID PRIMARY KEY (InvoiceDetailID),
		CONSTRAINT FK_InvoiceID FOREIGN KEY (InvoiceID) REFERENCES INVOICE(InvoiceID),
		CONSTRAINT FK_ProductID FOREIGN KEY (ProductID) REFERENCES PRODUCT(ProductID)
	)
END
Go
-- Thêm sản phẩm mới vào bảng Product với mã sản phẩm dạng SP01, SP02...
INSERT INTO Product (ProductID, ProductName, Price) VALUES
('SP01', N'Sản phẩm A', 100000),
('SP02', N'Sản phẩm B', 200000),
('SP03', N'Sản phẩm C', 150000);
-- Thêm khách hàng mới vào bảng Customer với mã khách hàng dạng KH01, KH02...
INSERT INTO Customer (CustomerID, CustomerName, Phone) VALUES
('KH01', N'Nguyễn Văn A', '0909123456'),
('KH02', N'Trần Thị B', '0909234567');
-- Thêm hóa đơn mới vào bảng Invoice với mã hóa đơn dạng HD01, HD02...
INSERT INTO Invoice (InvoiceID, CustomerID, InvoiceDate) VALUES
('HD01', 'KH01', '2024-09-17'),
('HD02', 'KH02', '2024-09-17'),
('HD03', 'KH01', '2024-09-18'),
('HD04', 'KH02', '2024-09-18'),
('HD05', 'KH01', '2024-09-19');
-- Thêm chi tiết hóa đơn mới vào bảng INVOICEDETAILS với mã hóa đơn dạng HD01, HD02...
INSERT INTO INVOICEDETAILS (InvoiceDetailID, InvoiceID, ProductID, Quantity, TotalPrice) VALUES
(1, 'HD01', 'SP01', 2, 200000),
(2, 'HD01', 'SP02', 1, 200000),
(3, 'HD02', 'SP03', 3, 450000),
(4, 'HD03', 'SP01', 1, 100000),
(5, 'HD04', 'SP02', 2, 400000),
(6, 'HD05', 'SP03', 1, 150000);

GO;

CREATE OR ALTER PROCEDURE GetCustomerRevenue
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra tham số đầu vào
    IF @StartDate IS NULL OR @EndDate IS NULL
    BEGIN
        RAISERROR(N'Ngày bắt đầu và ngày kết thúc không được để trống.', 16, 1);
        RETURN;
    END

    IF @StartDate > @EndDate
    BEGIN
        RAISERROR(N'Ngày bắt đầu không được lớn hơn ngày kết thúc.', 16, 1);
        RETURN;
    END

    -- 1. Chi tiết doanh thu theo từng hóa đơn
    SELECT 
        c.CustomerID,
        c.CustomerName,
        i.InvoiceID,
        SUM(ISNULL(id.TotalPrice, 0)) AS InvoiceRevenue
    FROM Customer c
    INNER JOIN Invoice i ON c.CustomerID = i.CustomerID
    INNER JOIN InvoiceDetails id ON i.InvoiceID = id.InvoiceID
    WHERE i.InvoiceDate >= @StartDate
      AND i.InvoiceDate < DATEADD(DAY, 1, @EndDate)
    GROUP BY c.CustomerID, c.CustomerName, i.InvoiceID
    ORDER BY i.InvoiceID;

    -- 2. Doanh thu theo từng khách hàng
    SELECT 
        c.CustomerID,
        c.CustomerName,
        SUM(ISNULL(id.TotalPrice, 0)) AS TotalRevenue
    FROM Customer c
    INNER JOIN Invoice i ON c.CustomerID = i.CustomerID
    INNER JOIN InvoiceDetails id ON i.InvoiceID = id.InvoiceID
    WHERE i.InvoiceDate >= @StartDate
      AND i.InvoiceDate < DATEADD(DAY, 1, @EndDate)
    GROUP BY c.CustomerID, c.CustomerName
    ORDER BY c.CustomerID;

    -- 3. Thống kê sản phẩm đã bán
    SELECT 
        p.ProductID,
        p.ProductName,
        SUM(ISNULL(id.Quantity, 0)) AS TotalQuantity,
        SUM(ISNULL(id.TotalPrice, 0)) AS TotalRevenue
    FROM Product p
    INNER JOIN InvoiceDetails id ON p.ProductID = id.ProductID
    INNER JOIN Invoice i ON id.InvoiceID = i.InvoiceID
    WHERE i.InvoiceDate >= @StartDate
      AND i.InvoiceDate < DATEADD(DAY, 1, @EndDate)
    GROUP BY p.ProductID, p.ProductName
    ORDER BY p.ProductID;
END;
GO

EXEC GetCustomerRevenue 
    @StartDate = '2024-09-17',
    @EndDate = '2024-09-18';
GO


