# Agentry Service

A microservice providing metadata-driven mobile application platform capabilities similar to **SAP BTP Agentry**. Built with D and vibe.d using a combination of clean and hexagonal architecture.

## Overview

Agentry enables customers to develop, test, and operate metadata-driven mobile applications that extend the functionality of SAP backend systems (S/4HANA, ECC, BTP) to mobile users. The service manages the full application lifecycle — from authoring metadata-driven app definitions to deploying app versions to enrolled devices and monitoring synchronisation sessions.

## Features

- **Mobile Application Management** — Register and manage mobile application catalogs across iOS, Android, Windows, and web platforms with lifecycle tracking (draft → active → deprecated → archived)
- **Metadata-driven App Definitions** — Author and version structured app definitions (XML/JSON) describing screens, fields, transmissions, actions, and business rules without native code changes
- **App Version Publishing** — Build and publish versioned app packages linked to a definition, with checksums, artifact URLs, mandatory-update flags, and release notes
- **Device Enrollment** — Enroll and manage mobile devices per application with push-token registration, OS version tracking, MDM integration, and group assignment
- **Data Synchronisation Sessions** — Monitor bidirectional data sync sessions between enrolled devices and SAP backends, tracking bytes/records transferred and error details
- **Backend Connections** — Configure and test connections to SAP backend systems (S/4HANA, ECC, BTP, CRM) supporting basic auth, OAuth 2.0, and SAML
- **Deployments** — Orchestrate app version rollouts to individual devices, device groups, or entire tenants with status tracking (pending → deploying → deployed) and rollback support

## Architecture

```
+-----------------------------------------------------------+
|                    Presentation Layer                      |
|  MobileApplicationController  AppDefinitionController     |
|  AppVersionController  DeviceController                   |
|  SyncSessionController  BackendConnectionController       |
|  DeploymentController  HealthController                   |
+-----------------------------------------------------------+
|                    Application Layer                       |
|  ManageMobileApplicationsUseCase  ManageAppDefinitionsUC  |
|  ManageAppVersionsUseCase  ManageDevicesUseCase           |
|  ManageSyncSessionsUseCase  ManageBackendConnectionsUC    |
|  ManageDeploymentsUseCase                                 |
+-----------------------------------------------------------+
|                     Domain Layer                           |
|  Entities  Repository Interfaces  AgentryValidator        |
+-----------------------------------------------------------+
|                  Infrastructure Layer                      |
|  MemoryRepositories  SrvConfig  Container                 |
+-----------------------------------------------------------+
```

### Hexagonal Architecture (Ports & Adapters)

| Port (Interface)                  | Adapter (Implementation)                |
|-----------------------------------|-----------------------------------------|
| `IMobileApplicationRepository`     | `MobileApplicationRepository`     |
| `IAppDefinitionRepository`         | `AppDefinitionRepository`         |
| `IAppVersionRepository`            | `AppVersionRepository`            |
| `IDeviceRepository`                | `DeviceRepository`                |
| `ISyncSessionRepository`           | `SyncSessionRepository`           |
| `IBackendConnectionRepository`     | `BackendConnectionRepository`     |
| `IDeploymentRepository`            | `DeploymentRepository`            |

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/health` | Health check |
| **Mobile Applications** | | |
| GET | `/api/v1/agentry/mobile-applications` | List all mobile applications |
| GET | `/api/v1/agentry/mobile-applications/{id}` | Get mobile application by ID |
| POST | `/api/v1/agentry/mobile-applications` | Register mobile application |
| PUT | `/api/v1/agentry/mobile-applications/{id}` | Update mobile application |
| DELETE | `/api/v1/agentry/mobile-applications/{id}` | Delete mobile application |
| **App Definitions** | | |
| GET | `/api/v1/agentry/app-definitions` | List all app definitions |
| GET | `/api/v1/agentry/app-definitions/{id}` | Get app definition by ID |
| POST | `/api/v1/agentry/app-definitions` | Create app definition |
| PUT | `/api/v1/agentry/app-definitions/{id}` | Update app definition |
| DELETE | `/api/v1/agentry/app-definitions/{id}` | Delete app definition |
| **App Versions** | | |
| GET | `/api/v1/agentry/app-versions` | List all app versions |
| GET | `/api/v1/agentry/app-versions/{id}` | Get app version by ID |
| POST | `/api/v1/agentry/app-versions` | Publish app version |
| PUT | `/api/v1/agentry/app-versions/{id}` | Update app version |
| DELETE | `/api/v1/agentry/app-versions/{id}` | Delete app version |
| **Devices** | | |
| GET | `/api/v1/agentry/devices` | List all enrolled devices |
| GET | `/api/v1/agentry/devices/{id}` | Get device by ID |
| POST | `/api/v1/agentry/devices` | Enroll device |
| PUT | `/api/v1/agentry/devices/{id}` | Update device |
| DELETE | `/api/v1/agentry/devices/{id}` | Remove device |
| **Sync Sessions** | | |
| GET | `/api/v1/agentry/sync-sessions` | List all sync sessions |
| GET | `/api/v1/agentry/sync-sessions/{id}` | Get sync session by ID |
| POST | `/api/v1/agentry/sync-sessions` | Create sync session |
| PUT | `/api/v1/agentry/sync-sessions/{id}` | Update sync session |
| DELETE | `/api/v1/agentry/sync-sessions/{id}` | Delete sync session |
| **Backend Connections** | | |
| GET | `/api/v1/agentry/backend-connections` | List all backend connections |
| GET | `/api/v1/agentry/backend-connections/{id}` | Get backend connection by ID |
| POST | `/api/v1/agentry/backend-connections` | Create backend connection |
| PUT | `/api/v1/agentry/backend-connections/{id}` | Update backend connection |
| DELETE | `/api/v1/agentry/backend-connections/{id}` | Delete backend connection |
| **Deployments** | | |
| GET | `/api/v1/agentry/deployments` | List all deployments |
| GET | `/api/v1/agentry/deployments/{id}` | Get deployment by ID |
| POST | `/api/v1/agentry/deployments` | Create deployment |
| PUT | `/api/v1/agentry/deployments/{id}` | Update deployment |
| DELETE | `/api/v1/agentry/deployments/{id}` | Delete deployment |

## Configuration

| Environment Variable | Default | Description |
|---------------------|---------|-------------|
| `AGENTRY_HOST` | `0.0.0.0` | Bind address |
| `AGENTRY_PORT` | `8117` | HTTP listen port |

## Running

### Locally with DUB

```bash
dub run --config=defaultRun
```

### Docker

```bash
docker build -t uim-agentry .
docker run -p 8117:8117 -e AGENTRY_HOST=0.0.0.0 -e AGENTRY_PORT=8117 uim-agentry
```

### Podman

```bash
podman build -f Containerfile -t uim-agentry .
podman run -p 8117:8117 uim-agentry
```

### Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## Domain Model

| Entity | Key Fields |
|--------|-----------|
| `MobileApplication` | name, platform, status, packageName, offlineCapable |
| `AppDefinition` | mobileApplicationId, definitionContent, definitionFormat, status |
| `AppVersion` | mobileApplicationId, definitionId, versionNumber, status, isMandatoryUpdate |
| `Device` | mobileApplicationId, deviceName, platform, osVersion, status, groupName |
| `SyncSession` | deviceId, backendConnectionId, status, direction, bytesSent, bytesReceived |
| `BackendConnection` | name, backendUrl, backendType, authMethod, sslEnabled |
| `Deployment` | mobileApplicationId, appVersionId, status, scope, devicesTotal |

## License

Apache-2.0 — Copyright (c) 2018-2026, Ozan Nurettin Suel
