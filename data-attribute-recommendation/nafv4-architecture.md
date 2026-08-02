# NAF v4 Architecture Description — Data Attribute Recommendation Service


## Documentation update

This document is maintained alongside the implementation, deployment manifests, and tests for the same package so the service documentation stays aligned with the codebase.

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> Data Attribute Recommendation Service — ML-based field value prediction,
> dataset management, model training and deployment, and inference execution.

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
Data Attribute Recommendation
├── C1.1  Dataset Management
│   ├── C1.1.1  Dataset registration (CSV, JSON, tabular)
│   └── C1.1.2  Training record upload and management
│
├── C1.2  Model Training
│   ├── C1.2.1  Model configuration (target field, feature fields)
│   ├── C1.2.2  Training job lifecycle (created → running → completed)
│   └── C1.2.3  Accuracy and evaluation metrics
│
├── C1.3  Model Deployment
│   ├── C1.3.1  Deploy trained models as inference endpoints
│   └── C1.3.2  Deployment status lifecycle
│
├── C1.4  Inference
│   ├── C1.4.1  Submit inference requests
│   ├── C1.4.2  Confidence-scored predictions
│   └── C1.4.3  Batch inference support
│
└── C1.5  Cross-Cutting
    ├── C1.5.1  Tenant isolation
    └── C1.5.2  Health monitoring
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide ML-based data attribute recommendation modelled on SAP Data Attribute Recommendation. |
| **Vision** | Enable business users to train models on labelled datasets and get confidence-scored field value predictions for incoming records. |
| **Scope** | Dataset ingestion, model training, deployment, and inference. |
| **Stakeholders** | Data Stewards, Business Analysts, Data Scientists. |

---

## 3. Service View (NSV)

### NSOV-2 – Service Definitions

| Service ID | Name | Path Prefix | Methods |
|---|---|---|---|
| SVC-DS-CRUD | Dataset | `/api/v1/datasets` | GET, POST, DELETE |
| SVC-DR-CRUD | Data Record | `/api/v1/data-records` | GET, POST, DELETE |
| SVC-MC-CRUD | Model Configuration | `/api/v1/model-configurations` | GET, POST, DELETE |
| SVC-TJ-CRUD | Training Job | `/api/v1/training-jobs` | GET, POST, DELETE |
| SVC-TJ-START | Start Training | `/api/v1/training-jobs/{id}/start` | POST |
| SVC-MD-CRUD | Model Deployment | `/api/v1/model-deployments` | GET, POST, DELETE |
| SVC-IR-CRUD | Inference Request | `/api/v1/inference-requests` | GET, POST |
| SVC-RES-LIST | Inference Results | `/api/v1/inference-results` | GET |
| SVC-HLTH | Health Check | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

```
┌────────────────────┐   REST/HTTP/JSON   ┌──────────────────────────────────┐
│  Business Analyst / │ ─────────────────> │  Data Attribute Recommendation   │
│  Data Steward       │                    │  Service — port 8092              │
└────────────────────┘                    └──────────────────────────────────┘
```

---

## 5. Logical View (NLV)

| Entity | Key Relationships |
|---|---|
| `Dataset` | Root; contains DataRecords; parent of ModelConfigurations |
| `DataRecord` | Belongs to Dataset; labelled training examples |
| `ModelConfiguration` | Parameterizes training; child of Dataset |
| `TrainingJob` | Runs training for a ModelConfiguration; produces ModelDeployment |
| `ModelDeployment` | Serving endpoint for a trained model |
| `InferenceRequest` | Submitted to a ModelDeployment; produces InferenceResult |
| `InferenceResult` | Confidence-scored prediction; linked to InferenceRequest |

---

## 6. Physical View (NPV)

```
Kubernetes Cluster — Namespace: uim-platform
├── ConfigMap: dataattribute-recommendation-config
│   DATAATTR_HOST: "0.0.0.0"
│   DATAATTR_PORT: "8092"
├── Deployment: dataattribute-recommendation  port: 8092
└── Service: dataattribute-recommendation (ClusterIP :8092)
```

---

## 7. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | End-to-end ML pipeline | Mirrors SAP Data Attribute Recommendation lifecycle |
| AD-2 | Confidence scoring on results | Matches the SAP service's output schema |
| AD-3 | In-memory repositories | Fast testing; swap for RDBMS + ML backend in production |
| AD-4 | Port 8092 | Consistent UIM platform port allocation |
