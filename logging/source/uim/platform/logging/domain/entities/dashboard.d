/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.domain.entities.dashboard;

// import uim.platform.logging.domain.types;
import uim.platform.logging;

mixin(ShowModule!());

@safe:
struct DashboardPanel {
  PanelId id;
  string title;
  PanelType panelType = PanelType.logView;
  string query;
  int positionX;
  int positionY;
  int width = 6;
  int height = 4;
}

struct Dashboard {
  DashboardId id;
  TenantId tenantId;
  string name;
  string description;
  bool isDefault;
  DashboardPanel[] panels;
  UserId createdBy;
  long createdAt;
  long updatedAt;
}
