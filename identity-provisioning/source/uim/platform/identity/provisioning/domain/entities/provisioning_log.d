/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.domain.entities.provisioning_log;

import uim.platform.identity.provisioning.domain.types;

/// An audit record for a single entity operation within a
/// provisioning job run.
struct ProvisioningLog {
  mixin TenantEntity!ProvisioningLogId;

  ProvisioningJobId jobId;
  EntityType entityType = EntityType.user;
  string entityId;
  OperationType operation = OperationType.create;
  LogStatus status = LogStatus.success;
  string sourceSystem;
  string targetSystem;
  string details; // JSON: error message, attribute diff, etc.

  Json toJson() {
    return entityToJson()
      .set("jobId", jobId)
      .set("entityType", entityType.to!string)
      .set("entityId", entityId)
      .set("operation", operation.to!string)
      .set("status", status.to!string)
      .set("sourceSystem", sourceSystem)
      .set("targetSystem", targetSystem)
      .set("details", details);
  }
}
