CREATE DATABASE  IF NOT EXISTS `restaurant_db` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `restaurant_db`;
-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: restaurant_db
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `customers`
--

DROP TABLE IF EXISTS `customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customers` (
  `customers_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  `phone` varchar(15) DEFAULT NULL,
  PRIMARY KEY (`customers_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customers`
--

LOCK TABLES `customers` WRITE;
/*!40000 ALTER TABLE `customers` DISABLE KEYS */;
INSERT INTO `customers` VALUES (1,'Salviyas Sojan','9120381218'),(2,'Hari Dev','9456732687'),(3,'Shajune','8249345627'),(4,'Anu Joseph','9000000004'),(5,'Meera Das','9000000005'),(6,'Aparna','9345712316'),(7,'nandana','9827557812'),(8,'navya','8127355634'),(9,'Walk-in Customer','0000000000'),(10,'Kiran','9188606248');
/*!40000 ALTER TABLE `customers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `menu`
--

DROP TABLE IF EXISTS `menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `menu` (
  `item_id` int NOT NULL AUTO_INCREMENT,
  `item_name` varchar(100) NOT NULL,
  `price` decimal(8,2) NOT NULL,
  PRIMARY KEY (`item_id`),
  CONSTRAINT `chk_price` CHECK ((`price` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menu`
--

LOCK TABLES `menu` WRITE;
/*!40000 ALTER TABLE `menu` DISABLE KEYS */;
INSERT INTO `menu` VALUES (1,'Chicken Biriyani',250.00),(2,'Masala Tea',35.00),(3,'parotta',20.00),(4,'Gulab Jamun',70.00),(5,'Fresh Lime Soda',50.00),(6,'Veg Fried Rice',160.00),(7,'Veg Cutlet',40.00),(9,'water',20.00),(10,'7-UP',40.00),(11,'pepsi',40.00),(12,'Dragon Chilly',270.00),(13,'Loaded Fries',210.00);
/*!40000 ALTER TABLE `menu` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `log_price_change` AFTER UPDATE ON `menu` FOR EACH ROW BEGIN
    IF OLD.price <> NEW.price THEN
        INSERT INTO price_log (item_id, old_price, new_price)
        VALUES (OLD.item_id, OLD.price, NEW.price);
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Temporary view structure for view `order_bills`
--

DROP TABLE IF EXISTS `order_bills`;
/*!50001 DROP VIEW IF EXISTS `order_bills`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `order_bills` AS SELECT 
 1 AS `order_id`,
 1 AS `name`,
 1 AS `order_date`,
 1 AS `waiter`,
 1 AS `table_no`,
 1 AS `bill_amount`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `order_items`
--

DROP TABLE IF EXISTS `order_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_items` (
  `order_items_id` int NOT NULL AUTO_INCREMENT,
  `order_id` int DEFAULT NULL,
  `item_id` int DEFAULT NULL,
  `quantity` int DEFAULT NULL,
  `unit_price` decimal(8,2) NOT NULL,
  PRIMARY KEY (`order_items_id`),
  KEY `order_id` (`order_id`),
  KEY `item_id` (`item_id`),
  CONSTRAINT `order_items_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`),
  CONSTRAINT `order_items_ibfk_2` FOREIGN KEY (`item_id`) REFERENCES `menu` (`item_id`),
  CONSTRAINT `chk_quantity` CHECK ((`quantity` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_items`
--

LOCK TABLES `order_items` WRITE;
/*!40000 ALTER TABLE `order_items` DISABLE KEYS */;
INSERT INTO `order_items` VALUES (1,1,1,1,250.00),(2,1,5,1,50.00),(3,1,4,1,70.00),(4,1,7,2,40.00),(5,2,1,1,250.00),(6,2,2,1,35.00),(7,2,4,1,70.00),(8,3,6,1,160.00),(9,3,5,1,50.00),(10,4,1,2,250.00),(11,4,4,1,70.00),(12,4,2,1,35.00),(13,5,1,1,250.00),(14,5,4,2,70.00),(15,5,5,1,50.00),(16,5,9,1,20.00),(17,6,3,3,20.00),(18,6,4,2,70.00),(19,6,11,1,40.00),(20,6,12,1,270.00);
/*!40000 ALTER TABLE `order_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_items_backup`
--

DROP TABLE IF EXISTS `order_items_backup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_items_backup` (
  `order_items_id` int NOT NULL DEFAULT '0',
  `order_id` int DEFAULT NULL,
  `item_id` int DEFAULT NULL,
  `quantity` int DEFAULT NULL,
  `unit_price` decimal(8,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_items_backup`
--

LOCK TABLES `order_items_backup` WRITE;
/*!40000 ALTER TABLE `order_items_backup` DISABLE KEYS */;
INSERT INTO `order_items_backup` VALUES (1,1,1,1,250.00),(2,1,2,2,30.00),(3,1,3,3,20.00),(4,2,1,2,250.00),(5,2,3,4,20.00),(6,3,2,3,30.00),(7,3,3,2,20.00),(8,4,4,2,70.00),(9,4,5,2,50.00),(10,5,6,1,160.00),(11,5,2,2,30.00),(12,6,1,1,250.00),(13,6,3,5,20.00),(14,7,1,2,250.00),(15,8,1,1,250.00),(16,9,1,1,250.00),(17,10,2,1,35.00),(18,11,1,1,250.00),(19,12,2,1,40.00),(20,13,5,2,50.00),(21,14,1,2,250.00),(22,14,5,2,50.00),(23,14,4,1,70.00);
/*!40000 ALTER TABLE `order_items_backup` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `order_id` int NOT NULL AUTO_INCREMENT,
  `customers_id` int DEFAULT NULL,
  `order_date` date DEFAULT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'Pending',
  `waiter_id` int DEFAULT NULL,
  `table_no` int DEFAULT NULL,
  PRIMARY KEY (`order_id`),
  KEY `customers_id` (`customers_id`),
  KEY `idx_order_date` (`order_date`),
  KEY `fk_orders_waiter` (`waiter_id`),
  CONSTRAINT `fk_orders_waiter` FOREIGN KEY (`waiter_id`) REFERENCES `waiters` (`waiter_id`),
  CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`customers_id`) REFERENCES `customers` (`customers_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES (1,6,'2026-11-22','Served',1,2),(2,1,'2026-11-22','Served',3,1),(3,2,'2026-11-22','Served',2,3),(4,9,'2026-11-22','Served',3,NULL),(5,10,'2026-11-22','Pending',5,2),(6,10,'2026-11-22','Pending',5,4);
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders_backup`
--

DROP TABLE IF EXISTS `orders_backup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders_backup` (
  `order_id` int NOT NULL DEFAULT '0',
  `customers_id` int DEFAULT NULL,
  `order_date` date DEFAULT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'Pending',
  `waiter_id` int DEFAULT NULL,
  `table_no` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders_backup`
--

LOCK TABLES `orders_backup` WRITE;
/*!40000 ALTER TABLE `orders_backup` DISABLE KEYS */;
INSERT INTO `orders_backup` VALUES (1,2,'2026-11-17','Served',NULL,NULL),(2,1,'2026-11-18','Served',NULL,NULL),(3,3,'2026-11-19','Pending',NULL,NULL),(4,2,'2026-11-19','Pending',NULL,NULL),(5,1,'2026-11-19','Pending',NULL,NULL),(6,4,'2026-11-19','Pending',NULL,NULL),(7,5,'2026-11-22','Pending',NULL,NULL),(8,1,'2026-11-22','Pending',NULL,NULL),(9,1,'2026-11-22','Pending',NULL,NULL),(10,1,'2026-11-22','Pending',NULL,NULL),(11,1,'2026-11-22','Pending',NULL,NULL),(12,2,'2026-11-22','Pending',NULL,NULL),(13,6,'2026-11-22','Pending',NULL,NULL),(14,6,'2026-11-22','Pending',1,2);
/*!40000 ALTER TABLE `orders_backup` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `price_log`
--

DROP TABLE IF EXISTS `price_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `price_log` (
  `log_id` int NOT NULL AUTO_INCREMENT,
  `item_id` int DEFAULT NULL,
  `old_price` decimal(8,2) DEFAULT NULL,
  `new_price` decimal(8,2) DEFAULT NULL,
  `changed_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`log_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `price_log`
--

LOCK TABLES `price_log` WRITE;
/*!40000 ALTER TABLE `price_log` DISABLE KEYS */;
INSERT INTO `price_log` VALUES (1,2,30.00,35.00,'2026-11-22 11:25:04'),(2,2,35.00,40.00,'2026-11-22 13:58:18'),(3,2,40.00,35.00,'2026-11-22 13:59:32');
/*!40000 ALTER TABLE `price_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `waiters`
--

DROP TABLE IF EXISTS `waiters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `waiters` (
  `waiter_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `phone` varchar(15) DEFAULT NULL,
  PRIMARY KEY (`waiter_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `waiters`
--

LOCK TABLES `waiters` WRITE;
/*!40000 ALTER TABLE `waiters` DISABLE KEYS */;
INSERT INTO `waiters` VALUES (1,'Sivadas',NULL),(2,'Aswin',NULL),(3,'Adhil',NULL),(4,'Abin',NULL),(5,'Online',NULL);
/*!40000 ALTER TABLE `waiters` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'restaurant_db'
--

--
-- Dumping routines for database 'restaurant_db'
--
/*!50003 DROP PROCEDURE IF EXISTS `place_order` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `place_order`(IN p_customer INT, IN p_item INT, IN p_qty INT)
BEGIN
    DECLARE v_order INT;

    INSERT INTO orders (customers_id, order_date)
    VALUES (p_customer, CURDATE());
    SET v_order = LAST_INSERT_ID();

    INSERT INTO order_items (order_id, item_id, quantity, unit_price)
    SELECT v_order, p_item, p_qty, price
    FROM menu
    WHERE item_id = p_item;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `order_bills`
--

/*!50001 DROP VIEW IF EXISTS `order_bills`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `order_bills` AS select `orders`.`order_id` AS `order_id`,`customers`.`name` AS `name`,`orders`.`order_date` AS `order_date`,coalesce(`waiters`.`name`,'-') AS `waiter`,`orders`.`table_no` AS `table_no`,sum((`order_items`.`quantity` * `order_items`.`unit_price`)) AS `bill_amount` from (((`orders` join `customers` on((`orders`.`customers_id` = `customers`.`customers_id`))) left join `waiters` on((`orders`.`waiter_id` = `waiters`.`waiter_id`))) join `order_items` on((`orders`.`order_id` = `order_items`.`order_id`))) group by `orders`.`order_id`,`customers`.`name`,`orders`.`order_date`,`waiters`.`name`,`orders`.`table_no` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-11-22 21:54:28
