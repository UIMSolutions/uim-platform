/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.workpage;

// import uim.platform.workzone.domain.types;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
/// A page within a workspace — containers for widgets and content.
struct Workpage {
  mixin TenantEntity!(WorkpageId);

  WorkspaceId workspaceId;
  string title;
  string description;
  WidgetId[] widgetIds;
  RoleId[] allowedRoleIds;
  int sortOrder;
  bool visible = true;
  bool isDefault;
  
  Json toJson() const {
    return entityToJson
      .set("workspaceId", workspaceId.value)
      .set("title", title)
      .set("description", description)
      .set("widgetIds", widgetIds.map!(w => w.value).array.toJson())
      .set("allowedRoleIds", allowedRoleIds.map!(r => r.value).array.toJson())
      .set("sortOrder", sortOrder)
      .set("visible", visible)
      .set("isDefault", isDefault);
  }
}
