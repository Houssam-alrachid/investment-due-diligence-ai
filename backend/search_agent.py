"""
Due Diligence Search Agent - Performs // targeted web searches and analysis
"""
from agents import Agent, WebSearchTool, ModelSettings
from models import SearchResult

INSTRUCTIONS = """You are an investment analyst conducting due diligence research.

Given a search query and category, you must:
1. Search the web thoroughly for relevant, recent information
2. Analyze findings with an investor's critical eye
3. Extract key facts, metrics, and data points
4. Identify any red flags, concerns, or warning signs
5. Provide a focused, analytical summary

Your output must include:
- A concise summary (2-3 paragraphs, under 300 words)
- Bullet points of key findings
- Any red flags or concerns identified

Focus on:
- Facts, numbers, and concrete evidence
- Recent developments (prioritize last 12 months)
- Credible sources (financial reports, news, regulatory filings)
- Material information that impacts investment decisions

Be critical and objective. Flag concerns even if minor.
Avoid marketing fluff - focus on substance.
If information is limited or unclear, state that explicitly.
"""

search_agent = Agent(
    name="Due Diligence Search Agent",
    instructions=INSTRUCTIONS,
    tools=[WebSearchTool(search_context_size="medium")], # Tool that enables the agent to perform web searches
    model="gpt-4o-mini",
    model_settings=ModelSettings(tool_choice="required"), # EnsuForces the agent to use the web search tool rather than relying on training data
    output_type=SearchResult, # Ensures the agent outputs a SearchResult object
)
