# Approuter — UIM Cloud Management

Single entry point on SAP BTP / Cloud Foundry: XSUAA login, CSRF protection and routing.

| Route                         | Target                                      | Scope (GET / other)  |
|-------------------------------|---------------------------------------------|----------------------|
| `/odata/v4/management/*`      | destination `management-srv` (D backend)    | Viewer or Admin / Admin |
| `/api/v1/*`, `/rest/v1/*`     | destination `management-srv`                | Viewer or Admin / Admin |
| `/*`                          | Fiori app in `resources/` (copied from `../frontend`) | Viewer or Admin |

## Run locally

```sh
cp default-env.example.json default-env.json   # fill in your XSUAA credentials — never commit it
npm install
npm run start:local                              # http://localhost:5000
```

`default-env.json` contains secrets and is listed in `.gitignore`.
