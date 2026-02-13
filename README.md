# 💼 Investment Due Diligence AI

A professional-grade AI-powered investment due diligence system that conducts comprehensive company analysis in minutes instead of weeks.

**FastAPI backend + Modern web frontend** for production-ready deployment.

## 🎯 What This System Does

This system uses **multiple specialized AI agents** to perform institutional-quality investment research automatically:

- **Planner Agent**: Creates targeted research strategies based on your investment context
- **Search Agent**: Conducts 6 parallel web searches with investor focus
- **Financial Analyst**: Evaluates financial performance, growth metrics, and funding history
- **Competitive Analyst**: Assesses market positioning and competitive landscape
- **Risk Analyst**: Identifies and categorizes investment risks across regulatory, market, operational, and financial dimensions
- **Report Writer**: Synthesizes all findings into professional investment memos (2000+ words)
- **Email Agent**: Distributes formatted reports automatically

## ✨ What You Get

### Comprehensive Analysis
- **Financial Performance**: Revenue trends, profitability, burn rate, funding history
- **Competitive Landscape**: Market positioning, key competitors, competitive advantages/threats
- **Risk Assessment**: Regulatory, legal, market, operational, and financial risks
- **Leadership Evaluation**: Team background and execution capability
- **Market Trends**: Industry dynamics and growth opportunities
- **Red Flags**: Automatic identification of concerning signals

### Professional Investment Reports
- **Investment Recommendations**: Strong Buy → Strong Pass with detailed rationale
- **Risk Scoring**: 1-10 scale with category breakdowns
- **Investment Thesis**: Bull case, bear case, and base case scenarios
- **Executive Summary**: Quick decision-making insights
- **Actionable Next Steps**: Clear recommendations for further diligence
- **Comprehensive Reports**: 2000+ word detailed analysis

### Advanced Capabilities
- ⚡ **Parallel Research**: 6 simultaneous searches for maximum speed
- 📊 **Real-time Progress**: Live updates during 10-15 minute analysis
- 🔒 **Structured Data**: Type-safe outputs with Pydantic models
- 📈 **Confidence Scoring**: Data quality and recommendation confidence levels
- 📧 **Email Distribution**: Automated report delivery via SendGrid
- 🔍 **OpenAI Traces**: Full execution monitoring and debugging

## 📊 Business Impact

### ROI Comparison

| Metric | Traditional Due Diligence | AI-Powered | Improvement |
|--------|--------------------------|------------|-------------|
| **Time** | 2-4 weeks | 10-15 minutes | **2,000x faster** |
| **Cost** | $50K-$200K | $5-$10 | **99.99% cheaper** |
| **Coverage** | Limited sources | Comprehensive web research | **10x more sources** |
| **Consistency** | Variable quality | Systematic analysis | **100% coverage** |

### Use Cases
- 💼 **Venture Capital**: Startup evaluation and portfolio monitoring
- 🏢 **Private Equity**: Acquisition target assessment
- 🤝 **Corporate Development**: M&A due diligence
- 📈 **Strategic Planning**: Competitive intelligence gathering
- 🏦 **Investment Banking**: Deal screening and preliminary analysis

## 🏗️ Architecture

```
investment_due_diligence_ai/
├── backend/                    # API FastAPI
│   ├── main.py                # Point d'entrée API
│   ├── diligence_manager.py   # Orchestration des agents
│   ├── *_agent.py             # Agents spécialisés
│   ├── models.py              # Modèles Pydantic
│   ├── config.py              # Configuration
│   └── run.py                 # Script de lancement
│
├── frontend/                   # Interface Web
│   ├── index.html             # Page principale
│   ├── styles.css             # Styles modernes
│   └── app.js                 # Logique frontend
│
├── pyproject.toml             # Configuration uv
├── .env                       # Variables d'environnement
└── README.md                  # Ce fichier
```

## 🚀 Quick Start

### Prerequisites
- Python 3.12+ (automatically installed by uv)
- [uv](https://docs.astral.sh/uv/) - Modern Python package manager
- **OpenAI API key** (required) - Get one at https://platform.openai.com/api-keys
- **SendGrid API key** (optional) - For email distribution features

### Installation avec uv

```bash
# 1. Update uv (if needed)
uv self update

# 2. Configure environment variables
# Edit the .env file at the project root and add your API keys:
# OPENAI_API_KEY=sk-your_key_here
# SENDGRID_API_KEY=your_key_here  # Optional

# 3. Sync environment (installs Python 3.12 and all dependencies)
uv sync

# 4. Update requirements.txt for deployment
# Use the provided script to regenerate requirements.txt without Windows-only dependencies
.\update-requirements.bat

# That's it! uv created a .venv virtual environment and installed everything
```

## 🎯 Launch Application

### Option 1: Automatic Start (Windows)

```bash
.\start.bat
```

This automatically launches both backend and frontend in separate windows.

### Option 2: Manual Start (Recommended for Development)

**Terminal 1 - Backend:**
```bash
cd backend
uv run run.py
```
Backend starts on `http://localhost:8080`

**Terminal 2 - Frontend:**
```bash
cd frontend
python -m http.server 3000
```
Frontend accessible at `http://localhost:3000`

## 📖 How to Use

### Basic Analysis
1. Open your browser to `http://localhost:3000`
2. Enter the company name (e.g., "Anthropic", "Stripe", "OpenAI")
3. Optionally provide investment context for focused analysis
4. Click "🚀 Run Due Diligence"
5. Monitor real-time progress through 8 stages
6. Review comprehensive analysis across multiple tabs

### Investment Context Examples

Providing context helps the AI focus on what matters most to you:

**Venture Capital:**
- "Considering $500M Series D investment. Evaluating AI safety positioning and competitive moat."
- "Pre-seed evaluation. Assess founding team and product-market fit."
- "Series B follow-on decision. Focus on unit economics and growth trajectory."

**Private Equity:**
- "Potential acquisition target. Focus on integration risks and synergies with portfolio companies."
- "Buyout opportunity. Evaluate cash flow stability and debt capacity."
- "Growth equity investment. Assess scalability and market expansion potential."

**Corporate Development:**
- "Strategic acquisition. Analyze technology stack compatibility and talent retention."
- "Competitive threat assessment. Evaluate their go-to-market strategy."
- "Partnership evaluation. Focus on complementary capabilities."

**General Investment:**
- "Pre-IPO evaluation. Assess market position and public market readiness."
- "Late-stage fintech investment. Focus on regulatory compliance and unit economics."
- "AI infrastructure play. Evaluate technical moat and competitive landscape."

## 📡 API Endpoints

### `GET /`
Point d'entrée de l'API avec informations de version

### `GET /health`
Health check de l'API

### `GET /api/analyze`
**Analyse en streaming (Server-Sent Events)**
- Retourne les mises à jour en temps réel
- Idéal pour l'interface utilisateur

**Query Parameters:**
- `company_name` (required): Nom de l'entreprise
- `investment_context` (optional): Contexte d'investissement

**Example:**
```
GET /api/analyze?company_name=Anthropic&investment_context=Series%20D%20evaluation
```

**Response:** Stream SSE avec updates progressifs

### `POST /api/analyze-sync`
**Analyse synchrone**
- Attend la fin de l'analyse
- Retourne le rapport complet

**Response:**
```json
{
  "success": true,
  "company_name": "Anthropic",
  "report": { ... }
}
```

## 🎨 Web Interface Features

### User Experience
- ✅ **Modern, Responsive Design**: Works on desktop, tablet, and mobile
- ✅ **Real-time Progress Bar**: Visual feedback through 8 analysis stages
- ✅ **Tabbed Results**: Organized presentation of findings
  - Executive Summary
  - Financial Analysis
  - Competitive Analysis
  - Risk Assessment
  - Full Report
  - Research Details
- ✅ **Click-to-Use Examples**: Quick start with sample companies
- ✅ **Markdown Rendering**: Professional report formatting
- ✅ **Risk Indicators**: Visual scoring and color-coded alerts
- ✅ **OpenAI Trace Links**: Direct access to execution details

### Progress Tracking Stages
1. **Initialization** (0%): Setting up analysis
2. **Planning** (10-20%): Creating research strategy
3. **Research** (25-60%): Conducting 6 parallel searches
4. **Financial Analysis** (65%): Evaluating metrics
5. **Competitive Analysis** (70%): Assessing market position
6. **Risk Assessment** (75%): Identifying risks
7. **Report Writing** (80-90%): Synthesizing findings
8. **Complete** (100%): Report ready

## 🔧 Configuration

### Backend (`backend/config.py`)
```python
NUM_SEARCHES = 6              # Nombre de recherches parallèles
DEFAULT_MODEL = "gpt-4o-mini" # Modèle par défaut
ADVANCED_MODEL = "gpt-4o"     # Modèle avancé pour le rapport
API_HOST = "0.0.0.0"
API_PORT = 8000
```

### Frontend (`frontend/app.js`)
```javascript
const API_BASE_URL = 'http://localhost:8000';
```

## 📊 Flux de Données

```
Frontend (Browser)
    ↓ HTTP POST
Backend API (FastAPI)
    ↓ Async
DiligenceManager
    ↓ Parallel
6 AI Agents (Search, Analysis, Writing)
    ↓ Streaming
Real-time Updates → Frontend
    ↓ Complete
Final Report Display
```

## 🎓 Avantages de cette Architecture

### Séparation Frontend/Backend
- **Scalabilité** : Backend et frontend peuvent être déployés séparément
- **Flexibilité** : Plusieurs frontends possibles (web, mobile, CLI)
- **Performance** : API peut servir plusieurs clients simultanément

### FastAPI
- **Async natif** : Parfait pour les agents IA
- **Documentation auto** : Swagger UI sur `/docs`
- **Type safety** : Validation Pydantic
- **WebSockets/SSE** : Streaming en temps réel

### Frontend Moderne
- **Pas de framework** : HTML/CSS/JS pur, léger et rapide
- **Responsive** : Fonctionne sur mobile et desktop
- **SSE** : Mises à jour en temps réel sans polling

## 🚀 Deployment Options

This project supports multiple deployment strategies to fit different needs and scales.

### **Option 1: Local Development (Recommended for Testing)**

**Quick Start with Batch Scripts (Windows):**
```bash
.\start.bat
```
This automatically launches both backend (port 8080) and frontend (port 3000) in separate windows.

**Manual Start:**
```bash
# Terminal 1 - Backend
cd backend
uv run run.py

# Terminal 2 - Frontend
cd frontend
python -m http.server 3000
```

---

### **Option 2: Docker Compose (Local Production-like)**

**Build and run:**
```bash
.\docker-build.bat
docker-compose up -d
```

---

### **Option 3: Google Cloud Run (Production) ✅**

**Automated Deployment:**
```bash
.\deploy-cloud-run.bat
```

**Why Cloud Run?**
- Serverless, auto-scaling, 1-10€/month
- HTTPS included, production-ready
- See `0 Docs/Deploiement/10-Cloud-Run-Deployment.md`

---

### **Option 4: Kubernetes**

```bash
kubectl apply -f k8s/
```
See `0 Docs/Deploiement/08-Kubernetes-Deployment.md`

---

## 📈 Améliorations Futures

- [ ] Authentification utilisateur
- [ ] Base de données pour historique
- [ ] Cache Redis pour résultats
- [ ] WebSocket pour chat en temps réel
- [ ] Export PDF des rapports
- [ ] Comparaison multi-entreprises
- [ ] Dashboard analytics
- [ ] Tests unitaires et E2E

## 🔗 Documentation API

Une fois le backend lancé, accédez à :
- **Swagger UI** : `http://localhost:8080/docs`
- **ReDoc** : `http://localhost:8080/redoc`

## 🔧 Advanced Configuration

### Customizing Analysis (`backend/config.py`)
```python
NUM_SEARCHES = 6              # Number of parallel searches (adjust based on needs)
DEFAULT_MODEL = "gpt-4o-mini" # Cost-efficient model for agents
ADVANCED_MODEL = "gpt-4o"     # High-quality model for final report
API_HOST = "0.0.0.0"          # API host
API_PORT = 8080               # API port
```

### Research Categories
The planner creates searches across these dimensions:
- Financial Performance & Metrics
- Competitive Landscape & Market Position
- Regulatory & Legal Environment
- Leadership & Team
- Technology & Product
- Market Trends & Opportunities

### Structured Output Models
All agents use Pydantic models for type-safe, validated outputs:
- `SearchPlan`: Research strategy with targeted searches
- `SearchResult`: Individual search findings with key points
- `FinancialMetrics`: Revenue, profitability, funding, burn rate
- `CompetitiveAnalysis`: Market position, competitors, advantages/threats
- `RiskAssessment`: Categorized risks across 4 dimensions
- `DueDiligenceReport`: Complete investment memo with recommendation

## ⚠️ Important Security Notes

- **API Keys**: Never commit `.env` file to version control
- **Production**: Add authentication (JWT, OAuth) before public deployment
- **HTTPS**: Use SSL/TLS certificates in production
- **Rate Limiting**: Implement request throttling to prevent abuse
- **Input Validation**: Already implemented via Pydantic models
- **CORS**: Configure properly for your frontend domain

## 🔗 Resources

- [OpenAI Agents SDK Documentation](https://platform.openai.com/docs/agents)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Pydantic Documentation](https://docs.pydantic.dev/)
- [View Execution Traces](https://platform.openai.com/traces)
- [uv Package Manager](https://docs.astral.sh/uv/)

## 🐛 Troubleshooting

### Backend won't start
- Verify `uv sync` completed successfully
- Check `.env` file exists at project root with `OPENAI_API_KEY`
- Ensure no other process is using port 8080
- Check backend terminal for error messages

### Frontend can't connect to backend
- Verify backend is running on port 8080
- Check `frontend/app.js` has correct API URL: `http://localhost:8080`
- Look for CORS errors in browser console
- Verify firewall isn't blocking local connections

### Analysis fails or times out
- Check OpenAI API key is valid and has credits
- Verify you're not hitting rate limits (check OpenAI dashboard)
- Review OpenAI traces for specific agent failures
- Try with a well-known company first (e.g., "Stripe")

### "Module not found" errors
```bash
uv sync  # Reinstall all dependencies
```

### Email sending fails
- Email failure won't stop the analysis
- Check SendGrid API key in `.env`
- Verify sender email is configured in `email_agent.py`
- Review backend logs for specific error messages