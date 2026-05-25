# NAFv4 Architecture — SAP Snowflake Service

## 1. Overview

The **SAP Snowflake** service is a UIM Platform microservice that integrates with Snowflake Data Cloud as part of SAP Business Data Cloud (BDC). It manages Snowflake account provisioning, zero-copy connector enrollment, warehouse/database lifecycle, data product sharing, role management, and tenant user administration.

---

## 2. NAFv4 Viewpoints

### 2.1 Capability Viewpoint (NCV)

| Capability | Description |
|---|---|
| Account Provisioning | Provision and activate Snowflake accounts with SAP BDC entitlement integration |
| Zero-Copy Connector | Enroll and manage Vhada/Snowflake connectors for direct data sharing without copying |
| Warehouse Management | Create and manage virtual warehouses with auto-suspend/resume |
| Database Management | Manage Snowflake databases with configurable retention |
| Data Product Sharing | Share SAP BDC data products into Snowflake and manage sync lifecycle |
| Role & Privilege Management | Manage Snowflake roles and fine-grained privileges per tenant |
| Tenant User Management | Manage user access with admin/editor/viewer roles |
| Provisioning Lifecycle | Full lifecycle management of provisioning requests with status tracking |

---

### 2.2 Operational Architecture Viewpoint (NOV)

```
┌───────────────────────────────────────────────────┐
│                 SAP BDC Platform                  │
│  ┌────────────────┐    ┌────────────────────────┐ │
│  │  BDC Console   │    │   Data Product Catalog │ │
│  └────────┬───────┘    └──────────┬─────────────┘ │
│           │                       │               │
│  ┌────────▼───────────────────────▼─────────────┐ │
│  │          SAP Snowflake Service (port 8100)    │ │
│  │  ┌──────────────────────────────────────────┐ │ │
│  │  │  REST API  /api/v1/snowflake/*           │ │ │
│  │  └─────────────────────────────────────────┘ │ │
│  └───────────────────────────────────────────────┘ │
│                         │                          │
└─────────────────────────┼──────────────────────────┘
                          │
            ┌─────────────▼──────────────┐
            │    Snowflake Data Cloud    │
            │  Accounts / Warehouses /   │
            │  Databases / Shares / Roles│
            └────────────────────────────┘
```

---

### 2.3 System Architecture Viewpoint (NSV)

| Layer | Component | Technology |
|---|---|---|
| Presentation | HTTP Controllers, CLI/Web/GUI MVC stubs | vibe.d URLRouter |
| Application | Use Cases, DTOs | D structs/classes |
| Domain | Entities, Port Interfaces, Validators | D structs/interfaces |
| Infrastructure | Memory Repositories, Config, Container | D classes, env vars |
| Containerization | Dockerfile, Containerfile | Docker / Podman |
| Orchestration | Kubernetes Deployment/Service/ConfigMap | K8s YAML |

---

### 2.4 Technical Standards Viewpoint (NTV)

| Standard | Compliance |
|---|---|
| REST API | HTTP/1.1, JSON payloads, standard HTTP status codes |
| Authentication | Tenant ID via request header `X-Tenant-ID` |
| Container | OCI-compliant image, non-root user, health check endpoint |
| Language | D (dlang), LDC2 1.40.1 compiler |
| Framework | vibe.d 0.10.x, vibe-http 1.4.x |
| Build | dub package manager, dub.sdl format |
| Architecture | Hexagonal + Clean Architecture, MVC in presentation layer |

---

### 2.5 Service Interfaces

| Interface | Direction | Protocol | Description |
|---|---|---|---|
| REST API | Inbound | HTTP/JSON | BDC platform clients |
| Health Check | Inbound | HTTP | Kubernetes liveness/readiness |
| Snowflake API | Outbound (future) | HTTPS/JSON | Snowflake management APIs |

---

## 3. Deployment View

```yaml
# Kubernetes
Deployment: cloud-snowflake
  replicas: 1
  containerPort: 8100
  envFrom: cloud-snowflake-config

Service: cloud-snowflake
  type: ClusterIP
  port: 8100

ConfigMap: cloud-snowflake-config
  SNOWFLAKE_HOST: "0.0.0.0"
  SNOWFLAKE_PORT: "8100"
```

---

## 4. Data Entities

| Entity | Key Relationships |
|---|---|
| `SnowflakeAccount` | Root aggregate; owns warehouses, databases, roles, connectors |
| `ZerocopyConnector` | Belongs to account; referenced by data product shares |
| `SnowflakeWarehouse` | Belongs to account |
| `SnowflakeDatabase` | Belongs to account |
| `DataProductShare` | Belongs to account; references connector and BDC data product |
| `SnowflakeRole` | Belongs to account; holds privilege list |
| `SnowflakeTenantUser` | Tenant-scoped user with role-based access |
| `ProvisioningRequest` | Lifecycle record for account provisioning |

---

## 5. Security Considerations

- All HTTP endpoints require `X-Tenant-ID` header for tenant isolation
- Container runs as non-root `appuser`
- No credentials stored in memory repositories (production: use secrets manager)
- OWASP Top 10 mitigations applied: no SQL injection (in-memory), input validation via `SnowflakeValidator`, tenant isolation enforced at repository level

---

## 6. References

- [SAP BDC Feature Scope Description](https://help.sap.com/docs/business-data-cloud/feature-scope-description-business-data-cloud/features)
- [SAP Business Data Cloud Help](https://help.sap.com/docs/business-data-cloud)
- [Snowflake Documentation](https://docs.snowflake.com)
- [NAFv4 Framework](https://www.nato.int/cps/en/natohq/topics_157575.htm)
