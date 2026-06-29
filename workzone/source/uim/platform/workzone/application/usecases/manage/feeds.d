/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.feeds;


// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.feed_entry;
// import uim.platform.workzone.domain.ports.repositories.feeds;
// import uim.platform.workzone.application.dto;
import uim.platform.workzone;

// mixin(ShowModule!());

@safe:
class ManageFeedsUseCase { // TODO: UIMUseCase {
  private FeedRepository repo;

  this(FeedRepository repo) {
    this.repo = repo;
  }

  CommandResult createFeedEntry(CreateFeedEntryRequest req) {
    FeedEntry entry;
    entry.initEntity(req.tenantId, req.actorId);

    entry.workspaceId = req.workspaceId;
    entry.actorId = req.actorId;
    entry.actorName = req.actorName;
    entry.action = req.action;
    entry.objectType = req.objectType;
    entry.objectId = req.objectId;
    entry.objectTitle = req.objectTitle;
    entry.message = req.message;

    repo.save(entry);
    return CommandResult(true, entry.id.value, "");
  }

  FeedEntry getFeedEntry(TenantId tenantId, FeedEntryId id) {
    return repo.findById(tenantId, id);
  }

  FeedEntry[] listFeedEntries(TenantId tenantId, WorkspaceId workspaceId) {
    return repo.findByWorkspace(tenantId, workspaceId);
  }

  CommandResult deleteFeedEntry(TenantId tenantId, FeedEntryId id) {
    auto entry = repo.findById(tenantId, id);
    if (entry.isNull)
      return CommandResult(false, "", "Feed entry not found");

    repo.remove(entry);
    return CommandResult(true, entry.id.value, "");
  }
}
