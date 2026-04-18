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

| Subpackage (uim-platform:)             | Service Name    | Type    | Port  | Status                                                                                                                                                                                                                                                 | Categories                                                          | Description                                                                                                                                      |
| -------------------------------------- | --------------- | ------- | ----- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| **service**                      | ---             | Library | ---   | [![uim-platform:service](https://github.com/UIMSolutions/uim-platform/actions/workflows/service.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/service.yml)                                                                 |                                                                     | Shared library — core utilities, base types, and shared infrastructure for all platform services                                                |
| **abap-enviroment**              |                 | Service | 10000 | [![uim-platform:abap-enviroment](https://github.com/UIMSolutions/uim-platform/actions/workflows/abap-enviroment.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/abap-enviroment.yml)                                         |                                                                     | Like SAP BTP ABAP Environment<br />ABAP system instances, software components, communication arrangements, transports, and business users/roles  |
| **ai-core**                      |                 | Service | 10001 | [![uim-platform:ai-core](https://github.com/UIMSolutions/uim-platform/actions/workflows/ai-core.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/ai-core.yml)                                                                 |                                                                     | Like SAP AI Core<br />ML lifecycle API v2 covering scenarios, executables, configurations, executions, deployments, artifacts, and metrics       |
| **ai-launchpad**                 |                 | Service | 10002 | [![uim-platform:ai-launchpad](https://github.com/UIMSolutions/uim-platform/actions/workflows/ai-launchpad.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/ai-launchpad.yml)                                                  |                                                                     | Like SAP AI Launchpad — unified AI runtime management, workspaces, ML lifecycle, and Generative AI Hub                                          |
| **analytics**                    |                 | Service |       | [![uim-platform:analytics](https://github.com/UIMSolutions/uim-platform/actions/workflows/analytics.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/analytics.yml)                                                           |                                                                     | Like SAP Analytics Cloud — embedded analytics, KPI management, stories, and reporting                                                           |
| **application-vulnerability**    |                 | Service |       | [![uim-platform:application-vulnerability](https://github.com/UIMSolutions/uim-platform/actions/workflows/application-vulnerability.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/application-vulnerability.yml)           |                                                                     | Like SAP Application Vulnerability Report — vulnerability scanning, component analysis, remediation tracking, and exception management          |
| **application-studio**           |                 | Service | 8111  | [![uim-platform:application-studio](https://github.com/UIMSolutions/uim-platform/actions/workflows/application-studio.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/application-studio.yml)                                |                                                                     | Like SAP Business Application Studio — cloud IDE with dev spaces, extensions, project templates, service bindings, and build/run configurations |
| **automation-pilot**             |                 | Service |       | [![uim-platform:service](https://github.com/UIMSolutions/uim-platform/actions/workflows/automation-pilot.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/automation-pilot.yml)                                               |                                                                     | Like SAP Automation Pilot — DevOps automation flows, command catalogs, scheduled executions, triggers, and content connectors                   |
| **auditlog**                     |                 | Service |       | [![uim-platform:auditlog](https://github.com/UIMSolutions/uim-platform/actions/workflows/auditlog.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/auditlog.yml)                                                              |                                                                     | Like SAP Audit Log — audit event capture, retention, and retrieval                                                                              |
| **cloud-foundry**                |                 | Service |       | [![uim-platform:cloud-foundry](https://github.com/UIMSolutions/uim-platform/actions/workflows/cloud-foundry.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/cloud-foundry.yml)                                               |                                                                     | Like SAP BTP Cloud Foundry Runtime — orgs, spaces, apps, services, buildpacks, routes, and domains                                              |
| **connectivity**                 |                 | Service |       | [![uim-platform:connectivity](https://github.com/UIMSolutions/uim-platform/actions/workflows/connectivity.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/connectivity.yml)                                                  |                                                                     | Like SAP BTP Connectivity — destination management, Cloud Connector tunnels, service channels, access control rules, and certificate stores     |
| **content-agent**                |                 | Service |       | [![uim-platform:content-agent](https://github.com/UIMSolutions/uim-platform/actions/workflows/content-agent.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/content-agent.yml)                                               |                                                                     | Like SAP Content Agent Service — content package assembly, provider sync, transport lifecycle, imports/exports, and activity tracking           |
| **credential-store**             |                 | Service |       | [![uim-platform:credential-store](https://github.com/UIMSolutions/uim-platform/actions/workflows/credential-store.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/credential-store.yml)                                      |                                                                     | Like SAP Credential Store — secure secret, password, and key storage with namespace and binding management                                      |
| **custom-domain**                |                 | Service |       | [![uim-platform:custom-domain](https://github.com/UIMSolutions/uim-platform/actions/workflows/custom-domain.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/custom-domain.yml)                                               |                                                                     | Like SAP Custom Domain Service — custom domain registration, TLS certificate management, and routing configuration                              |
| **dataattribute-recommendation** |                 | Service |       | [![uim-platform:data-attribute-recommendation](https://github.com/UIMSolutions/uim-platform/actions/workflows/dataattribute-recommendation.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/dataattribute-recommendation.yml) |                                                                     | Like SAP Data Attribute Recommendation — ML-driven attribute suggestion with dataset, model training, deployment, and inference management      |
| **data-privacy**                 |                 | Service |       | [![uim-platform:data-privacy](https://github.com/UIMSolutions/uim-platform/actions/workflows/data-privacy.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/data-privacy.yml)                                                  |                                                                     | Like SAP Data Privacy Integration — data subject management, consent tracking, deletion/blocking/correction requests, and GDPR compliance       |
| **data-quality**                 |                 | Service |       | [![uim-platform:data-quality](https://github.com/UIMSolutions/uim-platform/actions/workflows/data-quality.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/data-quality.yml)                                                  |                                                                     | Like SAP Data Quality Management — address cleansing, geocoding, and data enrichment                                                            |
| **datasphere**                   |                 | Service |       | [![uim-platform:datasphere](https://github.com/UIMSolutions/uim-platform/actions/workflows/datasphere.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/datasphere.yml)                                                        |                                                                     | Like SAP Datasphere — spaces, connections, remote tables, data flows, views, tasks, data access controls, and catalog                           |
| **destination**                  |                 | Service |       | [![uim-platform:destination](https://github.com/UIMSolutions/uim-platform/actions/workflows/destination.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/destination.yml)                                                     |                                                                     | Like SAP Destination Service — centralised connectivity destinations, certificates, and destination fragments                                   |
| **dms-application**              |                 | Service |       | [![uim-platform:dms-application](https://github.com/UIMSolutions/uim-platform/actions/workflows/dms-application.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/dms-application.yml)                                         |                                                                     | Like SAP Document Management Service — repositories, folders, documents, versioning, sharing, and access control                                |
| **document-ai**                  |                 | Service |       | [![uim-platform:document-ai](https://github.com/UIMSolutions/uim-platform/actions/workflows/document-ai.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/document-aiervice.yml)                                               |                                                                     | Like SAP Document Information Extraction — document classification, field extraction, and schema management                                     |
| **event-mesh**                   |                 | Service |       | [![uim-platform:event-mesh](https://github.com/UIMSolutions/uim-platform/actions/workflows/event-mesh.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/event-mesh.yml)                                                        |                                                                     | Like SAP Event Mesh — message queues, topic subscriptions, webhooks, and event-driven messaging                                                 |
| **field-service**                |                 | Service |       | [![uim-platform:field-service](https://github.com/UIMSolutions/uim-platform/actions/workflows/field-service.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/field-service.yml)                                               |                                                                     | Like SAP Field Service Management — service orders, technicians, scheduling, equipment, and work orders                                         |
| **hana**                         |                 | Service |       | [![uim-platform:hana](https://github.com/UIMSolutions/uim-platform/actions/workflows/hana.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/hana.yml)                                                                          |                                                                     | Like SAP HANA Cloud — database instances, schemas, users, roles, backups, and monitoring                                                        |
| **html-repository**              | html-repository | Service |       | [![uim-platform:html-repository](https://github.com/UIMSolutions/uim-platform/actions/workflows/html-repository.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/html-repository.yml)                                         |                                                                     | Like SAP HTML5 Application Repository — static app hosting, version management, zero-downtime deployment, routing, and content caching          |
| **identity-authentication**      |                 | Service |       | [![uim-platform:identity-authentication](https://github.com/UIMSolutions/uim-platform/actions/workflows/identity-authentication.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/identity-authentication.yml)                 |                                                                     | Like SAP Cloud Identity Services (IAS) — authentication, users, groups, application registration, tenants, and policies                         |
| **identity-directory**           |                 | Service |       | [![uim-platform:identity-directory](https://github.com/UIMSolutions/uim-platform/actions/workflows/identity-directory.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/identity-directory.yml)                                |                                                                     | Like SAP Cloud Identity Directory — user, group, schema, and attribute management (SCIM-based)                                                  |
| **identity-provisioning**        |                 | Service |       | [![uim-platform:identity-provisioning](https://github.com/UIMSolutions/uim-platform/actions/workflows/identity-provisioning.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/identity-provisioning.yml)                       |                                                                     | Like SAP Identity Provisioning — source/target/proxy system configuration, provisioning jobs, transformation rules, and audit logging           |
| **integration-automation**       |                 | Service |       | [![uim-platform:integration-automation](https://github.com/UIMSolutions/uim-platform/actions/workflows/integration-automation.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/integration-automation.yml)                    |                                                                     | Like SAP Cloud Integration Automation — integration scenarios, task workflows, system connections, and execution runs                           |
| **job-scheduling**               |                 | Service |       | [![uim-platform:job-scheduling](https://github.com/UIMSolutions/uim-platform/actions/workflows/job-scheduling.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/job-scheduling.yml)                                            |                                                                     | Like SAP Job Scheduling Service — cron/interval-based job scheduling, run logs, and configuration management                                    |
| **kyma**                         |                 | Service |       | [![uim-platform:kyma](https://github.com/UIMSolutions/uim-platform/actions/workflows/kyma.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/kyma.yml)                                                                          |                                                                     | Like SAP BTP Kyma Runtime — serverless functions, API rules, service instances, event subscriptions, modules, and applications                  |
| **logging**                      |                 | Service |       | [![uim-platform:logging](https://github.com/UIMSolutions/uim-platform/actions/workflows/logging.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/logging.yml)                                                                 |                                                                     | Like SAP Application Logging — log entry ingestion, log level management, retention policies, and search                                        |
| **malware-scanning**             |                 | Service |       | [![uim-platform:malware-scanning](https://github.com/UIMSolutions/uim-platform/actions/workflows/malware-scanning.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/malware-scanning.yml)                                      |                                                                     | Like SAP Malware Scanning Service — content scanning, quarantine management, scan profiles, signature definitions, and webhook notifications    |
| **management**                   |                 | Service |       | [![uim-platform:management](https://github.com/UIMSolutions/uim-platform/actions/workflows/management.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/management.yml)                                                        |                                                                     | Like SAP BTP Cloud Management Service — global accounts, directories, subaccounts, entitlements, environments, subscriptions, and labels        |
| **masterdata-integration**       |                 | Service |       | [![uim-platform:masterdata-integration](https://github.com/UIMSolutions/uim-platform/actions/workflows/masterdata-integration.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/masterdata-integration.yml)                    |                                                                     | Like SAP Master Data Integration — master data orchestration, distribution models, key mappings, replication jobs, and change log               |
| **mobile**                       |                 | Service |       | [![uim-platform:mobile](https://github.com/UIMSolutions/uim-platform/actions/workflows/mobile.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/mobile.yml)                                                                    |                                                                     | Like SAP Mobile Services — mobile application management, push notifications, app configurations, and device registration                       |
| **monitoring**                   |                 | Service |       | [![uim-platform:monitoring](https://github.com/UIMSolutions/uim-platform/actions/workflows/monitoring.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/monitoring.yml)                                                        |                                                                     | Like SAP Platform Monitoring Service — resource monitoring, metric ingestion, health checks, alert rules, and notification channels             |
| **object-store**                 |                 | Service |       | [![uim-platform:object-store](https://github.com/UIMSolutions/uim-platform/actions/workflows/object-store.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/object-store.yml)                                                  |                                                                     | Like SAP Object Store Service — S3-compatible bucket and object management, versioning, access policies, lifecycle rules, and CORS              |
| **personal-data**                |                 | Service |       | [![uim-platform:personal-data](https://github.com/UIMSolutions/uim-platform/actions/workflows/personal-data.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/personal-data.yml)                                               |                                                                     | Like SAP Personal Data Manager — personal data inventory, data subject requests, and cross-application data reporting                           |
| **portal**                       |                 | Service |       | [![uim-platform:portal](https://github.com/UIMSolutions/uim-platform/actions/workflows/portal.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/portal.yml)                                                                    |                                                                     | Like SAP Build Work Zone (Standard) — portal sites, pages, sections, tiles, catalogs, themes, roles, menus, and i18n                            |
| **process-automation**           |                 | Service |       | [![uim-platform:process-automation](https://github.com/UIMSolutions/uim-platform/actions/workflows/process-automation.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/process-automation.yml)                                |                                                                     | Like SAP Build Process Automation — workflows, forms, decisions, bots, and automation project management                                       |
| **situation-automation**         |                 | Service |       | [![uim-platform:situation-automation](https://github.com/UIMSolutions/uim-platform/actions/workflows/situation-automation.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/situation-automation.yml)                          |                                                                     | Like SAP Intelligent Situation Automation — situation templates, automation rules, actions, dashboards, and notifications                       |
| **task-center**                  | task-center     | Service |       | [![uim-platform:task-center](https://github.com/UIMSolutions/uim-platform/actions/workflows/task-center.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/task-center.yml)                                                     | - Application Development and Automation<br />- Process Automation | Like SAP Task Center — unified task inbox, task providers, task definitions, and user task management                                           |
| **workzone**                     |                 | Service |       | [![uim-platform:workzone](https://github.com/UIMSolutions/uim-platform/actions/workflows/workzone.yml/badge.svg)](https://github.com/UIMSolutions/uim-platform/actions/workflows/workzone.yml)                                                              |                                                                     | Like SAP Work Zone (Advanced) — collaborative workspaces, work pages, integration cards, feeds, notifications, tasks, and channels              |

- Application Development and Automation
- Process Automation
- Application Development and Automation
- Process Automation

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
