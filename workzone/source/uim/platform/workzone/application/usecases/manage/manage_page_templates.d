/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.manage_page_templates;

// import std.uuid;
// import std.datetime.systime : Clock;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.page_template;
import uim.platform.workzone.domain.ports.repositories.page_templates;
import uim.platform.workzone.application.dto;

class ManagePageTemplatesUseCase : UIMUseCase {
  private PageTemplateRepository repo;

  this(PageTemplateRepository repo)
  {
    this.repo = repo;
  }

  CommandResult createPageTemplate(CreatePageTemplateRequest req)
  {
    if (req.name.length == 0)
      return CommandResult("", "Page template name is required");

    auto now = Clock.currStdTime();
    auto t = PageTemplate();
    t.id = randomUUID().toString();
    t.tenantId = req.tenantId;
    t.name = req.name;
    t.description = req.description;
    t.thumbnailUrl = req.thumbnailUrl;
    t.sections = req.sections;
    t.isDefault = req.isDefault;
    t.isPublic = req.isPublic;
    t.createdAt = now;
    t.updatedAt = now;

    repo.save(t);
    return CommandResult(t.id, "");
  }

  PageTemplate* getPageTemplate(PageTemplateId id, TenantId tenantId)
  {
    return repo.findById(id, tenantId);
  }

  PageTemplate[] listPageTemplates(TenantId tenantId)
  {
    return repo.findByTenant(tenantId);
  }

  CommandResult updatePageTemplate(UpdatePageTemplateRequest req)
  {
    auto t = repo.findById(req.id, req.tenantId);
    if (t is null)
      return CommandResult("", "Page template not found");

    if (req.name.length > 0)
      t.name = req.name;
    if (req.description.length > 0)
      t.description = req.description;
    t.sections = req.sections;
    t.isDefault = req.isDefault;
    t.isPublic = req.isPublic;
    t.updatedAt = Clock.currStdTime();

    repo.update(*t);
    return CommandResult(t.id, "");
  }

  CommandResult deletePageTemplate(PageTemplateId id, TenantId tenantId)
  {
    auto t = repo.findById(id, tenantId);
    if (t is null)
      return CommandResult("", "Page template not found");

    repo.remove(id, tenantId);
    return CommandResult(id, "");
  }
}
