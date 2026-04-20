/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.domain.entities.replication_job;

import uim.platform.master_data_integration.domain.types;

/// A replication job — executes data synchronization between systems.
struct ReplicationJob {
  mixin TenantEntity!(ReplicationJobId);

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

  Json toJson() const {
    auto j = entityToJson
      .set("distributionModelId", distributionModelId.value)
      .set("name", name)
      .set("description", description)
      .set("status", status.to!string)
      .set("trigger", trigger.to!string)
      .set("categories", categories.map!(c => c.to!string).array)
      .set("sourceClientId", sourceClientId.value)
      .set("targetClientIds", targetClientIds.map!(id => id.value).array)
      .set("totalRecords", totalRecords)
      .set("processedRecords", processedRecords)
      .set("successRecords", successRecords)
      .set("errorRecords", errorRecords)
      .set("skippedRecords", skippedRecords)
      .set("errorMessages", errorMessages.array)
      .set("lastDeltaToken", lastDeltaToken)
      .set("isInitialLoad", isInitialLoad)
      .set("startedAt", startedAt)
      .set("completedAt", completedAt);

    return j;
  }
}
