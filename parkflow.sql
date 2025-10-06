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
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notification`
--

LOCK TABLES `notification` WRITE;
/*!40000 ALTER TABLE `notification` DISABLE KEYS */;
INSERT INTO `notification` VALUES (1,'Signup successful','success','unread','2025-10-05 10:55:07',1),(2,'Login successful','success','unread','2025-10-05 10:55:21',1),(3,'Driver signup successful','success','read','2025-10-05 15:30:32',2),(4,'Failed login attempt detected','security','read','2025-10-05 15:31:22',2),(5,'Login successful','success','read','2025-10-05 15:31:30',2),(6,'Login successful','success','read','2025-10-05 16:54:16',2),(7,'Login successful','success','read','2025-10-05 16:58:16',2),(8,'Login successful','success','read','2025-10-05 17:04:38',2),(9,'Login successful','success','read','2025-10-05 17:40:40',2),(10,'Login successful','success','read','2025-10-05 17:44:31',2),(11,'Login successful','success','read','2025-10-05 18:01:05',2),(12,'Login successful','success','read','2025-10-06 02:11:15',2),(13,'Login successful','success','read','2025-10-06 02:21:05',2),(14,'Login successful','success','read','2025-10-06 02:23:51',2),(15,'Login successful','success','read','2025-10-06 02:28:55',2),(16,'Login successful','success','read','2025-10-06 02:55:26',2),(17,'Login successful','success','read','2025-10-06 02:59:38',2),(18,'Login successful','success','read','2025-10-06 03:10:54',2),(19,'Login successful','success','read','2025-10-06 03:18:39',2),(20,'Login successful','success','read','2025-10-06 03:30:59',2),(21,'Login successful','success','read','2025-10-06 03:57:02',2),(22,'Login successful','success','read','2025-10-06 05:19:36',1),(23,'Login successful','success','read','2025-10-06 05:43:54',1),(24,'Login successful','success','unread','2025-10-06 06:23:36',1),(25,'Login successful','success','read','2025-10-06 06:55:52',1),(26,'Failed login attempt detected','security','unread','2025-10-06 07:58:25',1),(27,'Login successful','success','unread','2025-10-06 07:59:02',1),(33,'Failed login attempt detected','security','unread','2025-10-06 09:33:15',1),(34,'Login successful','success','unread','2025-10-06 09:33:32',1),(35,'You have successfully deleted user Sadishi','info','unread','2025-10-06 09:33:52',1),(39,'You have successfully deleted user Sahani','info','unread','2025-10-06 09:53:30',1),(40,'Failed login attempt detected','security','unread','2025-10-06 12:13:03',1),(41,'Login successful','success','unread','2025-10-06 12:13:18',1);
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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (1,'Navodya Fernando','fernandonavodya3@gmail.com','$2b$12$v5f6IoMlL5oh3KebQSyxLum0ZKg34Muig7WkxRLBObttHLzV.x5bq','+94766017197',NULL,'admin','active','2025-10-05 10:55:07','2025-10-06 07:53:47'),(2,'Shenara De Silva','shenarades03@gmail.com','$2b$12$kKR1Vt3I1vCcGO4HQpSfxuYqD9.HAWGfMvedlZCujCyoq/YCoowzW','+94774103987',NULL,'driver','active','2025-10-05 15:30:31','2025-10-05 15:30:31');
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
INSERT INTO `usersession` VALUES (1,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwicm9sZSI6ImFkbWluIiwiZXhwIjoxNzU5NjY1MzIwfQ.4V9g-NQtD0ofsLTEqSpp2oZzKREYm-2CNGkptiS6CNc','2025-10-05 11:55:21',1,'2025-10-05 10:55:20'),(2,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwicm9sZSI6ImRyaXZlciIsImV4cCI6MTc1OTY4MTg5MH0.vMPxjrHF8gXnW_NScxrtnHx3bN1Oxp6TZZy7xvEGhEc','2025-10-05 16:31:31',2,'2025-10-05 15:31:30'),(3,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwicm9sZSI6ImRyaXZlciIsImV4cCI6MTc1OTY4Njg1Nn0.QvBYYkq4-SrKCGsiyYvJsYa9u7wFePNXfNHaQ4UPBqI','2025-10-05 17:54:16',2,'2025-10-05 16:54:16'),(4,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwicm9sZSI6ImRyaXZlciIsImV4cCI6MTc1OTY4NzA5NX0.Z3u3i2Zvh-NuIAvYwYD26ezmeGqXeG1MDt-okAZy7w4','2025-10-05 17:58:16',2,'2025-10-05 16:58:15'),(5,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwicm9sZSI6ImRyaXZlciIsImV4cCI6MTc1OTY4NzQ3OH0.Vdx2qrRG_HFBrUKeZzUP2CCNS2aa9WDOcelc9qT4KC8','2025-10-05 18:04:38',2,'2025-10-05 17:04:38'),(6,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwicm9sZSI6ImRyaXZlciIsImV4cCI6MTc1OTY4OTY0MH0.KcwUuiSbbQ6ntATjPM93pmX6tUl1wOeOAvS4D2u6xBY','2025-10-05 18:40:41',2,'2025-10-05 17:40:40'),(7,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwicm9sZSI6ImRyaXZlciIsImV4cCI6MTc1OTY4OTg3MX0.pUtpi9pzXuJkqH-hV8q1nmCL463laQyYeI6mv6Ldg9s','2025-10-05 18:44:31',2,'2025-10-05 17:44:31'),(8,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwicm9sZSI6ImRyaXZlciIsImV4cCI6MTc1OTY5MDg2NX0.tGbLqmbMaeREnTwwMR_mgeCRJrUL15B9t1pc0bkWXjU','2025-10-05 19:01:05',2,'2025-10-05 18:01:05'),(9,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwicm9sZSI6ImRyaXZlciIsImV4cCI6MTc1OTcyMDI3NX0.ZLbPL3riJEYqgWq72X2ZIPM2tpSM3irYjBGsjPSu_2o','2025-10-06 03:11:15',2,'2025-10-06 02:11:15'),(10,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwicm9sZSI6ImRyaXZlciIsImV4cCI6MTc1OTcyMDg2NX0.197QaAnn-kDW27f2xn5mhyVf_F77bbL20_Q-GywNKpM','2025-10-06 03:21:06',2,'2025-10-06 02:21:05'),(11,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwicm9sZSI6ImRyaXZlciIsImV4cCI6MTc1OTcyMTAzMX0.QmI-fUJwFbizlppqIQbmdUcvmltxeuWLUGgcEsJGfXo','2025-10-06 03:23:51',2,'2025-10-06 02:23:51'),(12,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwicm9sZSI6ImRyaXZlciIsImV4cCI6MTc1OTcyMTMzNX0.CA0GynQR_zXiuxbjsKto8B72y3OPuJRZ1kQvh3AZRbE','2025-10-06 03:28:55',2,'2025-10-06 02:28:55'),(13,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwicm9sZSI6ImRyaXZlciIsImV4cCI6MTc1OTcyMjkyNn0.rm_tVtukBt_DmcAjG31fHvC96icFnBw-CK4tHwgRaSM','2025-10-06 03:55:26',2,'2025-10-06 02:55:26'),(14,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwicm9sZSI6ImRyaXZlciIsImV4cCI6MTc1OTcyMzE3OH0.93BhSPKxBrj01jqsI0B2IdzQ74Pn6YvIByecK7FxwqE','2025-10-06 03:59:38',2,'2025-10-06 02:59:38'),(15,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwicm9sZSI6ImRyaXZlciIsImV4cCI6MTc1OTcyMzg1NH0.lPxi72rjBj8HCyhanW8g5iH7urbQr4RhJagMYO6af5I','2025-10-06 04:10:54',2,'2025-10-06 03:10:54'),(16,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwicm9sZSI6ImRyaXZlciIsImV4cCI6MTc1OTcyNDMxOX0.M_KT3yMJejvQBkrIKkXE8fJ7aVqHwu0tVQ8aOXFjCdA','2025-10-06 04:18:40',2,'2025-10-06 03:18:39'),(17,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwicm9sZSI6ImRyaXZlciIsImV4cCI6MTc1OTcyNTA1OX0.LGU3mbXZxy32vcXIuOuEvHwZIRuoU-dnX9kqBTbQlHU','2025-10-06 04:31:00',2,'2025-10-06 03:30:59'),(18,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwicm9sZSI6ImRyaXZlciIsImV4cCI6MTc1OTcyNjYyMX0.l1QoN4gzsoU4llEbBKpop_Pltq_HIIw3rc5BDa-1HVc','2025-10-06 04:57:02',2,'2025-10-06 03:57:01'),(19,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwicm9sZSI6ImFkbWluIiwiZXhwIjoxNzU5NzMxNTc2fQ.8d91lavNT_9cPShvmRLHIX62mxIYBXFho8Xd-JWl7Lk','2025-10-06 06:19:36',1,'2025-10-06 05:19:36'),(20,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwicm9sZSI6ImFkbWluIiwiZXhwIjoxNzU5NzMzMDM0fQ.3NCKUNqMFUY6KhGSXGSEwiqcpzustjQciH9ll_3FYuk','2025-10-06 06:43:55',1,'2025-10-06 05:43:54'),(21,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwicm9sZSI6ImFkbWluIiwiZXhwIjoxNzU5NzM1NDE2fQ.6Qk1fOcVvQm6zz1Qq77ZcJa9AdpdSAf1tM_TuiJvr64','2025-10-06 07:23:36',1,'2025-10-06 06:23:36'),(22,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwicm9sZSI6ImFkbWluIiwiZXhwIjoxNzU5NzM3MzUyfQ.4qTwPgo-Hywsr0Ax9YRdpMQUn6-URIRZep4eeqR30r8','2025-10-06 07:55:53',1,'2025-10-06 06:55:52'),(23,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwicm9sZSI6ImFkbWluIiwiZXhwIjoxNzU5NzQxMTQyfQ.xwY9C3cveDlTc8hFVwXLOs06qFV0GvACvBIniGuJLF0','2025-10-06 08:59:02',1,'2025-10-06 07:59:02'),(24,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwicm9sZSI6ImFkbWluIiwiZXhwIjoxNzU5NzQ2ODEyfQ.WkAC0PwYcxvF-QqIg5cjKiI91Yht-s1ocOitlzJDSbA','2025-10-06 10:33:32',1,'2025-10-06 09:33:32'),(25,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwicm9sZSI6ImFkbWluIiwiZXhwIjoxNzU5NzU2Mzk4fQ.Jla29c0uGubAJWcXc6HRjoHqAdL4JmO4wkrS81HgiX0','2025-10-06 13:13:18',1,'2025-10-06 12:13:18');
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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vehicle`
--

LOCK TABLES `vehicle` WRITE;
/*!40000 ALTER TABLE `vehicle` DISABLE KEYS */;
INSERT INTO `vehicle` VALUES (1,'CAB-2254','Car',2,'2025-10-05 15:30:31');
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

-- Dump completed on 2025-10-06 17:43:18
