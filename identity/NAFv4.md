# NAFv4 Architecture — UIM Identity Platform Service

Aligned with NATO Architecture Framework v4 (NAFv4) viewpoints.

---

## NCV — Capability Taxonomy

| Capability | Sub-Capability | Description |
|---|---|---|
| **Identity Management** | User Lifecycle | Create, update, delete, and query users across tenants |
| | Group Management | Manage user groups and authorization groups |
| | User Authentication | Support for form, basic, certificate, token, and SPNEGO auth |
| **Application Management** | Application Registration | Register OIDC/SAML applications with client credentials |
| | Auth Scheme Configuration | Configure per-application authentication schemes |
| | Risk-Based Auth | Enable/disable risk-based authentication per application |
| **Federation** | Identity Provider Configuration | Configure corporate OIDC/SAML identity providers |
| | Default IdP | Designate a default identity provider per tenant |
| | Domain Restrictions | Restrict IdP usage by email domain |
| **Provisioning** | Job Orchestration | Create and lifecycle-manage provisioning jobs |
| | Source/Target System Mapping | Map source to target systems for data sync |
| | Job Lifecycle Control | Start, cancel, and monitor provisioning jobs |
| **Multi-Tenancy** | Tenant Isolation | All entities scoped to TenantId |
| **Persistence** | Memory Backend | Stateless in-process storage |
| | File Backend | JSON file persistence with hot-load on startup |
| | MongoDB Backend | Document-store persistence via vibe.db.mongo |

---

## NSV — Service View

| Service | Interface | Protocol | Consumer |
|---|---|---|---|
| User Management API | REST JSON | HTTP/1.1 | Service consumers, admin tools |
| Group Management API | REST JSON | HTTP/1.1 | Service consumers |
| Application Registry API | REST JSON | HTTP/1.1 | App developers, platform services |
| Identity Provider API | REST JSON | HTTP/1.1 | Platform administrators |
| Provisioning Job API | REST JSON | HTTP/1.1 | IPS schedulers, admin tools |
| Web UI | HTML | HTTP/1.1 | Browser clients |
| Health Endpoint | REST JSON | HTTP/1.1 | Kubernetes, load balancers |

---

## NOV — Operational Node Connectivity

```mermaid
graph LR
    subgraph External
        Browser[Browser Client]
        APIClient[REST API Client]
        K8sProbe[K8s Health Probe]
        MongoDB[(MongoDB)]
        FileSystem[(File System)]
    end

    subgraph UIM Identity Service
        Router[URLRouter]
        IASCtrl[IAS Controllers]
        IPSCtrl[IPS Controller]
        WebCtrl[Web Controller]
        UseCases[Use Cases]
        Repos[Repository Adapters]
    end

    Browser -->|GET /web/identity/*| Router
    APIClient -->|REST /api/v1/ias/* /api/v1/ips/*| Router
    K8sProbe -->|GET /api/v1/health| Router
    Router --> IASCtrl
    Router --> IPSCtrl
    Router --> WebCtrl
    IASCtrl --> UseCases
    IPSCtrl --> UseCases
    WebCtrl --> UseCases
    UseCases --> Repos
    Repos -->|memory| UseCases
    Repos -->|file| FileSystem
    Repos -->|mongodb| MongoDB
```

---

## NLV — Logical Data Model

```mermaid
erDiagram
    TENANT ||--o{ USER : "owns"
    TENANT ||--o{ GROUP : "owns"
    TENANT ||--o{ APPLICATION : "owns"
    TENANT ||--o{ IDENTITY_PROVIDER : "owns"
    TENANT ||--o{ PROVISIONING_JOB : "owns"

    USER {
        string id PK
        TenantId tenantId FK
        string userName
        string email
        string displayName
        string status
        string type_
    }

    GROUP {
        string id PK
        TenantId tenantId FK
        string name
        string type_
    }

    USER_GROUP_MEMBERSHIP {
        string userId FK
        string groupId FK
    }

    APPLICATION {
        string id PK
        TenantId tenantId FK
        string name
        string clientId
        string protocol
        string status
    }

    IDENTITY_PROVIDER {
        string id PK
        TenantId tenantId FK
        string name
        string entityId
        string type_
        bool isDefault
    }

    PROVISIONING_JOB {
        string id PK
        TenantId tenantId FK
        string name
        string sourceSystem
        string targetSystem
        string status
    }

    USER ||--o{ USER_GROUP_MEMBERSHIP : "member"
    GROUP ||--o{ USER_GROUP_MEMBERSHIP : "has"
    APPLICATION }o--|| IDENTITY_PROVIDER : "delegates to"
```

---

## NPV — Physical Deployment

```mermaid
graph TD
    subgraph Kubernetes Cluster
        subgraph Namespace: uim-platform
            CM[ConfigMap: identity-config]
            Deploy[Deployment: identity]
            Svc[Service: identity ClusterIP:8121]
            Pod[Pod: uim-identity-platform-service]
        end
        subgraph Storage Options
            EmptyDir[EmptyDir Volume - memory/file mode]
            MongoPod[MongoDB StatefulSet - mongodb mode]
        end
    end
    subgraph Container Registry
        Image[uim-platform/identity:latest]
    end
    Deploy --> Pod
    Pod --> EmptyDir
    Pod -.-> MongoPod
    CM --> Pod
    Image --> Deploy
    Svc --> Pod

    subgraph Base Images
        Builder["dlang2/ldc-ubuntu:1.40.1 (build)"]
        Runtime["ubuntu:24.04 (runtime)"]
    end
    Builder --> Image
    Runtime --> Image
```

---

## Summary

| NAFv4 View | Coverage |
|---|---|
| NCV (Capability) | 6 capability areas, 14 sub-capabilities |
| NSV (Service) | 7 REST/HTML services mapped |
| NOV (Operational) | Node connectivity with all consumers and backends |
| NLV (Logical Data) | Full ER diagram with 5 entity types |
| NPV (Physical) | Kubernetes deployment topology with 3 storage backends |
