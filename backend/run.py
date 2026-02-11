"""
Quick start script for FastAPI Backend
This is a startup script that performs pre-flight checks before launching the FastAPIserver. 
It ensures the environment is properly configured and all dependencies are installed.
"""
import sys
import os
from pathlib import Path

# Function to check environment configuration
def check_environment():
    """Check if environment is properly configured"""
    print("🔍 Checking environment...")
    
    # Check for .env file in project root
    env_path = Path(__file__).parent.parent / '.env'
    
    if not env_path.exists():
        print(f"❌ .env file not found at {env_path}!")
        print("📝 Please create .env file in the project root directory")
        return False
    
    # Check for API key
    from dotenv import load_dotenv
    load_dotenv(dotenv_path=env_path, override=True)
    
    if not os.getenv('OPENAI_API_KEY'):
        print("❌ OPENAI_API_KEY not found in .env!")
        print(f"📝 Please add your OpenAI API key to {env_path}")
        return False
    
    print(f"✅ Environment configured correctly (using {env_path})")
    return True

# Function to check if required packages are installed
def check_dependencies():
    """Check if required packages are installed"""
    print("\n🔍 Checking dependencies...")
    
    # Only check packages that are safe to import at startup
    # 'agents' is checked at runtime when actually needed to avoid TensorFlow import issues
    required = ['fastapi', 'uvicorn', 'pydantic', 'dotenv']
    missing = []
    
    for package in required:
        try:
            __import__(package) # Dynamically imports the package
        except ImportError:
            missing.append(package)
    
    if missing:
        print(f"❌ Missing packages: {', '.join(missing)}")
        print("📦 Install with: uv sync")
        return False
    
    print("✅ Core dependencies installed")
    return True

# Main entry point
def main():
    """Main entry point"""
    print("=" * 60)
    print("💼 Investment Due Diligence API - FastAPI Backend")
    print("=" * 60)
    
    # Run checks
    if not check_dependencies():
        sys.exit(1)
    
    if not check_environment():
        sys.exit(1)
    
    # Launch application
    print("\n🚀 Starting FastAPI server...")
    print("📊 API will be available at http://localhost:8000")
    print("📖 API documentation at http://localhost:8000/docs")
    print("⏹️  Press Ctrl+C to stop\n")
    
    import uvicorn
    from config import API_HOST, API_PORT # from config.py

    uvicorn.run(
        "main:app", # Module name and app variable
        host=API_HOST, # Host to bind to
        port=API_PORT, # Port to listen on
        reload=True, # Reload server on code changes (development only)
        log_level="info" # Log level
    )

if __name__ == "__main__":
    main()
