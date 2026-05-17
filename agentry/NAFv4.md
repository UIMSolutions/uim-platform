# NAF v4 Architecture Description — Agentry Service

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> Agentry Service — metadata-driven mobile application development, device management,
> backend integration, data synchronisation, and app deployment for SAP BTP.

---

## 1. NAF v4 Grid Mapping

| NAF View | Viewpoint | Covered Below |
|---|---|---|
| **NCV** | C1 Capability Taxonomy, C2 Enterprise Vision | §2 |
| **NSV** | NSOV-2 Service Definitions | §3 |
| **NOV** | NOV-2 Operational Node Connectivity | §4 |
| **NLV** | NLV-1 Logical Data Model | §5 |
| **NPV** | NPV-1 Physical Deployment | §6 |
| **NIV** | NIV-1 Information Structure | §7 |

---

## 2. Capability View (NCV)

### C1 – Capability Taxonomy

```
Agentry
├── C1.1  Mobile Application Lifecycle
│   ├── C1.1.1  Register and catalogue mobile applications
│   └── C1.1.2  Platform and status management (iOS, Android, Windows)
│
├── C1.2  Metadata-driven App Authoring
│   ├── C1.2.1  Create and validate app definitions (XML/JSON metadata)
│   └── C1.2.2  Schema versioning and business object model binding
│
├── C1.3  App Version Management
│   ├── C1.3.1  Build and publish versioned app packages
│   └── C1.3.2  Mandatory update enforcement and artifact distribution
│
├── C1.4  Device Management
│   ├── C1.4.1  Mobile device enrollment and group assignment
│   ├── C1.4.2  MDM integration and push notification tokens
│   └── C1.4.3  OS version and installed app version tracking
│
├── C1.5  Data Synchronisation
│   ├── C1.5.1  Bidirectional offline data sync sessions
│   └── C1.5.2  Sync monitoring (bytes, records, errors)
│
├── C1.6  Backend Integration
│   ├── C1.6.1  SAP backend connection configuration (S/4HANA, ECC, BTP)
│   └── C1.6.2  Authentication management (Basic, OAuth 2.0, SAML)
│
├── C1.7  Deployment Orchestration
│   ├── C1.7.1  Targeted app version rollouts (device, group, tenant)
│   └── C1.7.2  Rollback and status tracking
│
└── C1.8  Cross-Cutting
    ├── C1.8.1  Tenant isolation
    └── C1.8.2  Health monitoring
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide a metadata-driven mobile platform modelled on SAP BTP Agentry, enabling mobile-first extension of SAP backends without native app code. |
| **Vision** | Give enterprises a unified service for authoring, deploying, and operating enterprise-grade mobile applications that synchronise data with SAP backend systems. |
| **Scope** | Mobile applications, app definitions, app versions, enrolled devices, sync sessions, backend connections, and deployments. |
| **Stakeholders** | Mobile Developers, IT Administrators, SAP Basis Teams, End Users on mobile devices. |

---

## 3. Service View (NSV)

| Service ID | Name | Path Prefix | Methods |
|---|---|---|---|
| SVC-APP-CRUD | Mobile Application | `/api/v1/agentry/mobile-applications` | GET, POST, PUT, DELETE |
| SVC-DEF-CRUD | App Definition | `/api/v1/agentry/app-definitions` | GET, POST, PUT, DELETE |
| SVC-VER-CRUD | App Version | `/api/v1/agentry/app-versions` | GET, POST, PUT, DELETE |
| SVC-DEV-CRUD | Device | `/api/v1/agentry/devices` | GET, POST, PUT, DELETE |
| SVC-SYNC-CRUD | Sync Session | `/api/v1/agentry/sync-sessions` | GET, POST, PUT, DELETE |
| SVC-CONN-CRUD | Backend Connection | `/api/v1/agentry/backend-connections` | GET, POST, PUT, DELETE |
| SVC-DEPLOY-CRUD | Deployment | `/api/v1/agentry/deployments` | GET, POST, PUT, DELETE |
| SVC-HLTH | Health Check | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

```
┌────────────────────┐   REST/HTTP/JSON   ┌──────────────────────────────┐
│  Mobile Client     │──────────────────▶ │  Agentry Service             │
│  (iOS/Android/Win) │                    │  POST /sync-sessions         │
└────────────────────┘                    │  PUT  /sync-sessions/{id}    │
                                          └──────────────┬───────────────┘
┌────────────────────┐   REST/HTTP/JSON                  │
│  SAP Cockpit /     │──────────────────▶ │  POST /mobile-applications   │
│  Developer Tools   │                    │  POST /app-definitions       │
└────────────────────┘                    │  POST /deployments           │
                                          └──────────────┬───────────────┘
┌────────────────────┐   REST/HTTP/JSON                  │
│  MDM / EMM System  │──────────────────▶ │  POST /devices               │
└────────────────────┘                    │  PUT  /devices/{id}          │
                                          └──────────────┬───────────────┘
                                                         │
                                          ┌──────────────▼───────────────┐
                                          │  SAP Backend                 │
                                          │  (S/4HANA, ECC, BTP)        │
                                          │  via BackendConnection       │
                                          └──────────────────────────────┘
```

---

## 5. Logical Data Model (NLV)

```
MobileApplication
  └── id, tenantId, name, description, platform, status,
      packageName, offlineCapable, pushNotificationsEnabled,
      minOsVersion, vendor, category, contactEmail

AppDefinition
  └── id, tenantId, mobileApplicationId, name, description,
      definitionContent, definitionFormat, schemaVersion,
      targetPlatform, businessObjectModel, status,
      validationPassed, validationErrors

AppVersion
  └── id, tenantId, mobileApplicationId, definitionId,
      versionNumber, releaseNotes, status, artifactUrl,
      checksum, minOsVersion, isMandatoryUpdate, changeLog

Device
  └── id, tenantId, mobileApplicationId, deviceName,
      deviceModel, manufacturer, platform, osVersion,
      appVersionInstalled, status, userId, userEmail,
      groupName, pushToken, isManaged, mdmDeviceId

SyncSession
  └── id, tenantId, deviceId, mobileApplicationId,
      backendConnectionId, status, direction,
      startedAt, completedAt, bytesSent, bytesReceived,
      recordsSent, recordsReceived, errorMessage,
      clientAppVersion, triggeredBy

BackendConnection
  └── id, tenantId, name, description, backendType, status,
      backendUrl, clientId, authMethod, sysId, sysNumber,
      client, language, destinationName, sslEnabled,
      certificateFingerprint, lastTestedAt

Deployment
  └── id, tenantId, mobileApplicationId, appVersionId,
      status, scope, targetDeviceId, targetGroupName,
      scheduledAt, startedAt, completedAt, deployedBy,
      notes, devicesTotal, devicesSucceeded, devicesFailed,
      rollbackVersionId
```

### Key Relationships

| From | Relation | To |
|---|---|---|
| AppDefinition | `mobileApplicationId →` | MobileApplication |
| AppVersion | `mobileApplicationId →` | MobileApplication |
| AppVersion | `definitionId →` | AppDefinition |
| Device | `mobileApplicationId →` | MobileApplication |
| SyncSession | `deviceId →` | Device |
| SyncSession | `mobileApplicationId →` | MobileApplication |
| SyncSession | `backendConnectionId →` | BackendConnection |
| Deployment | `mobileApplicationId →` | MobileApplication |
| Deployment | `appVersionId →` | AppVersion |

---

## 6. Physical Deployment (NPV)

```
┌──────────────────────────────────────────────────────────────────┐
│  Kubernetes Namespace: uim-platform                              │
│                                                                  │
│  ┌───────────────────────────────────────────┐                  │
│  │  Deployment: agentry                      │                  │
│  │  Image: uim-platform/agentry:latest       │                  │
│  │  Port: 8117                               │                  │
│  │  Resources: 64Mi req / 256Mi limit        │                  │
│  │  ReadOnlyRootFilesystem: true             │                  │
│  │  RunAsNonRoot: true                       │                  │
│  └───────────────────────────────────────────┘                  │
│                                                                  │
│  ┌───────────────────────────────────────────┐                  │
│  │  Service: agentry (ClusterIP :8117)       │                  │
│  └───────────────────────────────────────────┘                  │
│                                                                  │
│  ┌───────────────────────────────────────────┐                  │
│  │  ConfigMap: agentry-config                │                  │
│  │    AGENTRY_HOST=0.0.0.0                   │                  │
│  │    AGENTRY_PORT=8117                      │                  │
│  └───────────────────────────────────────────┘                  │
└──────────────────────────────────────────────────────────────────┘

Container Runtime Compatibility:
  - Docker  (Dockerfile)
  - Podman  (Containerfile — identical content)
  - Kubernetes (k8s/ manifests)
```

### Multi-stage Build

| Stage | Base Image | Purpose |
|---|---|---|
| `build` | `dlang2/ldc-ubuntu:1.40.1` | Compile D source with LDC2 |
| `runtime` | `ubuntu:24.04` | Minimal runtime, non-root user |

---

## 7. Information Structure (NIV)

### REST Request/Response Schema

**Mobile Application (POST body)**
```json
{
  "id": "app-001",
  "name": "Field Service Mobile",
  "description": "Technician mobile app for field service",
  "platform": "android",
  "packageName": "com.example.fieldservice",
  "offlineCapable": true,
  "pushNotificationsEnabled": true,
  "minOsVersion": "12.0",
  "vendor": "Example Corp",
  "category": "field-service",
  "contactEmail": "mobile@example.com"
}
```

**App Definition (POST body)**
```json
{
  "id": "def-001",
  "mobileApplicationId": "app-001",
  "name": "FieldService v2 Definition",
  "definitionFormat": "xml",
  "definitionContent": "<agentry-definition>...</agentry-definition>",
  "schemaVersion": "3.0",
  "targetPlatform": "android",
  "businessObjectModel": "S4HANA_PM"
}
```

**Device Enrollment (POST body)**
```json
{
  "id": "dev-001",
  "mobileApplicationId": "app-001",
  "deviceName": "Samsung Galaxy S24",
  "deviceModel": "SM-S921B",
  "manufacturer": "Samsung",
  "platform": "android",
  "osVersion": "14",
  "userId": "user@example.com",
  "groupName": "technicians-emea",
  "isManaged": true
}
```

**Standard List Response**
```json
{
  "count": 3,
  "resources": [ ... ],
  "message": "Mobile application list retrieved successfully"
}
```

**Health Response**
```json
{
  "status": "UP",
  "service": "Agentry Service"
}
```

### Enumerations

| Enum | Values |
|---|---|
| `AppPlatform` | `ios`, `android`, `windows`, `web`, `cross` |
| `AppStatus` | `draft`, `active`, `deprecated_`, `archived` |
| `DefinitionStatus` | `draft`, `published`, `archived` |
| `AppVersionStatus` | `pending`, `published`, `deprecated_`, `withdrawn` |
| `DeviceStatus` | `enrolled`, `active`, `suspended`, `removed` |
| `SyncStatus` | `pending`, `inProgress`, `completed`, `failed`, `cancelled` |
| `SyncDirection` | `upload`, `download`, `bidirectional` |
| `BackendType` | `s4hana`, `ecc`, `btp`, `crm`, `custom` |
| `ConnectionStatus` | `active`, `inactive`, `error`, `testing` |
| `DeploymentStatus` | `pending`, `deploying`, `deployed`, `failed`, `rolledBack` |
| `DeploymentScope` | `device`, `group`, `tenant` |
