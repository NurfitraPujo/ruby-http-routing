CREATE USER 'ruby_dev'@'localhost' IDENTIFIED BY 'rubydev';

CREATE SCHEMA IF NOT EXISTS food_oms_db;

GRANT ALL ON food_oms_db.* to 'ruby_dev'@'localhost';

CREATE TABLE IF NOT EXISTS food_oms_db.items (
    id int(11) UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
    nama varchar(50) NOT NULL,
    price int DEFAULT 0
);
    
CREATE TABLE IF NOT EXISTS food_oms_db.categories (
    id int(11) UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
    category varchar(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS food_oms_db.item_categories (
    item_id int(11) UNSIGNED,
    category_id int(11) UNSIGNED,
    PRIMARY KEY(item_id, category_id),
    FOREIGN KEY (item_id)
    	REFERENCES items(id)
    	ON UPDATE CASCADE
    	ON DELETE RESTRICT,
    FOREIGN KEY (category_id)
    	REFERENCES categories(id)
    	ON UPDATE CASCADE
    	ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS food_oms_db.customer (
	id int(11) UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
	name varchar(100) NOT NULL,
	no_hp varchar(14) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS food_oms_db.cashier (
	id int(11) UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
	name varchar(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS food_oms_db.order (
	id int(11) UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
	customer_id int(11) UNSIGNED NOT NULL,
	cashier_id int(11) UNSIGNED NOT NULL,
	order_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	total_nominal decimal(14,2) NOT NULL,
	FOREIGN KEY (customer_id)
		REFERENCES customer(id)
    	ON UPDATE CASCADE
    	ON DELETE RESTRICT,
    FOREIGN KEY (cashier_id)
		REFERENCES cashier(id)
    	ON UPDATE CASCADE
    	ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS food_oms_db.order_details (
   id int(11) UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
   item_id int(11) UNSIGNED NOT NULL,
   order_id int(11) UNSIGNED NOT NULL,
   amount int NOT NULL DEFAULT 1,
   FOREIGN KEY (item_id)
		REFERENCES items(id)
    	ON UPDATE CASCADE
    	ON DELETE RESTRICT,
    FOREIGN KEY (order_id)
		REFERENCES food_oms_db.order(id)
    	ON UPDATE CASCADE
    	ON DELETE RESTRICT
);

INSERT INTO food_oms_db.categories (category) VALUES
	('main dish'),
	('beverage'),
	('dessert'),
	('snacks'),
	('chineese cuisine');
	 
INSERT INTO food_oms_db.items (nama,price) VALUES
	 ('Nasi Goreng Gila',25000),
	 ('Ice Water',2000),
	 ('Spaghetti',40000),
	 ('Green Tea Latte',18000),
	 ('Orange Juice',15000),
	 ('Vanilla Ice Cream',13000),
	 ('Cordon Bleu',36000),
	 ('French Fries',20000),
	 ('Kwetiaw', 15000),
	 ('Noodles', 15000),
	 ('Doughnut', 5000);
	
INSERT INTO food_oms_db.item_categories (item_id,category_id) VALUES
	 (1,1),
	 (2,2),
	 (3,1),
	 (4,2),
	 (5,2),
	 (6,3),
	 (7,1),
	 (8,4),
	 (9,5),
	 (10,5),
	 (11,4);
	
INSERT INTO food_oms_db.customer (name, no_hp) 
VALUES ('Nurfitra', '08711374111'),
	('Pujo', '08200011123'),
	('Santiko', '08571272212'),
	('Made', '082173177373'),
	('Riani', '089212124212');

INSERT INTO food_oms_db.cashier (name)
VALUES ('Rina'),
	('Rini'),
	('Yanti'),
	('Andi'),
	('Putra');

INSERT INTO food_oms_db.`order` (cashier_id, customer_id, total_nominal)
VALUES (1, 1, 17000),
	(1, 2, 28000),
	(2,3, 55000),
	(3, 5, 27000),
	(4, 4, 10000);
	 
INSERT INTO food_oms_db.order_details (item_id, order_id, amount)
VALUES (10, 1, 1),
	(2, 1, 1),
	(4, 2, 1),
	(11, 2, 2),
	(3, 3, 1),
	(4, 3, 1),
	(2, 4, 1),
	(10, 4, 1),
	(11, 4, 2),
	(11, 5, 2);

-- SELECT o.id as 'Order id', DATE(o.order_date) as 'Order date', 
-- 	c.name as 'Customer name', c.no_hp as 'Customer phone', o.total_nominal as 'Total' , 
-- 	GROUP_CONCAT(DISTINCT i.nama separator ", ") as 'Item bought'
-- FROM `order` o 
-- JOIN customer c on o.customer_id = c.id 
-- JOIN order_details od on o.id = od.order_id 
-- JOIN items i on od.item_id = i.id 
-- GROUP BY o.id;
