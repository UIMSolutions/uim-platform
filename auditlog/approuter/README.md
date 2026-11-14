# Approuter

Single entry point on SAP BTP / Cloud Foundry: XSUAA login, CSRF protection and
routing of `/odata/v4/auditlog/*` and `/api/v1/*` to the D backend
(destination `auditlog-srv`). The Fiori app is served from `resources/`, which
the MTA build fills with a copy of `../frontend`.

Local run (backend on :8085):

```sh
cf create-service-key auditlog-xsuaa local && cf service-key auditlog-xsuaa local
# copy the credentials into default-env.json (never commit it)
npm install
npm run start:local   # http://localhost:5000
```
