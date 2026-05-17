/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.application.dto;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

struct MobileApplicationDTO {
    MobileApplicationId mobileApplicationId;
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
}

struct AppDefinitionDTO {
    AppDefinitionId definitionId;
    MobileApplicationId mobileApplicationId;
    TenantId tenantId;

    string name;
    string description;
    string status;
    string definitionContent;
    string definitionFormat;
    string schemaVersion;
    string authoredBy;
    string targetPlatform;
    string businessObjectModel;
    UserId createdBy;
    UserId updatedBy;
    long createdAt;
    long updatedAt;
}

struct AppVersionDTO {
    AppVersionId appVersionId;
    MobileApplicationId mobileApplicationId;
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
}

struct DeviceDTO {
    DeviceId deviceId;
    MobileApplicationId mobileApplicationId;
    TenantId tenantId;

    string deviceName;
    string deviceModel;
    string manufacturer;
    string platform;
    string osVersion;
    string appVersionInstalled;
    string status;
    string pushToken;
    string userId;
    string userEmail;
    string groupName;
    bool isManaged;
    string mdmDeviceId;
    UserId createdBy;
    UserId updatedBy;
    long createdAt;
    long updatedAt;
}

struct SyncSessionDTO {
    SyncSessionId syncSessionId;
    DeviceId deviceId;
    MobileApplicationId mobileApplicationId;
    BackendConnectionId backendConnectionId;
    TenantId tenantId;

    string status;
    string direction;
    string triggeredBy;
    string clientAppVersion;
    UserId createdBy;
    UserId updatedBy;
    long createdAt;
    long updatedAt;
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
}

struct DeploymentDTO {
    DeploymentId deploymentId;
    MobileApplicationId mobileApplicationId;
    AppVersionId appVersionId;
    TenantId tenantId;

    string status;
    string scope_;
    string targetDeviceId;
    string targetGroupName;
    string scheduledAt;
    string deployedBy;
    string notes;
    UserId createdBy;
    UserId updatedBy;
    long createdAt;
    long updatedAt;
}
