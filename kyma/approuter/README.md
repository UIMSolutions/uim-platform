# Approuter

Single entry point on SAP BTP / Cloud Foundry: XSUAA login, CSRF protection and
routing of `/odata/v4/kyma/*` and `/api/v1/*` to the D backend (destination
`kyma-srv`). The Fiori app is served from `resources/`, which the MTA build fills
with a copy of `../frontend`.

Scopes: `KymaViewer` (read), `KymaDeveloper` (workloads), `KymaAdmin` (runtimes, modules, applications).
The approuter enforces read vs. write per route; finer grained checks belong in the backend.

Local run (backend on :8095):

```sh
cf create-service-key kyma-xsuaa local && cf service-key kyma-xsuaa local
# copy the credentials into default-env.json (never commit it — it is in .gitignore)
npm install
npm run start:local   # http://localhost:5000
```
