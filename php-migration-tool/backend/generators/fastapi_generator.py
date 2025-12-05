"""
FastAPI Code Generator
Generates Python/FastAPI code from PHP analysis
"""

from typing import Dict
import yaml

class FastAPIGenerator:
    """Generates FastAPI Python code"""
    
    def generate(self, analysis: Dict, openapi_spec: str) -> Dict[str, str]:
        """Generate FastAPI code files"""
        
        return {
            'main': self._generate_main(analysis),
            'models': self._generate_models(analysis),
            'routes': self._generate_routes(analysis)
        }
    
    def _generate_main(self, analysis: Dict) -> str:
        """Generate main.py"""
        
        code = '''"""
Migrated FastAPI Application
Generated from PHP project
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import routes

app = FastAPI(
    title="Migrated API",
    description="API migrated from PHP to Python",
    version="1.0.0"
)

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(routes.router)

@app.get("/")
async def root():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "message": "Migrated API is running"
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
'''
        
        return code
    
    def _generate_models(self, analysis: Dict) -> str:
        """Generate models.py with Pydantic models"""
        
        code = '''"""
Pydantic Models
Generated from PHP classes
"""

from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime

'''
        
        for model in analysis.get('models', []):
            class_name = model['name']
            
            code += f"\nclass {class_name}(BaseModel):\n"
            code += f'    """Migrated from {model.get("file", "unknown")}"""\n'
            
            if model.get('properties'):
                for prop in model['properties']:
                    prop_name = prop['name']
                    prop_type = self._php_type_to_python(prop.get('type', 'str'))
                    
                    code += f"    {prop_name}: {prop_type}\n"
            else:
                code += "    pass\n"
            
            code += "\n"
        
        # Add a generic response model if no models found
        if not analysis.get('models'):
            code += '''
class GenericResponse(BaseModel):
    """Generic API response"""
    message: str
    data: Optional[dict] = None
'''
        
        return code
    
    def _generate_routes(self, analysis: Dict) -> str:
        """Generate routes.py with API endpoints"""
        
        code = '''"""
API Routes
Generated from PHP routes
"""

from fastapi import APIRouter, HTTPException
from models import *

router = APIRouter()

'''
        
        for route in analysis.get('routes', []):
            method = route['method'].lower()
            path = route['path']
            handler = route.get('handler', 'unknown')
            
            # Convert PHP path params to FastAPI format
            # /users/:id -> /users/{id}
            fastapi_path = path.replace(':', '')
            
            # Generate function name from path
            func_name = self._path_to_function_name(path, method)
            
            # Determine if path has parameters
            has_params = '{' in fastapi_path or ':' in path
            
            if has_params:
                # Extract parameter name
                param_name = self._extract_param_name(path)
                
                code += f'''
@router.{method}("{fastapi_path}")
async def {func_name}({param_name}: str):
    """
    Migrated from: {route.get('file', 'unknown')}
    Original handler: {handler}
    """
    # TODO: Implement business logic
    return {{
        "message": "Endpoint migrated from PHP",
        "{param_name}": {param_name}
    }}

'''
            else:
                code += f'''
@router.{method}("{fastapi_path}")
async def {func_name}():
    """
    Migrated from: {route.get('file', 'unknown')}
    Original handler: {handler}
    """
    # TODO: Implement business logic
    return {{
        "message": "Endpoint migrated from PHP",
        "path": "{path}"
    }}

'''
        
        return code
    
    def _path_to_function_name(self, path: str, method: str) -> str:
        """Convert path to valid Python function name"""
        # Remove leading slash and special chars
        name = path.strip('/').replace('/', '_').replace('-', '_')
        name = name.replace(':', '').replace('{', '').replace('}', '')
        
        # Add method prefix
        name = f"{method}_{name}" if name else method
        
        # Ensure valid Python identifier
        if not name:
            name = f"{method}_root"
        
        return name.lower()
    
    def _extract_param_name(self, path: str) -> str:
        """Extract parameter name from path"""
        import re
        
        # Match :param or {param}
        match = re.search(r'[:{](\w+)[}]?', path)
        
        if match:
            return match.group(1)
        
        return "id"
    
    def _php_type_to_python(self, php_type: str) -> str:
        """Convert PHP type to Python type hint"""
        type_map = {
            'string': 'str',
            'int': 'int',
            'integer': 'int',
            'float': 'float',
            'double': 'float',
            'bool': 'bool',
            'boolean': 'bool',
            'array': 'List',
            'object': 'dict',
            'mixed': 'str'
        }
        
        return type_map.get(php_type.lower(), 'str')
