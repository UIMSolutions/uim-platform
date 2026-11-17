/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.content;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// Interactor: content items. Wiki pages need the wiki feature; publishing
/// writes a feed entry; tags must exist in the tag catalogue.
class ManageContentUseCase
  : ResourceUseCase!(ContentItem, ContentId, CreateContentRequest, UpdateContentRequest),
  IManageContentUseCase {

  protected FeedRecorder feed;

  this(WorkzoneRepositories repos, FeedRecorder feed, IWorkzoneEventPublisher publisher) {
    super(repos, repos.content, publisher, "Content", "workzone.content");
    this.feed = feed;
  }

  override protected ContentItem build(CreateContentRequest r) {
    auto ws = requireWorkspace(r.tenantId, r.parentId, "content");
    auto c = ContentItem(r.tenantId);
    c.workspaceId = ws.id;
    c.workspaceName = ws.name;
    c.authorId = r.actor;
    assignMatching(c, r.spec);
    if (c.authorName.strip.length == 0)
      c.authorName = feed.displayNameOf(r.tenantId, r.actor);
    if (c.contentType == ContentType.wikiPage)
      ensureFeature(ws.enableWiki, ws, "wiki");
    check(c);
    return c;
  }

  override protected void apply(ref ContentItem c, ContentSpec spec) {
    ensureState(c.status != ContentStatus.archived, "Content '" ~ c.title ~ "' is archived");
    auto type = c.contentType;
    assignMatching(c, spec, ["contentType"]);
    c.contentType = type; // the kind is fixed after creation
    check(c);
  }

  protected void check(ref ContentItem c) {
    c.title = c.title.strip;
    validateDisplayName("Title", c.title, 200);
    c.tags = normalizedNames(c.tags);
    foreach (t; c.tags)
      ensureFound(!repos.tags.findByName(c.tenantId, t).isNull, "Tag '" ~ t ~ "' not found");
    foreach (u; c.attachmentUrls)
      validate(isLaunchTarget(u), "Attachment '" ~ u ~ "' must be an http(s) URL or a relative path");
    if (c.summary.length == 0 && c.body_.length > 0)
      c.summary = c.body_.length > 160 ? c.body_[0 .. 157] ~ "..." : c.body_;
  }

  UsecaseResult publish(TenantId tenantId, ContentId id, UserId actor) {
    ContentItem published;
    auto result = transition(tenantId, id, actor, "published", (ref ContentItem c) {
      ensureState(c.status == ContentStatus.draft, "Only drafts can be published ('" ~ c.title ~ "' is "
          ~ enumText(c.status) ~ ")");
      requireWorkspace(tenantId, c.workspaceId, "content");
      validate(c.body_.strip.length > 0, "Content '" ~ c.title ~ "' has no body");
      c.status = ContentStatus.published;
      c.publishedAt = nowStdTime();
      published = c;
    });
    if (result.isSuccess)
      feed.record(tenantId, published.workspaceId, actor, "published", "content", published.id.value, published.title);
    return result;
  }

  UsecaseResult archive(TenantId tenantId, ContentId id, UserId actor) {
    return transition(tenantId, id, actor, "archived", (ref ContentItem c) {
      ensureState(c.status != ContentStatus.archived, "Content '" ~ c.title ~ "' is already archived");
      c.status = ContentStatus.archived;
      c.pinned = false;
    });
  }

  UsecaseResult pin(TenantId tenantId, ContentId id, UserId actor) {
    return transition(tenantId, id, actor, "pinned", (ref ContentItem c) {
      ensureState(c.status == ContentStatus.published, "Only published content can be pinned");
      c.pinned = true;
    });
  }

  UsecaseResult unpin(TenantId tenantId, ContentId id, UserId actor) {
    return transition(tenantId, id, actor, "unpinned", (ref ContentItem c) { c.pinned = false; });
  }

  UsecaseResult like(TenantId tenantId, ContentId id, UserId actor) {
    return transition(tenantId, id, actor, "liked", (ref ContentItem c) {
      ensureState(c.status == ContentStatus.published, "Only published content can be liked");
      c.likeCount++;
    });
  }
}

/// Interactor: activity stream entries (manual posts; most entries are written by FeedRecorder).
class ManageFeedEntriesUseCase
  : ResourceUseCase!(FeedEntry, FeedEntryId, CreateFeedEntryRequest, UpdateFeedEntryRequest),
  IManageFeedEntriesUseCase {

  protected FeedRecorder feed;

  this(WorkzoneRepositories repos, FeedRecorder feed, IWorkzoneEventPublisher publisher) {
    super(repos, repos.feedEntries, publisher, "Feed entry", "workzone.feed");
    this.feed = feed;
  }

  override protected FeedEntry build(CreateFeedEntryRequest r) {
    auto ws = requireWorkspace(r.tenantId, r.parentId, "feed entries");
    ensureFeature(ws.enableFeeds, ws, "feed");
    auto e = FeedEntry(r.tenantId);
    e.workspaceId = ws.id;
    e.workspaceName = ws.name;
    e.actorId = r.actor;
    assignMatching(e, r.spec);
    if (e.actorName.strip.length == 0)
      e.actorName = feed.displayNameOf(r.tenantId, r.actor);
    check(e);
    return e;
  }

  override protected void apply(ref FeedEntry e, FeedEntrySpec spec) {
    assignMatching(e, spec);
    check(e);
  }

  protected static void check(ref FeedEntry e) {
    e.message = e.message.strip;
    validate(e.message.length > 0, "A feed entry needs a message");
    validate(e.message.length <= 2000, "Feed messages are limited to 2000 characters");
    if (e.action.strip.length == 0)
      e.action = "posted";
    e.mentionedUserIds = normalizedNames(e.mentionedUserIds);
  }
}
