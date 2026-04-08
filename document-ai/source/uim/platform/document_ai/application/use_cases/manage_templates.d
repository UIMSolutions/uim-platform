/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.application.usecases.manage.templates;

import uim.platform.document_ai.domain.types;
import uim.platform.document_ai.domain.entities.template_;
import uim.platform.document_ai.domain.ports.repositories.templates;
import uim.platform.document_ai.application.dto;

import std.uuid : randomUUID;
import std.conv : to;

class ManageTemplatesUseCase : UIMUseCase {
  private TemplateRepository repo;

  this(TemplateRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateTemplateRequest r) {
    if (r.name.length == 0)
      return CommandResult(false, "", "Template name is required");
    if (r.clientid.isEmpty)
      return CommandResult(false, "", "Client ID is required");
    if (r.schemaid.isEmpty)
      return CommandResult(false, "", "Schema ID is required");

    Template t;
    t.id = randomUUID().to!string;
    t.tenantId = r.tenantId;
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

    import core.time : MonoTime;
    auto now = MonoTime.currTime.ticks;
    t.createdAt = now;
    t.modifiedAt = now;

    repo.save(t);
    return CommandResult(true, t.id, "");
  }

  CommandResult update(UpdateTemplateRequest r) {
    if (r.templateid.isEmpty)
      return CommandResult(false, "", "Template ID is required");

    auto existing = repo.findById(r.templateId, r.clientId);
    if (existing.id.isEmpty)
      return CommandResult(false, "", "Template not found");

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

    import core.time : MonoTime;
    existing.modifiedAt = MonoTime.currTime.ticks;

    repo.update(existing);
    return CommandResult(true, existing.id, "");
  }

  Template get_(TemplateId id, ClientId clientId) {
    return repo.findById(id, clientId);
  }

  Template[] list(ClientId clientId) {
    return repo.findByClient(clientId);
  }

  Template[] listBySchema(SchemaId schemaId, ClientId clientId) {
    return repo.findBySchema(schemaId, clientId);
  }

  Template[] listByDocumentType(DocumentTypeId typeId, ClientId clientId) {
    return repo.findByDocumentType(typeId, clientId);
  }

  CommandResult remove(TemplateId id, ClientId clientId) {
    auto existing = repo.findById(id, clientId);
    if (existing.id.isEmpty)
      return CommandResult(false, "", "Template not found");

    repo.remove(id, clientId);
    return CommandResult(true, id, "");
  }

  long count(ClientId clientId) {
    return repo.countByClient(clientId);
  }
}
