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

  CommandResult create(CreateDashboardRequest req) {
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

  CommandResult updateDashboard(DashboardId id, UpdateDashboardRequest req) {
    auto d = repo.findById(id);
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
    return CommandResult(true, id.value, "");
  }

  bool hasById(DashboardId id) {
    return repo.existsById(id);
  }

  Dashboard getDashboard(DashboardId id) {
    return repo.findById(id);
  }

  Dashboard[] listDashboards(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  Dashboard getDefault(TenantId tenantId) {
    return repo.findDefault(tenantId);
  }

  CommandResult removeDashboard(DashboardId id) {
    repo.removeById(id);
    return CommandResult(true, id.value, "");
  }

  private static PanelType parsePanelType(string s) {
    switch (s) {
    case "lineChart":
      return PanelType.lineChart;
    case "barChart":
      return PanelType.barChart;
    case "pieChart":
      return PanelType.pieChart;
    case "table":
      return PanelType.table;
    case "counter":
      return PanelType.counter;
    case "traceView":
      return PanelType.traceView;
    case "heatmap":
      return PanelType.heatmap;
    default:
      return PanelType.logView;
    }
  }


}
