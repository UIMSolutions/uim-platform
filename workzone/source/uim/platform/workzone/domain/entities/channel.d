/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.channel;

// import uim.platform.workzone.domain.types;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
/// A content channel — a feed source within a workspace for activity streams.
struct Channel {
  mixin TenantEntity!(ChannelId);

  WorkspaceId workspaceId;
  string name;
  string description;
  ChannelType channelType = ChannelType.activity;
  bool active = true;
  RoleId[] allowedRoleIds;
  ChannelConfig config;

  Json toJson() const {
    return entityToJson
      .set("workspaceId", workspaceId.value)
      .set("name", name)
      .set("description", description)
      .set("channelType", channelType.to!string())
      .set("active", active)
      .set("allowedRoleIds", allowedRoleIds.map!(r => r.value).array.toJson())
      .set("config", config.toJson());
  }
}

/// Channel-specific configuration.
struct ChannelConfig {
  string sourceUrl; // external feed URL
  int pollIntervalSec; // how often to poll
  string authType;
  string authToken;
  int maxItems;

  Json toJson() const {
    return Json.emptyObject
      .set("sourceUrl", sourceUrl)
      .set("pollIntervalSec", pollIntervalSec)
      .set("authType", authType)
      .set("authToken", authToken)
      .set("maxItems", maxItems);
  }
}
