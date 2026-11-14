/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.application.services.statistics;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

/// Application service: aggregated figures of a tenant.
class AbapStatisticsService : IAbapStatisticsService {
  protected AbapRepositories repos;

  this(AbapRepositories repos) {
    this.repos = repos;
  }

  AbapStatistics statistics(TenantId tenantId) {
    AbapStatistics s;
    s.tenantId = tenantId;
    int pending;

    foreach (x; repos.systems.findByTenant(tenantId)) {
      s.systems++;
      if (x.status == SystemStatus.active)
        s.systemsActive++;
      if (x.status.isTransitional)
        pending++;
    }
    foreach (c; repos.softwareComponents.findByTenant(tenantId)) {
      s.softwareComponents++;
      if (c.status == ComponentStatus.cloned)
        s.componentsCloned++;
      if (c.status == ComponentStatus.cloning || c.status == ComponentStatus.pulling)
        pending++;
    }
    s.communicationArrangements = cast(int) repos.communicationArrangements.findByTenant(tenantId).length;
    foreach (b; repos.serviceBindings.findByTenant(tenantId)) {
      s.serviceBindings++;
      if (b.status == BindingStatus.published)
        s.serviceBindingsPublished++;
    }
    foreach (u; repos.businessUsers.findByTenant(tenantId)) {
      s.businessUsers++;
      if (u.status == UserStatus.locked)
        s.usersLocked++;
    }
    s.businessRoles = cast(int) repos.businessRoles.findByTenant(tenantId).length;
    foreach (t; repos.transportRequests.findByTenant(tenantId)) {
      final switch (t.status) {
      case TransportStatus.modifiable:
        s.transportsOpen++;
        break;
      case TransportStatus.released:
        s.transportsReleased++;
        break;
      case TransportStatus.importing:
        pending++;
        break;
      case TransportStatus.imported:
        s.transportsImported++;
        break;
      case TransportStatus.error:
        break;
      }
    }
    foreach (j; repos.applicationJobs.findByTenant(tenantId)) {
      s.applicationJobs++;
      if (j.status == JobStatus.scheduled && j.active) {
        s.jobsScheduled++;
        if (s.nextJobAt == 0 || j.scheduledAt < s.nextJobAt)
          s.nextJobAt = j.scheduledAt;
      } else if (j.status == JobStatus.failed)
        s.jobsFailed++;
      else if (j.status == JobStatus.running)
        pending++;
    }
    s.pendingReconciliation = pending;
    return s;
  }
}
