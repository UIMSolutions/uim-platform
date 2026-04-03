module uim.platform.xyz.domain.entities.replication_job;

import uim.platform.xyz.domain.types;

/// A replication job — executes data synchronization between systems.
struct ReplicationJob
{
    ReplicationJobId id;
    TenantId tenantId;
    DistributionModelId distributionModelId;

    string name;
    string description;
    ReplicationJobStatus status = ReplicationJobStatus.pending;
    ReplicationTrigger trigger = ReplicationTrigger.manual;

    // Scope
    MasterDataCategory[] categories;
    ClientId sourceClientId;
    ClientId[] targetClientIds;

    // Progress
    long totalRecords;
    long processedRecords;
    long successRecords;
    long errorRecords;
    long skippedRecords;
    string[] errorMessages;

    // Delta tracking
    string lastDeltaToken;
    bool isInitialLoad;

    // Timing
    long startedAt;
    long completedAt;
    long createdAt;
    string createdBy;
}
