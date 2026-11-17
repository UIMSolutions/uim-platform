/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.workpage;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// A page of a workspace that hosts widgets (cards, apps).
struct Workpage {
  mixin TenantEntity!WorkpageId;

  WorkspaceId workspaceId;
  string workspaceName;
  string title; /// unique per workspace
  string description;
  PageTemplateId templateId;
  string templateName;
  int sortOrder;
  bool visible = true;
  bool isDefault; /// at most one default page per workspace
  string[] allowedRoles; /// role names; empty = all members
}
