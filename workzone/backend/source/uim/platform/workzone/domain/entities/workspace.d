/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.workspace;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// A collaborative workspace of a team, project or department.
/// Feature toggles decide which kinds of content the workspace accepts.
struct Workspace {
  mixin TenantEntity!WorkspaceId;

  string name; /// unique per tenant
  string description;
  string alias_; /// "alias": URL slug, unique per tenant (derived from the name if empty)
  WorkspaceType type = WorkspaceType.team;
  WorkspaceStatus status = WorkspaceStatus.active;
  string imageUrl;
  string defaultLanguage = "en";

  bool allowExternalMembers;
  bool enableNotifications = true;
  bool enableFeeds = true;
  bool enableWiki = true;
  bool enableKnowledgeBase = true;
  bool enableForum = true;

  WorkspaceMember[] members;
}
