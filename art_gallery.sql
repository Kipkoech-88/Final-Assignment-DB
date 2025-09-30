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

-- ========================================
-- TABLE: artwork_tags (Many-to-Many junction table)
-- Links artworks with tags
-- ========================================
CREATE TABLE artwork_tags (
    artwork_tag_id INT AUTO_INCREMENT PRIMARY KEY,
    artwork_id INT NOT NULL,
    tag_id INT NOT NULL,
    added_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (artwork_id) REFERENCES artworks(artwork_id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES tags(tag_id) ON DELETE CASCADE,
    UNIQUE KEY unique_artwork_tag (artwork_id, tag_id)
);

-- ========================================
-- TABLE: shipping_addresses
-- Customer shipping addresses (One-to-Many)
-- ========================================
CREATE TABLE shipping_addresses (
    address_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    address_label VARCHAR(50), -- e.g., "Home", "Office"
    recipient_name VARCHAR(100) NOT NULL,
    address_line1 VARCHAR(150) NOT NULL,
    address_line2 VARCHAR(150),
    city VARCHAR(50) NOT NULL,
    state_province VARCHAR(50),
    country VARCHAR(50) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    phone VARCHAR(20),
    is_default BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    INDEX idx_customer (customer_id)
);

-- ========================================
-- TABLE: artist_social_media
-- Artist social media profiles (One-to-Many)
-- ========================================
CREATE TABLE artist_social_media (
    social_id INT AUTO_INCREMENT PRIMARY KEY,
    artist_id INT NOT NULL,
    platform VARCHAR(50) NOT NULL, -- Instagram, Twitter, Facebook, etc.
    profile_url VARCHAR(255) NOT NULL,
    follower_count INT DEFAULT 0,
    is_verified BOOLEAN DEFAULT FALSE,
    added_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id) ON DELETE CASCADE,
    UNIQUE KEY unique_artist_platform (artist_id, platform)
);

-- ========================================
-- TABLE: exhibition_tickets
-- Tickets for physical exhibitions (One-to-Many)
-- ========================================
CREATE TABLE exhibition_tickets (
    ticket_id INT AUTO_INCREMENT PRIMARY KEY,
    exhibition_id INT NOT NULL,
    customer_id INT NOT NULL,
    ticket_type ENUM('General', 'VIP', 'Student', 'Group', 'Complimentary') NOT NULL,
    ticket_price DECIMAL(8,2) NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    purchase_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    visit_date DATE,
    ticket_code VARCHAR(50) UNIQUE NOT NULL,
    is_used BOOLEAN DEFAULT FALSE,
    payment_status ENUM('Pending', 'Paid', 'Refunded') DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (exhibition_id) REFERENCES exhibitions(exhibition_id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    CHECK (quantity > 0),
    INDEX idx_exhibition (exhibition_id),
    INDEX idx_customer (customer_id)
);


-- ========================================
-- SAMPLE DATA INSERTION
-- ========================================

-- Insert Categories
INSERT INTO categories (category_name, description, parent_category_id) VALUES
('Abstract', 'Non-representational art focusing on colors, shapes, and forms', NULL),
('Portrait', 'Artwork depicting people', NULL),
('Landscape', 'Natural scenery depictions', NULL),
('Digital Art', 'Computer-generated or digitally created artwork', NULL),
('Sculpture', 'Three-dimensional artworks', NULL),
('Contemporary', 'Modern art from late 20th century onwards', 1),
('Impressionism', 'Art characterized by visible brush strokes and light', 3);

-- Insert Artists
INSERT INTO artists (first_name, last_name, artist_name, email, phone, country, city, biography, specialization, verification_status) VALUES
('Elena', 'Martinez', 'Elena Martinez', 'elena.martinez@artmail.com', '+1-555-0101', 'Spain', 'Barcelona', 'Award-winning contemporary artist known for vibrant abstract compositions', 'Abstract', 'Verified'),
('James', 'Chen', 'J.Chen Arts', 'james.chen@artmail.com', '+1-555-0102', 'USA', 'New York', 'Digital artist specializing in surreal landscapes and futuristic themes', 'Digital Art', 'Verified'),
('Sophie', 'Dubois', 'Sophie D.', 'sophie.dubois@artmail.com', '+33-555-0103', 'France', 'Paris', 'Classical portrait artist with modern techniques', 'Portrait', 'Verified'),
('Raj', 'Kumar', 'Raj Kumar Studio', 'raj.kumar@artmail.com', '+91-555-0104', 'India', 'Mumbai', 'Sculptor working with bronze and mixed media', 'Sculpture', 'Pending'),
('Maria', 'Silva', 'Maria Silva Art', 'maria.silva@artmail.com', '+55-555-0105', 'Brazil', 'Rio de Janeiro', 'Landscape painter inspired by tropical environments', 'Landscape', 'Verified');

-- Insert Customers
INSERT INTO customers (first_name, last_name, email, phone, city, country, membership_tier) VALUES
('Robert', 'Johnson', 'robert.j@email.com', '+1-555-1001', 'Los Angeles', 'USA', 'Gold'),
('Emma', 'Williams', 'emma.w@email.com', '+44-555-1002', 'London', 'UK', 'Silver'),
('Lucas', 'Brown', 'lucas.b@email.com', '+61-555-1003', 'Sydney', 'Australia', 'Bronze'),
('Isabella', 'Garcia', 'isabella.g@email.com', '+34-555-1004', 'Madrid', 'Spain', 'Platinum'),
('Yuki', 'Tanaka', 'yuki.t@email.com', '+81-555-1005', 'Tokyo', 'Japan', 'Gold');

-- Insert Galleries
INSERT INTO galleries (gallery_name, gallery_type, city, country, phone, email, opening_date) VALUES
('Modern Arts Gallery', 'Physical', 'New York', 'USA', '+1-555-2001', 'info@modernarts.com', '2015-06-15'),
('Virtual Canvas', 'Virtual', 'Online', 'International', '+1-555-2002', 'contact@virtualcanvas.com', '2020-01-10'),
('European Fine Arts', 'Hybrid', 'Paris', 'France', '+33-555-2003', 'hello@europeanfinearts.fr', '2010-03-20');

-- Insert Artworks
INSERT INTO artworks (artist_id, category_id, title, description, medium, dimensions, year_created, artwork_type, base_price, current_price, availability_status, is_featured) VALUES
(1, 1, 'Crimson Dreams', 'A vibrant abstract piece exploring the boundaries of color', 'Acrylic on Canvas', '36x48 inches', 2024, 'Original', 5500.00, 5500.00, 'Available', TRUE),
(2, 4, 'Digital Horizons', 'Futuristic cityscape with neon elements', 'Digital Print', '24x36 inches', 2024, 'Print', 1200.00, 1200.00, 'Available', TRUE),
(3, 2, 'Portrait of Elegance', 'Classical portrait with modern color palette', 'Oil on Canvas', '30x40 inches', 2023, 'Original', 8500.00, 8500.00, 'Available', FALSE),
(4, 5, 'Bronze Warrior', 'Contemporary sculpture depicting strength', 'Bronze', '24 inches tall', 2024, 'Sculpture', 15000.00, 15000.00, 'Available', TRUE),
(5, 3, 'Tropical Sunset', 'Vibrant landscape of Brazilian coastline', 'Watercolor', '20x30 inches', 2024, 'Original', 3200.00, 3200.00, 'Available', FALSE),
(1, 6, 'Abstract Emotions', 'Contemporary exploration of human feelings through color', 'Mixed Media', '40x50 inches', 2024, 'Original', 6800.00, 6800.00, 'In Auction', TRUE),
(2, 4, 'Cyber City Nights', 'Limited edition digital artwork', 'Digital Print', '30x40 inches', 2024, 'Print', 1800.00, 1800.00, 'Available', FALSE);

-- Insert Tags
INSERT INTO tags (tag_name) VALUES
('vibrant'), ('modern'), ('colorful'), ('minimalist'), ('expressive'), 
('geometric'), ('nature'), ('urban'), ('emotional'), ('futuristic');

-- Insert Artwork Tags
INSERT INTO artwork_tags (artwork_id, tag_id) VALUES
(1, 1), (1, 2), (1, 5),
(2, 8), (2, 10), (2, 2),
(3, 9), (3, 4),
(4, 2), (4, 6),
(5, 1), (5, 7),
(6, 1), (6, 5), (6, 9),
(7, 8), (7, 10);


-- Insert Exhibitions
INSERT INTO exhibitions (gallery_id, exhibition_name, theme, description, curator_name, start_date, end_date, ticket_price, status) VALUES
(1, 'Colors of Emotion', 'Abstract Expressionism', 'Exploring human emotions through abstract art', 'Dr. Sarah Mitchell', '2025-02-01', '2025-03-31', 25.00, 'Upcoming'),
(2, 'Digital Revolution', 'Future of Art', 'Celebrating digital artistry and innovation', 'Michael Zhang', '2024-11-01', '2025-01-31', 0.00, 'Active'),
(3, 'Classical Meets Modern', 'Art Evolution', 'Bridging traditional and contemporary techniques', 'Pierre Rousseau', '2025-03-15', '2025-05-15', 30.00, 'Upcoming');

-- Insert Exhibition Artworks
INSERT INTO exhibition_artworks (exhibition_id, artwork_id, display_order) VALUES
(1, 1, 1), (1, 6, 2),
(2, 2, 1), (2, 7, 2),
(3, 3, 1), (3, 5, 2);

-- Insert Auctions
INSERT INTO auctions (artwork_id, auction_title, starting_bid, reserve_price, current_bid, start_datetime, end_datetime, auction_type, auction_status) VALUES
(6, 'Abstract Emotions - Live Auction', 5000.00, 6500.00, 5500.00, '2025-10-15 10:00:00', '2025-10-15 14:00:00', 'Live', 'Scheduled');

-- Insert Bids
INSERT INTO bids (auction_id, customer_id, bid_amount, is_winning_bid, bid_status) VALUES
(1, 1, 5000.00, FALSE, 'Outbid'),
(1, 4, 5500.00, TRUE, 'Active');

-- Insert Sales
INSERT INTO sales (artwork_id, customer_id, artist_id, sale_type, sale_price, payment_method, payment_status) VALUES
(3, 4, 3, 'Direct Purchase', 8500.00, 'Bank Transfer', 'Completed'),
(5, 2, 5, 'Direct Purchase', 3200.00, 'Credit Card', 'Completed');

-- Insert Reviews
INSERT INTO reviews (artwork_id, customer_id, rating, review_title, review_text, is_verified_purchase, is_approved) VALUES
(3, 4, 5, 'Absolutely Stunning!', 'The portrait exceeded my expectations. The detail and color work are exceptional.', TRUE, TRUE),
(5, 2, 4, 'Beautiful Landscape', 'Lovely watercolor with vibrant colors. Perfect for my living room.', TRUE, TRUE);

-- Insert Wishlist
INSERT INTO wishlist (customer_id, artwork_id, notes) VALUES
(1, 1, 'Waiting for salary to purchase'),
(2, 4, 'Perfect for office entrance'),
(3, 2, 'Interested in digital art collection');

-- Insert Artist Followers
INSERT INTO artist_followers (artist_id, customer_id) VALUES
(1, 1), (1, 4),
(2, 1), (2, 3),
(3, 4), (3, 2),
(5, 2);

-- Insert Commissions
INSERT INTO commissions (customer_id, artist_id, commission_title, description, budget_min, budget_max, preferred_medium, commission_status) VALUES
(1, 1, 'Custom Abstract for Office', 'Looking for a large abstract piece with blue and gold tones', 4000.00, 6000.00, 'Acrylic on Canvas', 'Under Review'),
(5, 2, 'Digital Portrait', 'Digital artwork of my family in futuristic style', 2000.00, 3000.00, 'Digital', 'Accepted');

-- Insert Payment Methods
INSERT INTO payment_methods (customer_id, payment_type, card_last_four, card_brand, expiry_month, expiry_year, is_default) VALUES
(1, 'Credit Card', '4532', 'Visa', 12, 2027, TRUE),
(2, 'Credit Card', '5412', 'Mastercard', 8, 2026, TRUE),
(4, 'PayPal', NULL, NULL, NULL, NULL, TRUE),
(5, 'Credit Card', '3782', 'Amex', 6, 2028, TRUE);

-- Insert Shipping Addresses
INSERT INTO shipping_addresses (customer_id, address_label, recipient_name, address_line1, city, state_province, country, postal_code, phone, is_default) VALUES
(1, 'Home', 'Robert Johnson', '456 Sunset Boulevard', 'Los Angeles', 'California', 'USA', '90028', '+1-555-1001', TRUE),
(2, 'Office', 'Emma Williams', '78 Baker Street', 'London', NULL, 'UK', 'W1U 6AG', '+44-555-1002', TRUE),
(4, 'Home', 'Isabella Garcia', 'Calle Mayor 25', 'Madrid', NULL, 'Spain', '28013', '+34-555-1004', TRUE),
(5, 'Home', 'Yuki Tanaka', 'Shibuya 2-21-1', 'Tokyo', NULL, 'Japan', '150-0002', '+81-555-1005', TRUE);

-- Insert Artist Social Media
INSERT INTO artist_social_media (artist_id, platform, profile_url, follower_count, is_verified) VALUES
(1, 'Instagram', 'https://instagram.com/elenamartinezart', 125000, TRUE),
(1, 'Twitter', 'https://twitter.com/elenamartinezart', 45000, FALSE),
(2, 'Instagram', 'https://instagram.com/jchenarts', 89000, TRUE),
(2, 'Behance', 'https://behance.net/jameschen', 34000, TRUE),
(3, 'Instagram', 'https://instagram.com/sophiedart', 67000, TRUE),
(5, 'Instagram', 'https://instagram.com/mariasilvaart', 52000, FALSE);

-- Insert Exhibition Tickets
INSERT INTO exhibition_tickets (exhibition_id, customer_id, ticket_type, ticket_price, quantity, ticket_code, payment_status) VALUES
(1, 1, 'General', 25.00, 2, 'TICK-2025-001', 'Paid'),
(1, 4, 'VIP', 50.00, 1, 'TICK-2025-002', 'Paid'),
(2, 2, 'General', 0.00, 1, 'TICK-2025-003', 'Paid'),
(3, 5, 'General', 30.00, 3, 'TICK-2025-004', 'Pending');

-- Insert Messages
INSERT INTO messages (sender_type, sender_id, receiver_type, receiver_id, subject, message_text, related_artwork_id, is_read) VALUES
('Customer', 1, 'Artist', 1, 'Question about Crimson Dreams', 'Hi Elena, I love your work! Is this piece available for viewing in person?', 1, TRUE),
('Artist', 1, 'Customer', 1, 'Re: Question about Crimson Dreams', 'Thank you! Yes, it will be on display at the Colors of Emotion exhibition in February. You are welcome to view it there.', 1, FALSE),
('Customer', 4, 'Artist', 3, 'Thank you for the portrait', 'Sophie, the Portrait of Elegance arrived safely. It is absolutely beautiful and looks perfect in my home. Thank you so much!', 3, TRUE),
('Customer', 1, 'Artist', 1, 'Commission Discussion', 'Hi Elena, I would like to discuss the custom abstract piece for my office. When can we schedule a consultation?', NULL, FALSE);
