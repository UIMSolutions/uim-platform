/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.manage.tags;

// import std.uuid;
// import std.datetime.systime : Clock;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.tag;
import uim.platform.workzone.domain.ports.repositories.tags;
import uim.platform.workzone.application.dto;

class ManageTagsUseCase { // TODO: UIMUseCase {
  private TagRepository repo;

  this(TagRepository repo) {
    this.repo = repo;
  }

  CommandResult createTag(CreateTagRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "Tag name is required");

    auto existing = repo.findByName(req.name, req.tenantId);
    if (existing !is null)
      return CommandResult(false, "", "Tag with this name already exists");

    auto now = Clock.currStdTime();
    auto t = Tag();
    t.id = randomUUID();
    t.tenantId = req.tenantId;
    t.name = req.name;
    t.description = req.description;
    t.color = req.color;
    t.parentTagId = req.parentTagId;
    t.createdAt = now;

    repo.save(t);
    return CommandResult(t.id, "");
  }

  Tag* getTag(TagId tenantId, id tenantId) {
    return repo.findById(tenantId, id);
  }

  Tag[] listTags(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult updateTag(UpdateTagRequest req) {
    auto t = repo.findById(req.id, req.tenantId);
    if (t is null)
      return CommandResult(false, "", "Tag not found");

    if (req.name.length > 0)
      t.name = req.name;
    if (req.description.length > 0)
      t.description = req.description;
    if (req.color.length > 0)
      t.color = req.color;

    repo.update(*t);
    return CommandResult(t.id, "");
  }

  CommandResult deleteTag(TagId tenantId, id tenantId) {
    auto t = repo.findById(tenantId, id);
    if (t is null)
      return CommandResult(false, "", "Tag not found");

    repo.removeById(tenantId, id);
    return CommandResult(true, id.toString, "");
  }
}
