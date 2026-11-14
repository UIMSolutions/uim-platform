# Approuter

Single entry point on SAP BTP / Cloud Foundry: XSUAA login, CSRF protection and
routing of `/odata/v4/connectivity/*` and `/api/v1/*` to the D backend
(destination `connectivity-srv`). The Fiori app is served from `resources/`,
which the MTA build fills with a copy of `../frontend`.

Scopes: `ConnectivityViewer` (read), `ConnectivityOperator` (write requests:
checks, heartbeats, open/close channels), `ConnectivityAdmin` (everything).
The approuter only distinguishes read (GET) from write; separating operator
actions from administration (create / delete) belongs in the backend.

Local run (backend on :8088):

```sh
cf create-service-key connectivity-xsuaa local && cf service-key connectivity-xsuaa local
# copy the credentials into default-env.json (never commit it — it is in .gitignore)
npm install
npm run start:local   # http://localhost:5000
```
