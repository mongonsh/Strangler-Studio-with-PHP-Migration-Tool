<?php
/**
 * RequestsController
 * Handles the requests list page with feature flag logic
 */

require_once __DIR__ . '/../Services/ApiClient.php';

class RequestsController
{
    private $apiClient;
    
    public function __construct()
    {
        $this->apiClient = new ApiClient();
    }
    
    /**
     * Display the requests list page
     * Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8
     */
    public function index()
    {
        // Check feature flag from query parameter
        $use_new = isset($_GET['use_new']) ? $_GET['use_new'] : '0';
        
        // Fetch data based on feature flag
        if ($use_new === '1') {
            // Use new API service
            $requests = $this->apiClient->fetchRequests();
            $data_source = 'new API';
            
            // Fallback to stub data if API call fails
            if ($requests === null) {
                $requests = $this->getStubData();
                $data_source = 'legacy (API unavailable)';
            }
        } else {
            // Use legacy stub data
            $requests = $this->getStubData();
            $data_source = 'legacy';
        }
        
        // Set page title and render
        $page_title = 'Strangler Studio - Student Requests';
        $page_content = $this->renderRequests($requests, $use_new, $data_source);
        
        // Load the layout
        require_once __DIR__ . '/../Views/layout.php';
    }
    
    /**
     * Render the requests page content
     * @param array $requests List of student requests
     * @param string $use_new Feature flag value
     * @param string $data_source Data source indicator
     * @return string HTML content for the requests page
     */
    private function renderRequests($requests, $use_new, $data_source)
    {
        ob_start();
        require __DIR__ . '/../Views/requests.php';
        return ob_get_clean();
    }
    
    /**
     * Get stub data for legacy mode
     * Requirements: 2.3
     * @return array Array of student request objects
     * 
     * Note: This data is aligned with the new API seed data to ensure
     * semantic equivalence during the Strangler Fig migration.
     */
    private function getStubData()
    {
        return [
            [
                'id' => 1,
                'student_name' => 'Victor Frankenstein',
                'school' => 'Miskatonic University',
                'status' => 'Active',  // Maps to API status: Possessed
                'created_at' => '2024-10-31 23:59:59',
                'priority' => 'Critical',
                'notes' => 'Urgent reanimation assistance required for final thesis project'
            ],
            [
                'id' => 2,
                'student_name' => 'Mina Harker',
                'school' => 'Transylvania Academy',
                'status' => 'Active',  // Maps to API status: Summoned
                'created_at' => '2024-10-30 18:30:00',
                'priority' => 'High',
                'notes' => 'Vampire literature research - need access to restricted archives'
            ],
            [
                'id' => 3,
                'student_name' => 'Henry Jekyll',
                'school' => 'London Medical College',
                'status' => 'Pending',  // Maps to API status: Pending
                'created_at' => '2024-10-29 14:15:30',
                'priority' => 'Medium',
                'notes' => 'Chemistry lab equipment request for transformation experiments'
            ],
            [
                'id' => 4,
                'student_name' => 'Dorian Gray',
                'school' => 'Oxford Academy of Arts',  // Updated to match API
                'status' => 'Completed',  // Maps to API status: Banished
                'created_at' => '2024-10-28 09:45:00',
                'priority' => 'Low',
                'notes' => 'Portrait restoration services - urgent but confidential'
            ],
            [
                'id' => 5,
                'student_name' => 'Ichabod Crane',
                'school' => 'Sleepy Hollow Institute',
                'status' => 'Active',  // Maps to API status: Possessed
                'created_at' => '2024-10-27 22:00:00',
                'priority' => 'High',
                'notes' => 'Requesting transfer due to headless horseman incidents'
            ],
            [
                'id' => 6,
                'student_name' => 'Wednesday Addams',
                'school' => 'Nevermore Academy',
                'status' => 'Active',  // Maps to API status: Summoned
                'created_at' => '2024-10-26 13:13:13',
                'priority' => 'Medium',
                'notes' => 'Advanced torture techniques seminar enrollment'
            ],
            [
                'id' => 7,
                'student_name' => 'Raven Darkholme',
                'school' => 'Xavier\'s School for Gifted Youngsters',
                'status' => 'Pending',  // Maps to API status: Pending
                'created_at' => '2024-10-25 16:20:00',
                'priority' => 'Critical',
                'notes' => 'Shape-shifting ethics course - mandatory for graduation'
            ]
        ];
    }
}
