# UIM UI Flexibility Platform Service — NAFv4 Architecture

## NOv-2 Operational Node Connectivity Description

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                     OPERATIONAL ARCHITECTURE (NOv-2)                            │
│                                                                                 │
│   ┌───────────────────────┐          ┌───────────────────────────────────────┐  │
│   │  Key User (Operator)  │          │  End User (Consumer)                  │  │
│   │  Role: UI Developer   │          │  Role: Business User                  │  │
│   └──────────┬────────────┘          └─────────────────┬─────────────────────┘  │
│              │ POST/GET/PUT/DELETE                      │ POST/GET/PUT/DELETE    │
│              │ /keyuser/v2/*                            │ /user/v2/personaliza.  │
│              ▼                                          ▼                        │
│   ┌──────────────────────────────────────────────────────────────────────────┐  │
│   │                UIM UI Flexibility Platform Service  :8098                │  │
│   │  ┌─────────────────────────────────────────────────────────────────────┐ │  │
│   │  │                      HTTP API (vibe.d)                              │ │  │
│   │  │  /keyuser/v2/changes   /keyuser/v2/variants  /keyuser/v2/versions   │ │  │
│   │  │  /keyuser/v2/drafts    /user/v2/personalizations                    │ │  │
│   │  │  /api/v2/applications  /api/v1/health                               │ │  │
│   │  └─────────────────────────────────────────────────────────────────────┘ │  │
│   │                              │                                            │  │
│   │               ┌──────────────▼──────────────┐                            │  │
│   │               │    Application Use Cases     │                            │  │
│   │               └──────────────┬──────────────┘                            │  │
│   │                              │                                            │  │
│   │         ┌────────────────────┼────────────────────┐                      │  │
│   │         ▼                    ▼                     ▼                      │  │
│   │   ┌──────────┐         ┌──────────┐         ┌──────────┐                 │  │
│   │   │ Memory   │         │  Files   │         │ MongoDB  │                 │  │
│   │   │ Storage  │         │  (JSON)  │         │  (stub)  │                 │  │
│   │   └──────────┘         └──────────┘         └──────────┘                 │  │
│   └──────────────────────────────────────────────────────────────────────────┘  │
│              │                                          │                        │
│              ▼                                          ▼                        │
│   ┌────────────────────┐                  ┌──────────────────────────────────┐  │
│   │ Platform Admin     │                  │  SAP BTP / SAPUI5 Runtime         │  │
│   │ /api/v2/applications│                 │  Flex Change Applier              │  │
│   └────────────────────┘                  └──────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## SV-6 Operational Activity to System Function Traceability

| Operational Activity              | System Function                                        | API Path                              |
|-----------------------------------|--------------------------------------------------------|---------------------------------------|
| Create UI adaptation (key user)   | Create FlexChange record                               | `POST /keyuser/v2/changes`            |
| Manage UI variants                | Create/Update/List FlexVariant                         | `/keyuser/v2/variants`                |
| Manage UI versions                | Create/Activate/Archive FlexVersion                    | `/keyuser/v2/versions`                |
| Draft management                  | Create/Update/Discard FlexDraft (1 per app/tenant)     | `/keyuser/v2/drafts`                  |
| End-user personalization          | Create/Update/Delete FlexPersonalization               | `/user/v2/personalizations`           |
| Reset user personalizations       | Remove all personalizations for user+app               | `DELETE /user/v2/personalizations`    |
| Register SAP Fiori application    | Create/Update FlexApplication                          | `/api/v2/applications`                |
| Monitor service health            | Health check endpoint                                  | `GET /api/v1/health`                  |

---

## SvcV-4 Service Functionality Description

```
Service: UIM UI Flexibility Platform Service
Version: 2.0.0
Port:    8098

┌───────────────────────────────────────────────────────────────────────┐
│ Service Capabilities                                                  │
├──────────────────────┬────────────────────────────────────────────────┤
│ Capability           │ Description                                    │
├──────────────────────┼────────────────────────────────────────────────┤
│ Change Management    │ CRUD for SAPUI5 flex change records.           │
│                      │ Supports layers: vendor, customer, user.       │
│                      │ Supports 14 change types.                      │
├──────────────────────┼────────────────────────────────────────────────┤
│ Variant Management   │ CRUD for UI variants (filterBar, table, chart, │
│                      │ dialog, page). Supports default/public flags.  │
├──────────────────────┼────────────────────────────────────────────────┤
│ Version Management   │ Create, activate (auto-archives current), and  │
│                      │ query versions per application.                │
├──────────────────────┼────────────────────────────────────────────────┤
│ Draft Management     │ One active draft per app per tenant.           │
│                      │ Drafts accumulate change IDs before publish.   │
├──────────────────────┼────────────────────────────────────────────────┤
│ Personalization      │ Per-user, per-control personalizations.        │
│                      │ Scope: control, page, app.                     │
│                      │ Bulk reset per user+app.                       │
├──────────────────────┼────────────────────────────────────────────────┤
│ App Registry         │ Register Fiori apps with namespace, validity   │
│                      │ windows, owner, version.                       │
├──────────────────────┼────────────────────────────────────────────────┤
│ Observability        │ Health check endpoint returns UP/DOWN status.  │
├──────────────────────┼────────────────────────────────────────────────┤
│ Storage Backends     │ Memory (default), JSON files, MongoDB (stub).  │
│                      │ Configured via UIFLEXIBILITY_STORAGE env var.  │
├──────────────────────┼────────────────────────────────────────────────┤
│ Multi-Tenancy        │ All data is isolated per tenant identifier     │
│                      │ supplied via X-Tenant-Id header (or default).  │
└──────────────────────┴────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────────────────────┐
│ Deployment Profiles                                                   │
├────────────┬──────────────────────────────────────────────────────────┤
│ Profile    │ Details                                                  │
├────────────┼──────────────────────────────────────────────────────────┤
│ Standalone │ Binary: uim-ui-flexibility-platform-service              │
│            │ Build: dub run / dub build                               │
├────────────┼──────────────────────────────────────────────────────────┤
│ Docker     │ Multi-stage: builder (ldc-ubuntu:1.40.1) +               │
│            │ runtime (ubuntu:24.04), non-root appuser, port 8098      │
├────────────┼──────────────────────────────────────────────────────────┤
│ Podman     │ OCI-compliant Containerfile (identical to Dockerfile)    │
├────────────┼──────────────────────────────────────────────────────────┤
│ Kubernetes │ Deployment (2 replicas) + ClusterIP Service + ConfigMap  │
│            │ Liveness + readiness probes on /api/v1/health:8098       │
│            │ readOnlyRootFilesystem, drop ALL capabilities            │
└────────────┴──────────────────────────────────────────────────────────┘
```

---

## SV-1 System Interface Description

```
                      ┌─────────────────────────┐
                      │  SAPUI5 / Fiori Elements │
                      │  (Key User / End User)   │
                      └────────────┬────────────┘
                                   │ REST/JSON  HTTP
                                   │
                      ┌────────────▼────────────┐
                      │  UIM UI Flexibility      │
                      │  Platform Service        │
                      │  :8098                   │
                      └────────────┬────────────┘
             ┌─────────────────────┼──────────────────────┐
             ▼                     ▼                       ▼
     ┌──────────────┐    ┌──────────────────┐   ┌──────────────────┐
     │ In-process   │    │ Filesystem       │   │ MongoDB          │
     │ Memory Store │    │ JSON Store       │   │ (stub / future)  │
     └──────────────┘    │ /data/ui-flex/   │   └──────────────────┘
                         └──────────────────┘
```
