"""
Configuration settings for Investment Due Diligence Backend
"""

# Search Configuration
NUM_SEARCHES = 6

# Research Categories
RESEARCH_CATEGORIES = [
    "Financial Performance",
    "Competitive Analysis", 
    "Regulatory & Legal",
    "Leadership & Team",
    "Market Position",
    "Risk Assessment"
]

# Investment Recommendation Levels
RECOMMENDATION_LEVELS = [
    "Strong Buy",
    "Buy", 
    "Hold",
    "Pass",
    "Strong Pass"
]

# Risk Score Thresholds
RISK_THRESHOLDS = {
    "low": (1, 3),
    "medium": (4, 6),
    "high": (7, 8),
    "critical": (9, 10)
}

# Model Configuration
DEFAULT_MODEL = "gpt-4o-mini"
ADVANCED_MODEL = "gpt-4o"

# API Configuration
API_HOST = "0.0.0.0"
API_PORT = 8080
