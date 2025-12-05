<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo htmlspecialchars($page_title ?? 'Strangler Studio'); ?></title>
    
    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Cinzel:wght@400;600;700&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    
    <!-- Halloween Theme CSS -->
    <link rel="stylesheet" href="/styles/halloween.css">
    
    <style>
        /* Base styles */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Inter', sans-serif;
            background-color: #0a0a0a;
            color: #f8f9fa;
            min-height: 100vh;
        }
        
        h1, h2, h3, h4, h5, h6 {
            font-family: 'Cinzel', serif;
        }
    </style>
</head>
<body>
    <!-- Main Content -->
    <main>
        <?php echo $page_content ?? ''; ?>
    </main>
    
    <!-- Footer -->
    <footer style="text-align: center; padding: 2rem; color: #6c757d; font-size: 0.875rem;">
        <p>Strangler Studio - A demonstration of the Strangler Fig pattern</p>
    </footer>
</body>
</html>
