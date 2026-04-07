# UIM Platform

A modular collection of SAP BTP-inspired cloud platform services, built with
**D** and **vibe.d**, following **Clean Architecture** and **Hexagonal
Architecture** (Ports & Adapters) principles.

Part of the [UIM Platform](https://www.sueel.de/uim/platform) suite.

## Overview

UIM Platform is a monorepo containing 15 independently deployable microservices
and a shared service library. Each service mirrors the feature set of a
corresponding SAP Business Technology Platform capability, re-implemented in the
D programming language using the vibe.d HTTP framework and the
[uim-framework](https://github.com/AnotherCoder/uim-framework).

All services share a consistent layered architecture:

```
service/
├── source/
│   ├── app.d                    # Entry point & HTTP server bootstrap
│   ├── domain/                  # Pure business logic (no external dependencies)
│   │   ├── types.d              #   Type aliases & enums
│   │   ├── entities/            #   Domain entities
│   │   ├── ports/               #   Repository interfaces (hexagonal boundary)
│   │   └── services/            #   Stateless domain services
│   ├── application/             # Use case orchestration
│   │   ├── dto.d                #   Request/response DTOs
│   │   └── usecases/            #   Application services
│   ├── infrastructure/          # Technical adapters
│   │   ├── config.d             #   Environment-based configuration
│   │   ├── container.d          #   Manual dependency injection wiring
│   │   └── persistence/         #   In-memory repository implementations
│   └── presentation/            # HTTP driving adapters
│       └── http/
│           ├── json_utils.d     #   JSON helper functions
│           └── *_controller.d   #   Route controllers
└── dub.sdl
```

## Services

| Service | Description | Port |
|---|---|---|
| **service** | Shared library — Authorization and Trust Management, Job Scheduling, Malware Scanning, and Datasphere-like business data fabric | — |
| **abap-enviroment** | SAP BTP ABAP Environment — ABAP development, lifecycle management, and system administration | 8090 |
| **analytics** | SAP Analytics Cloud — embedded analytics, KPI management, and reporting | — |
| **auditlog** | SAP Audit Log — audit event capture, retention, and retrieval | — |
| **cloud-foundry** | SAP BTP Cloud Foundry Runtime — orgs, spaces, apps, services, buildpacks, routes, and domains | 8091 |
| **connectivity** | SAP BTP Connectivity — destination management, Cloud Connector tunnels, service channels, access control rules, and certificate stores | 8088 |
| **data-attribute-recommendation** | SAP Data Attribute Recommendation — ML-driven attribute suggestion with dataset, model, and inference management | 8092 |
| **data-privacy** | SAP Data Privacy Integration — data subject management, consent tracking, and data residency | 8089 |
| **data-quality** | SAP Data Quality Management — address cleansing, geocoding, and data enrichment | — |
| **dms-application** | SAP Document Management Service — repositories, folders, documents, versioning, sharing, and access control | 8094 |
| **identity-authentication** | SAP Cloud Identity Services — authentication policies, identity providers, and application registration | — |
| **identity-directory** | SAP Cloud Identity Directory — user, group, schema, and attribute management (SCIM-based) | 8082 |
| **identity-provisioning** | SAP Identity Provisioning — source/target system configuration, provisioning jobs, transformation rules, and audit logging | 8093 |
| **integration-automation** | SAP Cloud Integration Automation — integration scenarios, task workflows, system connections, and execution runs | 8090 |
| **portal** | SAP Build Work Zone — portal sites, pages, sections, tiles, catalogs, themes, roles, menus, and i18n | 8083 |
| **workzone** | SAP Work Zone — collaborative workspaces, integration cards, content management, feeds, notifications, tasks, and channels | 8084 |

## Prerequisites

- **D Compiler** (DMD or LDC2)
- **DUB** package manager
- **OpenSSL** development headers (for vibe.d TLS)

## Building

Build the entire platform (all subpackages):

```bash
dub build
```

Build a single service:

```bash
cd connectivity
dub build
```

The compiled binary is placed in the service's `build/` directory.

## Testing

Run tests for the entire platform:

```bash
dub test
```

Run tests for a single service:

```bash
cd connectivity
dub test
```

## Running a Service

After building, start a service directly:

```bash
./connectivity/build/uim-connectivity-platform-service
```

Each service reads its host and port from environment variables (falling back to
`0.0.0.0` and the default port listed above):

```bash
export CONNECTIVITY_HOST=0.0.0.0
export CONNECTIVITY_PORT=8088
./connectivity/build/uim-connectivity-platform-service
```

All services expose a health endpoint at `GET /api/v1/health` and expect a
tenant identifier via the `X-Tenant-Id` HTTP header on every request.

## Dependencies

- [uim-framework ~>26.4.1](https://github.com/AnotherCoder/uim-framework) — Core utilities, OOP extensions, JSON helpers
- [vibe.d 0.10.x](https://vibed.org/) — HTTP server framework

## License

[Apache License 2.0](LICENSE)

**Copyright © 2018–2026, Ozan Nurettin Süel / UI Manufaktur**
