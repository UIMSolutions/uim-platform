/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Request models of the Agentry use cases. Enum values are carried as their
/// external string representation and parsed (and rejected if unknown) by the
/// use cases, so every adapter (HTTP, OData, CLI, GUI) gets the same checks.
module uim.platform.agentry.application.dtos.agentry;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

struct MobileApplicationDTO {
  MobileApplicationId applicationId;
  TenantId tenantId;

  string name;
  string description;
  string platform;
  string status;
  string iconUrl;
  string category;
  string vendor;
  string contactEmail;
  string backendSystemId;
  bool offlineCapable;
  bool pushNotificationsEnabled;
  string minOsVersion;
  string packageName;
  UserId createdBy;
  UserId updatedBy;
  long createdAt;
  long updatedAt;

  static MobileApplicationDTO fromEntity(const MobileApplication e) {
    MobileApplicationDTO d;
    d.applicationId = e.id;
    d.tenantId = e.tenantId;
    d.name = e.name;
    d.description = e.description;
    d.platform = enumValue(e.platform);
    d.status = enumValue(e.status);
    d.iconUrl = e.iconUrl;
    d.category = e.category;
    d.vendor = e.vendor;
    d.contactEmail = e.contactEmail;
    d.backendSystemId = e.backendSystemId;
    d.offlineCapable = e.offlineCapable;
    d.pushNotificationsEnabled = e.pushNotificationsEnabled;
    d.minOsVersion = e.minOsVersion;
    d.packageName = e.packageName;
    return d;
  }
}

struct AppDefinitionDTO {
  AppDefinitionId definitionId;
  MobileApplicationId applicationId;
  TenantId tenantId;

  string name;
  string description;
  string status;
  string definitionContent;
  string definitionFormat;
  string schemaVersion;
  UserId authoredBy;
  string targetPlatform;
  string businessObjectModel;
  UserId createdBy;
  UserId updatedBy;
  long createdAt;
  long updatedAt;

  static AppDefinitionDTO fromEntity(const AppDefinition e) {
    AppDefinitionDTO d;
    d.definitionId = e.id;
    d.applicationId = e.applicationId;
    d.tenantId = e.tenantId;
    d.name = e.name;
    d.description = e.description;
    d.status = enumValue(e.status);
    d.definitionContent = e.definitionContent;
    d.definitionFormat = e.definitionFormat;
    d.schemaVersion = e.schemaVersion;
    d.authoredBy = e.authoredBy;
    d.targetPlatform = e.targetPlatform;
    d.businessObjectModel = e.businessObjectModel;
    return d;
  }
}

struct AppVersionDTO {
  AppVersionId versionId;
  MobileApplicationId applicationId;
  AppDefinitionId definitionId;
  TenantId tenantId;

  string versionNumber;
  string releaseNotes;
  string status;
  string artifactUrl;
  string checksum;
  string minOsVersion;
  string changeLog;
  bool isMandatoryUpdate;
  UserId createdBy;
  UserId updatedBy;
  long createdAt;
  long updatedAt;

  static AppVersionDTO fromEntity(const AppVersion e) {
    AppVersionDTO d;
    d.versionId = e.id;
    d.applicationId = e.mobileApplicationId;
    d.definitionId = e.definitionId;
    d.tenantId = e.tenantId;
    d.versionNumber = e.versionNumber;
    d.releaseNotes = e.releaseNotes;
    d.status = enumValue(e.status);
    d.artifactUrl = e.artifactUrl;
    d.checksum = e.checksum;
    d.minOsVersion = e.minOsVersion;
    d.changeLog = e.changeLog;
    d.isMandatoryUpdate = e.isMandatoryUpdate;
    return d;
  }
}

struct DeviceDTO {
  DeviceId deviceId;
  MobileApplicationId applicationId;
  TenantId tenantId;

  string deviceName;
  string deviceModel;
  string manufacturer;
  string platform;
  string osVersion;
  string appVersionInstalled;
  string status;
  string pushToken;
  UserId userId;
  string userEmail;
  string groupName;
  bool isManaged;
  string mdmDeviceId;
  UserId createdBy;
  UserId updatedBy;
  long createdAt;
  long updatedAt;

  static DeviceDTO fromEntity(const MobileDevice e) {
    DeviceDTO d;
    d.deviceId = e.id;
    d.applicationId = e.mobileApplicationId;
    d.tenantId = e.tenantId;
    d.deviceName = e.deviceName;
    d.deviceModel = e.deviceModel;
    d.manufacturer = e.manufacturer;
    d.platform = enumValue(e.platform);
    d.osVersion = e.osVersion;
    d.appVersionInstalled = e.appVersionInstalled;
    d.status = enumValue(e.status);
    d.pushToken = e.pushToken;
    d.userId = e.userId;
    d.userEmail = e.userEmail;
    d.groupName = e.groupName;
    d.isManaged = e.isManaged;
    d.mdmDeviceId = e.mdmDeviceId;
    return d;
  }
}

struct SyncSessionDTO {
  SyncSessionId sessionId;
  DeviceId deviceId;
  MobileApplicationId applicationId;
  BackendConnectionId connectionId;
  TenantId tenantId;

  string status;
  string direction;
  UserId triggeredBy;
  string clientAppVersion;
  UserId createdBy;
  UserId updatedBy;
  long createdAt;
  long updatedAt;

  static SyncSessionDTO fromEntity(const SyncSession e) {
    SyncSessionDTO d;
    d.sessionId = e.id;
    d.deviceId = e.deviceId;
    d.applicationId = e.applicationId;
    d.connectionId = e.connectionId;
    d.tenantId = e.tenantId;
    d.status = enumValue(e.status);
    d.direction = enumValue(e.direction);
    d.triggeredBy = e.triggeredBy;
    d.clientAppVersion = e.clientAppVersion;
    return d;
  }
}

/// Transfer figures reported when a sync session completes.
struct SyncMetricsDTO {
  long bytesSent;
  long bytesReceived;
  long recordsSent;
  long recordsReceived;
}

struct BackendConnectionDTO {
  BackendConnectionId connectionId;
  TenantId tenantId;

  string name;
  string description;
  string backendType;
  string status;
  string backendUrl;
  string clientId;
  string authMethod;
  string sysId;
  string sysNumber;
  string client;
  string language;
  string destinationName;
  bool sslEnabled;
  string certificateFingerprint;
  UserId createdBy;
  UserId updatedBy;
  long createdAt;
  long updatedAt;

  static BackendConnectionDTO fromEntity(const BackendConnection e) {
    BackendConnectionDTO d;
    d.connectionId = e.id;
    d.tenantId = e.tenantId;
    d.name = e.name;
    d.description = e.description;
    d.backendType = enumValue(e.backendType);
    d.status = enumValue(e.status);
    d.backendUrl = e.backendUrl;
    d.clientId = e.clientId;
    d.authMethod = e.authMethod;
    d.sysId = e.sysId;
    d.sysNumber = e.sysNumber;
    d.client = e.client;
    d.language = e.language;
    d.destinationName = e.destinationName;
    d.sslEnabled = e.sslEnabled;
    d.certificateFingerprint = e.certificateFingerprint;
    return d;
  }
}

struct DeploymentDTO {
  DeploymentId deploymentId;
  MobileApplicationId applicationId;
  AppVersionId versionId;
  TenantId tenantId;

  string status;
  string scope_;
  string targetDeviceId;
  string targetGroupName;
  long scheduledAt;
  UserId deployedBy;
  string notes;
  UserId createdBy;
  UserId updatedBy;
  long createdAt;
  long updatedAt;

  static DeploymentDTO fromEntity(const Deployment e) {
    DeploymentDTO d;
    d.deploymentId = e.id;
    d.applicationId = e.mobileApplicationId;
    d.versionId = e.appVersionId;
    d.tenantId = e.tenantId;
    d.status = enumValue(e.status);
    d.scope_ = enumValue(e.scope_);
    d.targetDeviceId = e.targetDeviceId;
    d.targetGroupName = e.targetGroupName;
    d.scheduledAt = e.scheduledAt;
    d.deployedBy = e.deployedBy;
    d.notes = e.notes;
    return d;
  }
}
