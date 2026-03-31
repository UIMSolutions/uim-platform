module domain.entities.offline_config;

import domain.types;

/// Configuration for OData offline store.
struct OfflineConfig
{
    OfflineConfigId id;
    MobileAppId appId;
    TenantId tenantId;
    string name;
    string description;
    string serviceUrl;              // OData service endpoint
    string[] definingRequests;      // OData queries defining the offline store scope
    SyncStrategy syncStrategy = SyncStrategy.deltaSync;
    ConflictResolution conflictResolution = ConflictResolution.lastWriteWins;
    long maxStoreSize;              // max offline DB size in bytes
    int syncIntervalSeconds = 300;  // auto-sync interval (0 = manual only)
    bool encryptStore = true;
    bool compressData = true;
    bool enableDeltaTracking = true;
    string[] excludedEntities;
    int maxRetries = 3;
    int retryDelaySeconds = 30;
    string createdBy;
    long createdAt;
    long updatedAt;
}
