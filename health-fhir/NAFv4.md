# NAF v4 Architecture — UIM Health FHIR Service

## Service Node: UIM Health FHIR Platform Service

| Attribute | Value |
|-----------|-------|
| Node Type | Platform Service |
| Standard | HL7 FHIR R4 (4.0.1) |
| Protocol | HTTP/REST (application/fhir+json) |
| Port | 8097 |
| Technology | D (dlang), vibe.d 0.10.x |
| Container | OCI (Docker / Podman), LDC 1.40.1 / Ubuntu 24.04 |
| Platform | SAP BTP (Kubernetes / Cloud Foundry compatible) |

## Operational Node View (NOv-2)

```
┌─────────────────────────────────────────────────────┐
│  SAP BTP Kubernetes Cluster                         │
│                                                     │
│  ┌──────────────────────────────────────────────┐   │
│  │  health-fhir Pod (port 8097)                 │   │
│  │  ┌────────────────────────────────────────┐  │   │
│  │  │  uim-health-fhir-platform-service      │  │   │
│  │  │  ─ PatientController                   │  │   │
│  │  │  ─ PractitionerController              │  │   │
│  │  │  ─ ObservationController               │  │   │
│  │  │  ─ ConditionController                 │  │   │
│  │  │  ─ OrganizationController              │  │   │
│  │  │  ─ EncounterController                 │  │   │
│  │  │  ─ MedicationController                │  │   │
│  │  │  ─ MedicationRequestController         │  │   │
│  │  │  ─ CapabilityController                │  │   │
│  │  │  ─ HealthController                    │  │   │
│  │  └────────────────────────────────────────┘  │   │
│  └──────────────────────────────────────────────┘   │
│                                                     │
│  Storage Options:                                   │
│  ┌────────────────────────────────────────────────┐ │
│  │  Memory (default) | Files (PVC) | MongoDB      │ │
│  └────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────┘
```

## System Data Flow (SV-6)

```
FHIR Client
    │
    ▼  HTTP/REST (application/fhir+json)
PatientController / ObservationController / ...
    │
    ▼  CreateXxxRequest / UpdateXxxRequest
ManageXxxUseCase
    │
    ├──► FhirValidator (domain rules)
    │
    ▼  IXxxRepository (port)
Persistence Adapter (memory / files / mongodb)
    │
    ▼
Storage (RAM / Filesystem / MongoDB)
```

## Service Interactions (SvcV-4)

| Consumer | Service | Endpoint |
|----------|---------|----------|
| EHR Client | Patient CRUD | `/fhir/R4/Patient` |
| Clinical Apps | Observation CRUD | `/fhir/R4/Observation` |
| Clinical Apps | Condition CRUD | `/fhir/R4/Condition` |
| Pharmacy | Medication + MedicationRequest | `/fhir/R4/Medication`, `/fhir/R4/MedicationRequest` |
| Scheduling | Encounter CRUD | `/fhir/R4/Encounter` |
| Directory | Practitioner + Organization | `/fhir/R4/Practitioner`, `/fhir/R4/Organization` |
| FHIR Aggregator | Capability discovery | `/fhir/R4/metadata` |
| k8s Probe | Health check | `/api/v1/health` |

## Standards Compliance

- HL7 FHIR R4 (version 4.0.1)
- FHIR RESTful API specification (HTTP binding)
- FHIR Bundle (searchset) for list responses
- FHIR OperationOutcome for error responses
- FHIR CapabilityStatement for server discovery
