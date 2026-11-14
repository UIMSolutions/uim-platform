# Approuter — UIM Translation Hub

Single entry point on SAP BTP / Cloud Foundry: XSUAA login, CSRF protection and
routing to the backend (`translation-srv` destination) or the Fiori app in
`resources/` (copied from `../frontend` at build time).

| Route | Target | Scope (GET / other) |
|---|---|---|
| `/odata/v4/translation/*` | backend OData v4 | Viewer / Translator, Admin |
| `/api/v1/*` | backend REST | Viewer / Translator, Admin |
| `/*` | `resources/` (Fiori app) | Viewer |

Local run (needs an XSUAA service key in `default-env.json`, which is git-ignored):

```bash
npm install
npm run start:local        # http://localhost:5000 → backend at http://localhost:8096
```
