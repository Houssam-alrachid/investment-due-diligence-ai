// Frontend JavaScript for Investment Due Diligence

const API_BASE_URL = 'http://localhost:8080';

// DOM Elements
const companyNameInput = document.getElementById('companyName');
const investmentContextInput = document.getElementById('investmentContext');
const analyzeBtn = document.getElementById('analyzeBtn');
const progressSection = document.getElementById('progressSection');
const progressBar = document.getElementById('progressBar');
const progressStatus = document.getElementById('progressStatus');
const progressLog = document.getElementById('progressLog');
const resultsSection = document.getElementById('resultsSection');
const tabButtons = document.querySelectorAll('.tab-button');
const tabPanels = document.querySelectorAll('.tab-panel');
const exampleCards = document.querySelectorAll('.example-card');

// Markdown to HTML converter (simple version)
function markdownToHtml(markdown) {
    if (!markdown) return '';
    
    let html = markdown
        // Headers
        .replace(/^### (.*$)/gim, '<h3>$1</h3>')
        .replace(/^## (.*$)/gim, '<h2>$1</h2>')
        .replace(/^# (.*$)/gim, '<h1>$1</h1>')
        // Bold
        .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
        // Lists
        .replace(/^\- (.*$)/gim, '<li>$1</li>')
        // Line breaks
        .replace(/\n\n/g, '</p><p>')
        .replace(/\n/g, '<br>');
    
    // Wrap lists
    html = html.replace(/(<li>.*<\/li>)/s, '<ul>$1</ul>');
    
    // Wrap paragraphs
    if (!html.startsWith('<h') && !html.startsWith('<ul')) {
        html = '<p>' + html + '</p>';
    }
    
    return html;
}

// Tab switching
tabButtons.forEach(button => {
    button.addEventListener('click', () => {
        const tabName = button.dataset.tab;
        
        // Update buttons
        tabButtons.forEach(btn => btn.classList.remove('active'));
        button.classList.add('active');
        
        // Update panels
        tabPanels.forEach(panel => panel.classList.remove('active'));
        document.getElementById(tabName).classList.add('active');
    });
});

// Example cards
exampleCards.forEach(card => {
    card.addEventListener('click', () => {
        companyNameInput.value = card.dataset.company;
        investmentContextInput.value = card.dataset.context;
        companyNameInput.scrollIntoView({ behavior: 'smooth' });
    });
});

// Main analysis function
async function runAnalysis() {
    const companyName = companyNameInput.value.trim();
    const investmentContext = investmentContextInput.value.trim();
    
    if (!companyName) {
        alert('Please enter a company name');
        return;
    }
    
    // Reset UI
    analyzeBtn.disabled = true;
    analyzeBtn.textContent = '⏳ Analyzing...';
    progressSection.classList.remove('hidden');
    resultsSection.classList.add('hidden');
    progressLog.innerHTML = '';
    progressBar.style.width = '0%';
    
    try {
        // Create EventSource for Server-Sent Events
        const eventSource = new EventSource(
            `${API_BASE_URL}/api/analyze?` + new URLSearchParams({
                company_name: companyName,
                investment_context: investmentContext
            })
        );
        
        // Handle messages
        eventSource.onmessage = (event) => {
            const update = JSON.parse(event.data);
            
            // Update progress
            if (update.progress !== undefined) {
                progressBar.style.width = `${update.progress}%`;
                progressBar.textContent = `${update.progress}%`;
            }
            
            // Update status
            if (update.status) {
                progressStatus.textContent = update.status;
                
                // Add to log
                const logEntry = document.createElement('div');
                logEntry.textContent = `[${update.progress}%] ${update.status}`;
                progressLog.appendChild(logEntry);
                progressLog.scrollTop = progressLog.scrollHeight;
            }
            
            // Handle completion
            if (update.stage === 'complete' && update.data && update.data.report) {
                eventSource.close();
                displayResults(update.data.report);
                analyzeBtn.disabled = false;
                analyzeBtn.textContent = '🚀 Run Due Diligence';
            }
            
            // Handle errors
            if (update.stage === 'error') {
                eventSource.close();
                alert(`Analysis failed: ${update.error}`);
                analyzeBtn.disabled = false;
                analyzeBtn.textContent = '🚀 Run Due Diligence';
            }
        };
        
        eventSource.onerror = (error) => {
            console.error('EventSource error:', error);
            eventSource.close();
            alert('Connection error. Please try again.');
            analyzeBtn.disabled = false;
            analyzeBtn.textContent = '🚀 Run Due Diligence';
        };
        
    } catch (error) {
        console.error('Analysis error:', error);
        alert(`Error: ${error.message}`);
        analyzeBtn.disabled = false;
        analyzeBtn.textContent = '🚀 Run Due Diligence';
    }
}

// Display results
function displayResults(report) {
    resultsSection.classList.remove('hidden');
    resultsSection.scrollIntoView({ behavior: 'smooth' });
    
    // Executive Summary
    const summaryHtml = `
        <div class="summary-card">
            <h2>📊 Investment Recommendation: <strong>${report.recommendation}</strong></h2>
            <div class="metrics-grid">
                <div class="metric">
                    <h3>Risk Score</h3>
                    <p class="metric-value risk-${getRiskLevel(report.risk_score)}">${report.risk_score}/10</p>
                </div>
                <div class="metric">
                    <h3>Confidence Level</h3>
                    <p class="metric-value">${report.confidence_level.toUpperCase()}</p>
                </div>
                <div class="metric">
                    <h3>Data Quality</h3>
                    <p class="metric-value">${report.data_quality_score}/10</p>
                </div>
            </div>
            <hr>
            ${markdownToHtml(report.executive_summary)}
        </div>
    `;
    document.getElementById('summary').innerHTML = summaryHtml;
    
    // Key Findings
    const strengthsList = report.key_strengths.map(s => `<li>✅ ${s}</li>`).join('');
    const concernsList = report.key_concerns.map(c => `<li>⚠️ ${c}</li>`).join('');
    const findingsHtml = `
        <h3>💪 Key Strengths</h3>
        <ul>${strengthsList}</ul>
        <h3>🚨 Key Concerns</h3>
        <ul>${concernsList}</ul>
    `;
    document.getElementById('findings').innerHTML = findingsHtml;
    
    // Investment Thesis
    const thesisHtml = `
        <h2>Investment Thesis</h2>
        ${markdownToHtml(report.investment_thesis)}
        <h3>Valuation Assessment</h3>
        ${markdownToHtml(report.valuation_assessment)}
    `;
    document.getElementById('thesis').innerHTML = thesisHtml;
    
    // Next Steps
    const actionsList = report.recommended_actions.map((a, i) => `<li>${i+1}. ${a}</li>`).join('');
    const researchList = report.additional_research_needed.map(r => `<li>${r}</li>`).join('');
    const stepsHtml = `
        <h3>📋 Recommended Actions</h3>
        <ol>${actionsList}</ol>
        <h3>🔍 Additional Research Needed</h3>
        <ul>${researchList}</ul>
    `;
    document.getElementById('steps').innerHTML = stepsHtml;
    
    // Full Report
    document.getElementById('report').innerHTML = markdownToHtml(report.markdown_report);
}

// Get risk level class
function getRiskLevel(score) {
    if (score <= 3) return 'low';
    if (score <= 6) return 'medium';
    if (score <= 8) return 'high';
    return 'critical';
}

// Event listeners
analyzeBtn.addEventListener('click', runAnalysis);

// Allow Enter key in company name field
companyNameInput.addEventListener('keypress', (e) => {
    if (e.key === 'Enter') {
        runAnalysis();
    }
});
