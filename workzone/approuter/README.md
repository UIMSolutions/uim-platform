# Work Zone approuter

Single entry point on SAP BTP / Cloud Foundry: XSUAA login, CSRF protection and routing.

| Route | Target |
|-------|--------|
| `/odata/v4/workzone/*` | backend destination `workzone-srv` (OData v4 for the Fiori app) |
| `/api/v1/*` | backend destination `workzone-srv` (REST, resource catalogue) |
| `/*` | the Fiori app, copied into `resources/` at build time |

Scopes: `WorkzoneViewer` (read), `WorkzoneContributor` (write content), `WorkzoneAdmin` (sites, roles, integrations) — see `xs-security.json`.

## Local run

```bash
cp default-env.example.json default-env.json   # fill in the XSUAA service key (never commit it)
npm install
npm run start:local                            # http://localhost:5000, backend on :8084
```

`default-env.json` contains secrets and is listed in `.gitignore`.
