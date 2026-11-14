# Approuter

Single entry point on SAP BTP / Cloud Foundry: XSUAA login, CSRF protection and
routing of `/odata/v4/abap-environment/*` and `/api/v1/*` to the D backend
(destination `abap-environment-srv`). The Fiori app is served from `resources/`,
which the MTA build fills with a copy of `../frontend`.

Scopes: `AbapViewer` (read), `AbapDeveloper` (development objects, transports, jobs),
`AbapAdmin` (systems, users and roles). The approuter enforces read vs. write per
route; finer grained checks belong in the backend.

Local run (backend on :10001):

```sh
cf create-service-key abap-environment-xsuaa local && cf service-key abap-environment-xsuaa local
# copy the credentials into default-env.json (never commit it — it is in .gitignore)
npm install
npm run start:local   # http://localhost:5000
```
