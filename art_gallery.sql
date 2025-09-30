-- ========================================
-- DIGITAL ART GALLERY & AUCTION PLATFORM
-- Database Management System
-- ========================================
-- A comprehensive system for managing digital art galleries,
-- artists, artworks, exhibitions, auctions, and customer transactions
-- ========================================

-- Create and use the database
DROP DATABASE IF EXISTS digital_art_gallery;
CREATE DATABASE digital_art_gallery;
USE digital_art_gallery;

-- ========================================
-- TABLE: artists
-- Stores information about artists
-- ========================================
CREATE TABLE artists (
    artist_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    artist_name VARCHAR(100) UNIQUE NOT NULL, -- Professional/stage name
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    country VARCHAR(50) NOT NULL,
    city VARCHAR(50),
    biography TEXT,
    specialization VARCHAR(100), -- e.g., Abstract, Portrait, Sculpture
    join_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    verification_status ENUM('Pending', 'Verified', 'Rejected') DEFAULT 'Pending',
    total_artworks_sold INT DEFAULT 0,
    average_rating DECIMAL(3,2) DEFAULT 0.00,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ========================================
-- TABLE: customers
-- Stores customer/buyer information
-- ========================================
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address_line1 VARCHAR(150),
    address_line2 VARCHAR(150),
    city VARCHAR(50),
    state_province VARCHAR(50),
    country VARCHAR(50) NOT NULL,
    postal_code VARCHAR(20),
    date_of_birth DATE,
    membership_tier ENUM('Bronze', 'Silver', 'Gold', 'Platinum') DEFAULT 'Bronze',
    total_purchases INT DEFAULT 0,
    total_spent DECIMAL(12,2) DEFAULT 0.00,
    registration_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);