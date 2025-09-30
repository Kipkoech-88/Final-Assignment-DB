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


-- ========================================
-- TABLE: exhibitions
-- Art exhibitions and shows
-- ========================================
CREATE TABLE exhibitions (
    exhibition_id INT AUTO_INCREMENT PRIMARY KEY,
    gallery_id INT NOT NULL,
    exhibition_name VARCHAR(200) NOT NULL,
    theme VARCHAR(150),
    description TEXT,
    curator_name VARCHAR(100),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    opening_hours VARCHAR(100), -- e.g., "Mon-Fri: 9AM-6PM"
    ticket_price DECIMAL(8,2) DEFAULT 0.00,
    max_visitors INT,
    total_visitors INT DEFAULT 0,
    status ENUM('Upcoming', 'Active', 'Completed', 'Cancelled') DEFAULT 'Upcoming',
    is_virtual BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (gallery_id) REFERENCES galleries(gallery_id) ON DELETE CASCADE,
    CHECK (end_date >= start_date),
    INDEX idx_dates (start_date, end_date),
    INDEX idx_status (status)
);

-- ========================================
-- TABLE: exhibition_artworks
-- Many-to-Many relationship between exhibitions and artworks
-- ========================================
CREATE TABLE exhibition_artworks (
    exhibition_artwork_id INT AUTO_INCREMENT PRIMARY KEY,
    exhibition_id INT NOT NULL,
    artwork_id INT NOT NULL,
    display_order INT DEFAULT 1,
    special_notes TEXT,
    added_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (exhibition_id) REFERENCES exhibitions(exhibition_id) ON DELETE CASCADE,
    FOREIGN KEY (artwork_id) REFERENCES artworks(artwork_id) ON DELETE CASCADE,
    UNIQUE KEY unique_exhibition_artwork (exhibition_id, artwork_id)
);

-- ========================================
-- TABLE: auctions
-- Auction events for artworks
-- ========================================
CREATE TABLE auctions (
    auction_id INT AUTO_INCREMENT PRIMARY KEY,
    artwork_id INT UNIQUE NOT NULL,
    auction_title VARCHAR(200) NOT NULL,
    starting_bid DECIMAL(12,2) NOT NULL,
    reserve_price DECIMAL(12,2), -- Minimum acceptable price
    current_bid DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    bid_increment DECIMAL(8,2) NOT NULL DEFAULT 100.00,
    total_bids INT DEFAULT 0,
    start_datetime DATETIME NOT NULL,
    end_datetime DATETIME NOT NULL,
    auction_type ENUM('Live', 'Online', 'Silent') DEFAULT 'Online',
    auction_status ENUM('Scheduled', 'Active', 'Completed', 'Cancelled') DEFAULT 'Scheduled',
    winner_customer_id INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (artwork_id) REFERENCES artworks(artwork_id) ON DELETE CASCADE,
    FOREIGN KEY (winner_customer_id) REFERENCES customers(customer_id) ON DELETE SET NULL,
    CHECK (end_datetime > start_datetime),
    CHECK (current_bid >= starting_bid),
    INDEX idx_dates (start_datetime, end_datetime),
    INDEX idx_status (auction_status)
);

-- ========================================
-- TABLE: bids
-- Individual bids placed on auctions
-- ========================================
CREATE TABLE bids (
    bid_id INT AUTO_INCREMENT PRIMARY KEY,
    auction_id INT NOT NULL,
    customer_id INT NOT NULL,
    bid_amount DECIMAL(12,2) NOT NULL,
    bid_datetime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_winning_bid BOOLEAN DEFAULT FALSE,
    bid_status ENUM('Active', 'Outbid', 'Won', 'Withdrawn') DEFAULT 'Active',
    notes TEXT,
    FOREIGN KEY (auction_id) REFERENCES auctions(auction_id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    INDEX idx_auction_customer (auction_id, customer_id),
    INDEX idx_bid_amount (bid_amount DESC)
);

-- ========================================
-- TABLE: sales
-- Direct sales and auction wins
-- ========================================
CREATE TABLE sales (
    sale_id INT AUTO_INCREMENT PRIMARY KEY,
    artwork_id INT NOT NULL,
    customer_id INT NOT NULL,
    artist_id INT NOT NULL,
    sale_type ENUM('Direct Purchase', 'Auction Win', 'Commission') NOT NULL,
    sale_price DECIMAL(12,2) NOT NULL,
    commission_rate DECIMAL(5,2) DEFAULT 15.00, -- Platform commission %
    commission_amount DECIMAL(12,2) GENERATED ALWAYS AS (sale_price * commission_rate / 100) STORED,
    artist_earnings DECIMAL(12,2) GENERATED ALWAYS AS (sale_price - (sale_price * commission_rate / 100)) STORED,
    sale_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    payment_method ENUM('Credit Card', 'Bank Transfer', 'PayPal', 'Cryptocurrency', 'Wire Transfer') NOT NULL,
    payment_status ENUM('Pending', 'Completed', 'Failed', 'Refunded') DEFAULT 'Pending',
    transaction_id VARCHAR(100) UNIQUE,
    shipping_required BOOLEAN DEFAULT TRUE,
    shipping_status ENUM('Not Shipped', 'Processing', 'Shipped', 'Delivered', 'Returned') DEFAULT 'Not Shipped',
    tracking_number VARCHAR(100),
    delivery_date DATE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (artwork_id) REFERENCES artworks(artwork_id) ON DELETE RESTRICT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE RESTRICT,
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id) ON DELETE RESTRICT,
    INDEX idx_customer (customer_id),
    INDEX idx_artist (artist_id),
    INDEX idx_sale_date (sale_date),
    INDEX idx_payment_status (payment_status)
);

-- ========================================
-- TABLE: reviews
-- Customer reviews for artworks and artists
-- ========================================
CREATE TABLE reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    artwork_id INT NOT NULL,
    customer_id INT NOT NULL,
    rating INT NOT NULL,
    review_title VARCHAR(150),
    review_text TEXT,
    review_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    is_verified_purchase BOOLEAN DEFAULT FALSE,
    helpful_count INT DEFAULT 0,
    is_approved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (artwork_id) REFERENCES artworks(artwork_id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    CHECK (rating BETWEEN 1 AND 5),
    UNIQUE KEY unique_customer_artwork_review (customer_id, artwork_id),
    INDEX idx_artwork_rating (artwork_id, rating)
);

-- ========================================
-- TABLE: wishlist
-- Customer wishlist for artworks
-- ========================================
CREATE TABLE wishlist (
    wishlist_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    artwork_id INT NOT NULL,
    added_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    notes TEXT,
    notify_on_discount BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (artwork_id) REFERENCES artworks(artwork_id) ON DELETE CASCADE,
    UNIQUE KEY unique_customer_artwork (customer_id, artwork_id),
    INDEX idx_customer (customer_id)
);

-- ========================================
-- TABLE: artist_followers
-- Customers following artists
-- ========================================
CREATE TABLE artist_followers (
    follower_id INT AUTO_INCREMENT PRIMARY KEY,
    artist_id INT NOT NULL,
    customer_id INT NOT NULL,
    follow_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    notification_enabled BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    UNIQUE KEY unique_artist_customer (artist_id, customer_id),
    INDEX idx_artist (artist_id)
);

-- ========================================
-- TABLE: commissions
-- Custom artwork commission requests
-- ========================================
CREATE TABLE commissions (
    commission_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    artist_id INT NOT NULL,
    commission_title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    budget_min DECIMAL(12,2),
    budget_max DECIMAL(12,2),
    preferred_medium VARCHAR(100),
    dimensions VARCHAR(50),
    deadline_date DATE,
    commission_status ENUM('Requested', 'Under Review', 'Accepted', 'In Progress', 'Completed', 'Rejected', 'Cancelled') DEFAULT 'Requested',
    agreed_price DECIMAL(12,2),
    request_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    completion_date DATE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id) ON DELETE CASCADE,
    CHECK (budget_max >= budget_min),
    INDEX idx_status (commission_status),
    INDEX idx_artist (artist_id)
);

-- ========================================
-- TABLE: messages
-- Communication between customers and artists
-- ========================================
CREATE TABLE messages (
    message_id INT AUTO_INCREMENT PRIMARY KEY,
    sender_type ENUM('Customer', 'Artist', 'Admin') NOT NULL,
    sender_id INT NOT NULL, -- References customer_id or artist_id
    receiver_type ENUM('Customer', 'Artist', 'Admin') NOT NULL,
    receiver_id INT NOT NULL,
    subject VARCHAR(200),
    message_text TEXT NOT NULL,
    related_artwork_id INT NULL,
    related_commission_id INT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    sent_datetime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    read_datetime DATETIME NULL,
    FOREIGN KEY (related_artwork_id) REFERENCES artworks(artwork_id) ON DELETE SET NULL,
    FOREIGN KEY (related_commission_id) REFERENCES commissions(commission_id) ON DELETE SET NULL,
    INDEX idx_receiver (receiver_type, receiver_id, is_read),
    INDEX idx_sent_date (sent_datetime)
);

-- ========================================
-- TABLE: payment_methods
-- Customer saved payment methods (One-to-Many)
-- ========================================
CREATE TABLE payment_methods (
    payment_method_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    payment_type ENUM('Credit Card', 'Debit Card', 'Bank Account', 'PayPal') NOT NULL,
    card_last_four CHAR(4),
    card_brand VARCHAR(20), -- Visa, Mastercard, etc.
    expiry_month INT,
    expiry_year INT,
    billing_address VARCHAR(200),
    is_default BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    added_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    INDEX idx_customer (customer_id),
    CHECK (expiry_month BETWEEN 1 AND 12)
);

-- ========================================
-- TABLE: artwork_tags
-- Tags for categorizing artworks
-- ========================================
CREATE TABLE tags (
    tag_id INT AUTO_INCREMENT PRIMARY KEY,
    tag_name VARCHAR(50) UNIQUE NOT NULL,
    usage_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);