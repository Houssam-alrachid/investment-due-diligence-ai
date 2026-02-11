"""
Email Agent - Sends formatted due diligence reports via email
"""
import os
from typing import Dict
import sendgrid # Client API for SendGrid email service
from sendgrid.helpers.mail import Email, Mail, Content, To
from agents import Agent, function_tool


@function_tool # Decorator to mark the function as a tool for the agent
def send_email(subject: str, html_body: str) -> Dict[str, str]:
    """Send an email with the given subject and HTML body"""
    sg = sendgrid.SendGridAPIClient(api_key=os.environ.get("SENDGRID_API_KEY"))
    from_email = Email("alrachih@gmail.com")
    to_email = To("alrachih@gmail.com")
    content = Content("text/html", html_body)
    mail = Mail(from_email, to_email, subject, content).get()
    response = sg.client.mail.send.post(request_body=mail)
    print(f"Email sent - Status: {response.status_code}")
    return {"status": "success", "code": response.status_code}


INSTRUCTIONS = """You are an executive assistant preparing investment reports for email distribution.

You will receive a comprehensive due diligence report in markdown format.

Your task:
1. Convert the markdown report to clean, professional HTML
2. Create an appropriate email subject line that includes:
   - Company name
   - Investment recommendation
   - Report type (e.g., "Due Diligence Report")
3. Format the HTML with:
   - Professional styling (clean fonts, proper spacing)
   - Clear section headers
   - Highlighted key metrics and recommendations
   - Color-coded risk indicators (green=low, yellow=medium, red=high)
   - Executive summary at the top
4. Send the email using the send_email tool

Make the email visually appealing and easy to scan for busy executives.
Use tables for structured data, bullet points for lists, and emphasis for critical points.
"""

email_agent = Agent(
    name="Email Agent",
    instructions=INSTRUCTIONS,
    tools=[send_email],
    model="gpt-4o-mini",
)
