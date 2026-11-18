/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_provisioning.ports.usecases.monitoring;

import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:

/// Read the audit log of the job runs.
interface IProvisioningLogsQuery : IQueryResource!(ProvisioningLog, ProvisioningLogId) {
  ProvisioningLog[] byJob(TenantId tenantId, ProvisioningJobId jobId);
  /// Delete entries older than `olderThanDays` (0 = all); returns the number deleted.
  int purge(TenantId tenantId, int olderThanDays);
}

/// Read the users and groups provisioned to the target systems.
interface IProvisionedEntitiesQuery : IQueryResource!(ProvisionedEntity, ProvisionedEntityId) {
  ProvisionedEntity[] byTarget(TenantId tenantId, TargetSystemId targetId);
}
