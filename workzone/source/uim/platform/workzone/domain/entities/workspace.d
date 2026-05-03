/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.workspace;

// import uim.platform.workzone.domain.types;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
/// A collaborative workspace — teams, projects, or departments.
struct Workspace {
  mixin TenantEntity!(WorkspaceId);

  string name;
  string description;
  string alias_; // URL-friendly slug
  WorkspaceType type = WorkspaceType.team;
  WorkspaceStatus status = WorkspaceStatus.active;
  string imageUrl;
  WorkspaceMember[] members;
  WorkpageId[] pageIds;
  ChannelId[] channelIds;
  WorkspaceSettings settings;

  Json toJson() const {
    return entityToJson
      .set("name", name)
      .set("description", description)
      .set("alias", alias_)
      .set("type", type.to!string)
      .set("status", status.to!string)
      .set("imageUrl", imageUrl)
      .set("members", members.map!(m => m.toJson()).array)
      .set("pageIds", pageIds.map!(p => p.value).array)
      .set("channelIds", channelIds.map!(c => c.value).array)
      .set("settings", settings.toJson());
  }
}

/// Membership record within a workspace.
struct WorkspaceMember {
  UserId userId;
  string displayName;
  MemberRole role = MemberRole.contributor;
  long joinedAt;

  Json toJson() const {
    return Json.emptyObject
      .set("userId", userId.value)
      .set("displayName", displayName)
      .set("role", role.to!string)
      .set("joinedAt", joinedAt);
  }
}

/// Workspace-level settings.
struct WorkspaceSettings {
  bool allowExternalMembers;
  bool enableNotifications;
  bool enableFeeds;
  bool enableWiki;
  bool enableKnowledgeBase;
  bool enableForum;
  string defaultLanguage;

  Json toJson() const {
    return Json.emptyObject
      .set("allowExternalMembers", allowExternalMembers)
      .set("enableNotifications", enableNotifications)
      .set("enableFeeds", enableFeeds)
      .set("enableWiki", enableWiki)
      .set("enableKnowledgeBase", enableKnowledgeBase)
      .set("enableForum", enableForum)
      .set("defaultLanguage", defaultLanguage);
  }
}
