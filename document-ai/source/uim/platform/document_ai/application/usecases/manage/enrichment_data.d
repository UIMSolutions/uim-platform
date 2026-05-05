/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.application.usecases.manage.enrichment_data;

import uim.platform.document_ai.domain.types;
import uim.platform.document_ai.domain.entities.enrichment_data;
import uim.platform.document_ai.domain.ports.repositories.enrichment_datas;
import uim.platform.document_ai.application.dto;

import std.uuid : randomUUID;
import std.conv : to;

class ManageEnrichmentDataUseCase { // TODO: UIMUseCase {
  private EnrichmentDataRepository repo;

  this(EnrichmentDataRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateEnrichmentDataRequest r) {
    if (r.name.length == 0)
      return CommandResult(false, "", "Enrichment data name is required");
    if (r.clientId.isEmpty)
      return CommandResult(false, "", "Client ID is required");

    EnrichmentData ed;
    ed.id = randomUUID();
    ed.tenantId = r.tenantId;
    ed.clientId = r.clientId;
    ed.documentTypeId = r.documentTypeId;
    ed.name = r.name;
    ed.description = r.description;
    ed.subtype = r.subtype;

    EnrichmentField[] fields;
    foreach (pair; r.fields) {
      if (pair.length >= 2) {
        EnrichmentField f;
        f.key = pair[0];
        f.value = pair[1];
        fields ~= f;
      }
    }
    ed.fields = fields;

    import core.time : MonoTime;
    auto now = MonoTime.currTime.ticks;
    ed.createdAt = now;
    ed.updatedAt = now;

    repo.save(ed);
    return CommandResult(true, ed.id.value, "");
  }

  CommandResult update(UpdateEnrichmentDataRequest r) {
    if (r.enrichmentDataId.isEmpty)
      return CommandResult(false, "", "Enrichment data ID is required");

    auto existing = repo.findById(r.enrichmentDataId, r.clientId);
    if (existing.isNull)
      return CommandResult(false, "", "Enrichment data not found");

    if (r.name.length > 0) existing.name = r.name;
    if (r.description.length > 0) existing.description = r.description;

    if (r.fields.length > 0) {
      EnrichmentField[] fields;
      foreach (pair; r.fields) {
        if (pair.length >= 2) {
          EnrichmentField field;
          field.key = pair[0];
          field.value = pair[1];
          fields ~= field;
        }
      }
      existing.fields = fields;
    }

    import core.time : MonoTime;
    existing.updatedAt = MonoTime.currTime.ticks;

    repo.update(existing);
    return CommandResult(true, existing.id.value, "");
  }

  EnrichmentData getById(EnrichmentDataId id, ClientId clientId) {
    return repo.findById(id, clientId);
  }

  EnrichmentData[] list(ClientId clientId) {
    return repo.findByClient(clientId);
  }

  EnrichmentData[] listByDocumentType(DocumentTypeId typeId, ClientId clientId) {
    return repo.findByDocumentType(typeId, clientId);
  }

  EnrichmentData[] listBySubtype(string subtype, ClientId clientId) {
    return repo.findBySubtype(subtype, clientId);
  }

  CommandResult remove(EnrichmentDataId id, ClientId clientId) {
    if (!repo.existsById(id, clientId))
      return CommandResult(false, "", "Enrichment data not found");

    repo.remove(id, clientId);
    return CommandResult(true, id.value, "");
  }

  size_t count(ClientId clientId) {
    return repo.countByClient(clientId);
  }
}
