-- MySQL dump 10.13  Distrib 8.0.42, for Win64 (x86_64)
--
-- Host: localhost    Database: parkflow
-- ------------------------------------------------------
-- Server version	8.0.42

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `aimodel`
--

DROP TABLE IF EXISTS `aimodel`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `aimodel` (
  `model_id` int NOT NULL AUTO_INCREMENT,
  `model_name` varchar(255) NOT NULL,
  `version` varchar(50) NOT NULL,
  `trained_at` timestamp NOT NULL,
  `accuracy` float NOT NULL,
  `is_active` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`model_id`),
  UNIQUE KEY `unique_model_version` (`model_name`,`version`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_trained_at` (`trained_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `aimodel`
--

LOCK TABLES `aimodel` WRITE;
/*!40000 ALTER TABLE `aimodel` DISABLE KEYS */;
/*!40000 ALTER TABLE `aimodel` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cancellationrequest`
--

DROP TABLE IF EXISTS `cancellationrequest`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cancellationrequest` (
  `id` int NOT NULL AUTO_INCREMENT,
  `reservation_id` int NOT NULL,
  `user_id` int NOT NULL,
  `vehicle_id` int NOT NULL,
  `reason` varchar(255) DEFAULT NULL,
  `status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `requested_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `processed_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `reservation_id` (`reservation_id`),
  KEY `user_id` (`user_id`),
  KEY `vehicle_id` (`vehicle_id`),
  CONSTRAINT `cancellationrequest_ibfk_1` FOREIGN KEY (`reservation_id`) REFERENCES `reservation` (`reservation_id`) ON DELETE CASCADE,
  CONSTRAINT `cancellationrequest_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `cancellationrequest_ibfk_3` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicle` (`vehicle_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cancellationrequest`
--

LOCK TABLES `cancellationrequest` WRITE;
/*!40000 ALTER TABLE `cancellationrequest` DISABLE KEYS */;
/*!40000 ALTER TABLE `cancellationrequest` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `location`
--

DROP TABLE IF EXISTS `location`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `location` (
  `location_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `address` text NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `hourly_rate` decimal(10,2) NOT NULL DEFAULT '150.00',
  `created_by` int DEFAULT NULL,
  PRIMARY KEY (`location_id`),
  KEY `fk_location_created_by` (`created_by`),
  CONSTRAINT `fk_location_created_by` FOREIGN KEY (`created_by`) REFERENCES `user` (`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `location`
--

LOCK TABLES `location` WRITE;
/*!40000 ALTER TABLE `location` DISABLE KEYS */;
/*!40000 ALTER TABLE `location` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notification`
--

DROP TABLE IF EXISTS `notification`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notification` (
  `notification_id` int NOT NULL AUTO_INCREMENT,
  `message` text NOT NULL,
  `type` varchar(50) NOT NULL,
  `status` enum('unread','read') NOT NULL DEFAULT 'unread',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `user_id` int NOT NULL,
  PRIMARY KEY (`notification_id`),
  KEY `idx_user_status` (`user_id`,`status`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `notification_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=62 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notification`
--

LOCK TABLES `notification` WRITE;
/*!40000 ALTER TABLE `notification` DISABLE KEYS */;
INSERT INTO `notification` VALUES (2,'Driver signup successful','success','unread','2025-10-01 12:53:30',1),(3,'Login successful','success','unread','2025-10-01 14:03:03',1),(4,'Login successful','success','unread','2025-10-01 14:10:35',1),(5,'Login successful','success','unread','2025-10-01 14:17:53',1),(6,'Login successful','success','unread','2025-10-01 14:22:29',1),(7,'Login successful','success','unread','2025-10-01 14:28:27',1),(8,'Login successful','success','unread','2025-10-01 14:31:34',1),(9,'Password reset requested','security','unread','2025-10-01 15:32:02',1),(10,'Password reset code verified','success','unread','2025-10-01 15:32:34',1),(11,'Password reset requested','security','unread','2025-10-01 15:44:18',1),(12,'Password reset code verified','success','unread','2025-10-01 15:44:43',1),(13,'Login successful','success','unread','2025-10-01 15:46:54',1),(14,'Password reset requested','security','unread','2025-10-01 15:47:15',1),(15,'Password reset code verified','success','unread','2025-10-01 15:47:29',1),(16,'Password reset requested','security','unread','2025-10-01 15:51:13',1),(17,'Password reset code verified','success','unread','2025-10-01 15:51:37',1),(18,'Password reset requested','security','unread','2025-10-01 16:35:35',1),(19,'Password reset code verified','success','unread','2025-10-01 16:36:06',1),(20,'Password reset requested','security','unread','2025-10-01 16:40:48',1),(21,'Password reset code verified','success','unread','2025-10-01 16:41:03',1),(22,'Password reset requested','security','unread','2025-10-01 16:43:20',1),(23,'Password reset code verified','success','unread','2025-10-01 16:43:42',1),(24,'Password reset requested','security','unread','2025-10-01 16:50:35',1),(25,'Password reset code verified','success','unread','2025-10-01 16:50:50',1),(26,'Password reset code verified','success','unread','2025-10-01 16:51:08',1),(27,'Password reset requested','security','unread','2025-10-01 16:55:17',1),(28,'Password reset code verified','success','unread','2025-10-01 16:55:35',1),(29,'Password reset code verified','success','unread','2025-10-01 16:55:52',1),(30,'Password reset successfully','success','unread','2025-10-01 16:55:52',1),(31,'Login successful','success','unread','2025-10-02 02:41:56',1),(32,'Login successful','success','unread','2025-10-02 02:45:15',1),(33,'Login successful','success','unread','2025-10-02 04:24:56',1),(34,'Login successful','success','unread','2025-10-02 04:34:09',1),(35,'Login successful','success','unread','2025-10-02 04:51:30',1),(36,'Login successful','success','unread','2025-10-02 05:09:03',1),(37,'Login successful','success','unread','2025-10-02 05:22:31',1),(38,'Login successful','success','unread','2025-10-02 05:28:44',1),(39,'Login successful','success','unread','2025-10-02 05:38:33',1),(40,'Login successful','success','unread','2025-10-02 05:44:51',1),(41,'Login successful','success','unread','2025-10-02 05:48:55',1),(42,'Failed login attempt detected','security','unread','2025-10-02 05:57:16',1),(43,'Login successful','success','unread','2025-10-02 05:57:26',1),(44,'Failed login attempt detected','security','unread','2025-10-02 06:46:54',1),(45,'Login successful','success','unread','2025-10-02 06:47:04',1),(46,'Login successful','success','unread','2025-10-02 06:52:26',1),(47,'Login successful','success','unread','2025-10-02 07:11:10',1),(48,'Login successful','success','unread','2025-10-02 07:38:27',1),(49,'Your profile was updated successfully','info','unread','2025-10-02 07:38:53',1),(50,'Login successful','success','unread','2025-10-02 07:56:41',1),(51,'Login successful','success','unread','2025-10-02 09:46:17',1),(52,'Your profile was updated successfully','info','unread','2025-10-02 09:46:43',1),(53,'Your profile was updated successfully','info','unread','2025-10-02 09:46:56',1),(54,'Your profile was updated successfully','info','unread','2025-10-02 09:47:04',1),(55,'Your profile was updated successfully','info','unread','2025-10-02 09:53:12',1),(56,'Login successful','success','unread','2025-10-02 10:29:00',1),(57,'Login successful','success','unread','2025-10-02 10:35:23',1),(58,'Failed login attempt detected','security','unread','2025-10-02 10:53:01',1),(59,'Login successful','success','unread','2025-10-02 10:53:10',1),(60,'Login successful','success','unread','2025-10-02 12:22:05',1),(61,'Login successful','success','unread','2025-10-02 12:27:32',1);
/*!40000 ALTER TABLE `notification` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `parkinglot`
--

DROP TABLE IF EXISTS `parkinglot`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `parkinglot` (
  `parking_lot_id` int NOT NULL AUTO_INCREMENT,
  `lot_name` varchar(255) NOT NULL,
  `location_id` int NOT NULL,
  `total_slots` int NOT NULL DEFAULT '0',
  `available_slots` int NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`parking_lot_id`),
  KEY `idx_location` (`location_id`),
  KEY `idx_available_slots` (`available_slots`),
  CONSTRAINT `parkinglot_ibfk_1` FOREIGN KEY (`location_id`) REFERENCES `location` (`location_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `parkinglot`
--

LOCK TABLES `parkinglot` WRITE;
/*!40000 ALTER TABLE `parkinglot` DISABLE KEYS */;
/*!40000 ALTER TABLE `parkinglot` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `parkingslot`
--

DROP TABLE IF EXISTS `parkingslot`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `parkingslot` (
  `parking_slot_id` int NOT NULL AUTO_INCREMENT,
  `slot_number` varchar(50) NOT NULL,
  `slot_type` varchar(50) NOT NULL,
  `status` enum('available','occupied','maintenance','reserved') NOT NULL DEFAULT 'available',
  `parking_lot_id` int NOT NULL,
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`parking_slot_id`),
  UNIQUE KEY `unique_slot_per_lot` (`parking_lot_id`,`slot_number`),
  KEY `idx_status` (`status`),
  KEY `idx_slot_type` (`slot_type`),
  KEY `fk_parkingslot_created_by` (`created_by`),
  CONSTRAINT `fk_parkingslot_created_by` FOREIGN KEY (`created_by`) REFERENCES `user` (`user_id`) ON DELETE SET NULL,
  CONSTRAINT `parkingslot_ibfk_1` FOREIGN KEY (`parking_lot_id`) REFERENCES `parkinglot` (`parking_lot_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `parkingslot`
--

LOCK TABLES `parkingslot` WRITE;
/*!40000 ALTER TABLE `parkingslot` DISABLE KEYS */;
/*!40000 ALTER TABLE `parkingslot` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `qrcode`
--

DROP TABLE IF EXISTS `qrcode`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `qrcode` (
  `qr_id` int NOT NULL AUTO_INCREMENT,
  `code_data` text NOT NULL,
  `generated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `expires_at` datetime NOT NULL,
  `is_scanned` tinyint(1) DEFAULT '0',
  `scanned_at` timestamp NULL DEFAULT NULL,
  `reservation_id` int NOT NULL,
  PRIMARY KEY (`qr_id`),
  KEY `idx_expires_at` (`expires_at`),
  KEY `idx_is_scanned` (`is_scanned`),
  KEY `idx_reservation` (`reservation_id`),
  CONSTRAINT `qrcode_ibfk_1` FOREIGN KEY (`reservation_id`) REFERENCES `reservation` (`reservation_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `qrcode`
--

LOCK TABLES `qrcode` WRITE;
/*!40000 ALTER TABLE `qrcode` DISABLE KEYS */;
/*!40000 ALTER TABLE `qrcode` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reservation`
--

DROP TABLE IF EXISTS `reservation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reservation` (
  `reservation_id` int NOT NULL AUTO_INCREMENT,
  `date` date NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `status` enum('pending','confirmed','active','completed','cancelled') NOT NULL DEFAULT 'pending',
  `user_id` int NOT NULL,
  `vehicle_id` int NOT NULL,
  `actual_entry` datetime DEFAULT NULL,
  `actual_exit` datetime DEFAULT NULL,
  `parking_slot_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`reservation_id`),
  KEY `vehicle_id` (`vehicle_id`),
  KEY `parking_slot_id` (`parking_slot_id`),
  KEY `idx_user_date` (`user_id`,`date`),
  KEY `idx_status` (`status`),
  KEY `idx_date_time` (`date`,`start_time`,`end_time`),
  CONSTRAINT `reservation_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `reservation_ibfk_2` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicle` (`vehicle_id`) ON DELETE CASCADE,
  CONSTRAINT `reservation_ibfk_3` FOREIGN KEY (`parking_slot_id`) REFERENCES `parkingslot` (`parking_slot_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reservation`
--

LOCK TABLES `reservation` WRITE;
/*!40000 ALTER TABLE `reservation` DISABLE KEYS */;
/*!40000 ALTER TABLE `reservation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password_hash` char(60) NOT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `profile_picture` text,
  `role` enum('admin','driver') NOT NULL DEFAULT 'admin',
  `status` enum('active','inactive') NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_email` (`email`),
  KEY `idx_role` (`role`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (1,'Shenara De Silva','shenarades03@gmail.com','$2b$12$0IBlZtIsNwTU3nswv4KBtOjPnDxt1MyB/owhWoJ5l0dBZx7tEbXL.','+94774103987',NULL,'driver','active','2025-10-01 12:53:30','2025-10-01 16:55:52');
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usersession`
--

DROP TABLE IF EXISTS `usersession`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usersession` (
  `session_id` int NOT NULL AUTO_INCREMENT,
  `token` text NOT NULL,
  `expiry` datetime NOT NULL,
  `user_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`session_id`),
  KEY `idx_expiry` (`expiry`),
  KEY `idx_user_id` (`user_id`),
  CONSTRAINT `usersession_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usersession`
--

LOCK TABLES `usersession` WRITE;
/*!40000 ALTER TABLE `usersession` DISABLE KEYS */;
INSERT INTO `usersession` VALUES (25,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwicm9sZSI6ImRyaXZlciIsImV4cCI6MTc1OTQxMTY1Mn0.zKGT9Ife6g94MN1ECBWnYch3JGlPy6_ePZal2jF-EKc','2025-10-02 13:27:33',1,'2025-10-02 12:27:32');
/*!40000 ALTER TABLE `usersession` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vehicle`
--

DROP TABLE IF EXISTS `vehicle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vehicle` (
  `vehicle_id` int NOT NULL AUTO_INCREMENT,
  `plate_number` varchar(50) NOT NULL,
  `type` varchar(50) NOT NULL,
  `user_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`vehicle_id`),
  UNIQUE KEY `plate_number` (`plate_number`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_plate_number` (`plate_number`),
  CONSTRAINT `vehicle_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vehicle`
--

LOCK TABLES `vehicle` WRITE;
/*!40000 ALTER TABLE `vehicle` DISABLE KEYS */;
INSERT INTO `vehicle` VALUES (4,'CAB-2254','Car',1,'2025-10-01 12:53:30');
/*!40000 ALTER TABLE `vehicle` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `waitlist`
--

DROP TABLE IF EXISTS `waitlist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `waitlist` (
  `waitlist_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `vehicle_id` int NOT NULL,
  `parking_slot_id` int DEFAULT NULL,
  `requested_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` enum('pending','notified','cancelled') NOT NULL DEFAULT 'pending',
  `priority` enum('High','Medium','Low') NOT NULL DEFAULT 'Medium',
  `notified_at` timestamp NULL DEFAULT NULL,
  `reservation_id` int DEFAULT NULL,
  PRIMARY KEY (`waitlist_id`),
  KEY `user_id` (`user_id`),
  KEY `vehicle_id` (`vehicle_id`),
  KEY `parking_slot_id` (`parking_slot_id`),
  KEY `fk_waitlist_reservation` (`reservation_id`),
  CONSTRAINT `fk_waitlist_reservation` FOREIGN KEY (`reservation_id`) REFERENCES `reservation` (`reservation_id`) ON DELETE SET NULL,
  CONSTRAINT `waitlist_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `waitlist_ibfk_2` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicle` (`vehicle_id`) ON DELETE CASCADE,
  CONSTRAINT `waitlist_ibfk_3` FOREIGN KEY (`parking_slot_id`) REFERENCES `parkingslot` (`parking_slot_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `waitlist`
--

LOCK TABLES `waitlist` WRITE;
/*!40000 ALTER TABLE `waitlist` DISABLE KEYS */;
/*!40000 ALTER TABLE `waitlist` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-10-02 17:57:33
