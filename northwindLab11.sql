CREATE DATABASE BTVNLab111
GO 
USE Northwind
GO
SELECT * INTO BTVNLab111.dbo.Customer FROM dbo.Customers
SELECT * INTO BTVNLab111.dbo.Orders FROM dbo.Orders
SELECT * INTO BTVNLab111.dbo.Products FROM dbo.Products
USE BTVNLab111
GO
--1. Tạo một INSERT trigger có tên là checkCustomerOnInsert cho bảng Customers. Trigger này có
--nhiệm vụ kiểm tra thao tác chèn dữ liệu cho bảng Customer, xem trường Phone có phải là null hay
--không, nếu trường Phone là null thì sẽ không cho tiến hành chèn dữ liệu vào bảng này.
SELECT * FROM dbo.Custmer
CREATE TRIGGER checkCustomerOnInsert ON Custmer FOR INSERT
AS
IF EXISTS (SELECT Phone FROM Custmer WHERE Phone is NULL)
BEGIN
	PRINT 'ERRO'
	ROLLBACK TRAN
END
DROP TRIGGER checkCustomerOnInsert
INSERT INTO Custmer(CustomerID, CompanyName, Phone) VALUES ('111', 'hfg', NULL)

--2. Tạo một UPDATE trigger với tên là checkCustomerContryOnUpdate cho bảng Customers.
--Trigger này sẽ không cho phép người dùng thay đổi thông tin của những khách hàng mà có tên
--nước là France.
CREATE TRIGGER checkCustomerContryOnUpdate 
ON Custmer
FOR UPDATE
AS
BEGIN
IF EXISTS (SELECT * FROM DELETED WHERE COUNTRY  = 'France')
BEGIN
	PRINT 'ERRO'
	ROLLBACK TRAN
END
END
SELECT * FROM Custmer

--3. Chèn thêm một cột mới có tên là Active vào bảng Customers và cài đặt giá trị mặc định cho nó là
--1. Tạo một trigger có tên là checkCustomerInsteadOfDelete nhằm chuyển giá trị của cột Active
--thành 0 thay vì tiến hành xóa dữ liệu thực sự ra khỏi bảng khi thao tác xóa dữ liệu được tiến hành.
ALTER TABLE Custmer ADD Active int DEFAULT (1)
CREATE TRIGGER checkCustomerInsteadOfDelete ON Custmer
FOR DELETE
AS
IF EXISTS (SELECT Active FROM DELETED)
BEGIN
	UPDATE Custmer
	SET Active = 0
	WHERE CustomerID IN (SELECT CustomerID FROM DELETED)
	BEGIN
		PRINT 'ERRO'
		ROLLBACK TRAN
	END
END

DROP TRIGGER checkCustomerInsteadOfDelete
SELECT * FROM Custmer

--4. Thay đổi mức độ ưu tiên của trigger checkCustomerContryOnUpdate lên mức cao nhất.
--------------------------------
sp_settriggerorder [ @triggername = ] '[ triggerschema. ] triggername', 
[ @order = ] 'value', 
[ @stmttype = ] 'statement_type'   
[ , [ @namespace = ] { 'DATABASE' | 'SERVER' | NULL } ]-- Cần hỏi cô
-------------------------------
sp_settriggerorder @triggername = 'checkCustomerInsteadOfDelete',  -- Cái Để Xử Lý 
@order = 'First', -- Cái xử lý đầu tiên
@stmttype = 'ALTER_TABLE' -- Xử Lý Sau


--5. Tạo một trigger có tên safety nhằm vô hiệu hóa tất cả các thao tác: CREAT_TABLE,
--DROP_TABLE, ALTER_TABLE.
CREATE TRIGGER safety ON DATABASE 
FOR CREAT_TABLE, DROP_TABLE, ALTER_TABLE
AS
BEGIN
	PRINT 'ERRO'
	ROLLBACK TRAN
END
