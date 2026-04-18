/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.domain.entities.replication_job;

import uim.platform.master_data_integration.domain.types;

/// A replication job — executes data synchronization between systems.
struct ReplicationJob {
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
