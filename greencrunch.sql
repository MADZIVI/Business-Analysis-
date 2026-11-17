-- GreenCrunch Pickle Manufacturing (Pty) Ltd — South African Database
-- Business Analysis 2.2 | VUT Computer Science Department
-- 20+ records per table | All data South African (Rands, cities, contacts)

CREATE DATABASE IF NOT EXISTS greencrunch; USE greencrunch;

--=====================================================================
--BUSINESS RULES  (enforced in this schema)
--=====================================================================
--BR-01 Every entity has a unique surrogate key (PK).
--BR-02 A sales order belongs to exactly one existing customer (FK).
--BR-03 A payment belongs to exactly one sales order (FK); one payment per order enforced by UNIQUE(order_id) in Payment.
--BR-04 A payment amount must equal the order total (sp_record_payment).
--BR-05 Product unit price must be greater than R0 (CHECK).
--BR-06 Stock can never go below zero (CHECK + trg_stock_out trigger).
--BR-07 Order line quantity must be positive (CHECK).
--BR-08 Payment method limited to Cash, EFT or Card (CHECK).
--BR-09 Customer phone numbers must be unique (UNIQUE).
--BR-10 Stock is auto-decremented whenever a line item is sold (trigger).
--BR-11 Purchase order must reference an existing approved supplier (FK).
--BR-12 Order dates cannot be in the future (CHECK order_date <= CURDATE()).

CREATE TABLE Supplier (
  supplier_id   INT(4)     PRIMARY KEY,
  supplier_name VARCHAR(60) NOT NULL UNIQUE,
  contact_person VARCHAR(60) NOT NULL,
  phone         VARCHAR(15) NOT NULL UNIQUE,
  city          VARCHAR(40) NOT NULL,
  province      VARCHAR(40) NOT NULL
);

CREATE TABLE Raw_Material (
  material_id   INT(4)     PRIMARY KEY,
  material_name VARCHAR(50) NOT NULL,
  unit          VARCHAR(10) NOT NULL,
  unit_cost     DECIMAL(8,2) NOT NULL CHECK (unit_cost > 0),
  qty_on_hand   INT NOT NULL DEFAULT 0 CHECK (qty_on_hand >= 0),
  supplier_id   CHAR(4) NOT NULL,
  FOREIGN KEY (supplier_id) REFERENCES Supplier(supplier_id)
) ;

CREATE TABLE Customer (
  customer_id   INT(4)     PRIMARY KEY,
  customer_name VARCHAR(60) NOT NULL,
  contact_person VARCHAR(60),
  phone         VARCHAR(15) NOT NULL UNIQUE,
  email         VARCHAR(60) UNIQUE,
  city          VARCHAR(40) NOT NULL,
  province      VARCHAR(40) NOT NULL
) ;

CREATE TABLE Product (
  product_id   CHAR(5)     PRIMARY KEY,
  product_name VARCHAR(60) NOT NULL,
  unit_price   DECIMAL(8,2) NOT NULL CHECK (unit_price > 0),
  qty_in_stock INT NOT NULL DEFAULT 0 CHECK (qty_in_stock >= 0)
) ENGINE=InnoDB;

CREATE TABLE Sales_Order (
  order_id    CHAR(4) PRIMARY KEY,
  order_date  DATE NOT NULL CHECK (order_date <= CURDATE()),
  customer_id CHAR(4) NOT NULL,
  status      ENUM('Pending','Delivered','Paid') NOT NULL DEFAULT 'Pending',
  FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
) ENGINE=InnoDB;

CREATE TABLE Order_Line (
  order_id   CHAR(4) NOT NULL,
  product_id CHAR(5) NOT NULL,
  qty        INT NOT NULL CHECK (qty > 0),
  unit_price DECIMAL(8,2) NOT NULL CHECK (unit_price > 0),
  PRIMARY KEY (order_id, product_id),
  FOREIGN KEY (order_id)   REFERENCES Sales_Order(order_id),
  FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

CREATE TABLE Payment (
  payment_id CHAR(4) PRIMARY KEY,
  order_id   CHAR(4) NOT NULL UNIQUE,
  pay_date   DATE NOT NULL,
  pay_method ENUM('Cash','EFT','Card') NOT NULL,
  amount     DECIMAL(10,2) NOT NULL CHECK (amount > 0),
  FOREIGN KEY (order_id) REFERENCES Sales_Order(order_id)
);

CREATE TABLE Purchase_Order (
  po_id       CHAR(4) PRIMARY KEY,
  order_date  DATE NOT NULL CHECK (order_date <= CURDATE()),
  supplier_id CHAR(4) NOT NULL,
  total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount > 0),
  status      ENUM('Ordered','Received','Paid') NOT NULL DEFAULT 'Ordered',
  FOREIGN KEY (supplier_id) REFERENCES Supplier(supplier_id)
);

INSERT INTO Raw_Material VALUES
('M001','Cucumbers','kg',50.50,298,'S001'),
('M002','White Vinegar','L',21.50,677,'S002'),
('M003','Brown Vinegar','L',129.50,238,'S003'),
('M004','Chili Flakes','kg',45.50,807,'S004'),
('M005','Garlic Cloves','kg',103.50,861,'S005'),
('M006','Turmeric','kg',35.50,287,'S006'),
('M007','Mustard Seeds','kg',83.50,100,'S007'),
('M008','Black Pepper','kg',96.50,665,'S008'),
('M009','Coriander Seeds','kg',60.50,615,'S009'),
('M010','Bay Leaves','kg',125.50,775,'S010'),
('M011','Glass Jar 500ml','pcs',27.50,640,'S011'),
('M012','Glass Jar 750ml','pcs',20.50,653,'S012'),
('M013','Glass Jar 1L','pcs',82.50,368,'S013'),
('M014','Metal Lids','pcs',122.50,244,'S014'),
('M015','Labels','pcs',61.50,164,'S015'),
('M016','Carrots','kg',164.50,593,'S016'),
('M017','Cauliflower','kg',159.50,112,'S017'),
('M018','Red Onions','kg',98.50,677,'S018'),
('M019','Jalapeño Peppers','kg',100.50,314,'S019'),
('M020','Dill Herb','kg',62.50,452,'S020');

INSERT INTO Supplier VALUES
('S001','FreshFarm Cucumbers','Sipho Ngcobo','076 945 5433','Johannesburg','Gauteng'),
('S002','Vinegar King SA','Pieter Pretorius','071 450 9713','Soweto','Gauteng'),
('S003','Spice Delights','Thabo Pretorius','076 618 5657','Pretoria','Gauteng'),
('S004','JarWorld Distributors','Kagiso Pretorius','079 776 4028','Sandton','Gauteng'),
('S005','Karoo Veg Co','Sipho Khumalo','079 696 1412','Durban','KwaZulu-Natal'),
('S006','Limpopo Harvest','Sipho Pretorius','082 537 2443','Cape Town','Western Cape'),
('S007','Cape Brine Supplies','Naledi Maseko','078 200 8073','Gqeberha','Eastern Cape'),
('S008','Ubuntu Spices','Johan Mokoena','074 624 4911','Bloemfontein','Free State'),
('S009','GlassPack SA','Johan Mokoena','072 569 4169','Polokwane','Limpopo'),
('S010','Mzanzi Veg Farms','Pieter Mokoena','082 485 6720','Nelspruit','Mpumalanga'),
('S011','Highveld Vinegar Works','Pieter Khumalo','078 744 4133','Vereeniging','Gauteng'),
('S012','Bo-Kaap Spice House','Zanele Mokoena','072 648 3205','Germiston','Gauteng'),
('S013','Eastern Cape Produce','Lerato van der Merwe','071 299 7729','Benoni','Gauteng'),
('S014','Golden Harvest Veg','Naledi Ngcobo','083 571 1708','Midrand','Gauteng'),
('S015','African Aroma Spices','Naledi Maseko','082 238 5656','Pietermaritzburg','KwaZulu-Natal'),
('S016','Cradle Glassworks','Zanele Maseko','072 758 6796','East London','Eastern Cape'),
('S017','Free State Farms','Naledi Dlamini','072 118 4061','Kimberley','Northern Cape'),
('S018','Transvaal Vinegar Co','Kagiso Khumalo','072 448 2593','Rustenburg','North West'),
('S019','Durban Spice Market','Pieter Pretorius','076 281 1685','Krugersdorp','Gauteng'),
('S020','Karoo Preserve Co','Naledi Botha','078 795 2934','Centurion','Gauteng');

INSERT INTO Customer VALUES
('C001','PickleWorld Shop','Nomsa Zwane','081 986 2114','info@pickleworldshop'.co.za','Polokwane','Limpopo'),
('C002','RetailMart','Riaan Sithole','076 870 2595','info@retailmart'.co.za','Nelspruit','Mpumalanga'),
('C003','Fresh Foods Co','Ayanda Baloyi','083 312 7598','info@freshfoodsco'.co.za','Vereeniging','Gauteng'),
('C004','Urban Eats Deli','Refilwe Coetzee','082 954 3955','info@urbaneatsdeli'.co.za','Germiston','Gauteng'),
('C005','Soweto SuperSpar','Thandi Ferreira','079 961 1540','info@sowetosuperspar'.co.za','Benoni','Gauteng'),
('C006','Jozi Food Market','Nomsa Ferreira','081 750 7265','info@jozifoodmarket'.co.za','Midrand','Gauteng'),
('C007','Pretoria Pickle Palace','Thandi Oosthuizen','081 359 5079','info@pretoriapicklepalace'.co.za','Pietermaritzburg','KwaZulu-Natal'),
('C008','Durban Deli Co','Nomsa Coetzee','076 166 3585','info@durbandelico'.co.za','East London','Eastern Cape'),
('C009','Cape Gourmet Store','Riaan Mthembu','071 130 9171','info@capegourmetstore'.co.za','Kimberley','Northern Cape'),
('C010','Karoo Kiosk','Riaan Zwane','071 967 8974','info@karookiosk'.co.za','Rustenburg','North West'),
('C011','Checkers Local','Thandi Zwane','071 320 8421','info@checkerslocal'.co.za','Krugersdorp','Gauteng'),
('C012','Boxer Superstore','Nomsa Baloyi','082 540 3291','info@boxersuperstore'.co.za','Centurion','Gauteng'),
('C013','Food Lover’s Market JHB','Refilwe Mthembu','076 984 1149','info@foodloversmarketjhb'.co.za','Johannesburg','Gauteng'),
('C014','Woolies Corner Cafe','Chris Coetzee','073 966 6932','info@wooliescornercafe'.co.za','Soweto','Gauteng'),
('C015','Spar Northgate','Kevin Zwane','074 365 5550','info@sparnorthgate'.co.za','Pretoria','Gauteng'),
('C016','Picasso’s Pizzeria','Andre Mdluli','078 958 9353','info@picassospizzeria'.co.za','Sandton','Gauteng'),
('C017','Braai & Spice House','Palesa Baloyi','073 651 4121','info@braai&spicehouse'.co.za','Durban','KwaZulu-Natal'),
('C018','Mama’s Kitchen','Palesa Oosthuizen','078 995 2271','info@mamaskitchen'.co.za','Cape Town','Western Cape'),
('C019','The Hungry Hippo Diner','Chris Ferreira','073 187 1829','info@thehungryhippodiner'.co.za','Gqeberha','Eastern Cape'),
('C020','Township Tastes','Chris Mthembu','074 155 9481','info@townshiptastes'.co.za','Bloemfontein','Free State');

INSERT INTO Product VALUES
('FG001','Sweet Pickle 500ml',50.00,236),
('FG002','Spicy Pickle 500ml',55.00,281),
('FG003','Garlic Pickle 500ml',60.00,450),
('FG004','Mixed Veg Pickle 750ml',58.00,80),
('FG005','Chili Bomb Pickle 500ml',62.00,408),
('FG006','Dill Cucumber 500ml',52.00,102),
('FG007','Bread & Butter Pickle 750ml',56.00,196),
('FG008','Hot Jalapeño 500ml',64.00,598),
('FG009','Sweet & Sour 1L',95.00,132),
('FG010','Spicy Carrot 500ml',54.00,146),
('FG011','Garlic Chili 500ml',63.00,180),
('FG012','Mixed Veg 1L',92.00,148),
('FG013','Gherkin Mini 500ml',58.00,262),
('FG014','Curry Pickle 500ml',65.00,343),
('FG015','Beetroot Pickle 500ml',53.00,596),
('FG016','Onion Marmalade Pickle 500ml',61.00,390),
('FG017','Peri-Peri Pickle 500ml',66.00,400),
('FG018','Sweet Pepper 750ml',57.00,501),
('FG019','Green Chili 500ml',59.00,420),
('FG020','Sampler Gift Pack 4x250ml',120.00,409);

INSERT INTO Sales_Order VALUES
('O001','2025-10-22','C002','Delivered'),
('O002','2025-10-26','C017','Paid'),
('O003','2025-10-22','C010','Paid'),
('O004','2025-10-08','C008','Paid'),
('O005','2025-10-04','C011','Paid'),
('O006','2025-10-01','C011','Paid'),
('O007','2025-10-04','C015','Paid'),
('O008','2025-10-06','C006','Pending'),
('O009','2025-10-10','C014','Pending'),
('O010','2025-10-12','C005','Pending'),
('O011','2025-10-10','C008','Delivered'),
('O012','2025-10-20','C012','Paid'),
('O013','2025-10-15','C009','Delivered'),
('O014','2025-10-03','C005','Delivered'),
('O015','2025-10-25','C010','Delivered'),
('O016','2025-10-15','C002','Paid'),
('O017','2025-10-08','C005','Paid'),
('O018','2025-10-18','C016','Paid'),
('O019','2025-10-26','C006','Pending'),
('O020','2025-10-03','C011','Delivered'),
('O021','2025-10-13','C005','Pending'),
('O022','2025-10-14','C018','Paid');

INSERT INTO Order_Line VALUES
('O001','FG015',25,53.00),
('O001','FG020',15,120.00),
('O002','FG001',9,50.00),
('O002','FG003',11,60.00),
('O003','FG003',38,60.00),
('O003','FG007',32,56.00),
('O004','FG009',12,95.00),
('O004','FG005',39,62.00),
('O004','FG001',21,50.00),
('O005','FG008',23,64.00),
('O005','FG019',27,59.00),
('O005','FG007',30,56.00),
('O006','FG006',37,52.00),
('O006','FG013',29,58.00),
('O006','FG015',18,53.00),
('O007','FG008',16,64.00),
('O008','FG017',38,66.00),
('O008','FG009',4,95.00),
('O008','FG010',40,54.00),
('O009','FG020',37,120.00),
('O010','FG012',31,92.00),
('O011','FG004',16,58.00),
('O011','FG019',24,59.00),
('O012','FG012',10,92.00),
('O012','FG005',4,62.00),
('O013','FG020',8,120.00),
('O013','FG017',10,66.00),
('O013','FG010',34,54.00),
('O014','FG008',8,64.00),
('O014','FG013',25,58.00),
('O014','FG005',34,62.00),
('O015','FG009',12,95.00),
('O015','FG001',30,50.00),
('O015','FG019',23,59.00),
('O016','FG016',12,61.00),
('O017','FG020',18,120.00),
('O017','FG006',25,52.00),
('O017','FG004',9,58.00),
('O018','FG006',7,52.00),
('O018','FG020',34,120.00),
('O019','FG009',30,95.00),
('O019','FG015',22,53.00),
('O019','FG018',38,57.00),
('O020','FG008',5,64.00),
('O020','FG006',9,52.00),
('O021','FG003',35,60.00),
('O021','FG001',36,50.00),
('O022','FG011',8,63.00),
('O022','FG014',16,65.00);

INSERT INTO Payment VALUES
('P001','O001','2025-10-28','Cash',4621.00),
('P002','O002','2025-10-02','Card',5930.00),
('P003','O003','2025-10-20','Card',4779.00),
('P004','O004','2025-10-05','Card',5673.00),
('P005','O005','2025-10-13','Card',1882.00),
('P006','O006','2025-10-01','Card',6041.00),
('P007','O007','2025-10-18','EFT',2890.00),
('P008','O008','2025-10-15','EFT',7705.00),
('P009','O009','2025-10-22','Cash',7252.00),
('P010','O010','2025-10-03','Cash',752.00),
('P011','O011','2025-10-28','Cash',6671.00),
('P012','O012','2025-10-07','Cash',2099.00),
('P013','O013','2025-10-20','Card',3080.00),
('P014','O014','2025-10-10','Card',2096.00),
('P015','O015','2025-10-02','Cash',3612.00),
('P016','O016','2025-10-11','Cash',3278.00),
('P017','O017','2025-10-15','EFT',3012.00),
('P018','O018','2025-10-03','EFT',2156.00),
('P019','O019','2025-10-07','Cash',7211.00),
('P020','O020','2025-10-25','Card',8286.00);

INSERT INTO Purchase_Order VALUES
('PO001','2025-10-21','S009',11064.00,'Ordered'),
('PO002','2025-10-22','S012',9836.00,'Received'),
('PO003','2025-10-10','S003',19285.00,'Received'),
('PO004','2025-10-08','S005',7181.00,'Received'),
('PO005','2025-10-13','S005',3447.00,'Received'),
('PO006','2025-10-25','S012',1353.00,'Received'),
('PO007','2025-10-17','S020',17742.00,'Received'),
('PO008','2025-10-07','S001',7938.00,'Paid'),
('PO009','2025-10-24','S010',2455.00,'Paid'),
('PO010','2025-10-27','S016',4864.00,'Ordered'),
('PO011','2025-10-12','S008',4655.00,'Ordered'),
('PO012','2025-10-08','S012',14580.00,'Paid'),
('PO013','2025-10-05','S009',22548.00,'Paid'),
('PO014','2025-10-26','S020',16775.00,'Ordered'),
('PO015','2025-10-14','S004',12303.00,'Paid'),
('PO016','2025-10-09','S005',5016.00,'Received'),
('PO017','2025-10-08','S012',12413.00,'Ordered'),
('PO018','2025-10-09','S020',3289.00,'Ordered'),
('PO019','2025-10-10','S013',19199.00,'Paid'),
('PO020','2025-10-07','S007',5362.00,'Paid');

/* ---------- VIEWS ---------- */
CREATE OR REPLACE VIEW v_debtors AS
SELECT so.order_id, c.customer_name, c.city, SUM(ol.qty*ol.unit_price) AS owed
FROM Sales_Order so
JOIN Customer c    ON so.customer_id = c.customer_id
JOIN Order_Line ol ON so.order_id    = ol.order_id
LEFT JOIN Payment p ON so.order_id  = p.order_id
WHERE p.payment_id IS NULL
GROUP BY so.order_id, c.customer_name, c.city;

CREATE OR REPLACE VIEW v_daily_sales AS
SELECT so.order_date, SUM(ol.qty*ol.unit_price) AS daily_revenue
FROM Sales_Order so JOIN Order_Line ol ON so.order_id = ol.order_id
GROUP BY so.order_date;

--TRIGGER (BR-06, BR-10)
DELIMITER //
CREATE TRIGGER trg_stock_out AFTER INSERT ON Order_Line
FOR EACH ROW
UPDATE Product SET qty_in_stock = qty_in_stock - NEW.qty
WHERE product_id = NEW.product_id //

-- STORED PROCEDURE (BR-04) 
CREATE PROCEDURE sp_record_payment(IN p_payment CHAR(4), IN p_order CHAR(4),
                                   IN p_date DATE, IN p_method VARCHAR(10), IN p_amount DECIMAL(10,2))
BEGIN
  DECLARE owed DECIMAL(10,2);
  SELECT IFNULL(SUM(qty*unit_price),0) INTO owed FROM Order_Line WHERE order_id = p_order;
  IF owed = 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Order does not exist';
  ELSEIF p_amount <> owed THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Amount does not match order total';
  ELSE INSERT INTO Payment VALUES (p_payment, p_order, p_date, p_method, p_amount); END IF;
END //

-- FUNCTION
CREATE FUNCTION fn_order_total(p_order CHAR(4)) RETURNS DECIMAL(10,2)
DETERMINISTIC READS SQL DATA
BEGIN
  DECLARE total DECIMAL(10,2);
  SELECT IFNULL(SUM(qty*unit_price),0) INTO total FROM Order_Line WHERE order_id = p_order;
  RETURN total;
END //

DELIMITER ;

-- INDEXES 
CREATE INDEX idx_customer_name ON Customer(customer_name);
CREATE INDEX idx_line_product  ON Order_Line(product_id);
CREATE INDEX idx_order_date    ON Sales_Order(order_date);
CREATE INDEX idx_po_supplier   ON Purchase_Order(supplier_id);

-- VERIFICATION QUERIES
SELECT 'Supplier' AS tbl, COUNT(*) FROM Supplier UNION ALL SELECT 'Raw_Material', COUNT(*) FROM Raw_Material
UNION ALL SELECT 'Customer', COUNT(*) FROM Customer UNION ALL SELECT 'Product', COUNT(*) FROM Product
UNION ALL SELECT 'Sales_Order', COUNT(*) FROM Sales_Order UNION ALL SELECT 'Order_Line', COUNT(*) FROM Order_Line
UNION ALL SELECT 'Payment', COUNT(*) FROM Payment UNION ALL SELECT 'Purchase_Order', COUNT(*) FROM Purchase_Order;
