<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        $input = file_get_contents('php://input');
        if (empty($input)) {
            http_response_code(400);
            echo json_encode(['error' => 'Request body is required']);
            exit();
        }

        $data = json_decode($input, true);
        if (json_last_error() !== JSON_ERROR_NONE) {
            http_response_code(400);
            echo json_encode(['error' => 'Invalid JSON format']);
            exit();
        }

        // Validate required fields
        if (!isset($data['origin']) || !isset($data['destination'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Origin and destination are required']);
            exit();
        }

        $origin = $data['origin'];
        $destination = $data['destination'];
        $apiKey = 'AIzaSyBw2yjQlova1YwxnvA733FZ9PK7sn99jlU';

        $url = "https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$apiKey";

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_TIMEOUT, 30);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);

        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $error = curl_error($ch);
        curl_close($ch);

        if ($error) {
            http_response_code(500);
            echo json_encode(['error' => 'cURL error: ' . $error]);
            exit();
        }

        if ($httpCode !== 200) {
            http_response_code($httpCode);
            echo json_encode(['error' => 'Google API returned status code: ' . $httpCode]);
            exit();
        }

        if (empty($response)) {
            http_response_code(500);
            echo json_encode(['error' => 'Empty response from Google API']);
            exit();
        }

        echo $response;
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Internal server error: ' . $e->getMessage()]);
    }
} else {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
}
