/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.workpage;

import uim.platform.workzone.domain.types;

/// A page within a workspace — containers for widgets and content.
struct Workpage {
  WorkpageId id;
  WorkspaceId workspaceId;
  TenantId tenantId;
  string title;
  string description;
  WidgetId[] widgetIds;
  RoleId[] allowedRoleIds;
  int sortOrder;
  bool visible = true;
  bool isDefault;
  long createdAt;
  long updatedAt;
}
