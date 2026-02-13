# 🔒 Guide Secret Manager - Console GCP

Guide pour configurer Secret Manager AVANT de déployer sur Cloud Run (méthode sécurisée).

---

## 🎯 Pourquoi Secret Manager?

| Aspect | Variables d'environnement | Secret Manager |
|--------|---------------------------|----------------|
| **Visibilité console** | ❌ Visible en clair | ✅ Masqué |
| **Visibilité gcloud** | ❌ Visible en clair | ✅ Masqué |
| **Chiffrement** | ⚠️ En transit seulement | ✅ Au repos + en transit |
| **Logs** | ⚠️ Peut fuiter | ✅ Jamais visible |
| **Rotation** | ❌ Redéploiement requis | ✅ Sans redéploiement |
| **Audit** | ❌ Limité | ✅ Complet |
| **Coût** | Gratuit | ~0.06€/secret/mois |

**Verdict:** Secret Manager coûte quelques centimes mais offre une sécurité professionnelle.

---

## 📋 Étape 1: Créer les Secrets

### 1.1 Accéder à Secret Manager

Ouvrez ce lien:
```
https://console.cloud.google.com/security/secret-manager?project=ysance-datascience
```

### 1.2 Créer le secret OpenAI

1. Cliquez sur **"+ CREATE SECRET"** (bouton bleu en haut)

**Configuration:**

**Name:**
```
OPENAI_API_KEY
```

**Secret value:**
```
[Collez votre nouvelle clé OpenAI ici]
```
Exemple: `sk-proj-xxxxxxxxxxxxx`

**Regions:** (Optionnel - laissez par défaut pour automatic)
- Ou sélectionnez: `europe-west1` pour garder les données en Europe

**Rotation:** (Optionnel - ignorez pour l'instant)

**Expiration:** (Optionnel - ignorez pour l'instant)

2. Cliquez **"CREATE SECRET"**

### 1.3 Créer le secret SendGrid

1. Cliquez à nouveau sur **"+ CREATE SECRET"**

**Name:**
```
SENDGRID_API_KEY
```

**Secret value:**
```
[Collez votre nouvelle clé SendGrid ici]
```
Exemple: `SG.xxxxxxxxxxxxx`

2. Cliquez **"CREATE SECRET"**

### 1.4 Vérification

Vous devriez maintenant voir 2 secrets dans la liste:
- ✅ `OPENAI_API_KEY`
- ✅ `SENDGRID_API_KEY`

**Important:** Une fois créés, vous ne pourrez plus voir les valeurs! C'est normal et c'est sécurisé.

---

## 🚀 Étape 2: Déployer le Backend avec Secret Manager

### 2.1 Accéder à Cloud Run

```
https://console.cloud.google.com/run?project=ysance-datascience
```

### 2.2 Créer le service

1. Cliquez **"CREATE SERVICE"**

### 2.3 Configuration de base

**Container image:**
```
gcr.io/ysance-datascience/investment-backend:latest
```

**Service name:**
```
investment-backend
```

**Region:**
```
europe-west1
```

**CPU allocation:**
- ☑️ CPU is only allocated during request processing

**Autoscaling:**
- Min: `0`, Max: `10`

**Authentication:**
- ☑️ Allow unauthenticated invocations

### 2.4 Configuration du conteneur

Cliquez sur **"CONTAINER(S), VOLUMES, NETWORKING, SECURITY"**

**Container port:** `8080`
**Memory:** `512 MiB`
**CPU:** `1`
**Request timeout:** `300`

### 2.5 Variables d'environnement (non-sensibles)

Cliquez sur l'onglet **"VARIABLES & SECRETS"**

Restez sur l'onglet **"VARIABLES"** (pas SECRETS encore)

Ajoutez ces variables **non-sensibles**:

| Name | Value |
|------|-------|
| `API_HOST` | `0.0.0.0` |
| `API_PORT` | `8080` |
| `PYTHONUNBUFFERED` | `1` |

### 2.6 Secrets (sensibles) 🔒

Maintenant, cliquez sur l'onglet **"SECRETS"** (à côté de VARIABLES)

**Pour OPENAI_API_KEY:**

1. Cliquez **"REFERENCE A SECRET"**
2. **Secret:** Sélectionnez `OPENAI_API_KEY` dans la liste déroulante
3. **Reference method:** ☑️ `Exposed as environment variable`
4. **Environment variable name:** `OPENAI_API_KEY`
5. **Version:** Sélectionnez `latest` (ou `1` si latest n'est pas disponible)
6. Cliquez **"DONE"**

**Pour SENDGRID_API_KEY:**

1. Cliquez à nouveau **"REFERENCE A SECRET"**
2. **Secret:** `SENDGRID_API_KEY`
3. **Reference method:** ☑️ `Exposed as environment variable`
4. **Environment variable name:** `SENDGRID_API_KEY`
5. **Version:** `latest`
6. Cliquez **"DONE"**

### 2.7 Résumé de la configuration

Vous devriez avoir:

**Variables (3):**
- API_HOST
- API_PORT
- PYTHONUNBUFFERED

**Secrets (2):**
- OPENAI_API_KEY → secret:OPENAI_API_KEY:latest
- SENDGRID_API_KEY → secret:SENDGRID_API_KEY:latest

### 2.8 Déployer

1. Cliquez **"CREATE"** en bas
2. Attendez 2-3 minutes

⚠️ **Si vous obtenez une erreur de permissions:**

```
Permission 'secretmanager.versions.access' denied
```

**Solution:**

1. Allez sur chaque secret (OPENAI_API_KEY et SENDGRID_API_KEY)
2. Cliquez sur l'onglet **"PERMISSIONS"**
3. Cliquez **"GRANT ACCESS"**
4. **New principals:** `185173375293-compute@developer.gserviceaccount.com`
5. **Role:** `Secret Manager Secret Accessor`
6. Cliquez **"SAVE"**
7. Répétez pour l'autre secret
8. Retournez sur Cloud Run et redéployez

### 2.9 Récupérer l'URL

Une fois déployé, copiez l'URL du backend:
```
https://investment-backend-xxxxx-ew.a.run.app
```

---

## 🎨 Étape 3: Déployer le Frontend

Le frontend n'a pas besoin de secrets, seulement de variables d'environnement normales.

### 3.1 Créer le service

1. Cliquez **"CREATE SERVICE"**

**Container image:**
```
gcr.io/ysance-datascience/investment-frontend:latest
```

**Service name:**
```
investment-frontend
```

**Region:** `europe-west1`

**CPU allocation:** ☑️ CPU is only allocated during request processing

**Autoscaling:** Min: `0`, Max: `5`

**Authentication:** ☑️ Allow unauthenticated invocations

### 3.2 Configuration du conteneur

**Container port:** `80`
**Memory:** `256 MiB`
**CPU:** `1`
**Request timeout:** `60`

### 3.3 Variable d'environnement

**VARIABLES** (pas SECRETS):

| Name | Value |
|------|-------|
| `BACKEND_URL` | `[URL du backend de l'étape 2.9]` |

### 3.4 Déployer

1. Cliquez **"CREATE"**
2. Récupérez l'URL du frontend

---

## 🔄 Étape 4: Mettre à jour le Backend avec FRONTEND_URL

1. Retournez sur le service **investment-backend**
2. Cliquez **"EDIT & DEPLOY NEW REVISION"**
3. Allez dans **"VARIABLES & SECRETS"** → onglet **"VARIABLES"**
4. Ajoutez:
   - **Name:** `FRONTEND_URL`
   - **Value:** `[URL du frontend]`
5. Cliquez **"DEPLOY"**

---

## ✅ Vérification de la Sécurité

### Test 1: Les secrets ne sont pas visibles dans la console

1. Allez sur le service backend
2. Cliquez sur **"EDIT & DEPLOY NEW REVISION"**
3. Allez dans **"VARIABLES & SECRETS"** → onglet **"SECRETS"**
4. ✅ Vous voyez seulement la référence, pas la valeur

### Test 2: Les secrets ne sont pas visibles via gcloud

Exécutez:
```bash
gcloud run services describe investment-backend --region=europe-west1 --project=ysance-datascience
```

✅ Vous devriez voir:
```
Secrets:
  OPENAI_API_KEY:
    OPENAI_API_KEY:latest
  SENDGRID_API_KEY:
    SENDGRID_API_KEY:latest
```

❌ Vous ne devriez PAS voir les valeurs réelles des clés

### Test 3: Audit trail

1. Allez sur Secret Manager
2. Cliquez sur `OPENAI_API_KEY`
3. Allez dans l'onglet **"AUDIT LOGS"**
4. ✅ Vous voyez tous les accès au secret

---

## 🔄 Rotation des Secrets (Bonus)

### Quand changer une clé API:

**Méthode 1: Créer une nouvelle version (recommandé)**

1. Allez sur Secret Manager
2. Cliquez sur le secret (ex: `OPENAI_API_KEY`)
3. Cliquez **"NEW VERSION"**
4. Entrez la nouvelle valeur
5. Cliquez **"ADD NEW VERSION"**
6. Cloud Run utilisera automatiquement `latest` (si configuré)

**Méthode 2: Modifier le secret existant**

1. Supprimez l'ancien secret
2. Créez-en un nouveau avec le même nom
3. Redéployez le service Cloud Run

---

## 💰 Coûts

**Secret Manager:**
- Stockage: $0.06 par secret par mois
- Accès: $0.03 par 10,000 accès
- Versions: $0.06 par version active par mois

**Pour 2 secrets:**
- ~$0.12/mois (12 centimes)

**Verdict:** Négligeable comparé à la sécurité apportée!

---

## 🎯 Comparaison Finale

### Variables d'environnement:
```bash
# Dans Cloud Run
OPENAI_API_KEY=sk-proj-xxxxx  ← ❌ Visible partout
```

### Secret Manager:
```bash
# Dans Cloud Run
OPENAI_API_KEY=secret:OPENAI_API_KEY:latest  ← ✅ Référence seulement
```

**Dans votre code Python, c'est identique:**
```python
import os
api_key = os.getenv("OPENAI_API_KEY")  # Fonctionne pareil!
```

---

## 📚 Ressources

**Secret Manager Console:**
```
https://console.cloud.google.com/security/secret-manager?project=ysance-datascience
```

**Documentation officielle:**
```
https://cloud.google.com/secret-manager/docs
```

**Best practices:**
```
https://cloud.google.com/secret-manager/docs/best-practices
```

---

## 🎉 Félicitations!

Votre application est maintenant déployée avec **Secret Manager** - la méthode professionnelle et sécurisée! 🔒

**Avantages obtenus:**
- ✅ Clés API chiffrées
- ✅ Pas de fuite dans les logs
- ✅ Audit trail complet
- ✅ Rotation facile
- ✅ Conforme aux standards de sécurité

**Vous pouvez dormir tranquille!** 😴
