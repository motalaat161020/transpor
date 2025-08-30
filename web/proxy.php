<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
  http_response_code(200);
  exit();
}

$apiKey = 'AIzaSyBw2yjQlova1YwxnvA733FZ9PK7sn99jlU';
$url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';

// Validate input parameter
$input = $_GET['input'] ?? '';
if (empty($input)) {
  http_response_code(400);
  echo json_encode(['error' => 'Input parameter is required']);
  exit();
}

$params = $_GET;
$params['key'] = $apiKey;

$query = http_build_query($params);
$fullUrl = "$url?$query";

try {
  $response = file_get_contents($fullUrl);
  if ($response === false) {
    http_response_code(500);
    echo json_encode(['error' => 'Failed to fetch data from Google API']);
    exit();
  }
  echo $response;
} catch (Exception $e) {
  http_response_code(500);
  echo json_encode(['error' => 'Internal server error: ' . $e->getMessage()]);
}
