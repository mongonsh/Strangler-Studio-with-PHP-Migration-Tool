"""
PHP Code Analyzer
Extracts routes, models, and business logic from PHP code
"""

import re
from pathlib import Path
from typing import Dict, List
import json

class PHPAnalyzer:
    """Analyzes PHP code to extract structure and patterns"""
    
    def __init__(self):
        self.routes = []
        self.models = []
        self.dependencies = []
        self.file_count = 0
    
    def analyze_directory(self, directory: Path) -> Dict:
        """Analyze entire PHP project directory"""
        self.routes = []
        self.models = []
        self.dependencies = []
        self.file_count = 0
        
        # Find all PHP files
        php_files = list(directory.rglob("*.php"))
        self.file_count = len(php_files)
        
        for php_file in php_files:
            try:
                content = php_file.read_text(encoding='utf-8', errors='ignore')
                self._analyze_file(content, php_file.name)
            except Exception as e:
                print(f"Error analyzing {php_file}: {e}")
        
        return {
            'routes': self.routes,
            'models': self.models,
            'dependencies': list(set(self.dependencies)),
            'file_count': self.file_count,
            'summary': self._generate_summary()
        }
    
    def _analyze_file(self, content: str, filename: str):
        """Analyze a single PHP file"""
        # Extract routes
        self._extract_routes(content, filename)
        
        # Extract models/classes
        self._extract_models(content, filename)
        
        # Extract dependencies
        self._extract_dependencies(content)
    
    def _extract_routes(self, content: str, filename: str):
        """Extract route definitions from PHP code"""
        
        # Pattern 1: Laravel-style routes
        # Route::get('/users', 'UserController@index');
        laravel_pattern = r"Route::(get|post|put|patch|delete)\s*\(\s*['\"]([^'\"]+)['\"]"
        matches = re.finditer(laravel_pattern, content, re.IGNORECASE)
        
        for match in matches:
            method = match.group(1).upper()
            path = match.group(2)
            
            self.routes.append({
                'method': method,
                'path': path,
                'file': filename,
                'framework': 'laravel',
                'handler': self._extract_handler_near(content, match.start())
            })
        
        # Pattern 2: Slim/Symfony-style routes
        # $app->get('/users', function() {});
        slim_pattern = r"\$app->(get|post|put|patch|delete)\s*\(\s*['\"]([^'\"]+)['\"]"
        matches = re.finditer(slim_pattern, content, re.IGNORECASE)
        
        for match in matches:
            method = match.group(1).upper()
            path = match.group(2)
            
            self.routes.append({
                'method': method,
                'path': path,
                'file': filename,
                'framework': 'slim',
                'handler': 'inline_function'
            })
        
        # Pattern 3: Plain PHP with $_SERVER['REQUEST_URI']
        if 'REQUEST_URI' in content or 'REQUEST_METHOD' in content:
            # Try to extract paths from switch/if statements
            uri_patterns = re.finditer(r"['\"]/([\w/\-]+)['\"]", content)
            for match in uri_patterns:
                path = '/' + match.group(1)
                if path not in [r['path'] for r in self.routes]:
                    self.routes.append({
                        'method': 'GET',  # Default
                        'path': path,
                        'file': filename,
                        'framework': 'plain',
                        'handler': 'unknown'
                    })
    
    def _extract_models(self, content: str, filename: str):
        """Extract class/model definitions"""
        
        # Pattern: class ClassName
        class_pattern = r"class\s+(\w+)(?:\s+extends\s+(\w+))?"
        matches = re.finditer(class_pattern, content)
        
        for match in matches:
            class_name = match.group(1)
            extends = match.group(2) if match.group(2) else None
            
            # Extract properties
            properties = self._extract_class_properties(content, match.start())
            
            # Extract methods
            methods = self._extract_class_methods(content, match.start())
            
            self.models.append({
                'name': class_name,
                'extends': extends,
                'file': filename,
                'properties': properties,
                'methods': methods
            })
    
    def _extract_class_properties(self, content: str, class_start: int) -> List[Dict]:
        """Extract properties from a class"""
        properties = []
        
        # Find class body
        class_body = self._extract_class_body(content, class_start)
        
        # Pattern: public/private/protected $property
        prop_pattern = r"(public|private|protected)\s+\$(\w+)"
        matches = re.finditer(prop_pattern, class_body)
        
        for match in matches:
            visibility = match.group(1)
            name = match.group(2)
            
            properties.append({
                'name': name,
                'visibility': visibility,
                'type': 'mixed'  # PHP doesn't always have type hints
            })
        
        return properties
    
    def _extract_class_methods(self, content: str, class_start: int) -> List[str]:
        """Extract method names from a class"""
        methods = []
        
        class_body = self._extract_class_body(content, class_start)
        
        # Pattern: function methodName
        method_pattern = r"function\s+(\w+)\s*\("
        matches = re.finditer(method_pattern, class_body)
        
        for match in matches:
            methods.append(match.group(1))
        
        return methods
    
    def _extract_class_body(self, content: str, class_start: int) -> str:
        """Extract the body of a class"""
        # Find opening brace
        brace_start = content.find('{', class_start)
        if brace_start == -1:
            return ""
        
        # Find matching closing brace
        brace_count = 1
        pos = brace_start + 1
        
        while pos < len(content) and brace_count > 0:
            if content[pos] == '{':
                brace_count += 1
            elif content[pos] == '}':
                brace_count -= 1
            pos += 1
        
        return content[brace_start:pos]
    
    def _extract_dependencies(self, content: str):
        """Extract dependencies (use/require statements)"""
        
        # Pattern: use Namespace\ClassName;
        use_pattern = r"use\s+([\w\\]+)"
        matches = re.finditer(use_pattern, content)
        
        for match in matches:
            self.dependencies.append(match.group(1))
        
        # Pattern: require/include
        require_pattern = r"(require|include)(?:_once)?\s*['\"]([^'\"]+)['\"]"
        matches = re.finditer(require_pattern, content)
        
        for match in matches:
            self.dependencies.append(match.group(2))
    
    def _extract_handler_near(self, content: str, position: int) -> str:
        """Extract handler name near a route definition"""
        # Look for controller@method pattern
        snippet = content[position:position+200]
        handler_match = re.search(r"['\"](\w+Controller)@(\w+)['\"]", snippet)
        
        if handler_match:
            return f"{handler_match.group(1)}.{handler_match.group(2)}"
        
        return "unknown"
    
    def _generate_summary(self) -> str:
        """Generate analysis summary"""
        return f"Found {len(self.routes)} routes, {len(self.models)} models/classes, and {self.file_count} PHP files"
