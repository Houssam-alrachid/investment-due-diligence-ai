# ============================================================================
# DOCKERFILE FRONTEND - Investment Due Diligence AI
# ============================================================================
# Ce Dockerfile crée une image Docker pour le frontend (HTML/CSS/JS statique)
# Utilise Nginx comme serveur web pour servir les fichiers statiques
# ============================================================================

# ============================================================================
# STAGE 1: BUILDER (Optionnel pour frontend statique)
# ============================================================================
# Pour un frontend statique simple, on pourrait sauter cette étape
# Mais on la garde pour la structure et pour faciliter l'ajout futur
# de build steps (minification, bundling, etc.)

FROM nginx:alpine AS builder

# Métadonnées
LABEL maintainer="alrachid.houssam@gmail.com"
LABEL description="Frontend pour Investment Due Diligence AI"
LABEL version="1.0"

# Copier les fichiers frontend
WORKDIR /tmp/frontend
COPY . .

# ============================================================================
# STAGE 2: RUNTIME
# ============================================================================
# Image finale ultra-légère avec Nginx Alpine

FROM nginx:alpine

# Métadonnées
LABEL maintainer="alrachid.houssam@gmail.com"
LABEL description="Frontend - Nginx Alpine optimisé"

# Supprimer la configuration Nginx par défaut
# Nginx vient avec une page d'accueil par défaut qu'on ne veut pas
RUN rm -rf /usr/share/nginx/html/*

# Copier les fichiers statiques dans le répertoire Nginx
# /usr/share/nginx/html est le répertoire par défaut de Nginx pour les fichiers statiques
COPY --from=builder /tmp/frontend/*.html /usr/share/nginx/html/
COPY --from=builder /tmp/frontend/*.css /usr/share/nginx/html/
COPY --from=builder /tmp/frontend/*.js /usr/share/nginx/html/

# Copier la configuration Nginx personnalisée
# Cette configuration est optimisée pour une SPA (Single Page Application)
COPY --from=builder /tmp/frontend/nginx.conf /etc/nginx/conf.d/default.conf

# Exposer le port 80 (HTTP)
# Nginx écoute par défaut sur le port 80
EXPOSE 80

# Healthcheck pour vérifier que Nginx répond
# Vérifie l'endpoint /health qu'on a configuré
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost/health || exit 1

# Nginx démarre automatiquement en foreground avec l'image nginx:alpine
# Pas besoin de CMD explicite, l'image de base le gère

# ============================================================================
# NOTES IMPORTANTES
# ============================================================================
#
# 1. POURQUOI NGINX?
#    - Ultra-léger (image Alpine: ~23MB)
#    - Très performant pour servir des fichiers statiques
#    - Production-ready (utilisé par des millions de sites)
#    - Gestion automatique du cache, compression, etc.
#
# 2. ALTERNATIVES:
#    - Apache: Plus lourd, mais plus de fonctionnalités
#    - Python http.server: Trop simple, pas pour production
#    - Node.js serve: Plus lourd que Nginx
#
# 3. CONFIGURATION NGINX EXPLIQUÉE:
#    - listen 80: Écoute sur le port 80 (HTTP)
#    - listen [::]:80: Support IPv6
#    - server_name _: Accepte tous les noms de domaine
#    - try_files: Si fichier n'existe pas, retourne index.html (SPA routing)
#    - gzip: Compression automatique (réduit bande passante)
#    - expires 1y: Cache navigateur 1 an pour assets statiques
#
# 4. SÉCURITÉ:
#    - Nginx tourne en tant qu'utilisateur nginx (non-root)
#    - Pas de secrets dans l'image
#    - Image Alpine (surface d'attaque minimale)
#
# 5. BUILD:
#    docker build -t investment-frontend:latest -f frontend/Dockerfile frontend/
#
# 6. RUN:
#    docker run -p 3000:80 investment-frontend:latest
#    # Accessible sur http://localhost:3000
#
# 7. PRODUCTION:
#    - Ajouter HTTPS avec un reverse proxy (Nginx, Traefik, ou Ingress K8s)
#    - Configurer un CDN (Cloudflare, AWS CloudFront) pour performance globale
#    - Activer HTTP/2 pour meilleures performances
#
# ============================================================================
