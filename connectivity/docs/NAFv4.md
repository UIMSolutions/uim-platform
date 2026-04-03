# Connectivity Service – NAF v4 Architecture Description

This document describes the **UIM Connectivity Platform Service**
using the **NATO Architecture Framework v4 (NAF v4)** viewpoints, adapted for
a microservice based on SAP BTP Connectivity Service concepts.

---

## 1. NAF v4 Grid Mapping

| Viewpoint | View | Section |
|---|---|---|
| **NCV** – Capability | C1 – Capability Taxonomy | §2 |
| **NCV** – Capability | C2 – Enterprise Vision | §2 |
| **NSOV** – Service | NSOV-1 – Service Taxonomy | §3 |
| **NSOV** – Service | NSOV-2 – Service Definitions | §3 |
| **NOV** – Operational | NOV-2 – Operational Node Connectivity | §4 |
| **NLV** – Logical | NLV-1 – Logical Data Model | §5 |
| **NPV** – Physical | NPV-1 – Physical Deployment | §6 |
| **NIV** – Information | NIV-1 – Information Structure | §7 |

---

## 2. Capability View (NCV)

### C1 – Capability Taxonomy

```
C1  Connectivity Capability
├── C1.1  Destination Management
│   ├── C1.1.1  Destination Provisioning (create, update, delete)
│   ├── C1.1.2  Destination Types (HTTP, RFC, Mail, LDAP)
│   ├── C1.1.3  Authentication Configuration (11 auth types)
│   ├── C1.1.4  Proxy Routing (Internet, On-Premise, Private Link)
│   ├── C1.1.5  Custom Properties & Additional Headers
│   ├── C1.1.6  Auth Flow Validation (domain service)
│   └── C1.1.7  Lookup by Name or Tenant
├── C1.2  Cloud Connector Management
│   ├── C1.2.1  Connector Registration (subaccount + location ID)
│   ├── C1.2.2  Heartbeat & Status Tracking
│   ├── C1.2.3  Tunnel Endpoint Configuration
│   ├── C1.2.4  Version Tracking
│   └── C1.2.5  Disconnect & Unregistration
├── C1.3  Service Channel Management
│   ├── C1.3.1  Channel Provisioning (create, delete)
│   ├── C1.3.2  Virtual-to-Backend Host/Port Mapping
│   ├── C1.3.3  Channel Types (HTTP, RFC, TCP)
│   ├── C1.3.4  Open / Close Lifecycle
│   └── C1.3.5  Connector Status Validation on Open
├── C1.4  Access Control
│   ├── C1.4.1  Access Rule Provisioning (create, update, delete)
│   ├── C1.4.2  Path-Prefix-Based Matching (longest prefix wins)
│   ├── C1.4.3  Allow / Deny Policies
│   ├── C1.4.4  Protocol Filtering (HTTP, HTTPS, RFC, TCP, LDAP)
│   └── C1.4.5  Principal Propagation Support
├── C1.5  Certificate Store
│   ├── C1.5.1  Certificate Provisioning (create, update, delete)
│   ├── C1.5.2  Certificate Formats (X.509, PKCS#12, PEM, JKS)
│   ├── C1.5.3  Certificate Usage (Authentication, Signing, Encryption)
│   ├── C1.5.4  Expiry Tracking & Expiring Query
│   └── C1.5.5  Active / Inactive Toggle
├── C1.6  Connectivity Monitoring
│   ├── C1.6.1  16 Event Types (connection, auth, certificate, channel, access, health, destination)
│   ├── C1.6.2  Severity Levels (info, warning, error, critical)
│   ├── C1.6.3  Source Tracking (entity ID + type)
│   └── C1.6.4  Tenant-Scoped Summary Aggregation
└── C1.7  Health & Readiness
    └── C1.7.1  Service Liveness Check
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide a centralised connectivity hub for managing destinations, on-premise tunnels, access control, and certificates across multi-tenant cloud environments |
| **Vision** | A unified connectivity layer that bridges cloud and on-premise systems through secure tunnels, configurable authentication flows, and fine-grained access control |
| **Strategic Goal** | Enable seamless cloud-to-on-premise integration with SAP BTP-compatible destination management, reverse-invoke Cloud Connector tunnels, path-based access rules, and certificate lifecycle management |
| **Scope** | Manages destinations, Cloud Connectors, service channels, access rules, certificates, and connectivity event logs |
| **Stakeholders** | Integration Architects, Network Administrators, Security Officers, Application Developers, Operations Engineers |

---

## 3. Service View (NSOV)

### NSOV-1 – Service Taxonomy

```
NSOV-1  Connectivity Services
├── SVC-DEST   Destination Management Services
├── SVC-CONN   Cloud Connector Management Services
├── SVC-CHAN   Service Channel Management Services
├── SVC-ACR    Access Rule Management Services
├── SVC-CERT   Certificate Store Services
├── SVC-MON    Connectivity Monitoring Services
└── SVC-HEALTH Health / Readiness Services
```

### NSOV-2 – Service Definitions

| Service ID | Name | Interface | Protocol | Path | Methods |
|---|---|---|---|---|---|
| SVC-DEST-CREATE | Create Destination | REST | HTTP/JSON | `/api/v1/destinations` | POST |
| SVC-DEST-LIST | List Destinations | REST | HTTP/JSON | `/api/v1/destinations` | GET |
| SVC-DEST-GET | Get Destination | REST | HTTP/JSON | `/api/v1/destinations/{id}` | GET |
| SVC-DEST-UPDATE | Update Destination | REST | HTTP/JSON | `/api/v1/destinations/{id}` | PUT |
| SVC-DEST-DELETE | Delete Destination | REST | HTTP/JSON | `/api/v1/destinations/{id}` | DELETE |
| SVC-CONN-REGISTER | Register Connector | REST | HTTP/JSON | `/api/v1/connectors` | POST |
| SVC-CONN-LIST | List Connectors | REST | HTTP/JSON | `/api/v1/connectors` | GET |
| SVC-CONN-GET | Get Connector | REST | HTTP/JSON | `/api/v1/connectors/{id}` | GET |
| SVC-CONN-HEARTBEAT | Heartbeat | REST | HTTP/JSON | `/api/v1/connectors/{id}/heartbeat` | POST |
| SVC-CONN-UNREGISTER | Unregister Connector | REST | HTTP/JSON | `/api/v1/connectors/{id}` | DELETE |
| SVC-CHAN-CREATE | Create Channel | REST | HTTP/JSON | `/api/v1/channels` | POST |
| SVC-CHAN-LIST | List Channels | REST | HTTP/JSON | `/api/v1/channels` | GET |
| SVC-CHAN-GET | Get Channel | REST | HTTP/JSON | `/api/v1/channels/{id}` | GET |
| SVC-CHAN-OPEN | Open Channel | REST | HTTP/JSON | `/api/v1/channels/{id}/open` | POST |
| SVC-CHAN-CLOSE | Close Channel | REST | HTTP/JSON | `/api/v1/channels/{id}/close` | POST |
| SVC-CHAN-DELETE | Delete Channel | REST | HTTP/JSON | `/api/v1/channels/{id}` | DELETE |
| SVC-ACR-CREATE | Create Access Rule | REST | HTTP/JSON | `/api/v1/access-rules` | POST |
| SVC-ACR-LIST | List Access Rules | REST | HTTP/JSON | `/api/v1/access-rules` | GET |
| SVC-ACR-GET | Get Access Rule | REST | HTTP/JSON | `/api/v1/access-rules/{id}` | GET |
| SVC-ACR-UPDATE | Update Access Rule | REST | HTTP/JSON | `/api/v1/access-rules/{id}` | PUT |
| SVC-ACR-DELETE | Delete Access Rule | REST | HTTP/JSON | `/api/v1/access-rules/{id}` | DELETE |
| SVC-CERT-CREATE | Create Certificate | REST | HTTP/JSON | `/api/v1/certificates` | POST |
| SVC-CERT-LIST | List Certificates | REST | HTTP/JSON | `/api/v1/certificates` | GET |
| SVC-CERT-GET | Get Certificate | REST | HTTP/JSON | `/api/v1/certificates/{id}` | GET |
| SVC-CERT-UPDATE | Update Certificate | REST | HTTP/JSON | `/api/v1/certificates/{id}` | PUT |
| SVC-CERT-DELETE | Delete Certificate | REST | HTTP/JSON | `/api/v1/certificates/{id}` | DELETE |
| SVC-MON-LOGS | List Logs | REST | HTTP/JSON | `/api/v1/monitoring/logs` | GET |
| SVC-MON-SUMMARY | Event Summary | REST | HTTP/JSON | `/api/v1/monitoring/summary` | GET |
| SVC-HEALTH | Health Check | REST | HTTP/JSON | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

### NOV-2 – Operational Node Connectivity

```
                     ┌──────────────────────────────────┐
                     │          HTTP Clients             │
                     │  (Integration Tooling /           │
                     │   Admin Console / On-Premise CC)  │
                     └──────────────┬───────────────────┘
                                    │ HTTP / JSON
                                    ▼
                     ┌──────────────────────────────────┐
                     │    Presentation Layer             │
                     │  ┌────────────────────────────┐  │
                     │  │ DestinationController       │  │
                     │  │ ConnectorController         │  │
                     │  │ ChannelController           │  │
                     │  │ AccessRuleController        │  │
                     │  │ CertificateController       │  │
                     │  │ MonitoringController        │  │
                     │  │ HealthController            │  │
                     │  └────────────────────────────┘  │
                     └──────────────┬───────────────────┘
                                    │ calls
                                    ▼
                     ┌──────────────────────────────────┐
                     │    Application Layer              │
                     │  ┌────────────────────────────┐  │
                     │  │ ManageDestinationsUseCase   │  │
                     │  │ ManageConnectorsUseCase     │  │
                     │  │ ManageChannelsUseCase       │  │
                     │  │ ManageAccessRulesUseCase    │  │
                     │  │ ManageCertificatesUseCase   │  │
                     │  │ MonitorConnectivityUseCase  │  │
                     │  └────────────────────────────┘  │
                     └──────────────┬───────────────────┘
                                    │ depends on ports
                                    ▼
                     ┌──────────────────────────────────┐
                     │    Domain Layer                   │
                     │  ┌────────────────────────────┐  │
                     │  │ Entities:                   │  │
                     │  │   Destination               │  │
                     │  │   CloudConnector            │  │
                     │  │   ServiceChannel            │  │
                     │  │   AccessRule                │  │
                     │  │   Certificate               │  │
                     │  │   ConnectivityLog           │  │
                     │  ├────────────────────────────┤  │
                     │  │ Ports (Interfaces):         │  │
                     │  │   DestinationRepository     │  │
                     │  │   ConnectorRepository       │  │
                     │  │   ChannelRepository         │  │
                     │  │   AccessRuleRepository      │  │
                     │  │   CertificateRepository     │  │
                     │  │   ConnectivityLogRepository │  │
                     │  ├────────────────────────────┤  │
                     │  │ Domain Services:            │  │
                     │  │   AuthFlowResolver          │  │
                     │  │   AccessControlEvaluator    │  │
                     │  └────────────────────────────┘  │
                     └──────────────┬───────────────────┘
                                    │ implements
                                    ▼
                     ┌──────────────────────────────────┐
                     │    Infrastructure Layer           │
                     │  ┌────────────────────────────┐  │
                     │  │ AppConfig (CONN_HOST/PORT)  │  │
                     │  │ Container (DI wiring)       │  │
                     │  ├────────────────────────────┤  │
                     │  │ In-Memory Repositories:     │  │
                     │  │   MemoryDestinationRepo   │  │
                     │  │   MemoryConnectorRepo     │  │
                     │  │   MemoryChannelRepo       │  │
                     │  │   MemoryAccessRuleRepo    │  │
                     │  │   MemoryCertificateRepo   │  │
                     │  │   MemoryConnectivityLogRepo│ │
                     │  └────────────────────────────┘  │
                     └──────────────────────────────────┘
                                    │
                     ┌──────────────┼───────────────────┐
                     ▼              ▼                    ▼
              ┌──────────┐  ┌──────────────┐  ┌────────────┐
              │ On-Prem  │  │ Identity     │  │  Portal    │
              │ Backend  │  │ Authentica.  │  │  Service   │
              └──────────┘  └──────────────┘  └────────────┘
```

**Operational Information Exchanges:**

| Exchange | From | To | Content | Frequency |
|---|---|---|---|---|
| OIE-1 | Integration Client | Connectivity | Destination CRUD operations with auth config | On demand |
| OIE-2 | Cloud Connector Agent | Connectivity | Register, heartbeat, disconnect | Periodic / On change |
| OIE-3 | Admin Console | Connectivity | Channel create/open/close, access rule CRUD | On demand |
| OIE-4 | Admin Console | Connectivity | Certificate store management | On demand |
| OIE-5 | Connectivity | Log Store | Connectivity event log per state change | Per operation |
| OIE-6 | Monitoring Tool | Connectivity | Log queries and summary retrieval | On demand |
| OIE-7 | Application | Connectivity | Destination lookup for routing decisions | Per request |
| OIE-8 | Application | Connectivity | Access evaluation for on-premise requests | Per request |

---

## 5. Logical View (NLV)

### NLV-1 – Logical Data Model

```
┌──────────────────────────────────────────────────────────────────┐
│  Destination Domain                                               │
│                                                                   │
│  ┌──────────────────────────┐       ┌──────────────────────┐   │
│  │  Destination              │──1:N──│  DestinationProperty  │   │
│  ├──────────────────────────┤       ├──────────────────────┤   │
│  │ id : DestinationId        │       │ key : string          │   │
│  │ tenantId : TenantId       │       │ value : string        │   │
│  │ name, description : string│       └──────────────────────┘   │
│  │ url : string              │                                    │
│  │ destinationType :         │   Auth Types (11):                 │
│  │   http | rfc | mail | ldap│   noAuthentication                 │
│  │ authType :                │   basicAuthentication              │
│  │   AuthenticationType      │   oauth2ClientCredentials          │
│  │ proxyType :               │   oauth2SAMLBearerAssertion        │
│  │   internet | onPremise    │   oauth2UserTokenExchange          │
│  │    | privateLink          │   oauth2JWTBearer                  │
│  │ user, password : string   │   oauth2Password                   │
│  │ clientId, clientSecret    │   oauth2AuthorizationCode          │
│  │ tokenServiceUrl : string  │   clientCertificateAuthentication  │
│  │ certificateId :           │   principalPropagation             │
│  │   CertificateId          │   samlAssertion                    │
│  │ cloudConnectorLocationId  │                                    │
│  │ additionalHeaders[] :     │                                    │
│  │   DestinationProperty     │                                    │
│  │ createdBy, createdAt      │                                    │
│  │ updatedAt                 │                                    │
│  └──────────────────────────┘                                    │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  Cloud Connector Domain                                           │
│                                                                   │
│  ┌──────────────────────────┐       ┌──────────────────────┐   │
│  │  CloudConnector           │──1:N──│  ServiceChannel       │   │
│  ├──────────────────────────┤       ├──────────────────────┤   │
│  │ id : ConnectorId          │       │ id : ChannelId        │   │
│  │ subaccountId :            │       │ connectorId :         │   │
│  │   SubaccountId            │       │   ConnectorId         │   │
│  │ tenantId : TenantId       │       │ tenantId : TenantId   │   │
│  │ locationId : string       │       │ name : string         │   │
│  │ description : string      │       │ channelType :         │   │
│  │ connectorVersion : string │       │   http | rfc | tcp    │   │
│  │ host : string             │       │ status :              │   │
│  │ port : ushort             │       │   open | closed | err │   │
│  │ status : ConnectorStatus  │       │ virtualHost : string  │   │
│  │ lastHeartbeat : long      │       │ virtualPort : ushort  │   │
│  │ connectedSince : long     │       │ backendHost : string  │   │
│  │ tunnelEndpoint : string   │       │ backendPort : ushort  │   │
│  │ createdAt, updatedAt      │       │ openedAt, closedAt    │   │
│  └──────────────────────────┘       │ createdAt, updatedAt  │   │
│           │                          └──────────────────────┘   │
│           │ 1:N                                                   │
│           ▼                                                       │
│  ┌──────────────────────────┐                                    │
│  │  AccessRule               │                                    │
│  ├──────────────────────────┤                                    │
│  │ id : RuleId               │                                    │
│  │ connectorId : ConnectorId │                                    │
│  │ tenantId : TenantId       │                                    │
│  │ description : string      │                                    │
│  │ protocol : AccessProtocol │                                    │
│  │   http|https|rfc|tcp|ldap │                                    │
│  │ virtualHost : string      │                                    │
│  │ virtualPort : ushort      │                                    │
│  │ urlPathPrefix : string    │                                    │
│  │ policy : allow | deny     │                                    │
│  │ principalPropagation:bool │                                    │
│  │ createdAt, updatedAt      │                                    │
│  └──────────────────────────┘                                    │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  Certificate Domain                                               │
│                                                                   │
│  ┌──────────────────────────────────────────┐                    │
│  │  Certificate                              │                    │
│  ├──────────────────────────────────────────┤                    │
│  │ id : CertificateId                        │                    │
│  │ tenantId : TenantId                       │                    │
│  │ name, description : string                │                    │
│  │ certType : x509 | pkcs12 | pem | jks      │                    │
│  │ usage : authentication | signing           │                    │
│  │         | encryption                      │                    │
│  │ subjectDN, issuerDN : string              │                    │
│  │ serialNumber, fingerprint : string        │                    │
│  │ validFrom, validTo : long                 │                    │
│  │ active : bool                             │                    │
│  │ createdAt, updatedAt : long               │                    │
│  ├──────────────────────────────────────────┤                    │
│  │ + isExpired(now) : bool                   │                    │
│  │ + expiresWithinDays(now, days) : bool     │                    │
│  └──────────────────────────────────────────┘                    │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  Monitoring Domain                                                │
│                                                                   │
│  ┌──────────────────────────────────────────┐                    │
│  │  ConnectivityLog (immutable)              │                    │
│  ├──────────────────────────────────────────┤                    │
│  │ id : ConnectivityLogId                    │                    │
│  │ tenantId : TenantId                       │                    │
│  │ eventType : ConnectivityEventType         │                    │
│  │   (16 values: connectionEstablished,      │                    │
│  │    connectionLost, connectionRefused,     │                    │
│  │    authenticationSuccess, authFailure,    │                    │
│  │    certificateExpiring, certExpired,      │                    │
│  │    channelOpened, channelClosed,          │                    │
│  │    channelError, accessDenied,            │                    │
│  │    accessGranted, healthCheckPassed,      │                    │
│  │    healthCheckFailed, destinationResolved,│                    │
│  │    destinationNotFound)                   │                    │
│  │ severity : info | warn | error | critical │                    │
│  │ sourceId, sourceType : string             │                    │
│  │ message : string                          │                    │
│  │ remoteHost : string                       │                    │
│  │ remotePort : ushort                       │                    │
│  │ timestamp : long                          │                    │
│  └──────────────────────────────────────────┘                    │
└──────────────────────────────────────────────────────────────────┘
```

**Key Enumerations:**

| Enum | Values |
|---|---|
| DestinationType | http, rfc, mail, ldap |
| AuthenticationType | noAuthentication, basicAuthentication, oauth2ClientCredentials, oauth2SAMLBearerAssertion, oauth2UserTokenExchange, oauth2JWTBearer, oauth2Password, oauth2AuthorizationCode, clientCertificateAuthentication, principalPropagation, samlAssertion |
| ProxyType | internet, onPremise, privateLink |
| ConnectorStatus | connected, disconnected, error, maintenance |
| ChannelType | http, rfc, tcp |
| ChannelStatus | open, closed, error |
| AccessPolicy | allow, deny |
| AccessProtocol | http, https, rfc, tcp, ldap |
| CertificateType | x509, pkcs12, pem, jks |
| CertificateUsage | authentication, signing, encryption |
| LogSeverity | info, warning, error, critical |
| ConnectivityEventType | connectionEstablished, connectionLost, connectionRefused, authenticationSuccess, authenticationFailure, certificateExpiring, certificateExpired, channelOpened, channelClosed, channelError, accessDenied, accessGranted, healthCheckPassed, healthCheckFailed, destinationResolved, destinationNotFound |

---

## 6. Physical View (NPV)

### NPV-1 – Physical Deployment

```
┌─────────────────────────────────────────────────────────────┐
│  Deployment Node: Application Server                         │
│  OS: Linux                                                   │
│  Runtime: Native D binary (compiled with dub + DMD/LDC)     │
│                                                              │
│  ┌────────────────────────────────────────────────────┐     │
│  │  Artifact: uim-connectivity-platform-service        │     │
│  │            (executable)                             │     │
│  │  Source:   connectivity/source/**/*.d                │     │
│  │  Binary:   connectivity/build/                       │     │
│  │            uim-connectivity-platform-service         │     │
│  │  Port:     8088 (configurable CONN_PORT)             │     │
│  │  Protocol: HTTP/1.1 (vibe.d event loop)              │     │
│  └────────────────────────────────────────────────────┘     │
│                                                              │
│  Environment Variables:                                      │
│  ┌────────────────┬──────────┬──────────────────────┐       │
│  │ Name           │ Default  │ Description           │       │
│  ├────────────────┼──────────┼──────────────────────┤       │
│  │ CONN_HOST      │ 0.0.0.0  │ HTTP bind address     │       │
│  │ CONN_PORT      │ 8088     │ HTTP listen port      │       │
│  └────────────────┴──────────┴──────────────────────┘       │
│                                                              │
│  Dependencies:                                               │
│  ┌────────────────────────────┬──────────┐                  │
│  │ Package                    │ Version  │                  │
│  ├────────────────────────────┼──────────┤                  │
│  │ uim-platform:service       │ local    │                  │
│  └────────────────────────────┴──────────┘                  │
│                                                              │
│  Persistence: In-memory (ephemeral)                          │
│  Scaling: Stateless – horizontally scalable with external    │
│           persistence adapter                                │
└─────────────────────────────────────────────────────────────┘
```

**Deployment Constraints:**

| Constraint | Description |
|---|---|
| DC-1 | Single-process, multi-threaded via vibe.d fibers |
| DC-2 | In-memory persistence is non-durable; data is lost on restart |
| DC-3 | Swapping to durable persistence requires implementing 6 repository interfaces |
| DC-4 | Passwords and client secrets are stored in plaintext in Destination structs; a production adapter should integrate with a secrets manager |
| DC-5 | Cloud Connector tunnel establishment is modeled but not physically tunneled; real reverse-invoke proxying requires a transport adapter |

---

## 7. Information View (NIV)

### NIV-1 – Information Structure

**Information Flows:**

| Flow ID | Source | Target | Data | Format | Trigger |
|---|---|---|---|---|---|
| IF-1 | Integration Client | DestinationController | Destination config (name, URL, auth, proxy, properties) | JSON | Admin action |
| IF-2 | Cloud Connector Agent | ConnectorController | Registration (subaccount, location, host, port, tunnel) | JSON | On connect |
| IF-3 | Cloud Connector Agent | ConnectorController | Heartbeat with version | JSON | Periodic |
| IF-4 | Admin Console | ChannelController | Channel config (connector, virtual/backend host:port) | JSON | Admin action |
| IF-5 | Admin Console | AccessRuleController | Rule config (connector, protocol, path prefix, policy) | JSON | Admin action |
| IF-6 | Admin Console | CertificateController | Certificate metadata (name, type, usage, DN, validity) | JSON | Admin action |
| IF-7 | ManageDestinationsUseCase | AuthFlowResolver | Destination for auth config validation | Internal | On create/update |
| IF-8 | ManageConnectorsUseCase | ConnectivityLogRepository | Connection event log | Internal | On register/disconnect |
| IF-9 | ManageChannelsUseCase | ConnectorRepository | Verify connector status before open | Internal | On open |
| IF-10 | Monitoring Tool | MonitoringController | Log queries and summary aggregation | JSON | On demand |

**Data Sensitivity:**

| Data Element | Classification | Handling |
|---|---|---|
| Destination password | Secret | Stored in Destination struct; not exposed in API serialization |
| Client secret | Secret | Stored for token service auth; not serialized to API responses |
| Certificate private key | Secret | Not stored (only metadata: DN, fingerprint, validity); actual key material managed externally |
| Tunnel endpoint | Internal | Internal reverse-proxy address; not exposed to external clients |
| Connectivity logs | Operational | Immutable; append-only; contains source/host references for diagnostics |
| Access rules | Configuration | Tenant-scoped; controls which on-premise paths are reachable |

---

## 8. Traceability Matrix

| Capability | Service(s) | Entity/ies | Controller | Use Case |
|---|---|---|---|---|
| C1.1 Destination Management | SVC-DEST-* | Destination, DestinationProperty | DestinationController | ManageDestinationsUseCase |
| C1.1.3 Auth Configuration | (internal) | Destination | — | AuthFlowResolver |
| C1.2 Cloud Connector | SVC-CONN-* | CloudConnector | ConnectorController | ManageConnectorsUseCase |
| C1.3 Service Channels | SVC-CHAN-* | ServiceChannel | ChannelController | ManageChannelsUseCase |
| C1.4 Access Control | SVC-ACR-* | AccessRule | AccessRuleController | ManageAccessRulesUseCase |
| C1.4.2 Path-Prefix Matching | (internal) | AccessRule | — | AccessControlEvaluator |
| C1.5 Certificate Store | SVC-CERT-* | Certificate | CertificateController | ManageCertificatesUseCase |
| C1.6 Monitoring | SVC-MON-* | ConnectivityLog | MonitoringController | MonitorConnectivityUseCase |
| C1.7 Health | SVC-HEALTH | — | HealthController | — |

---

*Document generated for the UIM Platform Connectivity Service.*
*Authors: UIM Platform Team*
*© 2018–2026 UIM Platform Team — Proprietary*
