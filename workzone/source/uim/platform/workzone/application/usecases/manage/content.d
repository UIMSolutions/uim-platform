/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.content;


// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.content_item;
// import uim.platform.workzone.domain.ports.repositories.contents;
// import uim.platform.workzone.domain.services.content_search;
// import uim.platform.workzone.application.dto;
import uim.platform.workzone;

// mixin(ShowModule!());

@safe:
class ManageContentUseCase { // TODO: UIMUseCase {
  private ContentRepository repo;

  this(ContentRepository repo) {
    this.repo = repo;
  }

  CommandResult createContent(CreateContentRequest req) {
    if (req.title.length == 0)
      return CommandResult(false, "", "Content title is required");

    auto now = currentTimestamp();
    ContentItem item;
    item.initEntity(req.tenantId, req.authorId);

    item.workspaceId = req.workspaceId;
    item.title = req.title;
    item.body_ = req.body_;
    item.summary = req.summary;
    item.contentType = req.contentType;
    item.status = ContentStatus.draft;
    item.authorId = req.authorId;
    item.authorName = req.authorName;
    item.tags = req.tags;
    item.language = req.language;

    repo.save(item);
    return CommandResult(true, item.id.value, "");
  }

  ContentItem getContent(TenantId tenantId, ContentId id) {
    return repo.find(tenantId, id);
  }

  ContentItem[] listByWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    return repo.findByWorkspace(tenantId, workspaceId);
  }

  ContentItem[] searchContent(TenantId tenantId, WorkspaceId workspaceId, string query) {
    auto items = repo.findByWorkspace(tenantId, workspaceId);
    // TODO: return ContentSearchService.search(items, query);
    return null;
  }

  CommandResult updateContent(UpdateContentRequest req) {
    auto item = repo.findById(req.tenantId, req.id);
    if (item.isNull)
      return CommandResult(false, "", "Content not found");

    if (req.title.length > 0)
      item.title = req.title;
    if (req.body_.length > 0)
      item.body_ = req.body_;
    if (req.summary.length > 0)
      item.summary = req.summary;
    item.status = req.status;
    item.tags = req.tags;
    item.pinned = req.pinned;
    item.updatedAt = currentTimestamp();

    if (item.status == ContentStatus.published && item.publishedAt == 0)
      item.publishedAt = currentTimestamp();

    repo.update(item);
    return CommandResult(true, item.id.value, "");
  }

  CommandResult publishContent(TenantId tenantId, ContentId id) {
    auto item = repo.find(tenantId, id);
    if (item.isNull)
      return CommandResult(false, "", "Content not found");

    item.status = ContentStatus.published;
    item.publishedAt = currentTimestamp();
    item.updatedAt = currentTimestamp();
    repo.update(item);
    return CommandResult(true, item.id.value, "");
  }

  CommandResult deleteContent(TenantId tenantId, ContentId id) {
    auto item = repo.find(tenantId, id);
    if (item.isNull)
      return CommandResult(false, "", "Content not found");

    repo.remove(item);
    return CommandResult(true, item.id.value, "");
  }
}
