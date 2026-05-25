# NAF v4 Architecture Views — UIM Databricks Platform Service

## C1 — Capability Taxonomy

| Capability | Sub-Capability | Service Feature |
|------------|---------------|-----------------|
| Data Management | Lakehouse | Delta Tables (Unity Catalog) |
| Data Management | Data Products | BDC Data Product publishing |
| Data Management | SQL Analytics | SQL Warehouses |
| Compute | Cluster Management | Interactive / Job Clusters |
| Compute | Workflow Orchestration | Jobs + Job Runs |
| AI/ML | Experiment Tracking | MLflow Experiments |
| AI/ML | Model Registry | ML Models + Stage Promotion |
| Developer Tools | Notebooks | Python/Scala/R/SQL Notebooks |
| Platform | Workspace Management | Multi-workspace, multi-tenant |

---

## C2 — Enterprise Vision

The UIM Databricks service represents the **Lakehouse + AI/ML** layer within the UIM Platform. It provides a tenant-isolated API surface that mirrors SAP BDC capabilities, enabling:

- Unified governance through Unity Catalog (Delta Tables, Data Products)
- Machine learning lifecycle management (MLflow-compatible)
- Serverless and autoscaling compute
- Open integration via REST APIs aligned with SAP BTP service patterns

---

## L1 — Node Architecture

```
+-------------------+       +------------------------+
|   Client / BTP    |  HTTP | UIM Databricks Service |
|   (SAP BDC UI)    +------>+  :8104                 |
+-------------------+       |  vibe.d REST API       |
                             +----------+-------------+
                                        |
                          +-------------+-------------+
                          |                           |
                    +-----v-----+             +-------v-------+
                    | In-Memory |             | MongoDB       |
                    | Store     |             | (planned)     |
                    +-----------+             +---------------+
```

---

## L2 — Logical Data Model

```
Workspace (root aggregate)
  |-- Cluster (compute)
  |-- Notebook (dev artifacts)
  |-- Job
  |     `-- JobRun (execution record)
  |-- DeltaTable (Unity Catalog)
  |-- DataProduct (BDC sharing)
  |-- MlExperiment
  |     `-- (runs tracked externally via MLflow)
  |-- MlModel
  `-- SqlWarehouse
```

---

## L4 — Service Lifecycle Node

| Phase | Action |
|-------|--------|
| Startup | Load config (env vars), build DI container, bind vibe.d HTTP listener |
| Running | Accept REST requests, route through controllers → use cases → repos |
| Shutdown | vibe.d graceful shutdown; in-memory state lost (by design for default profile) |
| Persistence upgrade | Wire file or MongoDB repos via DI container switch |

---

## L6 — System Context

```
+------------------+     REST/HTTP    +------------------------+
| SAP BTP Consumer |<---------------->| UIM Databricks Service |
+------------------+                  |  (this service)        |
                                       +------------------------+
                                            |          |
                        +-------------------+    +-----+--------+
                        | Kubernetes / Podman|    | MongoDB      |
                        | (container runtime)|    | (optional)   |
                        +--------------------+    +--------------+
```

---

## Pr — Process / Behaviour

### Workspace Provisioning Flow

```
1. Client POST /api/v1/databricks/workspaces
2. WorkspaceController extracts tenantId + JSON body
3. ManageWorkspacesUseCase.create() called
4. WorkspaceEntity created with status=provisioning
5. MemoryWorkspaceRepository.save()
6. UseCaseResult returned → 201 JSON response
```

### ML Model Promotion Flow

```
1. Client PUT /api/v1/databricks/models/{id}  body: {latestStage: "production"}
2. MlModelController.handleUpdate()
3. ManageMlModelsUseCase.update()
4. Repo.findById() → update latestStage → repo.save()
5. UseCaseResult returned → 200 JSON
```

---

## S — Service / Standards

| Standard | Application |
|----------|-------------|
| REST / HTTP 1.1 | All API endpoints |
| JSON (RFC 8259) | Request/response serialization |
| OpenMetrics (planned) | /metrics endpoint |
| OCI (container image) | Dockerfile + Containerfile |
| Kubernetes 1.28+ | k8s/deployment.yaml |
| NAF v4 | This document |
