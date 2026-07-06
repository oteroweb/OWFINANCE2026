---
name: feedback-deploy-strategy
description: Estrategia de deploy activa — prod directo, staging pausado
metadata:
  type: feedback
---

Hasta nuevo aviso, todo deploy va directo a producción (`bash deploy-backend.sh prod` / `bash deploy-frontend.sh prod`). No usar staging.

**Why:** El usuario decidió pausar la infraestructura de staging (OWF-004/005/006/020) indefinidamente. No hay SSH keys configuradas ni hay prioridad de resolverlo ahora.

**How to apply:** No mencionar staging como paso previo. No sugerir "primero prueba en stage". Deploy prod es el flujo normal de esta sesión en adelante.
