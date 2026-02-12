# 🚢 Déploiement Kubernetes - Investment Due Diligence AI

Ce dossier contient tous les manifests Kubernetes pour déployer l'application.

---

## 📋 Structure des Manifests

```
k8s/
├── namespace.yaml              # Namespace isolé pour l'application
├── configmap.yaml              # Configuration non-sensible
├── secrets.yaml                # Clés API (à ne pas committer!)
├── backend-deployment.yaml     # Déploiement du backend FastAPI
├── frontend-deployment.yaml    # Déploiement du frontend Nginx
├── backend-service.yaml        # Service interne pour le backend
├── frontend-service.yaml       # Service externe pour le frontend
└── ingress.yaml                # Routage HTTP/HTTPS
```

---

## 🚀 Déploiement sur Minikube (Local)

### **Prérequis**

1. **Docker Desktop** installé et en cours d'exécution
2. **Minikube** installé
3. **kubectl** installé

### **Installation de Minikube (Windows)**

```powershell
# Avec Chocolatey
choco install minikube

# Ou télécharger depuis:
# https://minikube.sigs.k8s.io/docs/start/

# Vérifier l'installation
minikube version
kubectl version --client
```

---

## 📦 Étape 1: Démarrer Minikube

```bash
# Démarrer Minikube avec Docker comme driver
minikube start --driver=docker

# Vérifier le statut
minikube status

# Activer l'addon Ingress
minikube addons enable ingress

# Vérifier que le cluster est prêt
kubectl cluster-info
```

---

## 🏗️ Étape 2: Charger les Images Docker dans Minikube

Minikube utilise son propre Docker daemon. Il faut charger vos images locales:

```bash
# Pointer vers le Docker daemon de Minikube
minikube docker-env | Invoke-Expression

# Rebuild les images dans Minikube
docker build -t investment-backend:latest -f backend/Dockerfile .
docker build -t investment-frontend:latest -f frontend/Dockerfile frontend/

# Vérifier que les images sont dans Minikube
minikube ssh "docker images | grep investment"
```

**Alternative (plus simple):**
```bash
# Charger les images existantes dans Minikube
minikube image load investment-backend:latest
minikube image load investment-frontend:latest
```

---

## 🔐 Étape 3: Configurer les Secrets

**IMPORTANT:** Ne jamais committer les vraies clés API!

```bash
# Créer le namespace d'abord
kubectl apply -f k8s/namespace.yaml

# Créer les secrets avec vos vraies clés
kubectl create secret generic investment-ai-secrets \
  --from-literal=OPENAI_API_KEY=sk-votre-vraie-cle \
  --from-literal=SENDGRID_API_KEY=SG.votre-vraie-cle \
  -n investment-ai

# Vérifier
kubectl get secrets -n investment-ai
```

---

## 🚀 Étape 4: Déployer l'Application

```bash
# Déployer tous les manifests
kubectl apply -f k8s/

# Ou un par un (dans l'ordre):
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secrets.yaml
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/backend-service.yaml
kubectl apply -f k8s/frontend-service.yaml
kubectl apply -f k8s/ingress.yaml
```

---

## 🔍 Étape 5: Vérifier le Déploiement

```bash
# Voir tous les pods
kubectl get pods -n investment-ai

# Voir les services
kubectl get services -n investment-ai

# Voir l'ingress
kubectl get ingress -n investment-ai

# Voir les logs du backend
kubectl logs -f deployment/backend-deployment -n investment-ai

# Voir les logs du frontend
kubectl logs -f deployment/frontend-deployment -n investment-ai

# Décrire un pod pour debug
kubectl describe pod <pod-name> -n investment-ai
```

**Résultat attendu:**
```
NAME                                   READY   STATUS    RESTARTS   AGE
backend-deployment-xxxxx-xxxxx         1/1     Running   0          2m
backend-deployment-xxxxx-yyyyy         1/1     Running   0          2m
frontend-deployment-xxxxx-xxxxx        1/1     Running   0          2m
frontend-deployment-xxxxx-yyyyy        1/1     Running   0          2m
```

---

## 🌐 Étape 6: Accéder à l'Application

### **Option A: Via LoadBalancer (Minikube Tunnel)**

```bash
# Dans un terminal séparé, lancer le tunnel Minikube
minikube tunnel

# Obtenir l'IP externe
kubectl get service frontend-service -n investment-ai

# Accéder à l'application
# http://<EXTERNAL-IP>
```

### **Option B: Via Ingress**

```bash
# Obtenir l'IP de Minikube
minikube ip

# Ajouter à votre fichier hosts (Windows: C:\Windows\System32\drivers\etc\hosts)
<MINIKUBE-IP> investment-ai.local

# Accéder à l'application
# http://investment-ai.local
```

### **Option C: Port Forward (Plus Simple)**

```bash
# Forward le port du frontend
kubectl port-forward service/frontend-service 3000:80 -n investment-ai

# Accéder à l'application
# http://localhost:3000
```

---

## 🧪 Tests de Validation

```bash
# Test healthcheck backend
kubectl port-forward service/backend-service 8080:8080 -n investment-ai
curl http://localhost:8080/health

# Test healthcheck frontend
kubectl port-forward service/frontend-service 3000:80 -n investment-ai
curl http://localhost:3000/health

# Test API docs
# http://localhost:8080/docs
```

---

## 📊 Monitoring et Debug

### **Voir les événements**
```bash
kubectl get events -n investment-ai --sort-by='.lastTimestamp'
```

### **Logs en temps réel**
```bash
# Tous les pods backend
kubectl logs -f -l component=backend -n investment-ai

# Tous les pods frontend
kubectl logs -f -l component=frontend -n investment-ai
```

### **Entrer dans un pod**
```bash
kubectl exec -it <pod-name> -n investment-ai -- /bin/sh
```

### **Vérifier les ressources**
```bash
kubectl top pods -n investment-ai
kubectl top nodes
```

---

## 🔄 Mise à Jour de l'Application

```bash
# 1. Rebuild les images
docker build -t investment-backend:latest -f backend/Dockerfile .
docker build -t investment-frontend:latest -f frontend/Dockerfile frontend/

# 2. Charger dans Minikube
minikube image load investment-backend:latest
minikube image load investment-frontend:latest

# 3. Redémarrer les deployments
kubectl rollout restart deployment/backend-deployment -n investment-ai
kubectl rollout restart deployment/frontend-deployment -n investment-ai

# 4. Vérifier le rollout
kubectl rollout status deployment/backend-deployment -n investment-ai
kubectl rollout status deployment/frontend-deployment -n investment-ai
```

---

## 🗑️ Nettoyage

```bash
# Supprimer toute l'application
kubectl delete namespace investment-ai

# Ou supprimer les ressources une par une
kubectl delete -f k8s/

# Arrêter Minikube
minikube stop

# Supprimer le cluster Minikube
minikube delete
```

---

## 🐛 Troubleshooting

### **Problème: Pods en CrashLoopBackOff**
```bash
# Voir les logs
kubectl logs <pod-name> -n investment-ai

# Voir les événements
kubectl describe pod <pod-name> -n investment-ai
```

### **Problème: ImagePullBackOff**
```bash
# Vérifier que les images sont dans Minikube
minikube ssh "docker images"

# Recharger les images
minikube image load investment-backend:latest
minikube image load investment-frontend:latest
```

### **Problème: Pods pas Ready**
```bash
# Vérifier les healthchecks
kubectl describe pod <pod-name> -n investment-ai

# Tester manuellement le healthcheck
kubectl exec -it <pod-name> -n investment-ai -- curl http://localhost:8080/health
```

### **Problème: Service non accessible**
```bash
# Vérifier les endpoints
kubectl get endpoints -n investment-ai

# Vérifier les services
kubectl get services -n investment-ai

# Tester depuis un pod
kubectl run -it --rm debug --image=curlimages/curl --restart=Never -n investment-ai -- curl http://backend-service:8080/health
```

---

## 📚 Ressources Utiles

- **Documentation Kubernetes:** https://kubernetes.io/docs/
- **Documentation Minikube:** https://minikube.sigs.k8s.io/docs/
- **kubectl Cheat Sheet:** https://kubernetes.io/docs/reference/kubectl/cheatsheet/

---

## 🎯 Prochaines Étapes

Après avoir validé sur Minikube:

1. **Déployer sur un cluster cloud** (GKE, DigitalOcean, AWS EKS)
2. **Configurer un domaine** et SSL/TLS avec cert-manager
3. **Ajouter monitoring** (Prometheus + Grafana)
4. **Configurer CI/CD** (GitHub Actions)
5. **Ajouter autoscaling** (HPA - Horizontal Pod Autoscaler)
