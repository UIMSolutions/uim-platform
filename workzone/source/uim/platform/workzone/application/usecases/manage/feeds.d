/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.feeds;

// import std.uuid;
// import std.datetime.systime : Clock;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.feed_entry;
import uim.platform.workzone.domain.ports.repositories.feeds;
import uim.platform.workzone.application.dto;

class ManageFeedsUseCase : UIMUseCase {
  private FeedRepository repo;

  this(FeedRepository repo) {
    this.repo = repo;
  }

  CommandResult createEntry(CreateFeedEntryRequest req) {
    auto entry = FeedEntry();
    entry.id = randomUUID();
    entry.workspaceId = req.workspaceId;
    entry.tenantId = req.tenantId;
    entry.actorId = req.actorId;
    entry.actorName = req.actorName;
    entry.action = req.action;
    entry.objectType = req.objectType;
    entry.objectId = req.objectId;
    entry.objectTitle = req.objectTitle;
    entry.message = req.message;
    entry.createdAt = Clock.currStdTime();

    repo.save(entry);
    return CommandResult(entry.id, "");
  }

  FeedEntry* getEntry(FeedEntryId tenantId, id tenantId) {
    return repo.findById(tenantId, id);
  }

  FeedEntry[] listByWorkspace(WorkspaceId workspacetenantId, id tenantId) {
    return repo.findByWorkspace(workspacetenantId, id);
  }

  void deleteEntry(FeedEntryId tenantId, id tenantId) {
    repo.remove(tenantId, id);
  }
}
