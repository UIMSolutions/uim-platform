# NAFv4 Architecture — SAP Continuous Integration and Delivery Service

## NOV-1: High-Level Operational Concept

The SAP Continuous Integration and Delivery (CI/CD) platform service enables automated build, test, and deployment workflows for SAP BTP applications. It supports all major SAP BTP pipeline types (CAP, Fiori, ABAP Fiori, Kyma Native, Integration Suite, Cloud Foundry, Container Registry) and integrates with popular source control systems.

### Operational Goals

1. **Automate software delivery** — eliminate manual build and deployment steps
2. **Enforce quality gates** — lint, unit tests, acceptance, performance, compliance, and security checks
3. **Multi-target deployment** — deploy to Cloud Foundry, Kyma, ABAP, Kubernetes, and container registries
4. **Event-driven pipelines** — trigger builds on Git push, pull request, tag, or release events
5. **Tenant isolation** — all resources are scoped to a tenant, enabling multi-tenant SaaS operation

### Stakeholders

| Role | Concern |
|------|---------|
| Developer | Commit code, monitor build results |
| DevOps Engineer | Configure pipelines, jobs, credentials |
| Platform Administrator | Manage deployment targets, tenant onboarding |
| Security Officer | Audit credential usage, compliance stage results |

---

## NOV-2: Operational Node Connectivity

```
[Developer Workstation]
        |
        | git push / PR
        v
[Git Repository]  ---- webhook event ----> [integration-delivery service :8120]
                                                    |
                                          +---------+---------+
                                          |         |         |
                                     [Build]    [Stage]   [Job]
                                          |
                              +-----------+-----------+
                              |                       |
                    [Cloud Foundry]           [Kyma Runtime]
                    [ABAP System]             [Kubernetes]
                    [Container Registry]
```

The `integration-delivery` service exposes a REST API on port **8120** within the `uim-platform` Kubernetes namespace. External Git repositories push webhook events to the service, which resolves the matching job and triggers a build.

---

## SV-1: Systems View — Service Interfaces

| Interface | Protocol | Endpoint Prefix | Consumer |
|-----------|----------|-----------------|----------|
| Repository Management | REST/JSON | `/api/v1/integration-delivery/repositories` | Platform Admin |
| Credential Management | REST/JSON | `/api/v1/integration-delivery/credentials` | DevOps Engineer |
| Pipeline Configuration | REST/JSON | `/api/v1/integration-delivery/pipelines` | DevOps Engineer |
| Job Management | REST/JSON | `/api/v1/integration-delivery/jobs` | Developer |
| Build Execution | REST/JSON | `/api/v1/integration-delivery/builds` | Developer / Webhook |
| Stage Monitoring | REST/JSON | `/api/v1/integration-delivery/stages` | Developer |
| Webhook Registration | REST/JSON | `/api/v1/integration-delivery/webhooks` | Git Repository |
| Deployment Target Registry | REST/JSON | `/api/v1/integration-delivery/deployment-targets` | Platform Admin |
| Health | REST | `/health` | Kubernetes / Load Balancer |

---

## SV-4: Services Functionality

### Repository Management
- Register Git repositories (GitHub, GitLab, Bitbucket, Azure DevOps, Gerrit)
- Associate credentials for authenticated access
- Enable/disable webhook integration per repository

### Credential Management
- Store references to secrets (not secret values) for source control and deployment
- Support Basic Auth, Token, SSH Key, Service Key, and OAuth2 credential types
- Enforce expiry tracking and status management

### Pipeline Configuration
- Define pipeline templates with enabled stage sets
- Support SAP-native pipeline types: CAP, Fiori, ABAP Fiori, Kyma Native, Integration Suite, Cloud Foundry, Container Registry
- Store pipeline YAML configuration for execution engines

### Job Management
- Bind a pipeline configuration to a specific repository
- Configure trigger modes: manual, git-push, pull-request, scheduled (cron), or API
- Associate an optional deployment target for release delivery stages

### Build Execution
- Track build lifecycle: pending → initializing → running → success/failed/cancelled/aborted
- Record commit metadata (SHA, branch, author, message)
- Store artifact and log URLs for post-build access

### Stage Monitoring
- Track individual pipeline stage execution: build/lint, unit tests, acceptance, performance, compliance, container build/push, deploy to production
- Ordered execution with optional stages support
- Per-stage log storage and error reporting

### Webhook Integration
- Register webhook endpoints for Git events (push, pull request, tag, release)
- HMAC secret verification for payload validation (secret not returned in API responses)
- Track trigger count and last trigger result

### Deployment Target Registry
- Register and manage deployment targets: Cloud Foundry spaces, Kyma namespaces, ABAP systems, Kubernetes clusters, container registries
- Associate credentials with targets for deployment authentication
- Track deployment status and last deployment timestamp

---

## Technology Stack

| Concern | Technology |
|---------|-----------|
| Language | D (dlang) with LDC2 compiler |
| Web Framework | vibe.d 0.10.x / vibe-http |
| Build Tool | DUB |
| Architecture | Hexagonal / Clean Architecture |
| Container Runtime | Ubuntu 24.04 (runtime), ldc-ubuntu:1.40.1 (build) |
| Orchestration | Kubernetes (namespace: `uim-platform`) |
| Storage | In-memory (production: MongoDB via TenantRepository) |
| Service Port | 8120 |
