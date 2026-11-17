/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.workspace_channel;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// A content channel of a workspace (activity stream or external feed).
struct WorkspaceChannel {
  mixin TenantEntity!ChannelId;

  WorkspaceId workspaceId;
  string workspaceName;
  string name; /// unique per workspace
  string description;
  ChannelType channelType = ChannelType.activity;
  bool active = true;
  string sourceUrl; /// required for external channels
  int pollIntervalSec = 300;
  string authType = "none";
  string authToken; /// secret
  int maxItems = 20;
  string[] allowedRoles;
}
