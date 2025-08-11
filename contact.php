<?php
// contact.php - Handler untuk form kontak
header('Content-Type: application/json');

// Konfigurasi
$config = [
    'recipient_email' => 'acchaveam@gmail.com',
    'subject_prefix' => '[Portofolio] ',
    'redirect_url' => 'index.html#kontak'
];

// Function untuk validasi input
function validateInput($data) {
    $errors = [];
    
    if (empty($data['name'])) {
        $errors[] = 'Nama harus diisi.';
    } elseif (strlen($data['name']) < 2) {
        $errors[] = 'Nama minimal 2 karakter.';
    }
    
    if (empty($data['email'])) {
        $errors[] = 'Email harus diisi.';
    } elseif (!filter_var($data['email'], FILTER_VALIDATE_EMAIL)) {
        $errors[] = 'Format email tidak valid.';
    }
    
    if (empty($data['subject'])) {
        $errors[] = 'Subjek harus diisi.';
    }
    
    if (empty($data['message'])) {
        $errors[] = 'Pesan harus diisi.';
    } elseif (strlen($data['message']) < 10) {
        $errors[] = 'Pesan minimal 10 karakter.';
    }
    
    return $errors;
}

// Function untuk sanitasi input
function sanitizeInput($data) {
    return [
        'name' => htmlspecialchars(trim($data['name']), ENT_QUOTES, 'UTF-8'),
        'email' => filter_var(trim($data['email']), FILTER_SANITIZE_EMAIL),
        'subject' => htmlspecialchars(trim($data['subject']), ENT_QUOTES, 'UTF-8'),
        'message' => htmlspecialchars(trim($data['message']), ENT_QUOTES, 'UTF-8')
    ];
}

// Function untuk logging
function logMessage($message, $type = 'INFO') {
    $log_file = 'contact_log.txt';
    $timestamp = date('Y-m-d H:i:s');
    $log_entry = "[$timestamp] [$type] $message" . PHP_EOL;
    
    // Pastikan direktori dapat ditulis
    if (is_writable(dirname($log_file)) || is_writable($log_file)) {
        file_put_contents($log_file, $log_entry, FILE_APPEND | LOCK_EX);
    }
}

// Function untuk mengirim email
function sendEmail($data, $config) {
    $to = $config['recipient_email'];
    $subject = $config['subject_prefix'] . $data['subject'];
    
    // Membuat pesan email
    $message = "Pesan baru dari portofolio website:\n\n";
    $message .= "Nama: " . $data['name'] . "\n";
    $message .= "Email: " . $data['email'] . "\n";
    $message .= "Subjek: " . $data['subject'] . "\n\n";
    $message .= "Pesan:\n" . $data['message'] . "\n\n";
    $message .= "---\n";
    $message .= "Dikirim pada: " . date('Y-m-d H:i:s') . "\n";
    $message .= "IP Address: " . ($_SERVER['REMOTE_ADDR'] ?? 'Unknown') . "\n";
    $message .= "User Agent: " . ($_SERVER['HTTP_USER_AGENT'] ?? 'Unknown');
    
    // Headers email
    $headers = [
        'From: ' . $data['email'],
        'Reply-To: ' . $data['email'],
        'X-Mailer: PHP/' . phpversion(),
        'Content-Type: text/plain; charset=UTF-8'
    ];
    
    return mail($to, $subject, $message, implode("\r\n", $headers));
}

// Function untuk simpan ke database (opsional)
function saveToDatabase($data) {
    try {
        // Konfigurasi database
        $host = 'localhost';
        $dbname = 'portfolio_db';
        $username = 'your_db_user';
        $password = 'your_db_password';
        
        $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8", $username, $password);
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        
        $stmt = $pdo->prepare("
            INSERT INTO contact_messages (name, email, subject, message, created_at, ip_address) 
            VALUES (:name, :email, :subject, :message, NOW(), :ip)
        ");
        
        return $stmt->execute([
            ':name' => $data['name'],
            ':email' => $data['email'],
            ':subject' => $data['subject'],
            ':message' => $data['message'],
            ':ip' => $_SERVER['REMOTE_ADDR'] ?? 'Unknown'
        ]);
        
    } catch (PDOException $e) {
        logMessage('Database error: ' . $e->getMessage(), 'ERROR');
        return false;
    }
}

// Cek metode request
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'message' => 'Method not allowed'
    ]);
    exit;
}

try {
    // Ambil dan sanitasi data
    $rawData = [
        'name' => $_POST['name'] ?? '',
        'email' => $_POST['email'] ?? '',
        'subject' => $_POST['subject'] ?? '',
        'message' => $_POST['message'] ?? ''
    ];
    
    $data = sanitizeInput($rawData);
    
    // Validasi input
    $errors = validateInput($data);
    
    if (!empty($errors)) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Data tidak valid',
            'errors' => $errors
        ]);
        exit;
    }
    
    // Simple rate limiting (opsional)
    session_start();
    $current_time = time();
    $last_submission = $_SESSION['last_contact_submission'] ?? 0;
    
    if ($current_time - $last_submission < 60) { // 1 menit cooldown
        http_response_code(429);
        echo json_encode([
            'success' => false,
            'message' => 'Mohon tunggu sebentar sebelum mengirim pesan lagi.'
        ]);
        exit;
    }
    
    $_SESSION['last_contact_submission'] = $current_time;
    
    // Log pesan masuk
    logMessage("New contact message from: {$data['name']} ({$data['email']})");
    
    // Kirim email
    $email_sent = sendEmail($data, $config);
    
    // Simpan ke database (jika diperlukan)
    // $db_saved = saveToDatabase($data);
    
    if ($email_sent) {
        logMessage("Email sent successfully to: {$config['recipient_email']}");
        
        // Jika request AJAX
        if (!empty($_SERVER['HTTP_X_REQUESTED_WITH']) && 
            strtolower($_SERVER['HTTP_X_REQUESTED_WITH']) == 'xmlhttprequest') {
            
            echo json_encode([
                'success' => true,
                'message' => 'Pesan Anda berhasil dikirim. Terima kasih!'
            ]);
        } else {
            // Redirect untuk form submit biasa
            header('Location: ' . $config['redirect_url'] . '?status=success');
        }
        
    } else {
        throw new Exception('Failed to send email');
    }
    
} catch (Exception $e) {
    logMessage('Error: ' . $e->getMessage(), 'ERROR');
    
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Terjadi kesalahan server. Silakan coba lagi nanti.'
    ]);
}
?>