# NAF v4 Architecture Description — Mobile Services

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> Mobile Services — mobile application management, device registration, push
> notification delivery, offline data stores, and client log collection.

---

## 1. NAF v4 Grid Mapping

| NAF View | Viewpoint | Covered Below |
|---|---|---|
| **NCV** – NATO Capability View | C1 Capability Taxonomy, C2 Enterprise Vision | §2 |
| **NSV** – NATO Service View | NSOV-1 Service Taxonomy, NSOV-2 Service Definitions | §3 |
| **NOV** – NATO Operational View | NOV-2 Operational Node Connectivity | §4 |
| **NLV** – NATO Logical View | NLV-1 Logical Data Model | §5 |
| **NPV** – NATO Physical View | NPV-1 Physical Deployment | §6 |
| **NIV** – NATO Information View | NIV-1 Information Structure | §7 |

---

## 2. Capability View (NCV)

### C1 – Capability Taxonomy

```
Mobile Services
├── C1.1  Application Management
│   ├── C1.1.1  Mobile app registration and versioning
│   └── C1.1.2  Platform (iOS / Android) management
│
├── C1.2  Device Management
│   ├── C1.2.1  Device registration and lifecycle
│   └── C1.2.2  Push token management
│
├── C1.3  Push Notifications
│   ├── C1.3.1  APNs and FCM provider integration
│   └── C1.3.2  Targeted and broadcast notifications
│
├── C1.4  Offline Data
│   ├── C1.4.1  Offline store configuration
│   └── C1.4.2  OData entity set synchronisation
│
├── C1.5  Client Resources
│   └── C1.5.1  App configuration and resource bundle delivery
│
├── C1.6  Client Logs
│   └── C1.6.1  Device-side log collection
│
└── C1.7  Cross-Cutting
    ├── C1.7.1  Tenant isolation
    └── C1.7.2  Health monitoring
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide mobile application backend services modelled on SAP Mobile Services for BTP. |
| **Vision** | Enable enterprises to deploy, manage, and monitor mobile apps with device registration, push notifications, offline data, and logging. |
| **Scope** | Mobile app lifecycle, device registration, push notifications, offline OData stores, client resources, and log collection. |
| **Stakeholders** | Mobile Developers, Platform Operators, Field Workers. |

---

## 3. Service View (NSV)

### NSOV-2 – Service Definitions

| Service ID | Name | Path Prefix | Methods |
|---|---|---|---|
| SVC-APP-CRUD | Mobile App | `/api/v1/mobile-apps` | GET, POST, PUT, DELETE |
| SVC-VER-CRUD | App Version | `/api/v1/app-versions` | GET, POST, DELETE |
| SVC-DEV-CRUD | Device Registration | `/api/v1/device-registrations` | GET, POST, DELETE |
| SVC-PUSH-CRUD | Push Registration | `/api/v1/push-registrations` | GET, POST, DELETE |
| SVC-NOTIF-CRUD | Push Notification | `/api/v1/push-notifications` | GET, POST |
| SVC-OS-CRUD | Offline Store | `/api/v1/offline-stores` | GET, POST, DELETE |
| SVC-LOG-LIST | Client Log | `/api/v1/client-logs` | GET, POST |
| SVC-RES-CRUD | Client Resource | `/api/v1/client-resources` | GET, POST, DELETE |
| SVC-HLTH | Health Check | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

```
┌────────────────────┐   REST/HTTP/JSON   ┌──────────────────────────────┐
│  Mobile Device /    │ ─────────────────> │  Mobile Services             │
│  App Admin          │                    │  port 8096                    │
└────────────────────┘                    └──────────────────────────────┘
```

---

## 5. Logical View (NLV)

| Entity | Key Relationships |
|---|---|
| `MobileApp` | Root; parent of AppVersions, DeviceRegistrations, OfflineStores, ClientResources |
| `AppVersion` | Versioned release of a MobileApp |
| `DeviceRegistration` | Device endpoint; parent of PushRegistrations and ClientLogEntries |
| `PushRegistration` | Provider token binding (APNs / FCM) for a device |
| `PushNotification` | Broadcast or targeted notification |
| `OfflineStore` | OData entity set sync configuration |
| `ClientLogEntry` | Device-side log uploaded to the platform |
| `ClientResource` | App resource bundle delivered to device |

---

## 6. Physical View (NPV)

```
Kubernetes Cluster — Namespace: uim-platform
├── ConfigMap: mobile-config
│   MOBILE_HOST: "0.0.0.0"
│   MOBILE_PORT: "8096"
├── Deployment: mobile  port: 8096
└── Service: mobile (ClusterIP :8096)
```

---

## 7. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | Device-centric push model | Mirrors SAP Mobile Services device registration and push patterns |
| AD-2 | Offline store configuration | Reflects SAP Mobile Services OData offline store concept |
| AD-3 | Client log collection | Enables remote device diagnostics |
| AD-4 | In-memory repositories | Fast testing; swap for persistent store + push gateways in production |
| AD-5 | Port 8096 | Consistent UIM platform port allocation |
