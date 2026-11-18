/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_provisioning.application.usecases.monitoring;

import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:

/// Query: audit log of the job runs.
class ProvisioningLogsQuery : IProvisioningLogsQuery {
  protected IProvisioningLogRepository logs;

  this(ProvisioningRepositories repos) {
    this.logs = repos.logs;
  }

  ProvisioningLog get(TenantId tenantId, ProvisioningLogId id) {
    return logs.findById(tenantId, id);
  }

  /// Newest first.
  ProvisioningLog[] list(TenantId tenantId) {
    auto all = logs.findByTenant(tenantId);
    all.sort!((a, b) => a.createdAt > b.createdAt);
    return all;
  }

  ProvisioningLog[] byJob(TenantId tenantId, ProvisioningJobId jobId) {
    return logs.findByJob(tenantId, jobId);
  }

  int purge(TenantId tenantId, int olderThanDays) {
    auto limit = nowStdTime() - olderThanDays * stdTimeDay;
    auto old = logs.findByTenant(tenantId).filter!(l => olderThanDays <= 0 || l.createdAt < limit).array;
    if (old.length)
      logs.remove(old);
    return cast(int) old.length;
  }
}

/// Query: users and groups provisioned to the target systems.
class ProvisionedEntitiesQuery : IProvisionedEntitiesQuery {
  protected IProvisionedEntityRepository entities;

  this(ProvisioningRepositories repos) {
    this.entities = repos.entities;
  }

  ProvisionedEntity get(TenantId tenantId, ProvisionedEntityId id) {
    return entities.findById(tenantId, id);
  }

  ProvisionedEntity[] list(TenantId tenantId) {
    auto all = entities.findByTenant(tenantId);
    all.sort!((a, b) => a.targetSystemName != b.targetSystemName ? a.targetSystemName < b.targetSystemName
        : a.entityType != b.entityType ? a.entityType < b.entityType : a.name < b.name);
    return all;
  }

  ProvisionedEntity[] byTarget(TenantId tenantId, TargetSystemId targetId) {
    return entities.findByTarget(tenantId, targetId);
  }
}
