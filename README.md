# UIM Platform

A modular collection of SAP BTP-inspired cloud platform services, built with
**D** and **vibe.d**, following **Clean Architecture** and **Hexagonal
Architecture** (Ports & Adapters) principles.

Part of the [UIM Platform](https://www.sueel.de/uim/platform) suite.

## Overview

UIM Platform is a monorepo containing 40 independently deployable microservices
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
| **service** | Shared library — core utilities, base types, and shared infrastructure for all platform services | — |
| **abap-enviroment** | SAP BTP ABAP Environment — ABAP system instances, software components, communication arrangements, transports, and business users/roles | 8090 |
| **ai-core** | SAP AI Core — ML lifecycle API v2 covering scenarios, executables, configurations, executions, deployments, artifacts, and metrics | 8090 |
| **ai-launchpad** | SAP AI Launchpad — unified AI runtime management, workspaces, ML lifecycle, and Generative AI Hub | 8097 |
| **analytics** | SAP Analytics Cloud — embedded analytics, KPI management, stories, and reporting | 8082 |
| **auditlog** | SAP Audit Log — audit event capture, retention, and retrieval | 8085 |
| **cloud-foundry** | SAP BTP Cloud Foundry Runtime — orgs, spaces, apps, services, buildpacks, routes, and domains | 8091 |
| **connectivity** | SAP BTP Connectivity — destination management, Cloud Connector tunnels, service channels, access control rules, and certificate stores | 8088 |
| **content-agent** | SAP Content Agent Service — content package assembly, provider sync, transport lifecycle, imports/exports, and activity tracking | 8092 |
| **credential-store** | SAP Credential Store — secure secret, password, and key storage with namespace and binding management | 8095 |
| **custom-domain** | SAP Custom Domain Service — custom domain registration, TLS certificate management, and routing configuration | 8101 |
| **data-attribute-recommendation** | SAP Data Attribute Recommendation — ML-driven attribute suggestion with dataset, model training, deployment, and inference management | 8092 |
| **data-privacy** | SAP Data Privacy Integration — data subject management, consent tracking, deletion/blocking/correction requests, and GDPR compliance | 8089 |
| **data-quality** | SAP Data Quality Management — address cleansing, geocoding, and data enrichment | 8086 |
| **datasphere** | SAP Datasphere — spaces, connections, remote tables, data flows, views, tasks, data access controls, and catalog | 8095 |
| **destination** | SAP Destination Service — centralised connectivity destinations, certificates, and destination fragments | 8094 |
| **dms-application** | SAP Document Management Service — repositories, folders, documents, versioning, sharing, and access control | 8094 |
| **document-ai** | SAP Document Information Extraction — document classification, field extraction, and schema management | 8096 |
| **event-mesh** | SAP Event Mesh — message queues, topic subscriptions, webhooks, and event-driven messaging | 8108 |
| **field-service** | SAP Field Service Management — service orders, technicians, scheduling, equipment, and work orders | 8107 |
| **hana** | SAP HANA Cloud — database instances, schemas, users, roles, backups, and monitoring | 8097 |
| **html-repository** | SAP HTML5 Application Repository — static app hosting, version management, zero-downtime deployment, routing, and content caching | 8097 |
| **identity-authentication** | SAP Cloud Identity Services (IAS) — authentication, users, groups, application registration, tenants, and policies | 8080 |
| **identity-directory** | SAP Cloud Identity Directory — user, group, schema, and attribute management (SCIM-based) | 8082 |
| **identity-provisioning** | SAP Identity Provisioning — source/target/proxy system configuration, provisioning jobs, transformation rules, and audit logging | 8093 |
| **integration-automation** | SAP Cloud Integration Automation — integration scenarios, task workflows, system connections, and execution runs | 8090 |
| **job-scheduling** | SAP Job Scheduling Service — cron/interval-based job scheduling, run logs, and configuration management | 8096 |
| **kyma** | SAP BTP Kyma Runtime — serverless functions, API rules, service instances, event subscriptions, modules, and applications | 8095 |
| **logging** | SAP Application Logging — log entry ingestion, log level management, retention policies, and search | 8094 |
| **malware-scanning** | SAP Malware Scanning Service — content scanning, quarantine management, scan profiles, signature definitions, and webhook notifications | 8097 |
| **management** | SAP BTP Cloud Management Service — global accounts, directories, subaccounts, entitlements, environments, subscriptions, and labels | 8098 |
| **master-data-integration** | SAP Master Data Integration — master data orchestration, distribution models, key mappings, replication jobs, and change log | 8096 |
| **mobile** | SAP Mobile Services — mobile application management, push notifications, app configurations, and device registration | 8096 |
| **monitoring** | Platform Monitoring Service — resource monitoring, metric ingestion, health checks, alert rules, and notification channels | 8093 |
| **object-store** | SAP Object Store Service — S3-compatible bucket and object management, versioning, access policies, lifecycle rules, and CORS | 8092 |
| **personal-data** | SAP Personal Data Manager — personal data inventory, data subject requests, and cross-application data reporting | 8102 |
| **portal** | SAP Build Work Zone (Standard) — portal sites, pages, sections, tiles, catalogs, themes, roles, menus, and i18n | 8083 |
| **process-automation** | SAP Build Process Automation — workflows, forms, decisions, bots, and automation project management | 8099 |
| **situationa-automation** | SAP Intelligent Situation Automation — situation templates, automation rules, actions, dashboards, and notifications | 8100 |
| **task-center** | SAP Task Center — unified task inbox, task providers, task definitions, and user task management | 8103 |
| **workzone** | SAP Work Zone (Advanced) — collaborative workspaces, work pages, integration cards, feeds, notifications, tasks, and channels | 8084 |

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
