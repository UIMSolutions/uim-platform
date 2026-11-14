# Agentry approuter

Single entry point on SAP BTP / Cloud Foundry: XSUAA login, CSRF protection and routing.

| Route | Target | Scope |
|---|---|---|
| `/odata/v4/agentry/*` | `agentry-srv` destination (backend OData v4) | GET: `AgentryViewer`; writes: `AgentryAdmin` |
| `/api/v1/*`, `/rest/v1/*` | `agentry-srv` destination (backend REST) | GET: `AgentryViewer`; writes: `AgentryAdmin` |
| `/*` | `resources/` (copy of `../frontend`) | `AgentryViewer` or `AgentryAdmin` |

## Local run

1. `cf create-service-key agentry-xsuaa local && cf service-key agentry-xsuaa local`
2. Paste the credentials into `default-env.json` (git-ignored, never deployed).
3. Start the backend (`cd ../backend && dub run`) on port 8117.
4. `npm install && npm run start:local` → http://localhost:5000
