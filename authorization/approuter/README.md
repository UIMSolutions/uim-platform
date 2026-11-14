# Approuter — UIM Authorization Management

Single entry point on SAP BTP / Cloud Foundry: XSUAA login, CSRF protection and routing.

| Route                            | Target                                             | Scope (GET / other)          |
|----------------------------------|----------------------------------------------------|------------------------------|
| `/odata/v4/authorization/*`      | destination `authorization-srv` (D backend)        | Read or Admin / Admin or Check |
| `/api/v1/*`, `/rest/v1/*`        | destination `authorization-srv`                    | Read or Admin / Admin or Check |
| `/web/*`                         | destination `authorization-srv` (Diet dashboard)   | Read or Admin                |
| `/*`                             | Fiori app in `resources/` (copied from `../frontend`) | Read or Admin             |

The backend verifies the forwarded XSUAA token (RS256, verification key from the
`xsuaa` binding) and enforces the scopes per entity set and action itself, so a
`Check` token can evaluate requests but not change policies.

## Run locally

```sh
cp default-env.example.json default-env.json   # fill in your XSUAA credentials — never commit it
npm install
npm run start:local                              # http://localhost:5000
```

`default-env.json` contains secrets and is listed in `.gitignore`.
