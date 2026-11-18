/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_provisioning.application.services.statistics;

import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:

/// Aggregates the figures of a tenant from the repositories.
class ProvisioningStatisticsService : IProvisioningStatisticsService {
  protected ProvisioningRepositories repos;

  this(ProvisioningRepositories repos) {
    this.repos = repos;
  }

  ProvisioningStatistics statistics(TenantId tenantId) {
    ProvisioningStatistics s;
    s.tenantId = tenantId;

    void systems(T)(T[] list, ref int total, ref int active) {
      foreach (x; list) {
        total++;
        if (x.status == SystemStatus.active)
          active++;
        else if (x.status == SystemStatus.error)
          s.systemsInError++;
      }
    }

    systems(repos.sourceSystems.findByTenant(tenantId), s.sourceSystems, s.sourceSystemsActive);
    systems(repos.targetSystems.findByTenant(tenantId), s.targetSystems, s.targetSystemsActive);
    systems(repos.proxySystems.findByTenant(tenantId), s.proxySystems, s.proxySystemsActive);

    foreach (t; repos.transformations.findByTenant(tenantId)) {
      s.transformations++;
      if (t.active)
        s.transformationsActive++;
    }

    foreach (j; repos.jobs.findByTenant(tenantId)) {
      s.jobs++;
      s.runs += j.runCount;
      if (j.intervalMinutes > 0 && j.status != JobStatus.cancelled)
        s.jobsScheduled++;
      final switch (j.status) {
      case JobStatus.scheduled, JobStatus.running:
        break;
      case JobStatus.completed:
        s.jobsCompleted++;
        break;
      case JobStatus.failed:
        s.jobsFailed++;
        break;
      case JobStatus.cancelled:
        s.jobsCancelled++;
        break;
      }
      s.lastRunAt = max(s.lastRunAt, j.completedAt);
    }

    foreach (e; repos.entities.findByTenant(tenantId)) {
      s.provisionedEntities++;
      if (e.entityType == EntityType.user)
        s.provisionedUsers++;
      else
        s.provisionedGroups++;
      if (e.status == EntityStatus.error)
        s.provisionedErrors++;
    }

    foreach (l; repos.logs.findByTenant(tenantId)) {
      s.logs++;
      if (l.status == LogStatus.failed)
        s.logsFailed++;
    }
    return s;
  }
}
