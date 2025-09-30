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

-- ========================================
-- TABLE: categories
-- Art categories/genres
-- ========================================
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    parent_category_id INT NULL, -- For subcategories
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id) ON DELETE SET NULL
);

-- ========================================
-- TABLE: artworks
-- Central table for all artworks
-- ========================================
CREATE TABLE artworks (
    artwork_id INT AUTO_INCREMENT PRIMARY KEY,
    artist_id INT NOT NULL,
    category_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    medium VARCHAR(100), -- e.g., Oil on Canvas, Digital, Watercolor
    dimensions VARCHAR(50), -- e.g., "24x36 inches"
    year_created YEAR,
    artwork_type ENUM('Original', 'Print', 'Digital', 'Sculpture', 'Mixed Media') NOT NULL,
    condition_status ENUM('Excellent', 'Good', 'Fair', 'Restored') DEFAULT 'Excellent',
    edition_number VARCHAR(50), -- For limited editions (e.g., "5/100")
    certificate_of_authenticity BOOLEAN DEFAULT FALSE,
    base_price DECIMAL(12,2) NOT NULL,
    current_price DECIMAL(12,2) NOT NULL,
    availability_status ENUM('Available', 'Reserved', 'Sold', 'In Auction', 'Not For Sale') DEFAULT 'Available',
    is_featured BOOLEAN DEFAULT FALSE,
    view_count INT DEFAULT 0,
    image_url VARCHAR(255),
    date_added DATE NOT NULL DEFAULT (CURRENT_DATE),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE RESTRICT,
    INDEX idx_artist (artist_id),
    INDEX idx_category (category_id),
    INDEX idx_availability (availability_status),
    INDEX idx_price (current_price)
);

-- ========================================
-- TABLE: galleries
-- Physical or virtual gallery spaces
-- ========================================
CREATE TABLE galleries (
    gallery_id INT AUTO_INCREMENT PRIMARY KEY,
    gallery_name VARCHAR(150) UNIQUE NOT NULL,
    gallery_type ENUM('Physical', 'Virtual', 'Hybrid') NOT NULL,
    address_line1 VARCHAR(150),
    address_line2 VARCHAR(150),
    city VARCHAR(50),
    country VARCHAR(50) NOT NULL,
    postal_code VARCHAR(20),
    phone VARCHAR(20),
    email VARCHAR(100),
    website_url VARCHAR(255),
    capacity INT, -- Maximum artworks or visitors
    description TEXT,
    opening_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
