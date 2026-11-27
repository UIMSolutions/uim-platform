/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// KPIs of a tenant (Fiori header, CLI "stats").
module uim.platform.datasphere.application.services.statistics;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

class DspStatisticsService : IDspStatisticsService {
  protected DspRepositories repos;
  protected IClock clock;

  this(DspRepositories repos, IClock clock) {
    this.repos = repos;
    this.clock = clock;
  }

  DspStatistics compute(TenantId t) {
    enum long mib = 1024 * 1024;
    DspStatistics s;
    s.tenantId = t;
    auto dayAgo = plusDays(clock.now, -1);
    long used, quota;
    foreach (x; repos.spaces.findAll(t)) {
      s.spaces++;
      if (!x.isActive)
        s.lockedSpaces++;
      used += x.usedDiskBytes;
      quota += x.diskQuotaBytes;
    }
    s.usedDiskMiB = used / mib;
    s.diskQuotaMiB = quota / mib;
    s.members = repos.members.countAll(t);
    foreach (x; repos.connections.findAll(t)) {
      s.connections++;
      if (x.isValid)
        s.validConnections++;
    }
    foreach (x; repos.remoteTables.findAll(t)) {
      s.remoteTables++;
      if (x.holdsData)
        s.replicatedTables++;
    }
    foreach (x; repos.views.findAll(t)) {
      s.views++;
      if (x.isDeployed)
        s.deployedViews++;
      if (x.exposed)
        s.exposedViews++;
    }
    s.dataFlows = repos.dataFlows.countAll(t);
    foreach (x; repos.tasks.findAll(t)) {
      s.tasks++;
      if (x.isScheduled)
        s.scheduledTasks++;
    }
    s.taskChains = repos.taskChains.countAll(t);
    foreach (r; repos.runs.findAll(t)) {
      if (r.startedAt < dayAgo || r.chainRunId.length)
        continue;
      s.runsLast24h++;
      if (r.status == RunStatus.failed)
        s.failedRunsLast24h++;
    }
    s.accessControls = repos.accessControls.countAll(t);
    s.catalogAssets = repos.catalog.countAll(t);
    s.users = repos.users.countAll(t);
    return s;
  }
}
