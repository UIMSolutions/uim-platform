/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.application.usecases.manage.enrichment_data;
// import uim.platform.document_ai.domain.types;
// import uim.platform.document_ai.domain.entities.enrichment_data;
// import uim.platform.document_ai.domain.ports.repositories.enrichment_datas;
// import uim.platform.document_ai.application.dto;
// import std.uuid : randomUUID;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:
class ManageEnrichmentDataUseCase { // TODO: UIMUseCase {
  private EnrichmentDataRepository repo;

  this(EnrichmentDataRepository repo) {
    this.repo = repo;
  }

  CommandResult createEnrichmentData(CreateEnrichmentDataRequest r) {
    if (r.name.length == 0)
      return CommandResult(false, "", "Enrichment data name is required");
    if (r.clientId.isEmpty)
      return CommandResult(false, "", "Client ID is required");

    EnrichmentData ed;
    ed.initEntity(r.tenantId) ;

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

    repo.save(ed);
    return CommandResult(true, ed.id.value, "");
  }

  CommandResult updateEnrichmentData(UpdateEnrichmentDataRequest r) {
    if (r.enrichmentDataId.isEmpty)
      return CommandResult(false, "", "Enrichment data ID is required");

    auto existing = repo.findById(r.clientId, r.enrichmentDataId);
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

  EnrichmentData getEnrichmentData(ClientId clientId, EnrichmentDataId id) {
    return repo.findById(clientId, id);
  }

  EnrichmentData[] listEnrichmentData(ClientId clientId) {
    return repo.findByClient(clientId);
  }

  EnrichmentData[] listEnrichmentData(ClientId clientId, DocumentTypeId typeId) {
    return repo.findByDocumentType(clientId, typeId);
  }

  EnrichmentData[] listEnrichmentData(ClientId clientId, string subtype) {
    return repo.findBySubtype(clientId, subtype);
  }
  size_t countEnrichmentData(ClientId clientId) {
    return repo.countByClient(clientId);
  }
  CommandResult deleteEnrichmentData(ClientId clientId, EnrichmentDataId id) {
    auto entity = repo.findById(clientId, id);
    if (entity.isNull)
      return CommandResult(false, "", "Enrichment data not found");

    repo.remove(entity);
    return CommandResult(true, entity.id.value, "");
  }


}
