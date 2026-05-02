/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.content;

// import std.uuid;
// import std.datetime.systime : Clock;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.content_item;
import uim.platform.workzone.domain.ports.repositories.contents;
import uim.platform.workzone.domain.services.content_search;
import uim.platform.workzone.application.dto;

class ManageContentUseCase { // TODO: UIMUseCase {
  private ContentRepository repo;

  this(ContentRepository repo) {
    this.repo = repo;
  }

  CommandResult createContent(CreateContentRequest req) {
    if (req.title.length == 0)
      return CommandResult(false, "", "Content title is required");

    auto now = Clock.currStdTime();
    auto item = ContentItem();
    item.id = randomUUID();
    item.workspaceId = req.workspaceId;
    item.tenantId = req.tenantId;
    item.title = req.title;
    item.body_ = req.body_;
    item.summary = req.summary;
    item.contentType = req.contentType;
    item.status = ContentStatus.draft;
    item.authorId = req.authorId;
    item.authorName = req.authorName;
    item.tags = req.tags;
    item.language = req.language;
    item.createdAt = now;
    item.updatedAt = now;

    repo.save(item);
    return CommandResult(item.id, "");
  }

  ContentItem* getContent(ContentId tenantId, id tenantId) {
    return repo.findById(tenantId, id);
  }

  ContentItem[] listByWorkspace(WorkspaceId workspacetenantId, id tenantId) {
    return repo.findByWorkspace(workspacetenantId, id);
  }

  ContentItem[] searchContent(WorkspaceId workspacetenantId, id tenantId, string query) {
    auto items = repo.findByWorkspace(workspacetenantId, id);
    return ContentSearchService.search(items, query);
  }

  CommandResult updateContent(UpdateContentRequest req) {
    auto item = repo.findById(req.id, req.tenantId);
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
    item.updatedAt = Clock.currStdTime();

    if (item.status == ContentStatus.published && item.publishedAt == 0)
      item.publishedAt = Clock.currStdTime();

    repo.update(item);
    return CommandResult(item.id, "");
  }

  CommandResult publishContent(ContentId tenantId, id tenantId) {
    auto item = repo.findById(tenantId, id);
    if (item.isNull)
      return CommandResult(false, "", "Content not found");

    item.status = ContentStatus.published;
    item.publishedAt = Clock.currStdTime();
    item.updatedAt = Clock.currStdTime();
    repo.update(item);
    return CommandResult(item.id, "");
  }

  void deleteContent(ContentId tenantId, id tenantId) {
    repo.removeById(tenantId, id);
  }
}
