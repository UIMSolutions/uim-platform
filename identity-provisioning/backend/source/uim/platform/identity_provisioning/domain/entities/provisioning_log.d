/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_provisioning.domain.entities.provisioning_log;

import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:

/// Immutable audit entry: one operation on one entity within a job run.
struct ProvisioningLog {
  mixin TenantEntity!ProvisioningLogId;

  string name; /// derived: "create user ada.lovelace"
  ProvisioningJobId jobId;
  string jobName;
  int runNumber;
  EntityType entityType = EntityType.user;
  string externalId;
  string entityName;
  OperationType operation = OperationType.create;
  LogStatus status = LogStatus.success;
  string sourceSystemName;
  string targetSystemName;
  string message;
}
