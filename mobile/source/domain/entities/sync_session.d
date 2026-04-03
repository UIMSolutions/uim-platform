module uim.platform.xyz.domain.entities.sync_session;

import uim.platform.xyz.domain.types;

/// A record of an offline store synchronization session.
struct SyncSession
{
    SyncSessionId id;
    OfflineConfigId offlineConfigId;
    MobileAppId appId;
    TenantId tenantId;
    string userId;
    string deviceId;
    SyncStrategy strategy;
    SyncSessionStatus status = SyncSessionStatus.started;
    ConflictResolution conflictResolution;
    long uploadedRecords;
    long downloadedRecords;
    long conflictCount;
    long resolvedConflicts;
    long uploadBytes;
    long downloadBytes;
    string deltaToken;              // for delta sync continuation
    string errorMessage;
    long startedAt;
    long completedAt;
}
