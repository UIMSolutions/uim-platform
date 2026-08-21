/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.application.usecases.manage.enrichment_data;

// import uim.platform.document_ai.domain.entities.enrichment_data;
// import uim.platform.document_ai.domain.ports.repositories.enrichment_datas;
// import uim.platform.document_ai.application.dto;


import uim.platform.document_ai;

mixin(ShowModule!());

@safe:
class ManageEnrichmentDataUseCase {
  protected IEnrichmentDataRepository repo;

  this(IEnrichmentDataRepository repo) {
    this.repo = repo;
  }

  UsecaseResult createEnrichmentData(CreateEnrichmentDataRequest r) {
    if (r.name.isEmpty)
      return UsecaseResult(false, "", "Enrichment data name is required");
    if (r.clientId.isEmpty)
      return UsecaseResult(false, "", "Client ID is required");

    auto ed = EnrichmentData(r.tenantId);
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
    return UsecaseResult(true, ed.id.value, "");
  }

  UsecaseResult updateEnrichmentData(UpdateEnrichmentDataRequest r) {
    if (r.enrichmentDataId.isEmpty)
      return UsecaseResult(false, "", "Enrichment data ID is required");

    auto existing = repo.findById(r.tenantId, r.clientId, r.enrichmentDataId);
    if (existing.isNull)
      return UsecaseResult(false, "", "Enrichment data not found");

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

    
    existing.updatedAt = currentTimestamp;

    repo.update(existing);
    return UsecaseResult(true, existing.id.value, "");
  }

  EnrichmentData getEnrichmentData(TenantId tenantId, ClientId clientId, EnrichmentDataId id) {
    return repo.findById(tenantId, clientId, id);
  }

  EnrichmentData[] listEnrichmentData(TenantId tenantId, ClientId clientId) {
    return repo.findByClient(tenantId, clientId);
  }

  EnrichmentData[] listEnrichmentData(TenantId tenantId, ClientId clientId, DocumentTypeId typeId) {
    return repo.findByDocumentType(tenantId, clientId, typeId);
  }

  EnrichmentData[] listEnrichmentData(TenantId tenantId, ClientId clientId, string subtype) {
    return repo.findBySubtype(tenantId, clientId, subtype);
  }
  size_t countEnrichmentData(TenantId tenantId, ClientId clientId) {
    return repo.countByClient(tenantId, clientId);
  }
  UsecaseResult deleteEnrichmentData(TenantId tenantId, ClientId clientId, EnrichmentDataId id) {
    auto entity = repo.findById(tenantId, clientId, id);
    if (entity.isNull)
      return UsecaseResult(false, "", "Enrichment data not found");

    repo.remove(entity);
    return UsecaseResult(true, entity.id.value, "");
  }


}
