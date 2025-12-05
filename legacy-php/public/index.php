<?php
/**
 * Front Controller for Strangler Studio Legacy PHP App
 * Routes all requests through this single entry point
 */

// Enable error reporting for development
error_reporting(E_ALL);
ini_set('display_errors', '1');

// Set up autoloading
spl_autoload_register(function ($class) {
    $prefix = '';
    $base_dir = __DIR__ . '/../src/';
    
    $len = strlen($prefix);
    if (strncmp($prefix, $class, $len) !== 0) {
        return;
    }
    
    $relative_class = substr($class, $len);
    $file = $base_dir . str_replace('\\', '/', $relative_class) . '.php';
    
    if (file_exists($file)) {
        require $file;
    }
});

// Parse the request URI
$request_uri = $_SERVER['REQUEST_URI'];
$request_path = parse_url($request_uri, PHP_URL_PATH);

// Simple routing logic
if ($request_path === '/' || $request_path === '') {
    // Landing page
    require_once __DIR__ . '/../src/Controllers/HomeController.php';
    $controller = new HomeController();
    $controller->index();
} elseif ($request_path === '/requests') {
    // Requests list page
    require_once __DIR__ . '/../src/Controllers/RequestsController.php';
    $controller = new RequestsController();
    $controller->index();
} else {
    // 404 Not Found
    http_response_code(404);
    echo '<!DOCTYPE html>
<html>
<head>
    <title>404 - Not Found</title>
</head>
<body>
    <h1>404 - Page Not Found</h1>
    <p>The requested page could not be found.</p>
</body>
</html>';
}
