# Mobile Services

A mobile services module for the UIM Platform, inspired by SAP Mobile Services for SAP BTP. Built with D language (dlang), vibe.d HTTP framework, and clean/hexagonal architecture.

## Features

- **Mobile App Management** - Register and manage mobile applications with platform-specific configurations (iOS, Android, Windows, Web)
- **Device Registration** - Register devices with lock, wipe, and block capabilities for enterprise mobile device management
- **Push Notifications** - Send push notifications via APNS (iOS), FCM (Android), WNS (Windows), and W3C Web Push with topic-based targeting
- **Push Registration** - Manage push token registrations and topic subscriptions per device
- **App Configuration** - Key-value configuration management with platform-specific and secret support
- **Feature Restrictions** - Feature flags with boolean toggles, percentage-based gradual rollout, and whitelist targeting
- **Client Resources** - Upload and manage client resource bundles, certificates, translations, and configuration files
- **App Version Management** - Track app versions with mandatory update support, release notes, and download URLs
- **Usage Analytics** - Collect and query usage metrics (app launches, screen views, API calls, crashes, custom events)
- **Offline Store** - Define OData-based offline stores with sync status tracking and defining requests
- **User Sessions** - Track active user sessions with device and platform information
- **Client Logging** - Upload and query client-side logs with level filtering (debug, info, warning, error, fatal)
- **Health Monitoring** - Health check endpoint for container orchestration

## Architecture

```
Clean Architecture + Hexagonal Architecture (Ports and Adapters)

Domain Layer (innermost)
  - Entities: MobileApp, DeviceRegistration, PushNotification, PushRegistration,
              AppConfiguration, FeatureRestriction, ClientResource, AppVersion,
              UsageReport, OfflineStore, UserSession, ClientLogEntry
  - Ports: 12 Repository interfaces (driven adapter contracts)
  - Services: PushDeliveryService, OfflineSyncService, FeatureEvaluationService

Application Layer
  - DTOs: Request/Response data transfer objects
  - Use Cases: ManageMobileApps, ManageDeviceRegistrations, ManagePushNotifications,
               ManagePushRegistrations, ManageAppConfigurations, ManageFeatureRestrictions,
               ManageClientResources, ManageAppVersions, ManageUsageReports,
               ManageOfflineStores, ManageUserSessions, ManageClientLogs, GetOverview

Infrastructure Layer
  - Config: Environment-based configuration (MOBILE_HOST, MOBILE_PORT)
  - Container: Dependency injection wiring
  - Persistence: In-memory repository implementations

Presentation Layer (outermost)
  - HTTP Controllers: 14 vibe.d REST API handlers
  - JSON Utils: Serialization helpers
```

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| CRUD | `/api/v1/apps` | Manage mobile applications |
| CRUD | `/api/v1/devices` | Register and manage devices |
| CRUD | `/api/v1/push/notifications` | Send and manage push notifications |
| CRUD | `/api/v1/push/registrations` | Manage push token registrations |
| CRUD | `/api/v1/configurations` | Manage app configurations |
| CRUD | `/api/v1/features` | Manage feature flags/restrictions |
| POST | `/api/v1/features/evaluate` | Evaluate a feature flag for user/device |
| CRUD | `/api/v1/resources` | Manage client resource bundles |
| CRUD | `/api/v1/versions` | Manage app versions |
| POST/GET | `/api/v1/usage` | Report and query usage analytics |
| CRUD | `/api/v1/offline-stores` | Manage offline data stores |
| CRUD | `/api/v1/sessions` | Manage user sessions |
| POST | `/api/v1/sessions/{id}/terminate` | Terminate a user session |
| POST/GET | `/api/v1/logs` | Upload and query client logs |
| GET | `/api/v1/overview` | Get system overview/dashboard |
| GET | `/api/v1/health` | Health check |

## Build and Run

### Local Development

```bash
cd mobile
dub run
```

The service starts on port 8096 by default.

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `MOBILE_HOST` | `0.0.0.0` | Bind address |
| `MOBILE_PORT` | `8096` | Listen port |

### Docker

```bash
cd mobile
docker build -t uim-mobile-services .
docker run -p 8096:8096 uim-mobile-services
```

### Podman

```bash
cd mobile
podman build -t uim-mobile-services -f Containerfile .
podman run -p 8096:8096 uim-mobile-services
```

### Kubernetes

```bash
kubectl apply -f mobile/k8s/configmap.yaml
kubectl apply -f mobile/k8s/deployment.yaml
kubectl apply -f mobile/k8s/service.yaml
```

## Inspired By

[SAP Mobile Services for SAP BTP](https://help.sap.com/doc/f53c64b93e5140918d676b927a3cd65b/Cloud/en-US/docs-en/guides/index.html) - providing mobile app management, push notifications, offline sync, usage analytics, feature flags, and device management capabilities.

## Testing

```bash
dub test
```

## License

See the repository root [LICENSE](../LICENSE) file.
