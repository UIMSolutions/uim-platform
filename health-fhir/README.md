# UIM Health FHIR Platform Service

HL7 FHIR R4 platform service for SAP BTP, implemented in D (dlang) using vibe.d.

## Overview

This service provides a complete HL7 FHIR R4 REST API for healthcare data management as part of the UIM Platform on SAP Business Technology Platform. It follows the hexagonal architecture pattern used across all UIM platform services.

## FHIR R4 Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/fhir/R4/metadata` | FHIR CapabilityStatement |
| GET | `/api/v1/health` | Service health check |
| GET/POST | `/fhir/R4/Patient` | List / Create patients |
| GET/PUT/DELETE | `/fhir/R4/Patient/{id}` | Read / Update / Delete patient |
| GET/POST | `/fhir/R4/Practitioner` | List / Create practitioners |
| GET/PUT/DELETE | `/fhir/R4/Practitioner/{id}` | Read / Update / Delete practitioner |
| GET/POST | `/fhir/R4/Observation` | List / Create observations |
| GET/PUT/DELETE | `/fhir/R4/Observation/{id}` | Read / Update / Delete observation |
| GET/POST | `/fhir/R4/Condition` | List / Create conditions |
| GET/PUT/DELETE | `/fhir/R4/Condition/{id}` | Read / Update / Delete condition |
| GET/POST | `/fhir/R4/Organization` | List / Create organizations |
| GET/PUT/DELETE | `/fhir/R4/Organization/{id}` | Read / Update / Delete organization |
| GET/POST | `/fhir/R4/Encounter` | List / Create encounters |
| GET/PUT/DELETE | `/fhir/R4/Encounter/{id}` | Read / Update / Delete encounter |
| GET/POST | `/fhir/R4/Medication` | List / Create medications |
| GET/PUT/DELETE | `/fhir/R4/Medication/{id}` | Read / Update / Delete medication |
| GET/POST | `/fhir/R4/MedicationRequest` | List / Create medication requests |
| GET/PUT/DELETE | `/fhir/R4/MedicationRequest/{id}` | Read / Update / Delete medication request |

### Search Parameters

| Resource | Parameter | Example |
|----------|-----------|---------|
| Patient | `?name=` | `/fhir/R4/Patient?name=Smith` |
| Observation | `?subject=` | `/fhir/R4/Observation?subject=Patient/123` |
| Condition | `?subject=` | `/fhir/R4/Condition?subject=Patient/123` |
| Encounter | `?subject=` | `/fhir/R4/Encounter?subject=Patient/123` |
| MedicationRequest | `?subject=` | `/fhir/R4/MedicationRequest?subject=Patient/123` |

## Storage Backends

| Backend | `HEALTHFHIR_STORAGE` value | Description |
|---------|---------------------------|-------------|
| Memory (default) | `memory` | In-memory store, data lost on restart |
| Files | `files` | JSON files on disk (Patient fully supported) |
| MongoDB | `mongodb` | MongoDB stub (delegates to memory, full impl pending) |

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `HEALTHFHIR_HOST` | `0.0.0.0` | Bind address |
| `HEALTHFHIR_PORT` | `8097` | Listen port |
| `HEALTHFHIR_STORAGE` | `memory` | Storage backend |
| `HEALTHFHIR_DATA_PATH` | `/data/health-fhir` | File storage base path |
| `HEALTHFHIR_MONGO_URI` | _(empty)_ | MongoDB connection URI |

## Build

```bash
cd health-fhir
dub build
```

## Run

```bash
HEALTHFHIR_PORT=8097 ./uim-health-fhir-platform-service
```

## Container

```bash
docker build -t uim-platform/health-fhir:latest .
docker run -p 8097:8097 uim-platform/health-fhir:latest
```

## Architecture

The service uses hexagonal (ports and adapters) architecture:

```
source/
  app.d                          # Entry point, wire-up, HTTP server start
  uim/platform/health_fhir/
    domain/                      # Business entities, IDs, port interfaces
      entities/                  # Patient, Practitioner, Observation, ...
      ports/repositories/        # Repository interfaces per resource
      services/                  # FhirValidator
      types.d                    # Domain ID types, FHIR structs, enums
    application/                 # Use cases (ManageXxxUseCase) + DTOs
      dto.d
      usecases/manage/
    infrastructure/              # Config, DI container, persistence adapters
      config.d
      container.d
      persistence/memory/
      persistence/files/
      persistence/mongodb/
    presentation/                # HTTP controllers, CLI/Web/GUI stubs
      http/controllers/
```

## FHIR Compliance

- FHIR version: **R4 (4.0.1)**
- All list responses return FHIR `Bundle` (type: `searchset`)
- All error responses return FHIR `OperationOutcome`
- CapabilityStatement available at `/fhir/R4/metadata`
