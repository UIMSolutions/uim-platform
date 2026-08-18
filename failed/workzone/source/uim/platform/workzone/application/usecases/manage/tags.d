/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.tags;


// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.tag;
// import uim.platform.workzone.domain.ports.repositories.tags;
// import uim.platform.workzone.application.dto;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
class ManageTagsUseCase {
  protected ITagRepository repo;

  this(ITagRepository repo) {
    this.repo = repo;
  }

  UsecaseResult createTag(CreateTagRequest req) {
    if (req.name.isEmpty)
      return UsecaseResult(false, "", "Tag name is required");

    auto existing = repo.findByName(req.tenantId, req.name);
    if (!existing.isNull)
      return UsecaseResult(false, "", "Tag with this name already exists");

    auto t = Tag(req.tenantId);
    t.name = req.name;
    t.description = req.description;
    t.color = req.color;
    t.parentTagId = req.parentTagId;

    repo.save(t);
    return UsecaseResult(true, t.id.value, "");
  }

  Tag getTag(TenantId tenantId, TagId id) {
    return repo.findById(tenantId, id);
  }

  Tag[] listTags(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  UsecaseResult updateTag(UpdateTagRequest req) {
    auto t = repo.findById(req.tenantId, req.id);
    if (t.isNull)
      return UsecaseResult(false, "", "Tag not found");

    if (req.name.length > 0)
      t.name = req.name;
    if (req.description.length > 0)
      t.description = req.description;
    if (req.color.length > 0)
      t.color = req.color;

    repo.update(t);
    return UsecaseResult(true, t.id.value, "");
  }

  UsecaseResult deleteTag(TenantId tenantId, TagId id) {
    auto t = repo.findById(tenantId, id);
    if (t.isNull)
      return UsecaseResult(false, "", "Tag not found");

    repo.remove(t);
    return UsecaseResult(true, t.id.value, "");
  }
}
