/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.page_templates;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:
class ManagePageTemplatesUseCase {
  protected IPageTemplateRepository repo;

  this(IPageTemplateRepository repo) {
    this.repo = repo;
  }

  UsecaseResult createTemplate(CreatePageTemplateRequest req) {
    if (req.name.isEmpty)
      return UsecaseResult(false, "", "Page template name is required");

    auto t = PageTemplate(req.tenantId);
    t.name = req.name;
    t.description = req.description;
    t.thumbnailUrl = req.thumbnailUrl;
    t.sections = req.sections;
    t.isDefault = req.isDefault;
    t.isPublic = req.isPublic;

    repo.save(t);
    return UsecaseResult(true, t.id.value, "");
  }

  PageTemplate getTemplate(TenantId tenantId, PageTemplateId id) {
    return repo.findById(tenantId, id);
  }

  PageTemplate[] listTemplates(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  UsecaseResult updateTemplate(UpdatePageTemplateRequest req) {
    auto t = repo.findById(req.tenantId, req.id);
    if (t.isNull)
      return UsecaseResult(false, "", "Page template not found");

    if (req.name.length > 0)
      t.name = req.name;
    if (req.description.length > 0)
      t.description = req.description;
    t.sections = req.sections;
    t.isDefault = req.isDefault;
    t.isPublic = req.isPublic;
    t.updatedAt = currentTimestamp();

    repo.update(t);
    return UsecaseResult(true, t.id.value, "");
  }

  UsecaseResult deleteTemplate(TenantId tenantId, PageTemplateId id) {
    auto t = repo.findById(tenantId, id);
    if (t.isNull)
      return UsecaseResult(false, "", "Page template not found");

    repo.remove(t);
    return UsecaseResult(true, t.id.value, "");
  }
}
