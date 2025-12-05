"""
PHP to Python Migration Tool - Backend API
"""

from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse, FileResponse
from pydantic import BaseModel
from typing import List, Dict, Optional
import zipfile
import tempfile
import os
import shutil
from pathlib import Path
import requests
import subprocess

# Set git environment before importing
os.environ['GIT_PYTHON_REFRESH'] = 'quiet'
os.environ['GIT_PYTHON_GIT_EXECUTABLE'] = '/usr/bin/git'

try:
    import git
    GIT_AVAILABLE = True
except Exception as e:
    print(f"Warning: GitPython not available: {e}")
    GIT_AVAILABLE = False

from analyzers.php_analyzer import PHPAnalyzer
from generators.openapi_generator import OpenAPIGenerator
from generators.fastapi_generator import FastAPIGenerator
from generators.test_generator import TestGenerator

app = FastAPI(
    title="PHP Migration Tool API",
    description="AI-powered PHP to Python migration tool",
    version="1.0.0"
)

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173", "http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Models
class AnalysisResult(BaseModel):
    routes: List[Dict]
    models: List[Dict]
    dependencies: List[str]
    file_count: int
    summary: str

class GenerateRequest(BaseModel):
    analysis: Dict
    options: Optional[Dict] = {}

class GitHubRepoRequest(BaseModel):
    repo_url: str
    branch: Optional[str] = "main"

class PreviewRequest(BaseModel):
    port: int
    project_id: str

# Storage for temporary files
UPLOAD_DIR = Path("uploads")
OUTPUT_DIR = Path("outputs")
UPLOAD_DIR.mkdir(exist_ok=True)
OUTPUT_DIR.mkdir(exist_ok=True)

@app.get("/")
async def root():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "PHP Migration Tool API",
        "version": "1.0.0"
    }

@app.post("/api/clone-github", response_model=Dict)
async def clone_github_repo(request: GitHubRepoRequest):
    """
    Clone a GitHub repository for analysis
    """
    if not GIT_AVAILABLE:
        raise HTTPException(
            status_code=503, 
            detail="Git is not available. Please rebuild the backend container with: docker-compose build --no-cache backend"
        )
    
    temp_dir = None
    try:
        # Create temporary directory
        temp_dir = tempfile.mkdtemp(dir=UPLOAD_DIR)
        extract_dir = Path(temp_dir) / "extracted"
        extract_dir.mkdir(exist_ok=True)
        
        # Clone repository
        repo_url = request.repo_url.strip()
        
        # Handle different GitHub URL formats
        if not repo_url.startswith('http'):
            raise HTTPException(status_code=400, detail="Repository URL must start with http:// or https://")
        
        # Add .git if not present
        if not repo_url.endswith('.git'):
            repo_url = repo_url + '.git'
        
        print(f"Cloning repository: {repo_url} (branch: {request.branch})")
        
        # Clone with error handling
        try:
            git.Repo.clone_from(
                repo_url,
                str(extract_dir),
                branch=request.branch,
                depth=1,
                single_branch=True
            )
        except git.exc.GitCommandError as git_error:
            error_msg = str(git_error)
            if "not found" in error_msg.lower():
                raise HTTPException(status_code=404, detail=f"Repository or branch '{request.branch}' not found")
            elif "authentication" in error_msg.lower() or "permission" in error_msg.lower():
                raise HTTPException(status_code=403, detail="Repository is private or requires authentication")
            else:
                raise HTTPException(status_code=400, detail=f"Git error: {error_msg}")
        
        # Remove .git directory to save space
        git_dir = extract_dir / '.git'
        if git_dir.exists():
            shutil.rmtree(git_dir)
        
        # Verify we have PHP files
        php_files = list(extract_dir.rglob("*.php"))
        if not php_files:
            shutil.rmtree(temp_dir, ignore_errors=True)
            raise HTTPException(status_code=400, detail="No PHP files found in repository")
        
        print(f"Successfully cloned repository. Found {len(php_files)} PHP files")
        
        return {
            "upload_id": Path(temp_dir).name,
            "repo_url": request.repo_url,
            "branch": request.branch,
            "status": "cloned",
            "php_files_found": len(php_files)
        }
    except HTTPException:
        # Re-raise HTTP exceptions
        if temp_dir and Path(temp_dir).exists():
            shutil.rmtree(temp_dir, ignore_errors=True)
        raise
    except Exception as e:
        # Handle unexpected errors
        if temp_dir and Path(temp_dir).exists():
            shutil.rmtree(temp_dir, ignore_errors=True)
        print(f"Unexpected error cloning repository: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Unexpected error: {str(e)}")

@app.post("/api/upload", response_model=Dict)
async def upload_php_project(file: UploadFile = File(...)):
    """
    Upload a PHP project (zip file) for analysis
    """
    if not file.filename.endswith('.zip'):
        raise HTTPException(status_code=400, detail="Only ZIP files are supported")
    
    # Create temporary directory for this upload
    temp_dir = tempfile.mkdtemp(dir=UPLOAD_DIR)
    zip_path = Path(temp_dir) / file.filename
    
    # Save uploaded file
    with open(zip_path, "wb") as buffer:
        content = await file.read()
        buffer.write(content)
    
    # Extract zip
    extract_dir = Path(temp_dir) / "extracted"
    extract_dir.mkdir(exist_ok=True)
    
    try:
        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
            zip_ref.extractall(extract_dir)
    except Exception as e:
        shutil.rmtree(temp_dir)
        raise HTTPException(status_code=400, detail=f"Failed to extract ZIP: {str(e)}")
    
    return {
        "upload_id": Path(temp_dir).name,
        "filename": file.filename,
        "size": len(content),
        "status": "uploaded"
    }

@app.post("/api/analyze/{upload_id}", response_model=AnalysisResult)
async def analyze_php_project(upload_id: str):
    """
    Analyze uploaded PHP project
    """
    upload_path = UPLOAD_DIR / upload_id / "extracted"
    
    if not upload_path.exists():
        raise HTTPException(status_code=404, detail="Upload not found")
    
    try:
        analyzer = PHPAnalyzer()
        analysis = analyzer.analyze_directory(upload_path)
        
        return AnalysisResult(
            routes=analysis['routes'],
            models=analysis['models'],
            dependencies=analysis['dependencies'],
            file_count=analysis['file_count'],
            summary=analysis['summary']
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Analysis failed: {str(e)}")

@app.post("/api/generate/{upload_id}")
async def generate_python_code(upload_id: str, request: GenerateRequest):
    """
    Generate Python/FastAPI code from analysis
    """
    try:
        # Generate OpenAPI spec
        openapi_gen = OpenAPIGenerator()
        openapi_spec = openapi_gen.generate(request.analysis)
        
        # Generate FastAPI code
        fastapi_gen = FastAPIGenerator()
        python_code = fastapi_gen.generate(request.analysis, openapi_spec)
        
        # Generate tests
        test_gen = TestGenerator()
        tests = test_gen.generate(request.analysis, openapi_spec)
        
        # Create output directory
        output_dir = OUTPUT_DIR / upload_id
        output_dir.mkdir(exist_ok=True)
        
        # Save generated files
        (output_dir / "openapi.yaml").write_text(openapi_spec)
        (output_dir / "main.py").write_text(python_code['main'])
        (output_dir / "models.py").write_text(python_code['models'])
        (output_dir / "routes.py").write_text(python_code['routes'])
        (output_dir / "test_api.py").write_text(tests)
        
        # Create requirements.txt
        requirements = """fastapi==0.104.1
uvicorn[standard]==0.24.0
pydantic==2.5.0
pytest==7.4.3
hypothesis==6.92.1
"""
        (output_dir / "requirements.txt").write_text(requirements)
        
        # Create README
        readme = f"""# Migrated Python API

Generated from PHP project using PHP Migration Tool.

## Setup

```bash
pip install -r requirements.txt
```

## Run

```bash
uvicorn main:app --reload
```

## Test

```bash
pytest test_api.py
```

## API Documentation

Visit http://localhost:8000/docs for interactive API documentation.
"""
        (output_dir / "README.md").write_text(readme)
        
        return {
            "status": "success",
            "output_id": upload_id,
            "files": {
                "openapi": "openapi.yaml",
                "main": "main.py",
                "models": "models.py",
                "routes": "routes.py",
                "tests": "test_api.py",
                "requirements": "requirements.txt",
                "readme": "README.md"
            }
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Generation failed: {str(e)}")

@app.get("/api/download/{output_id}")
async def download_generated_code(output_id: str):
    """
    Download generated Python project as ZIP
    """
    output_dir = OUTPUT_DIR / output_id
    
    if not output_dir.exists():
        raise HTTPException(status_code=404, detail="Generated code not found")
    
    # Create ZIP file
    zip_path = OUTPUT_DIR / f"{output_id}.zip"
    
    with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for file_path in output_dir.rglob('*'):
            if file_path.is_file():
                arcname = file_path.relative_to(output_dir)
                zipf.write(file_path, arcname)
    
    return FileResponse(
        zip_path,
        media_type="application/zip",
        filename=f"migrated-python-api-{output_id}.zip"
    )

@app.get("/api/preview/{output_id}/{filename}")
async def preview_file(output_id: str, filename: str):
    """
    Preview a generated file
    """
    file_path = OUTPUT_DIR / output_id / filename
    
    if not file_path.exists():
        raise HTTPException(status_code=404, detail="File not found")
    
    content = file_path.read_text()
    
    return {
        "filename": filename,
        "content": content
    }

@app.post("/api/check-php-server")
async def check_php_server(request: PreviewRequest):
    """
    Check if PHP server is accessible at given port
    """
    try:
        response = requests.get(f"http://localhost:{request.port}", timeout=2)
        return {
            "accessible": True,
            "status_code": response.status_code,
            "port": request.port
        }
    except Exception as e:
        return {
            "accessible": False,
            "error": str(e),
            "port": request.port
        }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
