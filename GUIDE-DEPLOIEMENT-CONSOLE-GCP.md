# 🌐 Guide de Déploiement via Console GCP

Guide complet pour déployer Investment Due Diligence AI sur Google Cloud Run en utilisant uniquement l'interface web de la console GCP.

---

## 📋 Prérequis

✅ Images Docker poussées vers GCR:
- `gcr.io/ysance-datascience/investment-backend:latest`
- `gcr.io/ysance-datascience/investment-frontend:latest`

✅ Clés API (nouvelles clés après révocation):
- OpenAI API Key
- SendGrid API Key

---

## 🚀 Étape 1: Déployer le Backend

### ⚠️ IMPORTANT - Sécurité des Clés API

**Vous avez 2 options pour gérer vos clés API:**

| Méthode | Sécurité | Complexité | Recommandation |
|---------|----------|------------|----------------|
| **Variables d'environnement** | ⚠️ Moyenne | ✅ Simple | Test rapide uniquement |
| **Secret Manager** | 🔒 Élevée | ⚠️ Moyenne | **PRODUCTION** |

**Variables d'environnement (moins sécurisé):**
- ❌ Visible dans la console GCP
- ❌ Visible via `gcloud describe`
- ❌ Peut apparaître dans les logs
- ✅ Configuration rapide

**Secret Manager (sécurisé):**
- ✅ Chiffré au repos
- ✅ Pas visible après création
- ✅ Audit trail complet
- ✅ Rotation facile
- ⚠️ Configuration en 2 étapes

**Ce guide montre les 2 méthodes. Pour la production, utilisez Secret Manager (voir Étape 5.2).**

---

### 1.1 Accéder à Cloud Run

Ouvrez ce lien dans votre navigateur:
```
https://console.cloud.google.com/run?project=ysance-datascience
```

### 1.2 Créer un nouveau service

1. Cliquez sur **"CREATE SERVICE"** (bouton bleu en haut)

### 1.3 Configuration du conteneur

**Section "Container, Networking, Security":**

**Container image URL:**
```
gcr.io/ysance-datascience/investment-backend:latest
```

- Cliquez sur **"SELECT"** à côté du champ
- Naviguez: `ysance-datascience` → `investment-backend` → `latest`
- Cliquez **"SELECT"**

### 1.4 Configuration du service

**Service name:**
```
investment-backend
```

**Region:**
```
europe-west1 (Belgium)
```

**CPU allocation and pricing:**
- Sélectionnez: ☑️ **"CPU is only allocated during request processing"**

**Autoscaling:**
- **Minimum number of instances:** `0`
- **Maximum number of instances:** `10`

**Ingress:**
- Sélectionnez: ☑️ **"All"** (Allow all traffic)

**Authentication:**
- Sélectionnez: ☑️ **"Allow unauthenticated invocations"**

### 1.5 Configuration du conteneur (Container tab)

Cliquez sur **"CONTAINER(S), VOLUMES, NETWORKING, SECURITY"** pour développer:

**Container port:**
```
8080
```

**Memory:**
```
512 MiB
```

**CPU:**
```
1
```

**Request timeout:**
```
300 seconds
```

**Maximum concurrent requests per instance:**
```
80
```

### 1.6 Variables d'environnement

Cliquez sur l'onglet **"VARIABLES & SECRETS"**

**Ajouter ces variables d'environnement:**

| Name | Value |
|------|-------|
| `API_HOST` | `0.0.0.0` |
| `API_PORT` | `8080` |
| `PYTHONUNBUFFERED` | `1` |
| `OPENAI_API_KEY` | `[Votre nouvelle clé OpenAI]` |
| `SENDGRID_API_KEY` | `[Votre nouvelle clé SendGrid]` |

**⚠️ IMPORTANT:** Utilisez vos **nouvelles clés** après avoir révoqué les anciennes!

Pour ajouter chaque variable:
1. Cliquez **"+ ADD VARIABLE"**
2. Entrez le **Name**
3. Entrez la **Value**
4. Répétez pour chaque variable

### 1.7 Déployer

1. Cliquez sur **"CREATE"** en bas de la page
2. Attendez 2-3 minutes pendant le déploiement
3. Une fois terminé, vous verrez une ✅ verte avec "Service is live"

### 1.8 Récupérer l'URL du backend

Une fois déployé:
1. Vous verrez l'URL en haut de la page (format: `https://investment-backend-xxxxx-ew.a.run.app`)
2. **COPIEZ cette URL** - vous en aurez besoin pour le frontend

---

## 🎨 Étape 2: Déployer le Frontend

### 2.1 Créer un nouveau service

1. Retournez à la liste des services Cloud Run
2. Cliquez sur **"CREATE SERVICE"**

### 2.2 Configuration du conteneur

**Container image URL:**
```
gcr.io/ysance-datascience/investment-frontend:latest
```

### 2.3 Configuration du service

**Service name:**
```
investment-frontend
```

**Region:**
```
europe-west1 (Belgium)
```

**CPU allocation and pricing:**
- ☑️ **"CPU is only allocated during request processing"**

**Autoscaling:**
- **Minimum:** `0`
- **Maximum:** `5`

**Ingress:**
- ☑️ **"All"**

**Authentication:**
- ☑️ **"Allow unauthenticated invocations"**

### 2.4 Configuration du conteneur

**Container port:**
```
80
```

**Memory:**
```
256 MiB
```

**CPU:**
```
1
```

**Request timeout:**
```
60 seconds
```

### 2.5 Variables d'environnement

**Ajouter cette variable:**

| Name | Value |
|------|-------|
| `BACKEND_URL` | `[URL du backend copiée à l'étape 1.8]` |

Exemple: `https://investment-backend-xxxxx-ew.a.run.app`

### 2.6 Déployer

1. Cliquez **"CREATE"**
2. Attendez 2-3 minutes
3. Récupérez l'URL du frontend (format: `https://investment-frontend-xxxxx-ew.a.run.app`)

---

## 🔄 Étape 3: Mettre à jour le Backend avec FRONTEND_URL

Le backend a besoin de connaître l'URL du frontend pour configurer CORS.

### 3.1 Accéder au service backend

1. Dans Cloud Run, cliquez sur **"investment-backend"**
2. Cliquez sur **"EDIT & DEPLOY NEW REVISION"** en haut

### 3.2 Ajouter FRONTEND_URL

1. Allez dans l'onglet **"VARIABLES & SECRETS"**
2. Cliquez **"+ ADD VARIABLE"**
3. **Name:** `FRONTEND_URL`
4. **Value:** `[URL du frontend de l'étape 2.6]`

Exemple: `https://investment-frontend-xxxxx-ew.a.run.app`

### 3.3 Déployer la nouvelle révision

1. Cliquez **"DEPLOY"** en bas
2. Attendez ~30 secondes

---

## ✅ Étape 4: Vérification

### 4.1 Tester le Backend

**Health Check:**
```
https://investment-backend-xxxxx-ew.a.run.app/health
```

Résultat attendu:
```json
{"status":"healthy"}
```

**API Documentation:**
```
https://investment-backend-xxxxx-ew.a.run.app/docs
```

Vous devriez voir l'interface Swagger UI.

### 4.2 Tester le Frontend

Ouvrez dans votre navigateur:
```
https://investment-frontend-xxxxx-ew.a.run.app
```

Vérifications:
- ✅ Page se charge
- ✅ Interface Investment Due Diligence visible
- ✅ Pas d'erreurs dans la console (F12)

### 4.3 Test complet

1. Dans le formulaire, entrez:
   - **Company Name:** `Anthropic`
   - **Investment Context:** `Series D evaluation`
2. Cliquez **"Run Due Diligence"**
3. Vérifiez que l'analyse se lance et affiche les résultats

---

## 🔒 Étape 5: Sécurité (Optionnel mais Recommandé)

### 5.1 Configurer l'accès public

Si vous obtenez une erreur "Forbidden":

1. Allez sur le service (backend ou frontend)
2. Cliquez sur l'onglet **"SECURITY"**
3. Cochez **"Allow unauthenticated invocations"**
4. Cliquez **"SAVE"**

### 5.2 Utiliser Secret Manager (Recommandé pour production)

Au lieu de mettre les clés API dans les variables d'environnement:

**Créer les secrets:**

1. Allez sur: https://console.cloud.google.com/security/secret-manager?project=ysance-datascience
2. Cliquez **"CREATE SECRET"**

**Secret 1: OPENAI_API_KEY**
- **Name:** `OPENAI_API_KEY`
- **Secret value:** Votre nouvelle clé OpenAI
- Cliquez **"CREATE SECRET"**

**Secret 2: SENDGRID_API_KEY**
- **Name:** `SENDGRID_API_KEY`
- **Secret value:** Votre nouvelle clé SendGrid
- Cliquez **"CREATE SECRET"**

**Utiliser les secrets dans Cloud Run:**

1. Éditez le service backend
2. Dans **"VARIABLES & SECRETS"**, cliquez sur l'onglet **"SECRETS"**
3. Cliquez **"REFERENCE A SECRET"**
4. Sélectionnez `OPENAI_API_KEY`
5. **Exposed as:** Environment variable
6. **Name:** `OPENAI_API_KEY`
7. **Version:** `latest`
8. Répétez pour `SENDGRID_API_KEY`
9. **SUPPRIMEZ** les variables d'environnement correspondantes
10. Cliquez **"DEPLOY"**

**Avantages:**
- ✅ Secrets chiffrés
- ✅ Pas visibles dans les logs
- ✅ Rotation facile
- ✅ Meilleure sécurité

---

## 📊 Monitoring et Logs

### Voir les logs

**Backend:**
```
https://console.cloud.google.com/run/detail/europe-west1/investment-backend/logs?project=ysance-datascience
```

**Frontend:**
```
https://console.cloud.google.com/run/detail/europe-west1/investment-frontend/logs?project=ysance-datascience
```

### Voir les métriques

1. Allez sur le service
2. Cliquez sur l'onglet **"METRICS"**
3. Vous verrez:
   - Request count
   - Request latency
   - Container instances
   - CPU utilization
   - Memory utilization

---

## 🔄 Mise à jour d'une nouvelle version

### Si vous modifiez le code:

1. **Rebuild l'image localement:**
   ```bash
   docker build -t investment-backend:latest ./backend
   ```

2. **Tag pour GCR:**
   ```bash
   docker tag investment-backend:latest gcr.io/ysance-datascience/investment-backend:latest
   ```

3. **Push vers GCR:**
   ```bash
   docker push gcr.io/ysance-datascience/investment-backend:latest
   ```

4. **Déployer via console:**
   - Allez sur le service
   - Cliquez **"EDIT & DEPLOY NEW REVISION"**
   - L'image sera automatiquement mise à jour
   - Cliquez **"DEPLOY"**

---

## 🗑️ Suppression

### Supprimer un service:

1. Allez sur Cloud Run
2. Cochez le service à supprimer
3. Cliquez sur l'icône **poubelle** en haut
4. Confirmez

### Supprimer les images GCR:

1. Allez sur: https://console.cloud.google.com/gcr/images/ysance-datascience?project=ysance-datascience
2. Cliquez sur l'image
3. Cochez les versions à supprimer
4. Cliquez **"DELETE"**

---

## 💡 Conseils

### Bonnes pratiques:

1. **Toujours utiliser Secret Manager** pour les clés API en production
2. **Tagger les images** avec des versions (v1.0, v1.1, etc.) pour faciliter les rollbacks
3. **Surveiller les logs** régulièrement
4. **Configurer des alertes** sur les erreurs
5. **Tester localement** avant de déployer

### Limites de ressources recommandées:

| Service | Memory | CPU | Timeout | Max Instances |
|---------|--------|-----|---------|---------------|
| Backend | 512Mi | 1 | 300s | 10 |
| Frontend | 256Mi | 1 | 60s | 5 |

---

## 🎉 Félicitations!

Votre application Investment Due Diligence AI est maintenant déployée sur Google Cloud Run!

**URLs de votre application:**
- Frontend: `https://investment-frontend-xxxxx-ew.a.run.app`
- Backend API: `https://investment-backend-xxxxx-ew.a.run.app`
- API Docs: `https://investment-backend-xxxxx-ew.a.run.app/docs`

---

## 📞 Support

En cas de problème:
1. Vérifiez les logs dans la console
2. Testez le healthcheck du backend
3. Vérifiez que les variables d'environnement sont correctes
4. Assurez-vous que les images sont bien dans GCR
