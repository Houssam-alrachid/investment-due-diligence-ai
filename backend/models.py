"""
Pydantic models for structured outputs in Investment Due Diligence
"""
from pydantic import BaseModel, Field
from typing import List, Optional


class SearchItem(BaseModel):
    """Individual search query with metadata"""
    category: str = Field(description="Research category: Financial, Competitive, Regulatory, Leadership, Market, or Risk")
    reason: str = Field(description="Why this search is critical for investment decision")
    query: str = Field(description="The specific search term to use")
    priority: str = Field(description="Priority level: high, medium, or low", default="medium")


class SearchPlan(BaseModel):
    """Complete search plan for due diligence"""
    company_name: str = Field(description="The company being researched")
    investment_context: str = Field(description="Investment context and objectives")
    searches: List[SearchItem] = Field(description="List of targeted searches to perform")


class SearchResult(BaseModel):
    """Result from a single search"""
    category: str = Field(description="Research category")
    query: str = Field(description="Search query used")
    findings: str = Field(description="Summary of search findings")
    key_points: List[str] = Field(description="Bullet points of key findings")
    red_flags: List[str] = Field(description="Any concerns or red flags identified", default_factory=list)


class FinancialMetrics(BaseModel):
    """Financial performance indicators"""
    revenue_trend: str = Field(description="Revenue growth trend")
    profitability: str = Field(description="Profitability status")
    funding_history: str = Field(description="Funding rounds and amounts")
    burn_rate: Optional[str] = Field(description="Cash burn rate if available", default=None)
    valuation: Optional[str] = Field(description="Current valuation if available", default=None)


class CompetitiveAnalysis(BaseModel):
    """Competitive positioning assessment"""
    market_position: str = Field(description="Position in the market")
    key_competitors: List[str] = Field(description="Main competitors")
    competitive_advantages: List[str] = Field(description="Unique advantages")
    competitive_threats: List[str] = Field(description="Competitive threats")


class RiskAssessment(BaseModel):
    """Comprehensive risk evaluation"""
    regulatory_risks: List[str] = Field(description="Regulatory and compliance risks")
    market_risks: List[str] = Field(description="Market and industry risks")
    operational_risks: List[str] = Field(description="Operational and execution risks")
    financial_risks: List[str] = Field(description="Financial risks")
    overall_risk_level: str = Field(description="Overall risk: low, medium, high, or critical")


class DueDiligenceReport(BaseModel):
    """Complete investment due diligence report"""
    company_name: str = Field(description="Company being evaluated")
    report_date: str = Field(description="Date of report generation")
    
    # Executive Summary
    recommendation: str = Field(description="Investment recommendation: Strong Buy, Buy, Hold, Pass, or Strong Pass")
    executive_summary: str = Field(description="3-4 paragraph executive summary")
    risk_score: int = Field(description="Overall risk score from 1-10, where 10 is highest risk")
    
    # Detailed Analysis
    financial_metrics: FinancialMetrics = Field(description="Financial performance analysis")
    competitive_analysis: CompetitiveAnalysis = Field(description="Competitive positioning")
    risk_assessment: RiskAssessment = Field(description="Risk evaluation")
    
    # Key Findings
    key_strengths: List[str] = Field(description="Major strengths and opportunities")
    key_concerns: List[str] = Field(description="Major concerns and red flags")
    
    # Investment Thesis
    investment_thesis: str = Field(description="Detailed investment thesis (3-5 paragraphs)")
    valuation_assessment: str = Field(description="Valuation analysis")
    
    # Full Report
    markdown_report: str = Field(description="Complete detailed report in markdown format (2000+ words)")
    
    # Next Steps
    recommended_actions: List[str] = Field(description="Recommended next steps before investment")
    additional_research_needed: List[str] = Field(description="Areas requiring deeper investigation")
    
    # Metadata
    confidence_level: str = Field(description="Confidence in recommendation: high, medium, or low")
    data_quality_score: int = Field(description="Quality of available data from 1-10")
