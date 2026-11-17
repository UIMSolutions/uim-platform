/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.services.feed_recorder;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// Writes activity stream entries for business events of a workspace
/// ("published", "joined", "replied", ...) — only if the workspace has feeds enabled.
class FeedRecorder {
  protected WorkzoneRepositories repos;

  this(WorkzoneRepositories repos) {
    this.repos = repos;
  }

  /// Display name of a user (profile display name, else the user id).
  string displayNameOf(TenantId tenantId, UserId user) {
    auto profiles = repos.userProfiles.findMatching(tenantId, (const UserProfile p) => p.userId == user);
    return profiles.length > 0 && profiles[0].displayName.length > 0 ? profiles[0].displayName : user.value;
  }

  /// Record an activity. Returns false if the workspace has no feed.
  bool record(TenantId tenantId, WorkspaceId workspaceId, UserId actor, string action,
      string objectType, string objectId, string objectTitle) {
    auto ws = repos.workspaces.findById(tenantId, workspaceId);
    if (ws.isNull || !ws.enableFeeds)
      return false;
    auto entry = FeedEntry(tenantId);
    entry.workspaceId = ws.id;
    entry.workspaceName = ws.name;
    entry.actorId = actor;
    entry.actorName = displayNameOf(tenantId, actor);
    entry.action = action;
    entry.objectType = objectType;
    entry.objectId = objectId;
    entry.objectTitle = objectTitle;
    entry.message = entry.actorName ~ " " ~ action ~ " " ~ (objectTitle.length ? "'" ~ objectTitle ~ "'" : objectType);
    entry.createdBy = actor;
    entry.updatedBy = actor;
    repos.feedEntries.save(entry);
    return true;
  }
}
