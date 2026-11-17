/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.knowledge_base;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// Interactor: knowledge base articles. Needs the knowledge base feature;
/// draft → review → published (version + 1) → archived; published articles
/// return to draft when they are edited.
class ManageKnowledgeBaseUseCase
  : ResourceUseCase!(KnowledgeBaseArticle, KBArticleId, CreateArticleRequest, UpdateArticleRequest),
  IManageKnowledgeBaseUseCase {

  protected FeedRecorder feed;

  this(WorkzoneRepositories repos, FeedRecorder feed, IWorkzoneEventPublisher publisher) {
    super(repos, repos.knowledgeBase, publisher, "Article", "workzone.kb-article");
    this.feed = feed;
  }

  override protected KnowledgeBaseArticle build(CreateArticleRequest r) {
    auto ws = requireWorkspace(r.tenantId, r.parentId, "articles");
    ensureFeature(ws.enableKnowledgeBase, ws, "knowledge base");
    auto a = KnowledgeBaseArticle(r.tenantId);
    a.workspaceId = ws.id;
    a.workspaceName = ws.name;
    a.authorId = r.actor;
    assignMatching(a, r.spec);
    if (a.authorName.strip.length == 0)
      a.authorName = feed.displayNameOf(r.tenantId, r.actor);
    check(a);
    return a;
  }

  override protected void apply(ref KnowledgeBaseArticle a, ArticleSpec spec) {
    ensureState(a.status != KBArticleStatus.archived, "Article '" ~ a.title ~ "' is archived");
    assignMatching(a, spec);
    check(a);
    if (a.status == KBArticleStatus.published)
      a.status = KBArticleStatus.draft; // a new version needs a new review
  }

  protected void check(ref KnowledgeBaseArticle a) {
    a.title = a.title.strip;
    validateDisplayName("Article title", a.title, 200);
    ensureUniqueInWorkspace(a, a.workspaceName);
    a.tags = normalizedNames(a.tags);
    a.relatedArticleIds = normalizedNames(a.relatedArticleIds);
    validate(!a.relatedArticleIds.canFind(a.id.value), "An article cannot be related to itself");
    foreach (rel; a.relatedArticleIds)
      ensureFound(!repos.knowledgeBase.findById(a.tenantId, KBArticleId(rel)).isNull, "Related article '" ~ rel ~ "' not found");
  }

  UsecaseResult submit(TenantId tenantId, KBArticleId id, UserId actor) {
    return transition(tenantId, id, actor, "submitted for review", (ref KnowledgeBaseArticle a) {
      ensureState(a.status == KBArticleStatus.draft, "Only drafts can be submitted for review");
      validate(a.body_.strip.length > 0, "Article '" ~ a.title ~ "' has no body");
      a.status = KBArticleStatus.review;
    });
  }

  UsecaseResult publish(TenantId tenantId, KBArticleId id, UserId actor) {
    KnowledgeBaseArticle published;
    auto result = transition(tenantId, id, actor, "published", (ref KnowledgeBaseArticle a) {
      ensureState(a.status == KBArticleStatus.review, "Article '" ~ a.title ~ "' must be reviewed before publishing");
      ensureState(a.authorId != actor || actor.isEmpty, "Articles are published by a reviewer, not by their author");
      a.status = KBArticleStatus.published;
      a.version_++;
      a.publishedAt = nowStdTime();
      published = a;
    });
    if (result.isSuccess)
      feed.record(tenantId, published.workspaceId, actor, "published", "article", published.id.value, published.title);
    return result;
  }

  UsecaseResult archive(TenantId tenantId, KBArticleId id, UserId actor) {
    return transition(tenantId, id, actor, "archived", (ref KnowledgeBaseArticle a) {
      ensureState(a.status != KBArticleStatus.archived, "Article '" ~ a.title ~ "' is already archived");
      a.status = KBArticleStatus.archived;
    });
  }

  UsecaseResult markHelpful(TenantId tenantId, KBArticleId id, UserId actor) {
    return transition(tenantId, id, actor, "rated helpful", (ref KnowledgeBaseArticle a) {
      ensureState(a.status == KBArticleStatus.published, "Only published articles can be rated");
      a.helpfulCount++;
    });
  }
}
