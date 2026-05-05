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

  Json toJson() const {
    return Json.emptyObject
      .set("id", id)
      .set("title", title)
      .set("panelType", panelType.to!string())
      .set("query", query)
      .set("positionX", positionX)
      .set("positionY", positionY)
      .set("width", width)
      .set("height", height);
  }
}

struct Dashboard {
  mixin TenantEntity!DashboardId;

  string name;
  string description;
  bool isDefault;
  DashboardPanel[] panels;
  
  Json toJson() const {
    return entityToJson
      .set("name", name)
      .set("description", description)
      .set("isDefault", isDefault)
      .set("panels", panels.map!(p => p.toJson()).array.toJson());
  }
}
