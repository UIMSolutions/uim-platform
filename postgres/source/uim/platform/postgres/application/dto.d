/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.application.dto;

import uim.platform.postgres;

mixin(ShowModule!());

@safe:

struct ServiceInstanceDTO {
    ServiceInstanceId serviceInstanceId;
    TenantId tenantId;
    string name;
    string description;
    ServicePlanId planId;
    Hyperscaler hyperscaler;
    string region;
    PostgresVersion engineVersion;
    long memoryGb;
    long storageGb;
    bool sslEnabled;
    bool multiAz;
    UserId createdBy;
    UserId updatedBy;
}

struct ServiceBindingDTO {
    ServiceBindingId serviceBindingId;
    TenantId tenantId;
    ServiceInstanceId instanceId;
    string appId;
    string name;
    SslMode sslMode;
    long expiresAt;
    UserId createdBy;
    UserId updatedBy;
}

struct ServicePlanDTO {
    ServicePlanId servicePlanId;
    TenantId tenantId;
    string name;
    string description;
    PlanTier tier;
    long memoryGb;
    long storageGb;
    long maxConnections;
    bool multiAzSupported;
    bool available;
    string pricingUnit;
    UserId createdBy;
    UserId updatedBy;
}

struct ConfigurationDTO {
    ConfigurationId configurationId;
    TenantId tenantId;
    ServiceInstanceId instanceId;
    string auditLogLevels;
    long backupRetentionPeriod;
    string locale;
    long maxConnections;
    long workMem;
    long sharedBuffersMb;
    string maintenanceWindowDay;
    long maintenanceWindowStartHour;
    long maintenanceWindowDuration;
    UserId createdBy;
    UserId updatedBy;
}

struct BackupPolicyDTO {
    BackupPolicyId backupPolicyId;
    TenantId tenantId;
    ServiceInstanceId instanceId;
    long retentionPeriod;
    string backupWindow;
    string backupLocation;
    UserId createdBy;
    UserId updatedBy;
}

struct DatabaseUserDTO {
    DatabaseUserId databaseUserId;
    TenantId tenantId;
    ServiceInstanceId instanceId;
    string username;
    string roles;
    UserId createdBy;
    UserId updatedBy;
}

struct DatabaseExtensionDTO {
    DatabaseExtensionId databaseExtensionId;
    TenantId tenantId;
    ServiceInstanceId instanceId;
    string extensionName;
    string extensionVersion;
    string schema_;
    UserId createdBy;
    UserId updatedBy;
}

struct MaintenanceWindowDTO {
    MaintenanceWindowId maintenanceWindowId;
    TenantId tenantId;
    ServiceInstanceId instanceId;
    string dayOfWeek;
    long startHourUtc;
    long durationHours;
    bool autoMinorVersionUpgrade;
    UserId createdBy;
    UserId updatedBy;
}
