"""
FastAPI Backend for Investment Due Diligence
Exposes HTTP endpoints for the frontend to interact with the due diligence system.
"""
from fastapi import FastAPI, HTTPException # FastAPI : Web framework for building APIs/ HTTPException : Raises HTTP exceptions
from fastapi.middleware.cors import CORSMiddleware # allows frontend to call backend
from fastapi.responses import StreamingResponse # Returns streaming responses
from pydantic import BaseModel # Pydantic model for structured data
from dotenv import load_dotenv # Loads environment variables from .env file
from pathlib import Path
import json
import asyncio # Asynchronous execution and parallel processing
from diligence_manager import DiligenceManager # Manages the complete investment due diligence workflow      

# Load environment variables from project root
env_path = Path(__file__).parent.parent / '.env'
load_dotenv(dotenv_path=env_path, override=True)

# Initialize FastAPI app with metadata that appears in auto-generated docs at /docs
app = FastAPI(
    title="Investment Due Diligence API",
    description="AI-powered investment analysis and due diligence",
    version="1.0.0"
)

# CORS configuration for frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify exact origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Pydantic models for structured data   
class AnalysisRequest(BaseModel):
    company_name: str
    investment_context: str = ""


class AnalysisStatus(BaseModel):
    status: str
    progress: int
    stage: str

# Root endpoint
@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": "Investment Due Diligence API",
        "version": "1.0.0",
        "docs": "/docs"
    }

# Health check endpoint
@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy"}

# Analyze endpoint (GET for SSE compatibility)
@app.get("/api/analyze")
async def analyze_company(company_name: str, investment_context: str = ""):
    """
    Start investment due diligence analysis (GET for SSE compatibility)
    Returns streaming updates via Server-Sent Events (SSE)
    """
    # Validate company name
    if not company_name.strip():
        raise HTTPException(status_code=400, detail="Company name is required")
    
    # Generate SSE updates
    async def generate_updates():
        """Generate SSE updates"""
        manager = DiligenceManager() # Creates DiligenceManager instance
        
        try:
            # Run workflow
            async for update in manager.run(company_name, investment_context):
                # For each progress update from the async generator: 
                # Converts update dict to JSON, Formats as SSE, Yields to client
                yield f"data: {json.dumps(update)}\n\n"
                
        except Exception as e:
            error_update = {
                "status": f"Error: {str(e)}",
                "progress": 0,
                "stage": "error",
                "error": str(e)
            }
            yield f"data: {json.dumps(error_update)}\n\n"
    # Returns StreamingResponse object with SSE updates
    return StreamingResponse(
        generate_updates(),
        media_type="text/event-stream", # Media type for Server-Sent Events
        headers={
            "Cache-Control": "no-cache", # Prevents browser from caching the response
            "Connection": "keep-alive", # Keeps connection open for streaming
        }
    )


# Synchronous Analysis endpoint (POST)
# Alternative endpoint that waits for completion before responding
@app.post("/api/analyze-sync")
async def analyze_company_sync(request: AnalysisRequest):
    """
    Synchronous analysis endpoint (waits for completion)
    Returns final report
    """
    # Validate company name
    if not request.company_name.strip():
        raise HTTPException(status_code=400, detail="Company name is required")
    
    manager = DiligenceManager()
    final_report = None
    
    try:
        # Run due diligence workflow
        # Ignores all progress updates (doesn't send them to client)
        # Only returns final report as single JSON response
        # Use case: For batch processing or when you don't need real-time updates
        async for update in manager.run(request.company_name, request.investment_context):
            if update.get("stage") == "complete":
                final_report = update.get("data", {}).get("report")
                break
        
        if not final_report:
            raise HTTPException(status_code=500, detail="Analysis failed to complete")
        
        return {
            "success": True,
            "company_name": request.company_name,
            "report": final_report
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Run app
if __name__ == "__main__": # Only runs when executing python main.py directly
    import uvicorn
    from config import API_HOST, API_PORT
    
    uvicorn.run(
        "main:app", # Module name and app variable
        host=API_HOST, # Host to bind to
        port=API_PORT, # Port to listen on
        reload=True, # Reload server on code changes (development only)
        log_level="info" # Log level
    )
