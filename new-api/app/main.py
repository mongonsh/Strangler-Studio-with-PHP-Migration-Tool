from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from app.models import StudentRequest
from app.data.seed_data import get_seed_data

# Initialize FastAPI application
app = FastAPI(
    title="Strangler Studio API",
    description="REST API for the Strangler Studio demonstration application. This API manages Student Requests with a Halloween theme.",
    version="1.0.0",
    contact={
        "name": "Strangler Studio"
    }
)

# Configure CORS middleware to allow cross-origin requests
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify exact origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load seed data on startup
student_requests: dict[int, StudentRequest] = {}


@app.on_event("startup")
async def startup_event():
    """Load deterministic seed data when the application starts"""
    seed_data = get_seed_data()
    for request in seed_data:
        student_requests[request.id] = request


@app.get("/health")
async def health_check():
    """
    Health check endpoint for monitoring service availability.
    Returns 200 OK when the service is running.
    """
    return {"status": "healthy", "service": "strangler-studio-api"}


@app.get("/requests", response_model=list[StudentRequest], tags=["requests"])
async def list_requests():
    """
    List all Student Requests.
    
    Returns a list of all Student Request objects in the system.
    Conforms to the OpenAPI contract specification.
    """
    return list(student_requests.values())


@app.get("/requests/{id}", response_model=StudentRequest, tags=["requests"])
async def get_request_by_id(id: int):
    """
    Get Student Request by ID.
    
    Returns a single Student Request object matching the specified ID.
    Returns 404 if the request is not found.
    
    Args:
        id: Unique identifier of the Student Request (must be >= 1)
    
    Returns:
        StudentRequest object
    
    Raises:
        HTTPException: 404 if request not found
    """
    if id not in student_requests:
        raise HTTPException(status_code=404, detail="Request not found")
    
    return student_requests[id]
