# Approuter — UIM Identity Provisioning

Single entry point on SAP BTP / Cloud Foundry: XSUAA login, CSRF protection and
routing to the backend (`identity-provisioning-srv` destination) or the Fiori app
in `resources/` (copied from `../frontend` at build time).

| Route | Target | Scope (GET / other) |
|---|---|---|
| `/odata/v4/identity-provisioning/*` | backend OData v4 (Fiori app) | Viewer / Operator, Admin |
| `/api/v1/*` | backend REST (automation, CLI-like access) | Viewer / Admin |
| `/*` | `resources/` (Fiori app) | Viewer |

Role collections: *UIM Identity Provisioning Viewer*, *… Operator* (run jobs, test
connections), *… Administrator* (maintain systems and credentials).

Local run (needs an XSUAA service key in `default-env.json`, which is git-ignored):

```bash
npm install
npm run start:local        # http://localhost:5000 → backend at http://localhost:8093
```
