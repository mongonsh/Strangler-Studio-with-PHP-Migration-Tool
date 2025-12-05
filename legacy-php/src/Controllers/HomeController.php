<?php
/**
 * HomeController
 * Handles the landing page display
 */

class HomeController
{
    /**
     * Display the landing page
     * Requirements: 1.2, 1.3, 1.4, 1.5
     */
    public function index()
    {
        // Set page title and content
        $page_title = 'Strangler Studio - Home';
        $page_content = $this->renderHome();
        
        // Load the layout
        require_once __DIR__ . '/../Views/layout.php';
    }
    
    /**
     * Render the home page content
     * @return string HTML content for the home page
     */
    private function renderHome()
    {
        ob_start();
        require __DIR__ . '/../Views/home.php';
        return ob_get_clean();
    }
}
