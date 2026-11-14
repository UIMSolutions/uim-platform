# Approuter

Single entry point on SAP BTP / Cloud Foundry: XSUAA login, CSRF protection and
routing of `/odata/v4/application-studio/*` and `/api/v1/*` to the D backend
(destination `application-studio-srv`). The Fiori app is served from `resources/`,
which the MTA build fills with a copy of `../frontend`.

Scopes: `StudioViewer` (read), `StudioDeveloper` (dev spaces, projects, bindings,
runs, builds, deployments), `StudioAdmin` (catalogue: dev space types, extensions,
templates). The approuter enforces read vs. write per route; finer grained checks
belong in the backend.

Local run (backend on :8111):

```sh
cf create-service-key application-studio-xsuaa local && cf service-key application-studio-xsuaa local
# copy the credentials into default-env.json (never commit it — it is in .gitignore)
npm install
npm run start:local   # http://localhost:5000
```
