/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.channel;

import uim.platform.workzone.domain.types;

/// A content channel — a feed source within a workspace for activity streams.
struct Channel {
  ChannelId id;
  WorkspaceId workspaceId;
  TenantId tenantId;
  string name;
  string description;
  ChannelType channelType = ChannelType.activity;
  bool active = true;
  RoleId[] allowedRoleIds;
  ChannelConfig config;
  long createdAt;
  long updatedAt;
}

/// Channel-specific configuration.
struct ChannelConfig {
  string sourceUrl; // external feed URL
  int pollIntervalSec; // how often to poll
  string authType;
  string authToken;
  int maxItems;
}
