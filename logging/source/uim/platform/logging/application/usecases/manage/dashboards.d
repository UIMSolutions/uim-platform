/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.application.usecases.manage.dashboards;
// import uim.platform.logging.domain.entities.dashboard;
// import uim.platform.logging.domain.ports.repositories.dashboards;
// import uim.platform.logging.domain.types;
// import uim.platform.logging.application.dto;


import uim.platform.logging;

mixin(ShowModule!());

@safe:
class ManageDashboardsUseCase { // TODO: UIMUseCase {
  private DashboardRepository repo;

  this(DashboardRepository repo) {
    this.repo = repo;
  }

  CommandResult createDashboard(CreateDashboardRequest req) {
    import std.uuid : randomUUID;

    if (req.name.length == 0)
      return CommandResult(false, "", "Dashboard name is required");

    Dashboard d;
    d.initEntity(req.tenantId, req.createdBy);
    d.name = req.name;
    d.description = req.description;
    d.isDefault = req.isDefault;

    foreach (p; req.panels) {
      DashboardPanel panel;
      panel.id = !p.panelId.isEmpty ? p.panelId : PanelId(randomUUID().toString);
      panel.title = p.title;
      panel.panelType = p.panelType.to!PanelType;
      panel.query = p.query;
      panel.positionX = p.positionX;
      panel.positionY = p.positionY;
      panel.width = (p.width > 0) ? p.width : 6;
      panel.height = (p.height > 0) ? p.height : 4;
      d.panels ~= panel;
    }

    repo.save(d);
    return CommandResult(true, d.id.value, "");
  }

  CommandResult updateDashboard(UpdateDashboardRequest req) {
    auto d = repo.findById(req.tenantId, req.dashboardId);
    if (d.isNull)
      return CommandResult(false, "", "Dashboard not found");

    if (req.name.length > 0)
      d.name = req.name;
    if (req.description.length > 0)
      d.description = req.description;
    d.isDefault = req.isDefault;
    d.updatedAt = clockSeconds();

    if (req.panels.length > 0) {
      d.panels = [];
      foreach (p; req.panels) {
        import std.uuid : randomUUID;

        DashboardPanel panel;
        panel.id = (!p.panelId.isEmpty) ? p.panelId : PanelId(randomUUID().toString);
        panel.title = p.title;
        panel.panelType = p.panelType.to!PanelType;
        panel.query = p.query;
        panel.positionX = p.positionX;
        panel.positionY = p.positionY;
        panel.width = (p.width > 0) ? p.width : 6;
        panel.height = (p.height > 0) ? p.height : 4;
        d.panels ~= panel;
      }
    }

    repo.update(d);
    return CommandResult(true, d.id.value, "");
  }

  bool hasDashboardById(TenantId tenantId, DashboardId dashboardId) {
    return repo.existsById(tenantId, dashboardId);
  }

  Dashboard getDashboard(TenantId tenantId, DashboardId dashboardId) {
    return repo.findById(tenantId, dashboardId);
  }

  Dashboard[] listDashboards(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  Dashboard getDefaultDashboard(TenantId tenantId) {
    return repo.findDefault(tenantId);
  }

  CommandResult deleteDashboard(TenantId tenantId, DashboardId dashboardId) {
    auto dashboard = repo.findById(tenantId, dashboardId);
    if (dashboard.isNull)
      return CommandResult(false, "", "Dashboard not found");

    repo.remove(dashboard);
    return CommandResult(true, dashboard.id.value, "");
  }


}
