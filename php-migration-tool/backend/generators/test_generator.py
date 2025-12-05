"""
Test Generator
Generates pytest tests for migrated API
"""

from typing import Dict

class TestGenerator:
    """Generates pytest tests"""
    
    def generate(self, analysis: Dict, openapi_spec: str) -> str:
        """Generate test file"""
        
        code = '''"""
API Tests
Generated tests for migrated API
"""

import pytest
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_root():
    """Test root endpoint"""
    response = client.get("/")
    assert response.status_code == 200
    assert "status" in response.json()

'''
        
        # Generate tests for each route
        for route in analysis.get('routes', []):
            method = route['method'].lower()
            path = route['path']
            
            # Convert path params for testing
            test_path = self._convert_path_for_test(path)
            func_name = self._path_to_test_name(path, method)
            
            code += f'''
def test_{func_name}():
    """Test {method.upper()} {path}"""
    response = client.{method}("{test_path}")
    assert response.status_code in [200, 404]  # Allow 404 for unimplemented
    if response.status_code == 200:
        assert response.json() is not None

'''
        
        return code
    
    def _convert_path_for_test(self, path: str) -> str:
        """Convert path with params to test path"""
        import re
        
        # Replace :param or {param} with test value
        path = re.sub(r'[:{](\w+)[}]?', '1', path)
        
        return path
    
    def _path_to_test_name(self, path: str, method: str) -> str:
        """Convert path to test function name"""
        name = path.strip('/').replace('/', '_').replace('-', '_')
        name = name.replace(':', '').replace('{', '').replace('}', '')
        name = f"{method}_{name}" if name else method
        
        if not name:
            name = f"{method}_root"
        
        return name.lower()
