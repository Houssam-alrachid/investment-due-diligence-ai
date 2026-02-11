"""
Investment Due Diligence Manager - Orchestrates the complete due diligence workflow with progress tracking in the DiligenceManager class :
- Defined as the program-wide manager for workflow orchestration.
- Coordinates planning, research, analysis, reporting, and distribution stages.
- Uses async generator to yield real-time progress updates.
"""

from agents import Runner, trace, gen_trace_id # Runner : Executes agents asynchronously
# All agents import
from planner_agent import planner_agent
from search_agent import search_agent
from analyst_agent import financial_analyst, competitive_analyst, risk_analyst
from writer_agent import writer_agent
from email_agent import email_agent
# Pydantic models for structured data
from models import SearchPlan, SearchResult, DueDiligenceReport

import asyncio #Asynchronous execution and parallel processing
from datetime import datetime # Date and time handling
from typing import AsyncGenerator, Dict, List # Type hints for async functions


class DiligenceManager:
    """
    Manages the complete investment due diligence workflow with progress tracking
    """
    
    def __init__(self):
        self.trace_id = None # Unique trace ID for OpenAI tracing
        self.search_plan = None # Research plan created by planner agent
        self.search_results = [] # List of search results
        self.report = None # Final investment report
        
    async def run(
        self, 
        company_name: str, 
        investment_context: str = ""
    ) -> AsyncGenerator[Dict, None]: # AsyncGenerator : Yields progress updates as dictionaries in real time
        """
        Execute complete due diligence workflow with real-time progress updates
        
        Yields progress updates as dictionaries with:
        - status: Current status message
        - progress: Progress percentage (0-100)
        - stage: Current stage name
        - data: Optional data payload
        """
        self.trace_id = gen_trace_id()
        
        with trace("Investment Due Diligence", trace_id=self.trace_id): # Generates unique trace_id for OpenAI tracing
            # Stage 1: Initialize
            yield { 
                "status": "Initializing due diligence analysis...",
                "progress": 0,
                "stage": "init",
                "trace_url": f"https://platform.openai.com/traces/trace?trace_id={self.trace_id}"
            }
            
            # Stage 2: Planning
            yield {
                "status": f"Planning research strategy for {company_name}...",
                "progress": 10,
                "stage": "planning"
            }
            # Planner Agent creates search plan
            self.search_plan = await self._plan_research(company_name, investment_context)
            
            # yields progress updates to the client : number of searches and categories
            yield {
                "status": f"Research plan created: {len(self.search_plan.searches)} targeted searches",
                "progress": 20,
                "stage": "planning_complete",
                "data": {
                    "num_searches": len(self.search_plan.searches),
                    "categories": list(set([s.category for s in self.search_plan.searches]))
                }
            }
            
            # Stage 3: Research
            yield {
                "status": "Conducting market research and analysis...",
                "progress": 25,
                "stage": "research"
            }
            # Search Agent executes each search
            async for update in self._perform_research(self.search_plan):
                yield update # Yields progress updates to the client
            
            yield {
                "status": f"Research complete: {len(self.search_results)} searches analyzed",
                "progress": 60,
                "stage": "research_complete"
            }
            
            # Stage 4: Analysis
            yield {
                "status": "Analyzing financial metrics...",
                "progress": 65,
                "stage": "analysis_financial"
            }
            
            financial_analysis = await self._analyze_financials()
            
            yield {
                "status": "Analyzing competitive position...",
                "progress": 70,
                "stage": "analysis_competitive"
            }
            
            competitive_analysis = await self._analyze_competition()
            
            yield {
                "status": "Assessing investment risks...",
                "progress": 75,
                "stage": "analysis_risk"
            }
            
            risk_analysis = await self._assess_risks()
            
            # Stage 5: Report Writing
            yield {
                "status": "Synthesizing findings into investment memo...",
                "progress": 80,
                "stage": "writing"
            }
            
            self.report = await self._write_report(
                company_name,
                investment_context,
                financial_analysis,
                competitive_analysis,
                risk_analysis
            )
            
            yield {
                "status": "Investment report completed",
                "progress": 90,
                "stage": "report_complete",
                "data": {
                    "recommendation": self.report.recommendation,
                    "risk_score": self.report.risk_score,
                    "confidence": self.report.confidence_level
                }
            }
            
            # Stage 6: Email Distribution
            yield {
                "status": "Preparing email distribution...",
                "progress": 95,
                "stage": "email"
            }
            
            await self._send_report()
            
            # Final Stage
            yield {
                "status": "Due diligence complete!",
                "progress": 100,
                "stage": "complete",
                "data": {
                    "report": self.report.model_dump(), # Serializes the report (DueDiligenceReport object) to a dictionary
                    "trace_url": f"https://platform.openai.com/traces/trace?trace_id={self.trace_id}"
                }
            }
    
    async def _plan_research(self, company_name: str, context: str) -> SearchPlan:
        """Create comprehensive research plan"""
        query = f"Company: {company_name}\nInvestment Context: {context}" if context else f"Company: {company_name}"
        result = await Runner.run(planner_agent, query) # Waits for planner agent to finish
        return result.final_output_as(SearchPlan)
    
    async def _perform_research(self, search_plan: SearchPlan) -> AsyncGenerator[Dict, None]:
        """Execute all searches in parallel with progress tracking"""
        total_searches = len(search_plan.searches)
        completed = 0
    
        
        # asyncio.create_task() schedules a task to run in the background //. Doesn't wait for it to finish 
        # asyncio.as_completed() returns an iterator that yields tasks as they complete. First to finish is first to be processed 

        # Create tasks for parallel execution
        tasks = [
            asyncio.create_task(self._execute_search(item))
            for item in search_plan.searches
        ]
        
        # Process results as they complete
        for task in asyncio.as_completed(tasks): 
            result = await task # Waits for each task to complete
            if result:
                self.search_results.append(result)
                completed += 1
                
                progress = 25 + int((completed / total_searches) * 35)
                
                yield {
                    "status": f"Research progress: {completed}/{total_searches} searches complete",
                    "progress": progress,
                    "stage": "research",
                    "data": {
                        "completed": completed,
                        "total": total_searches,
                        "latest_category": result.category
                    }
                }
    
    async def _execute_search(self, search_item) -> SearchResult | None:
        """Execute a single search"""
        try:
            input_data = f"Category: {search_item.category}\nQuery: {search_item.query}\nReason: {search_item.reason}"
            result = await Runner.run(search_agent, input_data)
            return result.final_output_as(SearchResult)
        except Exception as e:
            print(f"Search failed for {search_item.query}: {e}")
            return None
    
    async def _analyze_financials(self):
        """Analyze financial performance"""
        # Filters search results for financial categories  
        financial_findings = [
            r for r in self.search_results 
            if r.category in ["Financial Performance", "Financial", "Market Position"]
        ]
        
        input_data = "Research Findings:\n" + "\n\n".join([
            f"[{r.category}]\n{r.findings}\nKey Points: {', '.join(r.key_points)}"
            for r in financial_findings
        ])
        
        result = await Runner.run(financial_analyst, input_data)
        return result.final_output
    
    async def _analyze_competition(self):
        """Analyze competitive positioning"""
        competitive_findings = [
            r for r in self.search_results 
            if r.category in ["Competitive Analysis", "Market Position", "Competitive"]
        ]
        
        input_data = "Research Findings:\n" + "\n\n".join([
            f"[{r.category}]\n{r.findings}\nKey Points: {', '.join(r.key_points)}"
            for r in competitive_findings
        ])
        
        result = await Runner.run(competitive_analyst, input_data)
        return result.final_output
    
    async def _assess_risks(self):
        """Assess investment risks"""
        all_findings = "\n\n".join([
            f"[{r.category}]\n{r.findings}\nKey Points: {', '.join(r.key_points)}\nRed Flags: {', '.join(r.red_flags) if r.red_flags else 'None'}"
            for r in self.search_results
        ])
        
        input_data = f"All Research Findings:\n{all_findings}"
        
        result = await Runner.run(risk_analyst, input_data)
        return result.final_output
    
    async def _write_report(
        self, 
        company_name: str, 
        context: str,
        financial_analysis,
        competitive_analysis,
        risk_analysis
    ) -> DueDiligenceReport:
        """Generate comprehensive investment report"""
        
        # Compile all research data
        research_summary = "\n\n".join([
            f"### {r.category}\n**Query:** {r.query}\n\n{r.findings}\n\n**Key Points:**\n" + 
            "\n".join([f"- {p}" for p in r.key_points]) +
            (f"\n\n**Red Flags:**\n" + "\n".join([f"- ⚠️ {f}" for f in r.red_flags]) if r.red_flags else "")
            for r in self.search_results
        ])
        
        input_data = f"""Company: {company_name}
Investment Context: {context}
Report Date: {datetime.now().strftime('%Y-%m-%d')}

RESEARCH FINDINGS:
{research_summary}

FINANCIAL ANALYSIS:
Revenue Trend: {financial_analysis.revenue_trend}
Profitability: {financial_analysis.profitability}
Funding History: {financial_analysis.funding_history}
Burn Rate: {financial_analysis.burn_rate or 'Not available'}
Valuation: {financial_analysis.valuation or 'Not available'}

COMPETITIVE ANALYSIS:
Market Position: {competitive_analysis.market_position}
Key Competitors: {', '.join(competitive_analysis.key_competitors)}
Competitive Advantages: {', '.join(competitive_analysis.competitive_advantages)}
Competitive Threats: {', '.join(competitive_analysis.competitive_threats)}

RISK ASSESSMENT:
Overall Risk Level: {risk_analysis.overall_risk_level}
Regulatory Risks: {', '.join(risk_analysis.regulatory_risks)}
Market Risks: {', '.join(risk_analysis.market_risks)}
Operational Risks: {', '.join(risk_analysis.operational_risks)}
Financial Risks: {', '.join(risk_analysis.financial_risks)}
"""
        
        result = await Runner.run(writer_agent, input_data)
        return result.final_output_as(DueDiligenceReport)
    
    async def _send_report(self):
        """Send report via email"""
        try:
            await Runner.run(email_agent, self.report.markdown_report)
        except Exception as e:
            print(f"Email sending failed: {e}")
            # Don't fail the whole process if email fails
