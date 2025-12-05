<!-- Requests List Page View -->
<!-- Requirements: 2.5, 2.6, 2.7, 2.8, 8.8 -->

<style>
    /* Requests Page Specific Styles */
    .requests-page {
        min-height: 100vh;
        padding: 3rem 1.5rem;
        position: relative;
        z-index: 1;
    }
    
    .requests-container {
        max-width: 1400px;
        margin: 0 auto;
    }
    
    /* Page Header */
    .page-header {
        text-align: center;
        margin-bottom: 3rem;
        animation: fade-in 0.6s ease-out;
    }
    
    .page-title {
        font-family: 'Cinzel', serif;
        font-size: 3rem;
        font-weight: 700;
        color: #ff6b35;
        margin-bottom: 1rem;
        text-shadow: 0 0 30px rgba(255, 107, 53, 0.5),
                     0 0 60px rgba(255, 107, 53, 0.3);
    }
    
    .page-subtitle {
        font-size: 1.125rem;
        color: #4ecdc4;
        text-shadow: 0 0 20px rgba(78, 205, 196, 0.3);
    }
    
    /* Control Panel */
    .control-panel {
        display: flex;
        justify-content: space-between;
        align-items: center;
        gap: 2rem;
        margin-bottom: 2rem;
        padding: 1.5rem;
        background: rgba(26, 26, 26, 0.7);
        backdrop-filter: blur(10px);
        -webkit-backdrop-filter: blur(10px);
        border: 1px solid rgba(255, 255, 255, 0.1);
        border-radius: 1rem;
        animation: fade-in 0.6s ease-out 0.2s backwards;
    }
    
    /* Witch Switch Container */
    .witch-switch-wrapper {
        display: flex;
        align-items: center;
        gap: 1rem;
    }
    
    .witch-switch {
        position: relative;
        display: inline-block;
        width: 80px;
        height: 40px;
    }
    
    .witch-switch input {
        opacity: 0;
        width: 0;
        height: 0;
    }
    
    .witch-slider {
        position: absolute;
        cursor: pointer;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background-color: rgba(108, 117, 125, 0.3);
        transition: all 0.3s cubic-bezier(0.4, 0.0, 0.2, 1);
        border-radius: 40px;
        border: 2px solid #6c757d;
    }
    
    .witch-slider::before {
        position: absolute;
        content: '🎃';
        height: 32px;
        width: 32px;
        left: 4px;
        bottom: 2px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.25rem;
        transition: all 0.3s cubic-bezier(0.4, 0.0, 0.2, 1);
    }
    
    .witch-switch input:checked + .witch-slider {
        background: linear-gradient(135deg, #ff6b35, #4ecdc4);
        border-color: #4ecdc4;
        box-shadow: 0 0 20px rgba(78, 205, 196, 0.4);
    }
    
    .witch-switch input:checked + .witch-slider::before {
        transform: translateX(40px);
        content: '✨';
    }
    
    .switch-label {
        font-weight: 600;
        font-size: 0.875rem;
        text-transform: uppercase;
        letter-spacing: 0.05em;
        transition: color 0.3s ease;
    }
    
    .switch-label-off {
        color: #6c757d;
    }
    
    .switch-label-on {
        color: #4ecdc4;
    }
    
    /* Data Source Indicator */
    .data-source-indicator {
        display: inline-flex;
        align-items: center;
        gap: 0.75rem;
        padding: 0.75rem 1.5rem;
        border-radius: 0.75rem;
        font-weight: 600;
        font-size: 0.875rem;
        text-transform: uppercase;
        letter-spacing: 0.05em;
    }
    
    .data-source-indicator::before {
        content: '';
        width: 12px;
        height: 12px;
        border-radius: 50%;
        animation: glow-pulse 2s ease-in-out infinite;
    }
    
    @keyframes glow-pulse {
        0%, 100% {
            opacity: 1;
            transform: scale(1);
        }
        50% {
            opacity: 0.7;
            transform: scale(1.2);
        }
    }
    
    .data-source-legacy {
        background: rgba(108, 117, 125, 0.2);
        color: #6c757d;
        border: 1px solid #6c757d;
    }
    
    .data-source-legacy::before {
        background-color: #6c757d;
        box-shadow: 0 0 10px rgba(108, 117, 125, 0.5);
    }
    
    .data-source-api {
        background: rgba(78, 205, 196, 0.2);
        color: #4ecdc4;
        border: 1px solid #4ecdc4;
    }
    
    .data-source-api::before {
        background-color: #4ecdc4;
        box-shadow: 0 0 10px rgba(78, 205, 196, 0.6);
    }
    
    .data-source-fallback {
        background: rgba(255, 107, 53, 0.2);
        color: #ff6b35;
        border: 1px solid #ff6b35;
    }
    
    .data-source-fallback::before {
        background-color: #ff6b35;
        box-shadow: 0 0 10px rgba(255, 107, 53, 0.6);
    }
    
    /* Requests Table Container */
    .requests-table-container {
        background: rgba(26, 26, 26, 0.5);
        backdrop-filter: blur(10px);
        -webkit-backdrop-filter: blur(10px);
        border: 1px solid rgba(255, 255, 255, 0.1);
        border-radius: 1rem;
        padding: 1.5rem;
        overflow-x: auto;
        animation: fade-in 0.6s ease-out 0.4s backwards;
    }
    
    /* Requests Table */
    .requests-table {
        width: 100%;
        border-collapse: separate;
        border-spacing: 0 0.75rem;
    }
    
    .requests-table thead th {
        background: rgba(26, 26, 26, 0.9);
        backdrop-filter: blur(10px);
        -webkit-backdrop-filter: blur(10px);
        padding: 1rem 1.25rem;
        text-align: left;
        font-weight: 600;
        text-transform: uppercase;
        font-size: 0.875rem;
        letter-spacing: 0.05em;
        color: #4ecdc4;
        border-bottom: 2px solid #ff6b35;
        position: sticky;
        top: 0;
        z-index: 10;
    }
    
    .requests-table tbody tr {
        background: rgba(26, 26, 26, 0.7);
        backdrop-filter: blur(10px);
        -webkit-backdrop-filter: blur(10px);
        transition: all 0.3s cubic-bezier(0.4, 0.0, 0.2, 1);
    }
    
    .requests-table tbody tr:hover {
        background: rgba(26, 26, 26, 0.9);
        box-shadow: 0 0 20px rgba(255, 107, 53, 0.2);
        transform: translateX(4px);
    }
    
    .requests-table td {
        padding: 1rem 1.25rem;
        border-top: 1px solid rgba(255, 255, 255, 0.05);
        border-bottom: 1px solid rgba(255, 255, 255, 0.05);
        vertical-align: middle;
    }
    
    .requests-table tbody tr td:first-child {
        border-left: 1px solid rgba(255, 255, 255, 0.05);
        border-top-left-radius: 0.75rem;
        border-bottom-left-radius: 0.75rem;
    }
    
    .requests-table tbody tr td:last-child {
        border-right: 1px solid rgba(255, 255, 255, 0.05);
        border-top-right-radius: 0.75rem;
        border-bottom-right-radius: 0.75rem;
    }
    
    /* Status Badges */
    .status-badge {
        display: inline-flex;
        align-items: center;
        gap: 0.5rem;
        padding: 0.5rem 1rem;
        border-radius: 9999px;
        font-size: 0.75rem;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.05em;
        transition: all 0.3s cubic-bezier(0.4, 0.0, 0.2, 1);
        white-space: nowrap;
    }
    
    .status-badge::before {
        content: '';
        width: 8px;
        height: 8px;
        border-radius: 50%;
        background-color: currentColor;
        animation: pulse-dot 2s ease-in-out infinite;
    }
    
    @keyframes pulse-dot {
        0%, 100% {
            opacity: 1;
        }
        50% {
            opacity: 0.5;
        }
    }
    
    .status-possessed {
        background-color: rgba(255, 107, 53, 0.2);
        color: #ff6b35;
        border: 1px solid #ff6b35;
    }
    
    .status-possessed:hover {
        box-shadow: 0 0 20px rgba(255, 107, 53, 0.4);
        transform: scale(1.05);
    }
    
    .status-banished {
        background-color: rgba(193, 18, 31, 0.2);
        color: #c1121f;
        border: 1px solid #c1121f;
    }
    
    .status-banished:hover {
        box-shadow: 0 0 20px rgba(193, 18, 31, 0.4);
        transform: scale(1.05);
    }
    
    .status-summoned {
        background-color: rgba(78, 205, 196, 0.2);
        color: #4ecdc4;
        border: 1px solid #4ecdc4;
    }
    
    .status-summoned:hover {
        box-shadow: 0 0 20px rgba(78, 205, 196, 0.4);
        transform: scale(1.05);
    }
    
    .status-pending {
        background-color: rgba(108, 117, 125, 0.2);
        color: #6c757d;
        border: 1px solid #6c757d;
    }
    
    .status-pending:hover {
        box-shadow: 0 0 20px rgba(108, 117, 125, 0.4);
        transform: scale(1.05);
    }
    
    /* Legacy status mapping */
    .status-active {
        background-color: rgba(78, 205, 196, 0.2);
        color: #4ecdc4;
        border: 1px solid #4ecdc4;
    }
    
    .status-active:hover {
        box-shadow: 0 0 20px rgba(78, 205, 196, 0.4);
        transform: scale(1.05);
    }
    
    .status-completed {
        background-color: rgba(108, 117, 125, 0.2);
        color: #6c757d;
        border: 1px solid #6c757d;
    }
    
    .status-completed:hover {
        box-shadow: 0 0 20px rgba(108, 117, 125, 0.4);
        transform: scale(1.05);
    }
    
    /* Priority Badges */
    .priority-badge {
        font-weight: 600;
        font-size: 0.875rem;
    }
    
    .priority-critical {
        color: #c1121f;
    }
    
    .priority-high {
        color: #ff6b35;
    }
    
    .priority-medium {
        color: #4ecdc4;
    }
    
    .priority-low {
        color: #6c757d;
    }
    
    /* Student Name Styling */
    .student-name {
        font-weight: 600;
        color: #f8f9fa;
        font-size: 1rem;
    }
    
    /* School Name Styling */
    .school-name {
        color: #b0b0b0;
        font-size: 0.875rem;
    }
    
    /* Date Styling */
    .date-text {
        color: #b0b0b0;
        font-size: 0.875rem;
        font-family: 'Fira Code', monospace;
    }
    
    /* Empty State */
    .empty-state {
        text-align: center;
        padding: 4rem 2rem;
        color: #6c757d;
    }
    
    .empty-state-icon {
        font-size: 4rem;
        margin-bottom: 1rem;
        opacity: 0.5;
    }
    
    .empty-state-text {
        font-size: 1.125rem;
    }
    
    /* Responsive Design */
    @media (max-width: 639px) {
        .requests-page {
            padding: 2rem 1rem;
        }
        
        .page-title {
            font-size: 2rem;
        }
        
        .page-subtitle {
            font-size: 1rem;
        }
        
        .control-panel {
            flex-direction: column;
            gap: 1rem;
            padding: 1rem;
        }
        
        .witch-switch-wrapper {
            flex-direction: column;
            text-align: center;
            gap: 0.75rem;
        }
        
        .data-source-indicator {
            font-size: 0.75rem;
            padding: 0.5rem 1rem;
        }
        
        .requests-table-container {
            padding: 1rem;
        }
        
        .requests-table {
            font-size: 0.875rem;
        }
        
        .requests-table thead th,
        .requests-table td {
            padding: 0.75rem 0.5rem;
        }
        
        .status-badge {
            font-size: 0.625rem;
            padding: 0.375rem 0.75rem;
        }
        
        /* Stack table on mobile */
        .requests-table thead {
            display: none;
        }
        
        .requests-table tbody tr {
            display: block;
            margin-bottom: 1rem;
            border-radius: 0.75rem;
        }
        
        .requests-table td {
            display: block;
            text-align: right;
            padding: 0.75rem 1rem;
            border: none !important;
            border-radius: 0 !important;
        }
        
        .requests-table td::before {
            content: attr(data-label);
            float: left;
            font-weight: 600;
            color: #4ecdc4;
            text-transform: uppercase;
            font-size: 0.75rem;
        }
    }
    
    @media (min-width: 640px) and (max-width: 1024px) {
        .page-title {
            font-size: 2.5rem;
        }
        
        .control-panel {
            flex-direction: column;
            align-items: stretch;
        }
        
        .witch-switch-wrapper {
            justify-content: center;
        }
        
        .data-source-indicator {
            text-align: center;
            justify-content: center;
        }
    }
    
    /* Accessibility */
    @media (prefers-reduced-motion: reduce) {
        .requests-table tbody tr,
        .status-badge,
        .witch-slider,
        .witch-slider::before,
        .data-source-indicator::before {
            animation: none !important;
            transition: none !important;
        }
        
        .requests-table tbody tr:hover {
            transform: none;
        }
    }
    
    @keyframes fade-in {
        from {
            opacity: 0;
            transform: translateY(20px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }
</style>

<div class="requests-page">
    <div class="requests-container">
        <!-- Page Header -->
        <div class="page-header">
            <h1 class="page-title">Student Requests</h1>
            <p class="page-subtitle">Demonstrating the Strangler Fig pattern in action</p>
        </div>
        
        <!-- Control Panel with Witch Switch and Data Source Indicator -->
        <div class="control-panel">
            <!-- Witch Switch Toggle -->
            <div class="witch-switch-wrapper">
                <span class="switch-label switch-label-off">Legacy Curse</span>
                <label class="witch-switch" aria-label="Toggle between legacy and new API">
                    <input 
                        type="checkbox" 
                        <?php echo ($use_new === '1') ? 'checked' : ''; ?>
                        onchange="window.location.href = this.checked ? '/requests?use_new=1' : '/requests?use_new=0';"
                    >
                    <span class="witch-slider"></span>
                </label>
                <span class="switch-label switch-label-on">Modern Magic</span>
            </div>
            
            <!-- Data Source Indicator -->
            <div class="data-source-indicator <?php 
                if (strpos($data_source, 'unavailable') !== false) {
                    echo 'data-source-fallback';
                } elseif ($data_source === 'new API') {
                    echo 'data-source-api';
                } else {
                    echo 'data-source-legacy';
                }
            ?>">
                <?php 
                if (strpos($data_source, 'unavailable') !== false) {
                    echo '⚠️ Fallback: Legacy Path (API Unavailable)';
                } elseif ($data_source === 'new API') {
                    echo '✨ Served by New API';
                } else {
                    echo '🎃 Served by Legacy Path';
                }
                ?>
            </div>
        </div>
        
        <!-- Requests Table -->
        <div class="requests-table-container">
            <?php if (empty($requests)): ?>
                <div class="empty-state">
                    <div class="empty-state-icon">👻</div>
                    <p class="empty-state-text">No student requests found</p>
                </div>
            <?php else: ?>
                <table class="requests-table">
                    <thead>
                        <tr>
                            <th>Student Name</th>
                            <th>School</th>
                            <th>Status</th>
                            <th>Priority</th>
                            <th>Created At</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($requests as $request): ?>
                            <tr>
                                <td data-label="Student Name">
                                    <span class="student-name">
                                        <?php echo htmlspecialchars($request['student_name']); ?>
                                    </span>
                                </td>
                                <td data-label="School">
                                    <span class="school-name">
                                        <?php echo htmlspecialchars($request['school']); ?>
                                    </span>
                                </td>
                                <td data-label="Status">
                                    <?php 
                                    $status = strtolower($request['status']);
                                    $statusClass = 'status-' . $status;
                                    $statusLabel = ucfirst($request['status']);
                                    ?>
                                    <span class="status-badge <?php echo $statusClass; ?>">
                                        <?php echo htmlspecialchars($statusLabel); ?>
                                    </span>
                                </td>
                                <td data-label="Priority">
                                    <?php 
                                    $priority = strtolower($request['priority']);
                                    $priorityClass = 'priority-' . $priority;
                                    ?>
                                    <span class="priority-badge <?php echo $priorityClass; ?>">
                                        <?php echo htmlspecialchars($request['priority']); ?>
                                    </span>
                                </td>
                                <td data-label="Created At">
                                    <span class="date-text">
                                        <?php 
                                        // Format the date consistently
                                        $date = $request['created_at'];
                                        // Handle both ISO 8601 and legacy formats
                                        if (strpos($date, 'T') !== false) {
                                            // ISO 8601 format from API
                                            $timestamp = strtotime($date);
                                        } else {
                                            // Legacy format
                                            $timestamp = strtotime($date);
                                        }
                                        echo date('Y-m-d H:i', $timestamp);
                                        ?>
                                    </span>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            <?php endif; ?>
        </div>
    </div>
</div>

