/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.app.usecases.dashboards;
// import uim.platform.analytics.domain.entities.dashboard;
// import uim.platform.analytics.domain.repositories.dashboard;

// import uim.platform.analytics.app.dto.dashboard;
import uim.platform.analytics;

// mixin(ShowModule!());
@safe:
/// Application service: dashboard use cases.
class DashboardUseCases {
  private DashboardRepository repo;

  this(DashboardRepository repo) {
    this.repo = repo;
  }

  DashboardResponse createDashboard(CreateDashboardRequest req) {
    auto dashboard = Dashboard.create(req.name, req.description, req.ownerId);
    repo.save(dashboard);
    return DashboardResponse.fromEntity(dashboard);
  }

  DashboardResponse getDashboard(TenantId tenantId, DashboardId id) {
    auto d = repo.findById(tenantId, id);
    return DashboardResponse.fromEntity(d);
  }

  DashboardResponse[] listDashboards(TenantId tenantId) {
    DashboardResponse[] result;
    foreach (d; repo.findByTenantId(tenantId))
      result ~= DashboardResponse.fromEntity(d);
    return result;
  }

  DashboardResponse addPageToDashboard(TenantId tenantId, DashboardId dashboardId, string title) {
    auto d = repo.findById(tenantId, dashboardId);
    if (d.isNull)
      return DashboardResponse.init;
    d.addPage(title);
    repo.save(d);
    return DashboardResponse.fromEntity(d);
  }

  DashboardResponse publishDashboard(TenantId tenantId, DashboardId dashboardId) {
    auto d = repo.findById(tenantId, dashboardId);
    if (d.isNull)
      return DashboardResponse.init;
    d.publish();
    repo.save(d);
    return DashboardResponse.fromEntity(d);
  }

  CommandResult deleteDashboard(TenantId tenantId, DashboardId dashboardId) {
    auto d = repo.findById(tenantId, dashboardId);
    if (d.isNull)
      return CommandResult(false, "", "Dashboard not found");

    repo.remove(d);
    return CommandResult(true, d.id.value, "");
  }
}
