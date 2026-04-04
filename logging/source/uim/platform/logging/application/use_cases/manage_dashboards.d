/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.application.usecases.manage_dashboards;

import uim.platform.logging.domain.entities.dashboard;
import uim.platform.logging.domain.ports.dashboard_repository;
import uim.platform.logging.domain.types;
import uim.platform.logging.application.dto;

import std.conv : to;

class ManageDashboardsUseCase : UIMUseCase {
  private DashboardRepository repo;

  this(DashboardRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateDashboardRequest req) {
    import std.uuid : randomUUID;

    if (req.name.length == 0)
      return CommandResult(false, "", "Dashboard name is required");

    Dashboard d;
    d.id = randomUUID().to!string;
    d.tenantId = req.tenantId;
    d.name = req.name;
    d.description = req.description;
    d.isDefault = req.isDefault;
    d.createdBy = req.createdBy;
    d.createdAt = clockSeconds();

    foreach (ref p; req.panels) {
      DashboardPanel panel;
      panel.id = (p.id.length > 0) ? p.id : randomUUID().to!string;
      panel.title = p.title;
      panel.panelType = parsePanelType(p.panelType);
      panel.query = p.query;
      panel.positionX = p.positionX;
      panel.positionY = p.positionY;
      panel.width = (p.width > 0) ? p.width : 6;
      panel.height = (p.height > 0) ? p.height : 4;
      d.panels ~= panel;
    }

    repo.save(d);
    return CommandResult(true, d.id, "");
  }

  CommandResult update(DashboardId id, UpdateDashboardRequest req) {
    auto d = repo.findById(id);
    if (d.id.length == 0)
      return CommandResult(false, "", "Dashboard not found");

    if (req.name.length > 0)
      d.name = req.name;
    if (req.description.length > 0)
      d.description = req.description;
    d.isDefault = req.isDefault;
    d.updatedAt = clockSeconds();

    if (req.panels.length > 0) {
      d.panels = [];
      foreach (ref p; req.panels) {
        import std.uuid : randomUUID;

        DashboardPanel panel;
        panel.id = (p.id.length > 0) ? p.id : randomUUID().to!string;
        panel.title = p.title;
        panel.panelType = parsePanelType(p.panelType);
        panel.query = p.query;
        panel.positionX = p.positionX;
        panel.positionY = p.positionY;
        panel.width = (p.width > 0) ? p.width : 6;
        panel.height = (p.height > 0) ? p.height : 4;
        d.panels ~= panel;
      }
    }

    repo.update(d);
    return CommandResult(true, id, "");
  }

  Dashboard get_(DashboardId id) {
    return repo.findById(id);
  }

  Dashboard[] list(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  Dashboard getDefault(TenantId tenantId) {
    return repo.findDefault(tenantId);
  }

  CommandResult remove(DashboardId id) {
    repo.remove(id);
    return CommandResult(true, id, "");
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

  private static long clockSeconds() {
    import core.time : MonoTime;

    return MonoTime.currTime.ticks / MonoTime.ticksPerSecond;
  }
}
