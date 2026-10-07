-- ========================================================
-- BÀI TẬP: VIEW, INDEX, STORED PROCEDURE
-- ========================================================

-- --------------------------------------------------------
-- BƯỚC 1: TẠO CƠ SỞ DỮ LIỆU DEMO
-- --------------------------------------------------------
CREATE DATABASE IF NOT EXISTS demo;
USE demo;

-- --------------------------------------------------------
-- BƯỚC 2: TẠO BẢNG PRODUCTS VÀ THÊM DỮ LIỆU MẪU
-- --------------------------------------------------------
DROP TABLE IF EXISTS Products;

CREATE TABLE Products (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    productCode VARCHAR(20) NOT NULL UNIQUE,
    productName VARCHAR(100) NOT NULL,
    productPrice DECIMAL(10, 2) NOT NULL,
    productAmount INT NOT NULL DEFAULT 0,
    productDescription TEXT,
    productStatus BIT DEFAULT 1
);

-- Chèn dữ liệu mẫu
INSERT INTO Products (productCode, productName, productPrice, productAmount, productDescription, productStatus) VALUES
('P001', 'iPhone 15 Pro Max', 1200.00, 15, 'Flagship smartphone from Apple', 1),
('P002', 'Samsung Galaxy S24 Ultra', 1100.00, 20, 'Flagship smartphone from Samsung', 1),
('P003', 'MacBook Pro M3', 2000.00, 10, 'High-performance laptop', 1),
('P004', 'Dell XPS 15', 1800.00, 8, 'Premium Windows laptop', 1),
('P005', 'Sony WH-1000XM5', 350.00, 30, 'Noise canceling headphones', 1),
('P006', 'iPad Air 5', 600.00, 25, 'Mid-range tablet from Apple', 1);

-- --------------------------------------------------------
-- BƯỚC 3: THỰC HÀNH VỚI INDEX
-- --------------------------------------------------------

-- Kiếm tra câu lệnh EXPLAIN trước khi tạo Index thủ công (để xem cách MySQL thực thi)
EXPLAIN SELECT * FROM Products WHERE productCode = 'P001';
EXPLAIN SELECT * FROM Products WHERE productName = 'MacBook Pro M3' AND productPrice = 2000.00;

-- 1. Tạo Unique Index trên cột productCode (Lưu ý: Do trường đã có ràng buộc UNIQUE nên index có thể đã tự tạo, đây là câu lệnh tạo thủ công nếu chưa có)
-- CREATE UNIQUE INDEX idx_productCode ON Products(productCode);

-- 2. Tạo Composite Index trên 2 cột productName và productPrice
CREATE INDEX idx_productName_price ON Products(productName, productPrice);

-- 3. Sử dụng EXPLAIN sau khi đã tạo Index để so sánh
EXPLAIN SELECT * FROM Products WHERE productCode = 'P001';
EXPLAIN SELECT * FROM Products WHERE productName = 'MacBook Pro M3' AND productPrice = 2000.00;

-- So sánh:
-- - Trước khi tạo Index: Cột 'type' thường là 'ALL' (Full Table Scan - duyệt toàn bộ bảng), cột 'possible_keys' là NULL.
-- - Sau khi tạo Index: Cột 'type' chuyển thành 'ref' hoặc 'const', cột 'key' sử dụng 'idx_productName_price' hoặc 'productCode', số dòng cần quét (cột 'rows') giảm đáng kể.

-- --------------------------------------------------------
-- BƯỚC 4: THỰC HÀNH VỚI VIEW
-- --------------------------------------------------------

-- 1. Tạo View lấy về các thông tin: productCode, productName, productPrice, productStatus
CREATE VIEW w_product_summary AS
SELECT productCode, productName, productPrice, productStatus
FROM Products;

-- Truy vấn từ View
SELECT * FROM w_product_summary;

-- 2. Tiến hành sửa đổi View (sử dụng CREATE OR REPLACE VIEW hoặc ALTER VIEW)
CREATE OR REPLACE VIEW w_product_summary AS
SELECT productCode, productName, productPrice, productAmount, productStatus
FROM Products;

-- Truy vấn kiểm tra View sau khi sửa
SELECT * FROM w_product_summary;

-- 3. Tiến hành xóa View
DROP VIEW IF EXISTS w_product_summary;

-- --------------------------------------------------------
-- BƯỚC 5: THỰC HÀNH VỚI STORED PROCEDURE
-- --------------------------------------------------------

DELIMITER //

-- 1. Stored Procedure lấy tất cả thông tin của tất cả các sản phẩm
CREATE PROCEDURE sp_get_all_products()
BEGIN
    SELECT * FROM Products;
END //

-- 2. Stored Procedure thêm một sản phẩm mới
CREATE PROCEDURE sp_add_product(
    IN p_code VARCHAR(20),
    IN p_name VARCHAR(100),
    IN p_price DECIMAL(10,2),
    IN p_amount INT,
    IN p_desc TEXT,
    IN p_status BIT
)
BEGIN
    INSERT INTO Products (productCode, productName, productPrice, productAmount, productDescription, productStatus)
    VALUES (p_code, p_name, p_price, p_amount, p_desc, p_status);
END //

-- 3. Stored Procedure sửa thông tin sản phẩm theo Id
CREATE PROCEDURE sp_update_product_by_id(
    IN p_id INT,
    IN p_code VARCHAR(20),
    IN p_name VARCHAR(100),
    IN p_price DECIMAL(10,2),
    IN p_amount INT,
    IN p_desc TEXT,
    IN p_status BIT
)
BEGIN
    UPDATE Products
    SET productCode = p_code,
        productName = p_name,
        productPrice = p_price,
        productAmount = p_amount,
        productDescription = p_desc,
        productStatus = p_status
    WHERE Id = p_id;
END //

-- 4. Stored Procedure xóa sản phẩm theo Id
CREATE PROCEDURE sp_delete_product_by_id(
    IN p_id INT
)
BEGIN
    DELETE FROM Products WHERE Id = p_id;
END //

DELIMITER ;

-- --------------------------------------------------------
-- KIỂM TRA THỬ CÁC STORED PROCEDURE
-- --------------------------------------------------------

-- Gọi SP lấy danh sách sản phẩm
CALL sp_get_all_products();

-- Gọi SP thêm sản phẩm
CALL sp_add_product('P007', 'AirPods Pro 2', 250.00, 50, 'Wireless earbuds', 1);

-- Gọi SP sửa thông tin sản phẩm có Id = 1
CALL sp_update_product_by_id(1, 'P001', 'iPhone 15 Pro Max 512GB', 1400.00, 10, 'Updated description', 1);

-- Gọi SP xóa sản phẩm có Id = 6
CALL sp_delete_product_by_id(6);

-- Kiểm tra lại bảng dữ liệu sau các thao tác
CALL sp_get_all_products();