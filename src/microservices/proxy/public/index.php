<?php

require_once __DIR__ . '/../vendor/autoload.php';

use App\Gateway;

// Обработка CORS (если необходимо для фронтенда)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    header('Access-Control-Allow-Origin: *');
    header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type, Authorization');
    exit(0);
}

// Запуск шлюза
$gateway = new Gateway();
$gateway->handle();