# Approuter — UIM Object Store

Single entry point on SAP BTP / Cloud Foundry: XSUAA login, CSRF protection and
routing to the backend (`object-store-srv` destination) or the Fiori app in
`resources/` (copied from `../frontend` at build time).

| Route | Target | Scope GET (HEAD) | Scope other methods |
|---|---|---|---|
| `/odata/v4/object-store/*` | backend OData v4 (management + Fiori) | Viewer | User, Admin |
| `/api/v1/object-store/content/*` | backend content API (data plane) | Viewer | User, Admin |
| `/api/v1/*` | backend REST (management plane) | Viewer | Admin |
| `/*` | `resources/` (Fiori app) | Viewer | – |

The backend additionally enforces the bucket **access policies** on the content
API, with the user id from the forwarded XSUAA token as principal.

Local run (needs an XSUAA service key in `default-env.json`, which is git-ignored):

```bash
npm install
npm run start:local        # http://localhost:5000 → backend at http://localhost:8092
```
