/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.forum_topics;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// Interactor: forum topics. Needs the forum feature; locked or closed topics
/// take no replies.
class ManageForumTopicsUseCase
  : ResourceUseCase!(ForumTopic, ForumTopicId, CreateForumTopicRequest, UpdateForumTopicRequest),
  IManageForumTopicsUseCase {

  protected FeedRecorder feed;

  this(WorkzoneRepositories repos, FeedRecorder feed, IWorkzoneEventPublisher publisher) {
    super(repos, repos.forumTopics, publisher, "Forum topic", "workzone.forum-topic");
    this.feed = feed;
  }

  override protected ForumTopic build(CreateForumTopicRequest r) {
    auto ws = requireWorkspace(r.tenantId, r.parentId, "forum topics");
    ensureFeature(ws.enableForum, ws, "forum");
    auto t = ForumTopic(r.tenantId);
    t.workspaceId = ws.id;
    t.workspaceName = ws.name;
    t.authorId = r.actor;
    assignMatching(t, r.spec);
    if (t.authorName.strip.length == 0)
      t.authorName = feed.displayNameOf(r.tenantId, r.actor);
    check(t);
    return t;
  }

  override protected void afterCreate(ForumTopic t, UserId actor) {
    feed.record(t.tenantId, t.workspaceId, actor, "started a discussion", "forumTopic", t.id.value, t.title);
  }

  override protected void apply(ref ForumTopic t, ForumTopicSpec spec) {
    ensureState(t.status != ForumTopicStatus.archived, "Forum topic '" ~ t.title ~ "' is archived");
    assignMatching(t, spec);
    check(t);
  }

  protected static void check(ref ForumTopic t) {
    t.title = t.title.strip;
    validateDisplayName("Topic title", t.title, 200);
    validate(t.body_.strip.length > 0, "A forum topic needs a body");
    t.tags = normalizedNames(t.tags);
  }

  UsecaseResult reply(TenantId tenantId, ForumTopicId id, UserId actor) {
    ForumTopic topic;
    auto result = transition(tenantId, id, actor, "replied", (ref ForumTopic t) {
      ensureState(t.status == ForumTopicStatus.open, "Forum topic '" ~ t.title ~ "' is " ~ enumText(t.status));
      ensureState(!t.locked, "Forum topic '" ~ t.title ~ "' is locked");
      t.replyCount++;
      t.lastReplyAt = nowStdTime();
      topic = t;
    });
    if (result.isSuccess)
      feed.record(tenantId, topic.workspaceId, actor, "replied to", "forumTopic", topic.id.value, topic.title);
    return result;
  }

  UsecaseResult close(TenantId tenantId, ForumTopicId id, UserId actor) {
    return transition(tenantId, id, actor, "closed", (ref ForumTopic t) {
      ensureState(t.status == ForumTopicStatus.open, "Forum topic '" ~ t.title ~ "' is not open");
      t.status = ForumTopicStatus.closed;
    });
  }

  UsecaseResult reopen(TenantId tenantId, ForumTopicId id, UserId actor) {
    return transition(tenantId, id, actor, "reopened", (ref ForumTopic t) {
      ensureState(t.status == ForumTopicStatus.closed, "Only closed topics can be reopened");
      t.status = ForumTopicStatus.open;
    });
  }

  UsecaseResult pin(TenantId tenantId, ForumTopicId id, UserId actor) {
    return transition(tenantId, id, actor, "pinned", (ref ForumTopic t) {
      ensureState(t.status != ForumTopicStatus.archived, "Archived topics cannot be pinned");
      t.pinned = true;
    });
  }

  UsecaseResult unpin(TenantId tenantId, ForumTopicId id, UserId actor) {
    return transition(tenantId, id, actor, "unpinned", (ref ForumTopic t) { t.pinned = false; });
  }

  UsecaseResult lock(TenantId tenantId, ForumTopicId id, UserId actor) {
    return transition(tenantId, id, actor, "locked", (ref ForumTopic t) {
      ensureState(!t.locked, "Forum topic '" ~ t.title ~ "' is already locked");
      t.locked = true;
    });
  }

  UsecaseResult unlock(TenantId tenantId, ForumTopicId id, UserId actor) {
    return transition(tenantId, id, actor, "unlocked", (ref ForumTopic t) {
      ensureState(t.locked, "Forum topic '" ~ t.title ~ "' is not locked");
      t.locked = false;
    });
  }
}
