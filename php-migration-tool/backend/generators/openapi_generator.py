"""
OpenAPI Specification Generator
Generates OpenAPI 3.0 specs from PHP analysis
"""

import yaml
from typing import Dict, List

class OpenAPIGenerator:
    """Generates OpenAPI specifications from PHP analysis"""
    
    def generate(self, analysis: Dict) -> str:
        """Generate OpenAPI YAML from analysis"""
        
        spec = {
            'openapi': '3.0.3',
            'info': {
                'title': 'Migrated API',
                'description': 'API migrated from PHP to Python',
                'version': '1.0.0'
            },
            'paths': {},
            'components': {
                'schemas': {}
            }
        }
        
        # Generate paths from routes
        for route in analysis.get('routes', []):
            path = route['path']
            method = route['method'].lower()
            
            if path not in spec['paths']:
                spec['paths'][path] = {}
            
            spec['paths'][path][method] = {
                'summary': f"{method.upper()} {path}",
                'description': f"Migrated from {route.get('file', 'unknown')}",
                'responses': {
                    '200': {
                        'description': 'Successful response',
                        'content': {
                            'application/json': {
                                'schema': {
                                    'type': 'object'
                                }
                            }
                        }
                    },
                    '404': {
                        'description': 'Not found'
                    },
                    '500': {
                        'description': 'Internal server error'
                    }
                }
            }
            
            # Add path parameters if present
            if '{' in path:
                params = self._extract_path_params(path)
                spec['paths'][path][method]['parameters'] = params
        
        # Generate schemas from models
        for model in analysis.get('models', []):
            schema_name = model['name']
            properties = {}
            required = []
            
            for prop in model.get('properties', []):
                prop_name = prop['name']
                properties[prop_name] = {
                    'type': self._php_type_to_openapi(prop.get('type', 'mixed'))
                }
                
                if prop.get('visibility') == 'public':
                    required.append(prop_name)
            
            spec['components']['schemas'][schema_name] = {
                'type': 'object',
                'properties': properties
            }
            
            if required:
                spec['components']['schemas'][schema_name]['required'] = required
        
        return yaml.dump(spec, default_flow_style=False, sort_keys=False)
    
    def _extract_path_params(self, path: str) -> List[Dict]:
        """Extract path parameters from route path"""
        import re
        params = []
        
        # Find {param} patterns
        param_pattern = r'\{(\w+)\}'
        matches = re.finditer(param_pattern, path)
        
        for match in matches:
            param_name = match.group(1)
            params.append({
                'name': param_name,
                'in': 'path',
                'required': True,
                'schema': {
                    'type': 'string'
                }
            })
        
        return params
    
    def _php_type_to_openapi(self, php_type: str) -> str:
        """Convert PHP type to OpenAPI type"""
        type_map = {
            'string': 'string',
            'int': 'integer',
            'integer': 'integer',
            'float': 'number',
            'double': 'number',
            'bool': 'boolean',
            'boolean': 'boolean',
            'array': 'array',
            'object': 'object',
            'mixed': 'string'
        }
        
        return type_map.get(php_type.lower(), 'string')
