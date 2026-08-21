/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.application.usecases.manage.templates;

// import uim.platform.document_ai.domain.entities.template_;
// import uim.platform.document_ai.domain.ports.repositories.templates;
// import uim.platform.document_ai.application.dto;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

class ManageTemplatesUseCase {
  protected ITemplateRepository repo;

  this(ITemplateRepository repo) {
    this.repo = repo;
  }

  UsecaseResult createTemplate(CreateTemplateRequest r) {
    if (r.name.isEmpty)
      return UsecaseResult(false, "", "AiTemplate name is required");
    if (r.clientId.isEmpty)
      return UsecaseResult(false, "", "Client ID is required");
    if (r.schemaId.isEmpty)
      return UsecaseResult(false, "", "Schema ID is required");

    auto t = AiTemplate(r.tenantId);
    t.clientId = r.clientId;
    t.schemaId = r.schemaId;
    t.documentTypeId = r.documentTypeId;
    t.name = r.name;
    t.description = r.description;
    t.status = TemplateStatus.draft;

    // Parse regions: [fieldName, page, x, y, width, height]
    TemplateRegion[] regions;
    foreach (pair; r.regions) {
      if (pair.length >= 6) {
        TemplateRegion reg;
        reg.fieldName = pair[0];
        try {
          reg.page = pair[1].to!int;
          reg.x = pair[2].to!double;
          reg.y = pair[3].to!double;
          reg.width = pair[4].to!double;
          reg.height = pair[5].to!double;
        } catch (Exception) {
          continue;
        }
        regions ~= reg;
      }
    }
    t.regions = regions;

    repo.save(t);
    return UsecaseResult(true, t.id.value, "");
  }

  UsecaseResult updateTemplate(UpdateTemplateRequest r) {
    if (r.templateId.isEmpty)
      return UsecaseResult(false, "", "AiTemplate ID is required");

    auto existing = repo.findById(r.tenantId, r.clientId, r.templateId);
    if (existing.isNull)
      return UsecaseResult(false, "", "AiTemplate not found");

    if (r.name.length > 0) existing.name = r.name;
    if (r.description.length > 0) existing.description = r.description;

    if (r.status.length > 0) {
      switch (r.status) {
        case "active": existing.status = TemplateStatus.active; break;
        case "inactive": existing.status = TemplateStatus.inactive; break;
        case "draft": existing.status = TemplateStatus.draft; break;
        default: break;
      }
    }

    
    existing.updatedAt = currentTimestamp;

    repo.update(existing);
    return UsecaseResult(true, existing.id.value, "");
  }

  AiTemplate getTemplate(TenantId tenantId, ClientId clientId, TemplateId id) {
    return repo.findById(tenantId, clientId, id);
  }

  AiTemplate[] listTemplates(TenantId tenantId, ClientId clientId) {
    return repo.findByClient(tenantId, clientId);
  }

  AiTemplate[] listTemplates(TenantId tenantId, ClientId clientId, SchemaId schemaId) {
    return repo.findBySchema(tenantId, clientId, schemaId);
  }

  AiTemplate[] listTemplates(TenantId tenantId, ClientId clientId, DocumentTypeId typeId) {
    return repo.findByDocumentType(tenantId, clientId, typeId);
  }
  size_t countTemplates(TenantId tenantId, ClientId clientId) {
    return repo.countByClient(tenantId, clientId);
  }
  UsecaseResult deleteTemplate(TenantId tenantId, ClientId clientId, TemplateId id) {
    auto entity = repo.findById(tenantId, clientId, id);
    if (entity.isNull)
      return UsecaseResult(false, "", "AiTemplate not found");

    repo.remove(entity);
    return UsecaseResult(true, entity.id.value, "");
  }


}
