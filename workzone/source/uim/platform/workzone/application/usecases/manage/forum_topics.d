/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.forum_topics;

// import std.uuid;
// import std.datetime.systime : Clock;

// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.forum_topic;
// import uim.platform.workzone.domain.ports.repositories.forum_topics;
// import uim.platform.workzone.application.dto;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
class ManageForumTopicsUseCase { // TODO: UIMUseCase {
  private ForumTopicRepository repo;

  this(ForumTopicRepository repo) {
    this.repo = repo;
  }

  CommandResult createForumTopic(CreateForumTopicRequest req) {
    if (req.title.length == 0)
      return CommandResult(false, "", "Forum topic title is required");

    auto now = Clock.currStdTime();
    auto t = ForumTopic();
    t.id = randomUUID();
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

  ForumTopic getForumTopic(TenantId tenantId, ForumTopicId id) {
    return repo.findById(tenantId, id);
  }

  ForumTopic[] listByWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    return repo.findByWorkspace(tenantId, workspaceId);
  }

  CommandResult updateForumTopic(UpdateForumTopicRequest req) {
    auto t = repo.findById(req.tenantId, req.id);
    if (t.isNull)
      return CommandResult(false, "", "Forum topic not found");

    if (req.title.length > 0)
      t.title = req.title;
    if (req.body_.length > 0)
      t.body_ = req.body_;
    t.status = req.status;
    t.pinned = req.pinned;
    t.locked = req.locked;
    t.updatedAt = Clock.currStdTime();

    repo.update(t);
    return CommandResult(t.id, "");
  }

  CommandResult deleteForumTopic(TenantId tenantId, ForumTopicId id) {
    auto t = repo.findById(tenantId, id);
    if (t.isNull)
      return CommandResult(false, "", "Forum topic not found");

    repo.removeById(tenantId, id);
    return CommandResult(true, id.value, "");
  }
}
