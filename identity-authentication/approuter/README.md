# Identity Authentication approuter

Single entry point on SAP BTP / Cloud Foundry: XSUAA login, CSRF protection and routing.

| Route | Target | Protection |
|---|---|---|
| `/odata/v4/identity-authentication/*` | `ias-srv` (backend OData v4) | GET: `IdentityViewer`; writes: `IdentityAdmin` |
| `/api/v1/auth/*`, `/.well-known/openid-configuration` | `ias-srv` (login, token, introspection) | public — these endpoints authenticate end users and OAuth clients themselves |
| `/api/v1/*`, `/rest/v1/*` | `ias-srv` (backend REST administration) | GET: `IdentityViewer`; writes: `IdentityAdmin` |
| `/*` | `resources/` (copy of `../frontend`) | `IdentityViewer` or `IdentityAdmin` |

## Local run

1. `cf create-service-key ias-xsuaa local && cf service-key ias-xsuaa local`
2. Paste the credentials into `default-env.json` (git-ignored, never deployed).
3. Start the backend (`cd ../backend && dub run`) on port 8125.
4. `npm install && npm run start:local` → http://localhost:5000
