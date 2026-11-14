/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.application.services.statistics;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// Application service: aggregated figures of a tenant.
class StudioStatisticsService : IStudioStatisticsService {
  protected StudioRepositories repos;

  this(StudioRepositories repos) {
    this.repos = repos;
  }

  StudioStatistics statistics(TenantId tenantId) {
    StudioStatistics s;
    s.tenantId = tenantId;
    int pending;

    s.devSpaceTypes = cast(int) repos.devSpaceTypes.findByTenant(tenantId).length;
    foreach (e; repos.extensions.findByTenant(tenantId)) {
      s.extensions++;
      if (e.status == ExtensionStatus.deprecated_)
        s.extensionsDeprecated++;
    }
    s.projectTemplates = cast(int) repos.projectTemplates.findByTenant(tenantId).length;

    foreach (d; repos.devSpaces.findByTenant(tenantId)) {
      s.devSpaces++;
      if (d.status == DevSpaceStatus.running)
        s.devSpacesRunning++;
      else if (d.status == DevSpaceStatus.stopped)
        s.devSpacesStopped++;
      else if (d.status == DevSpaceStatus.hibernated)
        s.devSpacesHibernated++;
      if (d.status.isTransitional)
        pending++;
    }
    foreach (p; repos.projects.findByTenant(tenantId)) {
      s.projects++;
      if (p.status == ProjectStatus.archived)
        s.projectsArchived++;
    }
    foreach (b; repos.serviceBindings.findByTenant(tenantId)) {
      s.serviceBindings++;
      if (b.status == BindingStatus.connected)
        s.bindingsConnected++;
      else if (b.status == BindingStatus.connecting)
        pending++;
    }
    foreach (r; repos.runConfigurations.findByTenant(tenantId)) {
      s.runConfigurations++;
      if (r.status == RunStatus.running)
        s.runsActive++;
      else if (r.status == RunStatus.starting)
        pending++;
    }
    foreach (b; repos.buildConfigurations.findByTenant(tenantId)) {
      s.buildConfigurations++;
      final switch (b.status) {
      case BuildStatus.pending, BuildStatus.cancelled:
        break;
      case BuildStatus.building, BuildStatus.deploying:
        pending++;
        break;
      case BuildStatus.succeeded:
        s.buildsSucceeded++;
        break;
      case BuildStatus.failed:
        s.buildsFailed++;
        break;
      case BuildStatus.deployed:
        s.buildsSucceeded++;
        s.deployments++;
        break;
      }
      if (b.lastDeployAt > s.lastDeployAt)
        s.lastDeployAt = b.lastDeployAt;
    }
    s.pendingReconciliation = pending;
    return s;
  }
}
