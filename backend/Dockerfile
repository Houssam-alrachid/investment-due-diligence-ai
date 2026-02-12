# ============================================================================
# DOCKERFILE BACKEND - Investment Due Diligence AI
# ============================================================================
# Ce Dockerfile crée une image Docker pour le backend FastAPI
# Il utilise un multi-stage build pour optimiser la taille de l'image finale
# ============================================================================

# ============================================================================
# STAGE 1: BUILDER
# ============================================================================
# Cette étape construit l'environnement avec toutes les dépendances
# On utilise l'image complète python:3.12 qui contient les outils de build

FROM python:3.12 AS builder

# Métadonnées de l'image (bonnes pratiques)
LABEL maintainer="alrachid.houssam@gmail.com"
LABEL description="Backend FastAPI pour Investment Due Diligence AI"
LABEL version="1.0"

# Définir le répertoire de travail dans le conteneur
# Tous les chemins relatifs seront basés sur /app
WORKDIR /app

# Copier uniquement requirements.txt en premier
# Pourquoi? Pour profiter du cache Docker
# Si requirements.txt ne change pas, cette couche est réutilisée
COPY requirements.txt .

# Installer les dépendances Python
# --no-cache-dir: Ne pas garder le cache pip (réduit la taille)
# --user: Installer dans le répertoire utilisateur (~/.local)
RUN pip install --no-cache-dir --user -r requirements.txt

# ============================================================================
# STAGE 2: RUNTIME
# ============================================================================
# Cette étape crée l'image finale légère
# On utilise python:3.12-slim qui est beaucoup plus petite

FROM python:3.12-slim

# Métadonnées
LABEL maintainer="alrachid.houssam@gmail.com"
LABEL description="Backend FastAPI - Runtime optimisé"

# Créer un utilisateur non-root pour la sécurité
# Pourquoi? Ne jamais exécuter des applications en tant que root dans un conteneur
# C'est une faille de sécurité majeure
RUN useradd -m -u 1000 appuser

# Définir le répertoire de travail
WORKDIR /app

# Copier les dépendances Python depuis le stage builder
# --from=builder: Copie depuis l'étape précédente
# Cela évite d'avoir tous les outils de build dans l'image finale
COPY --from=builder /root/.local /home/appuser/.local

# Ajouter le répertoire des binaires Python au PATH
# Nécessaire pour que les commandes installées (uvicorn, etc.) soient trouvées
ENV PATH=/home/appuser/.local/bin:$PATH

# Copier tout le code du backend
# Le .dockerignore exclura les fichiers inutiles
COPY --chown=appuser:appuser backend/ .

# Changer le propriétaire de tous les fichiers vers appuser
# Nécessaire car COPY copie avec les permissions root par défaut
RUN chown -R appuser:appuser /app

# Basculer vers l'utilisateur non-root
USER appuser

# Exposer le port 8080
# ATTENTION: Ceci est DOCUMENTAIRE uniquement
# Cela n'ouvre pas réellement le port, c'est juste une indication
EXPOSE 8080

# Variables d'environnement par défaut
# Ces valeurs peuvent être surchargées au runtime avec -e ou dans docker-compose
ENV API_HOST=0.0.0.0
ENV API_PORT=8080
ENV PYTHONUNBUFFERED=1

# PYTHONUNBUFFERED=1 expliqué:
# Par défaut, Python bufferise stdout/stderr
# Avec cette variable, les logs apparaissent immédiatement
# Crucial pour voir les logs en temps réel dans Docker

# Healthcheck: Vérifie que l'application est en bonne santé
# Docker peut redémarrer automatiquement le conteneur si le healthcheck échoue
# --interval=30s: Vérifie toutes les 30 secondes
# --timeout=10s: Timeout après 10 secondes
# --start-period=40s: Attendre 40s avant le premier check (temps de démarrage)
# --retries=3: Considérer unhealthy après 3 échecs consécutifs
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8080/health')" || exit 1

# Commande par défaut pour démarrer l'application
# CMD vs ENTRYPOINT:
# - CMD: Peut être surchargé facilement avec docker run
# - ENTRYPOINT: Plus difficile à surcharger (pour forcer une commande)
# 
# Format exec (liste): ["executable", "param1", "param2"]
# Avantage: Pas de shell intermédiaire, signaux (SIGTERM) passent directement
#
# uvicorn main:app expliqué:
# - main: Nom du fichier Python (main.py)
# - app: Nom de la variable FastAPI dans main.py
# - --host 0.0.0.0: Écouter sur toutes les interfaces (nécessaire pour Docker)
# - --port 8080: Port d'écoute
# - --workers 1: Nombre de workers (1 pour dev, 4+ pour prod)
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080", "--workers", "1"]

# ============================================================================
# NOTES IMPORTANTES
# ============================================================================
# 
# 1. SÉCURITÉ:
#    - Utilisateur non-root ✓
#    - Pas de secrets dans l'image ✓
#    - Image slim (surface d'attaque réduite) ✓
#
# 2. OPTIMISATION:
#    - Multi-stage build (image finale: ~200MB vs ~1.2GB)
#    - Cache Docker optimisé (requirements.txt copié en premier)
#    - --no-cache-dir pour pip
#
# 3. PRODUCTION:
#    - Healthcheck configuré
#    - Logs non-bufferisés (PYTHONUNBUFFERED)
#    - Variables d'environnement configurables
#
# 4. BUILD:
#    docker build -t investment-backend:latest -f backend/Dockerfile .
#
# 5. RUN:
#    docker run -p 8080:8080 \
#      -e OPENAI_API_KEY=sk-xxx \
#      -e SENDGRID_API_KEY=SG.xxx \
#      investment-backend:latest
#
# ============================================================================
