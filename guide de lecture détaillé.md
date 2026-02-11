# 📚 Guide de Lecture du Code - Investment Due Diligence AI

Voici un guide structuré pour comprendre le projet dans l'ordre optimal :

## 🎯 **Phase 1 : Organisation & Configuration**

### 1. **Structure du Projet**
- `@c:\Users\houssam.alrachid\Desktop\investment_due_diligence_ai\README.md:66-83` - Architecture complète
- Le projet suit une architecture **Frontend/Backend séparée**

### 2. **Gestion des Dépendances (uv)**
- `@c:\Users\houssam.alrachid\Desktop\investment_due_diligence_ai\pyproject.toml:1-26` - Configuration moderne avec **uv**
- `@c:\Users\houssam.alrachid\Desktop\investment_due_diligence_ai\requirements.txt:1-167` - Dépendances verrouillées (généré automatiquement)

**Dépendances clés :**
- **FastAPI** : Framework API async
- **openai-agents** : SDK pour agents IA
- **Pydantic** : Validation de données
- **SendGrid** : Envoi d'emails
- **uvicorn** : Serveur ASGI

### 3. **Git & Environnement**
- `@c:\Users\houssam.alrachid\Desktop\investment_due_diligence_ai\.gitignore:1-49` - Fichiers exclus du versioning
- `@c:\Users\houssam.alrachid\Desktop\investment_due_diligence_ai\.env` - Variables d'environnement (API keys)

### 4. **Script de Démarrage**
- `@c:\Users\houssam.alrachid\Desktop\investment_due_diligence_ai\start.bat:1-24` - Lance backend + frontend automatiquement

---

## 🔧 **Phase 2 : Backend - Ordre de Lecture**

### **Étape 1 : Configuration & Modèles de Données**

#### A. Configuration
```
backend/config.py
```
Contient les constantes globales (ports, modèles IA, nombre de recherches)

#### B. Modèles Pydantic
```
backend/models.py
```
**À lire en premier** - Définit toutes les structures de données :
- `SearchPlan` : Plan de recherche
- `SearchResult` : Résultats de recherche
- `FinancialMetrics` : Métriques financières
- `CompetitiveAnalysis` : Analyse concurrentielle
- `RiskAssessment` : Évaluation des risques
- `DueDiligenceReport` : Rapport final

### **Étape 2 : Les Agents IA (dans cet ordre)**

#### 1. **Planner Agent**
```
backend/planner_agent.py
```
Crée la stratégie de recherche (6 recherches ciblées)

#### 2. **Search Agent**
```
backend/search_agent.py
```
Exécute les recherches web en parallèle

#### 3. **Analyst Agents**
```
backend/analyst_agent.py
```
Contient 3 analystes spécialisés :
- **Financial Analyst** : Métriques financières
- **Competitive Analyst** : Positionnement marché
- **Risk Analyst** : Identification des risques

#### 4. **Writer Agent**
```
backend/writer_agent.py
```
Synthétise tous les résultats en rapport d'investissement professionnel

#### 5. **Email Agent**
```
backend/email_agent.py
```
Envoie le rapport par email (optionnel)

### **Étape 3 : Orchestration**

#### **Diligence Manager**
```
backend/diligence_manager.py
```
**Fichier central** - Orchestre tous les agents :
- Gère le flux de travail complet
- Coordonne les appels parallèles
- Émet les mises à jour en temps réel
- Gère les erreurs

### **Étape 4 : API & Point d'Entrée**

#### A. API FastAPI
```
backend/main.py
```
Définit les endpoints :
- `GET /` : Info API
- `GET /health` : Health check
- `GET /api/analyze` : Analyse streaming (SSE)
- `POST /api/analyze-sync` : Analyse synchrone

#### B. Script de Lancement
```
backend/run.py
```
Lance le serveur uvicorn

---

## 🎨 **Phase 3 : Frontend**

### **Ordre de Lecture Frontend :**

#### 1. **Structure HTML**
```
frontend/index.html
```
Interface utilisateur avec :
- Formulaire de saisie
- Barre de progression
- Onglets de résultats

#### 2. **Styles CSS**
```
frontend/styles.css
```
Design moderne et responsive

#### 3. **Logique JavaScript**
```
frontend/app.js
```
Gère :
- Connexion SSE au backend
- Mise à jour temps réel
- Affichage des résultats
- Rendu Markdown

---

## 🔄 **Phase 4 : Flux de Données**

### **Comprendre le Flux Complet :**

```
1. Frontend (app.js)
   ↓ Envoie requête HTTP
   
2. Backend API (main.py)
   ↓ Route vers /api/analyze
   
3. DiligenceManager (diligence_manager.py)
   ↓ Orchestre les agents
   
4. Agents IA (exécution parallèle)
   - Planner → Crée stratégie
   - Search → 6 recherches parallèles
   - Analysts → 3 analyses parallèles
   - Writer → Synthèse finale
   - Email → Envoi (optionnel)
   
5. Streaming SSE
   ↓ Mises à jour temps réel
   
6. Frontend
   ↓ Affichage progressif
```

---

## 📖 **Ordre de Lecture Recommandé**

### **Pour Comprendre le Projet :**

1. **[README.md](cci:7://file:///c:/Users/houssam.alrachid/Desktop/investment_due_diligence_ai/README.md:0:0-0:0)** - Vue d'ensemble complète
2. **[QUICKSTART.md](cci:7://file:///c:/Users/houssam.alrachid/Desktop/investment_due_diligence_ai/QUICKSTART.md:0:0-0:0)** - Installation rapide
3. **[backend/models.py](cci:7://file:///c:/Users/houssam.alrachid/Desktop/investment_due_diligence_ai/backend/models.py:0:0-0:0)** - Structures de données
4. **[backend/config.py](cci:7://file:///c:/Users/houssam.alrachid/Desktop/investment_due_diligence_ai/backend/config.py:0:0-0:0)** - Configuration
5. **[backend/planner_agent.py](cci:7://file:///c:/Users/houssam.alrachid/Desktop/investment_due_diligence_ai/backend/planner_agent.py:0:0-0:0)** - Premier agent
6. **[backend/search_agent.py](cci:7://file:///c:/Users/houssam.alrachid/Desktop/investment_due_diligence_ai/backend/search_agent.py:0:0-0:0)** - Recherche web
7. **[backend/analyst_agent.py](cci:7://file:///c:/Users/houssam.alrachid/Desktop/investment_due_diligence_ai/backend/analyst_agent.py:0:0-0:0)** - Analyses spécialisées
8. **[backend/writer_agent.py](cci:7://file:///c:/Users/houssam.alrachid/Desktop/investment_due_diligence_ai/backend/writer_agent.py:0:0-0:0)** - Génération rapport
9. **[backend/diligence_manager.py](cci:7://file:///c:/Users/houssam.alrachid/Desktop/investment_due_diligence_ai/backend/diligence_manager.py:0:0-0:0)** - Orchestration centrale
10. **[backend/main.py](cci:7://file:///c:/Users/houssam.alrachid/Desktop/investment_due_diligence_ai/backend/main.py:0:0-0:0)** - API endpoints
11. **[backend/run.py](cci:7://file:///c:/Users/houssam.alrachid/Desktop/investment_due_diligence_ai/backend/run.py:0:0-0:0)** - Lancement serveur
12. **[frontend/index.html](cci:7://file:///c:/Users/houssam.alrachid/Desktop/investment_due_diligence_ai/frontend/index.html:0:0-0:0)** - Interface
13. **[frontend/app.js](cci:7://file:///c:/Users/houssam.alrachid/Desktop/investment_due_diligence_ai/frontend/app.js:0:0-0:0)** - Logique frontend
14. **[frontend/styles.css](cci:7://file:///c:/Users/houssam.alrachid/Desktop/investment_due_diligence_ai/frontend/styles.css:0:0-0:0)** - Design

### **Pour Modifier le Projet :**

- **Ajouter un agent** → Créer dans [backend/](cci:7://file:///c:/Users/houssam.alrachid/Desktop/investment_due_diligence_ai/backend:0:0-0:0), intégrer dans [diligence_manager.py](cci:7://file:///c:/Users/houssam.alrachid/Desktop/investment_due_diligence_ai/backend/diligence_manager.py:0:0-0:0)
- **Modifier l'analyse** → Éditer les agents correspondants
- **Changer l'UI** → Modifier [frontend/index.html](cci:7://file:///c:/Users/houssam.alrachid/Desktop/investment_due_diligence_ai/frontend/index.html:0:0-0:0) et [styles.css](cci:7://file:///c:/Users/houssam.alrachid/Desktop/investment_due_diligence_ai/frontend/styles.css:0:0-0:0)
- **Ajouter un endpoint** → Éditer [backend/main.py](cci:7://file:///c:/Users/houssam.alrachid/Desktop/investment_due_diligence_ai/backend/main.py:0:0-0:0)

---

## 🎓 **Concepts Clés à Comprendre**

1. **Agents OpenAI** : Chaque agent est une instance spécialisée avec instructions et modèle
2. **Pydantic Models** : Validation et typage fort des données
3. **Async/Await** : Exécution parallèle des agents
4. **Server-Sent Events (SSE)** : Streaming temps réel vers frontend
5. **FastAPI** : Framework moderne avec documentation auto-générée

Voulez-vous que je détaille un fichier ou un concept spécifique ?