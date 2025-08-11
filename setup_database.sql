-- setup_database.sql
-- Script untuk membuat database dan tabel untuk portofolio

-- Membuat database
CREATE DATABASE IF NOT EXISTS portfolio_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

-- Menggunakan database
USE portfolio_db;

-- Tabel untuk menyimpan pesan kontak
CREATE TABLE IF NOT EXISTS contact_messages (
    id INT(11) NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL,
    subject VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    ip_address VARCHAR(45) DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('new', 'read', 'replied') DEFAULT 'new',
    PRIMARY KEY (id),
    INDEX idx_created_at (created_at),
    INDEX idx_status (status),
    INDEX idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabel untuk menyimpan informasi proyek (opsional)
CREATE TABLE IF NOT EXISTS projects (
    id INT(11) NOT NULL AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    technologies VARCHAR(500),
    image_url VARCHAR(255),
    demo_url VARCHAR(255),
    github_url VARCHAR(255),
    status ENUM('development', 'completed', 'maintenance') DEFAULT 'development',
    featured BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX idx_status (status),
    INDEX idx_featured (featured)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert contoh data proyek
INSERT INTO projects (title, description, technologies, status, featured) VALUES
('Aplikasi Cloud Desktop', 
 'Aplikasi desktop berbasis cloud yang memungkinkan pengguna untuk mengakses dan mengelola file mereka dari mana saja dengan interface yang intuitif.',
 'HTML, CSS, JavaScript, PHP, MySQL',
 'completed',
 TRUE),

('Website Cloud', 
 'Platform website berbasis cloud dengan fitur manajemen konten yang mudah, hosting yang reliable, dan performa yang optimal.',
 'PHP, MySQL, Apache, Linux',
 'completed',
 TRUE),

('E-commerce Platform',
 'Platform e-commerce modern dengan fitur lengkap untuk toko online.',
 'PHP, MySQL, Bootstrap, JavaScript',
 'development',
 FALSE);

-- Tabel untuk blog posts (opsional)
CREATE TABLE IF NOT EXISTS blog_posts (
    id INT(11) NOT NULL AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    slug VARCHAR(200) UNIQUE NOT NULL,
    excerpt TEXT,
    content LONGTEXT,
    featured_image VARCHAR(255),
    tags VARCHAR(500),
    status ENUM('draft', 'published') DEFAULT 'draft',
    published_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE INDEX idx_slug (slug),
    INDEX idx_status (status),
    INDEX idx_published_at (published_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert contoh blog posts
INSERT INTO blog_posts (title, slug, excerpt, content, status, published_at) VALUES
('Cara Belajar HTML untuk Pemula',
 'cara-belajar-html-untuk-pemula',
 'HTML adalah fondasi dari web development. Dalam artikel ini, saya akan membahas cara efektif belajar HTML dari dasar.',
 '<h2>Pengenalan HTML</h2><p>HTML (HyperText Markup Language) adalah bahasa markup standar untuk membuat halaman web...</p>',
 'published',
 '2025-07-27 00:00:00'),

('Mengapa CSS Penting dalam Web Development?',
 'mengapa-css-penting-dalam-web-development',
 'CSS bukan hanya tentang styling, tetapi juga tentang user experience.',
 '<h2>Pentingnya CSS</h2><p>CSS (Cascading Style Sheets) memainkan peran penting dalam web development...</p>',
 'published',
 '2025-07-20 00:00:00'),

('Setup Development Environment di Linux',
 'setup-development-environment-di-linux',
 'Panduan lengkap untuk menyiapkan environment development web di Linux.',
 '<h2>Persiapan</h2><p>Linux adalah sistem operasi yang ideal untuk web development...</p>',
 'published',
 '2025-07-15 00:00:00');

-- Tabel untuk konfigurasi website (opsional)
CREATE TABLE IF NOT EXISTS site_config (
    config_key VARCHAR(100) PRIMARY KEY,
    config_value TEXT,
    description VARCHAR(255),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert konfigurasi dasar
INSERT INTO site_config (config_key, config_value, description) VALUES
('site_name', 'Angga Ariya Saputra - Portfolio', 'Nama website'),
('site_description', 'Full Stack Web Developer dari SMKN 1 Lumajang', 'Deskripsi website'),
('contact_email', 'acchaveam@gmail.com', 'Email kontak'),
('github_url', 'https://github.com/yourusername', 'URL GitHub'),
('linkedin_url', 'https://linkedin.com/in/yourusername', 'URL LinkedIn'),
('instagram_url', 'https://instagram.com/yourusername', 'URL Instagram');

-- User untuk admin panel (jika diperlukan)
CREATE TABLE IF NOT EXISTS admin_users (
    id INT(11) NOT NULL AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100),
    role ENUM('admin', 'editor') DEFAULT 'admin',
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE INDEX idx_username (username),
    UNIQUE INDEX idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert admin user default (password: admin123 - ganti setelah login!)
INSERT INTO admin_users (username, email, password_hash, full_name) VALUES
('admin', 'acchaveam@gmail.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Angga Ariya Saputra');

-- Tabel untuk tracking visitors (opsional)
CREATE TABLE IF NOT EXISTS visitors (
    id INT(11) NOT NULL AUTO_INCREMENT,
    ip_address VARCHAR(45) NOT NULL,
    user_agent TEXT,
    page_visited VARCHAR(255),
    referrer VARCHAR(255),
    visit_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX idx_ip (ip_address),
    INDEX idx_visit_time (visit_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- View untuk statistik pesan kontak
CREATE VIEW contact_stats AS
SELECT 
    DATE(created_at) as date,
    COUNT(*) as total_messages,
    COUNT(CASE WHEN status = 'new' THEN 1 END) as new_messages,
    COUNT(CASE WHEN status = 'read' THEN 1 END) as read_messages,
    COUNT(CASE WHEN status = 'replied' THEN 1 END) as replied_messages
FROM contact_messages 
GROUP BY DATE(created_at) 
ORDER BY date DESC;