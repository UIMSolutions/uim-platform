# UIM Platform

![DUB Version](https://img.shields.io/dub/v/uim-platform) [![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![DUB Downloads](https://img.shields.io/dub/dm/uim-platform) ![DUB Score](https://img.shields.io/dub/score/uim-platform)

A modular collection of SAP BTP-inspired cloud platform services, built with **D** and **vibe.d**, following **Clean Architecture** and **Hexagonal Architecture** (Ports & Adapters) principles.

## Overview

UIM Platform is a monorepo containing 42 independently deployable microservices
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
│           └── controller.d   #   Route controllers
└── dub.sdl
```

## Services

| Service                                 | Port | Status                                                                                                                                                                                 | Description                                                                                                                                     |
| --------------------------------------- | ---- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| **service**                       |  ---    | [![uim-platform:service](https://github.com/UIMSolutions/uim-platform/actions/workflows/service.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/service.yml) | Shared library — core utilities, base types, and shared infrastructure for all platform services                                               |
| **abap-enviroment**               |  8090    | [![uim-platform:abap-enviroment](https://github.com/UIMSolutions/uim-platform/actions/workflows/abap-enviroment.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/abap-enviroment.yml) | Like SAP BTP ABAP Environment<br />ABAP system instances, software components, communication arrangements, transports, and business users/roles |
| **ai-core**                       |      | [![uim-platform:service](https://github.com/UIMSolutions/uim-platform/actions/workflows/ai-core.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/ai-core.yml) | Like SAP AI Core<br />ML lifecycle API v2 covering scenarios, executables, configurations, executions, deployments, artifacts, and metrics      |
| **ai-launchpad**                  |      | [![uim-platform:service](https://github.com/UIMSolutions/uim-platform/actions/workflows/ai-launchpad.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/ai-launchpad.yml) | Like SAP AI Launchpad — unified AI runtime management, workspaces, ML lifecycle, and Generative AI Hub                                         |
| **analytics**                     |      | [![uim-platform:service](https://github.com/UIMSolutions/uim-platform/actions/workflows/service.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/service.yml) | Like SAP Analytics Cloud — embedded analytics, KPI management, stories, and reporting                                                          |
| **application-vulnerability**     |      | [![uim-platform:service](https://github.com/UIMSolutions/uim-platform/actions/workflows/service.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/service.yml) | Like SAP Application Vulnerability Report — vulnerability scanning, component analysis, remediation tracking, and exception management          |
| **automation-pilot**              |      | [![uim-platform:service](https://github.com/UIMSolutions/uim-platform/actions/workflows/service.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/service.yml) | Like SAP Automation Pilot — DevOps automation flows, command catalogs, scheduled executions, triggers, and content connectors                   |
| **auditlog**                      |      | [![uim-platform:service](https://github.com/UIMSolutions/uim-platform/actions/workflows/service.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/service.yml) | Like SAP Audit Log — audit event capture, retention, and retrieval                                                                             |
| **cloud-foundry**                 |      | [![uim-platform:service](https://github.com/UIMSolutions/uim-platform/actions/workflows/service.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/service.yml) | Like SAP BTP Cloud Foundry Runtime — orgs, spaces, apps, services, buildpacks, routes, and domains                                             |
| **connectivity**                  |      | [![uim-platform:service](https://github.com/UIMSolutions/uim-platform/actions/workflows/service.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/service.yml) | Like SAP BTP Connectivity — destination management, Cloud Connector tunnels, service channels, access control rules, and certificate stores    |
| **content-agent**                 |      | [![uim-platform:service](https://github.com/UIMSolutions/uim-platform/actions/workflows/service.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/service.yml) | Like SAP Content Agent Service — content package assembly, provider sync, transport lifecycle, imports/exports, and activity tracking          |
| **credential-store**              |      | [![uim-platform:service](https://github.com/UIMSolutions/uim-platform/actions/workflows/service.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/service.yml) | Like SAP Credential Store — secure secret, password, and key storage with namespace and binding management                                     |
| **custom-domain**                 |      | [![uim-platform:service](https://github.com/UIMSolutions/uim-platform/actions/workflows/service.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/service.yml) | Like SAP Custom Domain Service — custom domain registration, TLS certificate management, and routing configuration                             |
| **data-attribute-recommendation** |      | [![uim-platform:service](https://github.com/UIMSolutions/uim-platform/actions/workflows/service.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/service.yml) | Like SAP Data Attribute Recommendation — ML-driven attribute suggestion with dataset, model training, deployment, and inference management     |
| **data-privacy**                  |      | [![uim-platform:service](https://github.com/UIMSolutions/uim-platform/actions/workflows/service.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/service.yml) | Like SAP Data Privacy Integration — data subject management, consent tracking, deletion/blocking/correction requests, and GDPR compliance      |
| **data-quality**                  |      | [![uim-platform:service](https://github.com/UIMSolutions/uim-platform/actions/workflows/service.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/service.yml) | Like SAP Data Quality Management — address cleansing, geocoding, and data enrichment                                                           |
| **datasphere**                    |      | [![uim-platform:service](https://github.com/UIMSolutions/uim-platform/actions/workflows/service.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/service.yml) | Like SAP Datasphere — spaces, connections, remote tables, data flows, views, tasks, data access controls, and catalog                          |
| **destination**                   |      | [![uim-platform:service](https://github.com/UIMSolutions/uim-platform/actions/workflows/service.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/service.yml) | Like SAP Destination Service — centralised connectivity destinations, certificates, and destination fragments                                  |
| **dms-application**               |      | [![uim-platform:service](https://github.com/UIMSolutions/uim-platform/actions/workflows/service.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/service.yml) | Like SAP Document Management Service — repositories, folders, documents, versioning, sharing, and access control                               |
| **document-ai**                   |      | [![uim-platform:service](https://github.com/UIMSolutions/uim-platform/actions/workflows/service.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/service.yml) | Like SAP Document Information Extraction — document classification, field extraction, and schema management                                    |
| **event-mesh**                    |      | [![uim-platform:service](https://github.com/UIMSolutions/uim-platform/actions/workflows/service.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/service.yml) | Like SAP Event Mesh — message queues, topic subscriptions, webhooks, and event-driven messaging                                                |
| **field-service**                 |      | [![uim-platform:service](https://github.com/UIMSolutions/uim-platform/actions/workflows/service.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/service.yml) | Like SAP Field Service Management — service orders, technicians, scheduling, equipment, and work orders                                        |
| **hana**                          |      | [![uim-platform:service](https://github.com/UIMSolutions/uim-platform/actions/workflows/service.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/service.yml) | Like SAP HANA Cloud — database instances, schemas, users, roles, backups, and monitoring                                                       |
| **html-repository**               |      | [![uim-platform:service](https://github.com/UIMSolutions/uim-platform/actions/workflows/service.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/service.yml) | Like SAP HTML5 Application Repository — static app hosting, version management, zero-downtime deployment, routing, and content caching         |
| **identity-authentication**       |      | [![uim-platform:service](https://github.com/UIMSolutions/uim-platform/actions/workflows/service.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/service.yml) | Like SAP Cloud Identity Services (IAS) — authentication, users, groups, application registration, tenants, and policies                        |
| **identity-directory**            |      | [![uim-platform:service](https://github.com/UIMSolutions/uim-platform/actions/workflows/service.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/service.yml) | Like SAP Cloud Identity Directory — user, group, schema, and attribute management (SCIM-based)                                                 |
| **identity-provisioning**         |      |                                                                                                                                                                                        | Like SAP Identity Provisioning — source/target/proxy system configuration, provisioning jobs, transformation rules, and audit logging          |
| **integration-automation**        |      |                                                                                                                                                                                        | Like SAP Cloud Integration Automation — integration scenarios, task workflows, system connections, and execution runs                          |
| **job-scheduling**                |      |                                                                                                                                                                                        | Like SAP Job Scheduling Service — cron/interval-based job scheduling, run logs, and configuration management                                   |
| **kyma**                          |      |                                                                                                                                                                                        | Like SAP BTP Kyma Runtime — serverless functions, API rules, service instances, event subscriptions, modules, and applications                 |
| **logging**                       |      |                                                                                                                                                                                        | Like SAP Application Logging — log entry ingestion, log level management, retention policies, and search                                       |
| **malware-scanning**              |      |                                                                                                                                                                                        | Like SAP Malware Scanning Service — content scanning, quarantine management, scan profiles, signature definitions, and webhook notifications   |
| **management**                    |      |                                                                                                                                                                                        | Like SAP BTP Cloud Management Service — global accounts, directories, subaccounts, entitlements, environments, subscriptions, and labels       |
| **master-data-integration**       |      |                                                                                                                                                                                        | Like SAP Master Data Integration — master data orchestration, distribution models, key mappings, replication jobs, and change log              |
| **mobile**                        |      |                                                                                                                                                                                        | Like SAP Mobile Services — mobile application management, push notifications, app configurations, and device registration                       |
| **monitoring**                    |      |                                                                                                                                                                                        | Like SAP Platform Monitoring Service — resource monitoring, metric ingestion, health checks, alert rules, and notification channels            |
| **object-store**                  |      |                                                                                                                                                                                        | Like SAP Object Store Service — S3-compatible bucket and object management, versioning, access policies, lifecycle rules, and CORS             |
| **personal-data**                 |      |                                                                                                                                                                                        | Like SAP Personal Data Manager — personal data inventory, data subject requests, and cross-application data reporting                          |
| **portal**                        |      |                                                                                                                                                                                        | Like SAP Build Work Zone (Standard) — portal sites, pages, sections, tiles, catalogs, themes, roles, menus, and i18n                           |
| **process-automation**            |      |                                                                                                                                                                                        | Like SAP Build Process Automation — workflows, forms, decisions, bots, and automation project management                                      |
| **situationa-automation**         |      |                                                                                                                                                                                        | Like SAP Intelligent Situation Automation — situation templates, automation rules, actions, dashboards, and notifications                      |
| **task-center**                   |      |                                                                                                                                                                                        | Like SAP Task Center — unified task inbox, task providers, task definitions, and user task management                                          |
| **workzone**                      |      |                                                                                                                                                                                        | Like SAP Work Zone (Advanced) — collaborative workspaces, work pages, integration cards, feeds, notifications, tasks, and channels              |

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

- [uim-framework ~&gt;26.4.1](https://github.com/AnotherCoder/uim-framework) — Core utilities, OOP extensions, JSON helpers
- [vibe.d 0.10.x](https://vibed.org/) — HTTP server framework

## License

[Apache License 2.0](LICENSE)

**Copyright © 2018–2026, Ozan Nurettin Süel / UI Manufaktur**
