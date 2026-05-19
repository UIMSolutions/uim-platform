/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.application.dto;

import uim.platform.redis;

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
    RedisVersion redisVersion;
    long memoryMb;
    long maxConnections;
    bool tlsEnabled;
    bool haEnabled;
    PersistenceMode persistenceMode;
    UserId createdBy;
    UserId updatedBy;
}

struct ServiceBindingDTO {
    ServiceBindingId serviceBindingId;
    TenantId tenantId;
    ServiceInstanceId instanceId;
    string appId;
    string name;
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
    long memoryMb;
    long maxConnections;
    bool haEnabled;
    bool persistenceEnabled;
    bool tlsEnabled;
    string pricingUnit;
    bool available;
    UserId createdBy;
    UserId updatedBy;
}

struct ConfigurationDTO {
    ConfigurationId configurationId;
    TenantId tenantId;
    ServiceInstanceId instanceId;
    MaxMemoryPolicy maxMemoryPolicy;
    long timeout_;
    long maxConnections;
    bool tlsEnabled;
    PersistenceMode persistenceMode;
    long maxMemoryMb;
    bool notifyKeyspaceEvents;
    string activeVersion;
    UserId createdBy;
    UserId updatedBy;
}

struct CacheEntryDTO {
    CacheEntryId cacheEntryId;
    TenantId tenantId;
    ServiceInstanceId instanceId;
    string key;
    string value;
    CacheEntryType entryType;
    long ttl;
    UserId createdBy;
    UserId updatedBy;
}

struct MetricDTO {
    MetricId metricId;
    TenantId tenantId;
    ServiceInstanceId instanceId;
    long timestamp_;
    long memoryUsedMb;
    long memoryTotalMb;
    long connectedClients;
    long commandsPerSecond;
    double hitRate;
    long evictedKeys;
    long expiredKeys;
    long totalCommandsProcessed;
    double cpuUsagePercent;
    long networkInputKbs;
    long networkOutputKbs;
    UserId createdBy;
}

struct BackupPolicyDTO {
    BackupPolicyId backupPolicyId;
    TenantId tenantId;
    ServiceInstanceId instanceId;
    bool enabled;
    long intervalHours;
    long retentionDays;
    string backupLocation;
    UserId createdBy;
    UserId updatedBy;
}

struct AccessControlDTO {
    AccessControlId accessControlId;
    TenantId tenantId;
    ServiceInstanceId instanceId;
    string cidr;
    string description;
    UserId createdBy;
    UserId updatedBy;
}
