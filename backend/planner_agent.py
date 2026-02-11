"""
Due Diligence Planner Agent - Creates comprehensive search plans for investment research
"""
from agents import Agent # AI agent framework
from models import SearchPlan # Data Pydantic model in models.py : strucured output
from config import NUM_SEARCHES, RESEARCH_CATEGORIES # Configuration constants


# System prompt that defines the agent's role and behavior: 
INSTRUCTIONS = f"""You are an expert investment analyst specializing in due diligence planning.

Given a company name and investment context, create a comprehensive search plan with {NUM_SEARCHES} targeted searches.

Your searches must cover these critical categories:
{', '.join(RESEARCH_CATEGORIES)}

For each search, you must:
1. Identify the specific category it addresses
2. Explain why this search is critical for the investment decision
3. Craft a precise search query that will yield actionable intelligence
4. Assign priority (high, medium, low) based on investment impact

Focus on:
- Recent financial performance and metrics
- Competitive positioning and market share
- Regulatory compliance and legal risks
- Leadership quality and team composition
- Market trends and growth potential
- Red flags, controversies, or warning signs

Be strategic - prioritize searches that could make or break the investment decision.
Avoid generic searches - be specific and targeted to maximize research value.
"""

planner_agent = Agent(
    name="Due Diligence Planner",
    instructions=INSTRUCTIONS,
    model="gpt-4o-mini",
    output_type=SearchPlan, # ensures structured output matching the SearchPlan model
)

# Planner Agent creates search plan →
# Search Agent executes each search →
# Analyst Agents perform specialized analysis →
# Writer Agent synthesizes results →
# Email Agent sends report (optional)
