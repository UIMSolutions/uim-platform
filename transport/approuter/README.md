# Approuter — UIM Cloud Transport Management

Single entry point on SAP BTP / Cloud Foundry: XSUAA login, CSRF protection and
routing to the D/vibe.d backend (`transport-srv`) and the Fiori app (`resources/`).

| Route | Target | Scopes |
|---|---|---|
| `/odata/v4/transport/*` | backend OData v4 | GET: Viewer · POST (actions, create): Operator · PATCH/DELETE: Admin |
| `/api/v1/*` | backend REST | GET: Viewer · others: Admin |
| `/*` | `resources/` (copy of `../frontend`) | any role |

## Local run

```sh
cd approuter
npm install
# default-env.json: fill in the XSUAA credentials (cf service-key transport-xsuaa local)
npm run start:local        # http://localhost:5000  → backend http://localhost:8117
```

`default-env.json` contains secrets — it is git-ignored and never deployed.
