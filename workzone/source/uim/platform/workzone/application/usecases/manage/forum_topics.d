/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.forum_topics;

// import std.uuid;
// import std.datetime.systime : Clock;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.forum_topic;
import uim.platform.workzone.domain.ports.repositories.forum_topics;
import uim.platform.workzone.application.dto;

class ManageForumTopicsUseCase : UIMUseCase {
  private ForumTopicRepository repo;

  this(ForumTopicRepository repo) {
    this.repo = repo;
  }

  CommandResult createForumTopic(CreateForumTopicRequest req) {
    if (req.title.length == 0)
      return CommandResult("", "Forum topic title is required");

    auto now = Clock.currStdTime();
    auto t = ForumTopic();
    t.id = randomUUID().toString();
    t.workspaceId = req.workspaceId;
    t.tenantId = req.tenantId;
    t.title = req.title;
    t.body_ = req.body_;
    t.authorId = req.authorId;
    t.authorName = req.authorName;
    t.status = ForumTopicStatus.open;
    t.tags = req.tags;
    t.createdAt = now;
    t.updatedAt = now;

    repo.save(t);
    return CommandResult(t.id, "");
  }

  ForumTopic* getForumTopic(ForumTopicId id, TenantId tenantId) {
    return repo.findById(id, tenantId);
  }

  ForumTopic[] listByWorkspace(WorkspaceId workspaceId, TenantId tenantId) {
    return repo.findByWorkspace(workspaceId, tenantId);
  }

  CommandResult updateForumTopic(UpdateForumTopicRequest req) {
    auto t = repo.findById(req.id, req.tenantId);
    if (t is null)
      return CommandResult("", "Forum topic not found");

    if (req.title.length > 0)
      t.title = req.title;
    if (req.body_.length > 0)
      t.body_ = req.body_;
    t.status = req.status;
    t.pinned = req.pinned;
    t.locked = req.locked;
    t.updatedAt = Clock.currStdTime();

    repo.update(*t);
    return CommandResult(t.id, "");
  }

  CommandResult deleteForumTopic(ForumTopicId id, TenantId tenantId) {
    auto t = repo.findById(id, tenantId);
    if (t is null)
      return CommandResult("", "Forum topic not found");

    repo.remove(id, tenantId);
    return CommandResult(id, "");
  }
}
