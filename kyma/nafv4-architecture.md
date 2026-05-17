# NAF v4 Architecture Description — Kyma Runtime Service

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> Kyma Runtime Service — Kubernetes-based extension platform management,
> serverless functions, service instances and bindings, API rules, and event subscriptions.

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
Kyma Runtime
├── C1.1  Environment Management
│   ├── C1.1.1  Provision and delete Kyma environments
│   ├── C1.1.2  Kubeconfig distribution
│   └── C1.1.3  Region and plan selection
│
├── C1.2  Namespace Management
│   └── C1.2.1  Kubernetes namespace lifecycle
│
├── C1.3  Module Management
│   ├── C1.3.1  Kyma module installation (Serverless, Istio, etc.)
│   └── C1.3.2  Module channel and version management
│
├── C1.4  Application Connectivity
│   └── C1.4.1  Register external applications and expose APIs
│
├── C1.5  Service Catalogue
│   ├── C1.5.1  Service instance provisioning (OSB)
│   └── C1.5.2  Service binding and secret injection
│
├── C1.6  Serverless Functions
│   ├── C1.6.1  Node.js / Python function deployment
│   └── C1.6.2  Function status and log management
│
├── C1.7  API Exposure
│   └── C1.7.1  API Rule gateway configuration
│
├── C1.8  Event Subscriptions
│   └── C1.8.1  Cloud Event subscription to Kyma Eventing
│
└── C1.9  Cross-Cutting
    ├── C1.9.1  Tenant isolation
    └── C1.9.2  Health monitoring
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide a Kyma Runtime management API modelled on SAP BTP Kyma Runtime. |
| **Vision** | Enable teams to extend SAP systems using Kubernetes-native serverless functions, event-driven integrations, and managed service instances within governed namespaces. |
| **Scope** | Kyma environment provisioning, namespace and module management, serverless functions, API rules, service instances, and event subscriptions. |
| **Stakeholders** | Extension Developers, Platform Engineers, Cloud Architects. |

---

## 3. Service View (NSV)

### NSOV-2 – Service Definitions

| Service ID | Name | Path Prefix | Methods |
|---|---|---|---|
| SVC-ENV-CRUD | Kyma Environment | `/api/v1/kyma-environments` | GET, POST, DELETE |
| SVC-NS-CRUD | Namespace | `/api/v1/namespaces` | GET, POST, DELETE |
| SVC-MOD-CRUD | Kyma Module | `/api/v1/kyma-modules` | GET, POST, DELETE |
| SVC-APP-CRUD | Application | `/api/v1/applications` | GET, POST, DELETE |
| SVC-SI-CRUD | Service Instance | `/api/v1/service-instances` | GET, POST, DELETE |
| SVC-SB-CRUD | Service Binding | `/api/v1/service-bindings` | GET, POST, DELETE |
| SVC-FN-CRUD | Serverless Function | `/api/v1/serverless-functions` | GET, POST, PUT, DELETE |
| SVC-AR-CRUD | API Rule | `/api/v1/api-rules` | GET, POST, DELETE |
| SVC-ES-CRUD | Event Subscription | `/api/v1/event-subscriptions` | GET, POST, DELETE |
| SVC-HLTH | Health Check | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

```
┌────────────────────┐   REST/HTTP/JSON   ┌──────────────────────────────┐
│  Extension Dev /    │ ─────────────────> │  Kyma Runtime Service        │
│  Platform Engineer  │                    │  port 8095                    │
└────────────────────┘                    └──────────────────────────────┘
```

---

## 5. Logical View (NLV)

| Entity | Key Relationships |
|---|---|
| `KymaEnvironment` | Root; contains Namespaces, KymaModules, Applications |
| `Namespace` | Kubernetes namespace; scopes all workloads |
| `KymaModule` | Installed capability module (Serverless, Telemetry, etc.) |
| `Application` | External system registered for app connectivity |
| `ServiceInstance` | OSB service instance provisioned within a Namespace |
| `ServiceBinding` | Injects credentials from ServiceInstance into workloads |
| `ServerlessFunction` | FaaS workload deployed in a Namespace |
| `ApiRule` | Istio VirtualService/Gateway config for function exposure |
| `EventSubscription` | Cloud Event subscriber linked to a Namespace |

---

## 6. Physical View (NPV)

```
Kubernetes Cluster — Namespace: uim-platform
├── ConfigMap: kyma-config
│   KYMA_HOST: "0.0.0.0"
│   KYMA_PORT: "8095"
├── Deployment: kyma  port: 8095
└── Service: kyma (ClusterIP :8095)
```

---

## 7. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | Namespace-scoped workloads | Mirrors Kyma's Kubernetes namespace isolation |
| AD-2 | Module-based capability extension | Reflects SAP Kyma module management pattern |
| AD-3 | API Rule for gateway config | Matches Kyma's APIRule CRD approach |
| AD-4 | In-memory repositories | Fast testing; swap for Kubernetes API calls in production |
| AD-5 | Port 8095 | Consistent UIM platform port allocation |
