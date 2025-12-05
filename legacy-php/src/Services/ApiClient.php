<?php
/**
 * ApiClient
 * Handles HTTP calls to the New API Service
 */

class ApiClient
{
    private $baseUrl;
    
    public function __construct()
    {
        // Get API base URL from environment variable or use default
        $this->baseUrl = getenv('API_BASE_URL') ?: 'http://new-api:8000';
    }
    
    /**
     * Fetch all student requests from the New API Service
     * Requirements: 2.2
     * 
     * @return array|null Array of student request objects, or null on failure
     */
    public function fetchRequests()
    {
        try {
            $url = $this->baseUrl . '/requests';
            
            // Initialize cURL
            $ch = curl_init($url);
            
            // Set cURL options
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_TIMEOUT, 5);
            curl_setopt($ch, CURLOPT_HTTPHEADER, [
                'Accept: application/json',
                'Content-Type: application/json'
            ]);
            
            // Execute request
            $response = curl_exec($ch);
            $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
            $error = curl_error($ch);
            
            curl_close($ch);
            
            // Check for errors
            if ($response === false || $http_code !== 200) {
                error_log("API request failed: HTTP $http_code, Error: $error");
                return null;
            }
            
            // Decode JSON response
            $data = json_decode($response, true);
            
            if (json_last_error() !== JSON_ERROR_NONE) {
                error_log("JSON decode error: " . json_last_error_msg());
                return null;
            }
            
            return $data;
            
        } catch (Exception $e) {
            error_log("Exception in fetchRequests: " . $e->getMessage());
            return null;
        }
    }
}
