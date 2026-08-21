/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.infrastructure.persistence.repositories.extraction_results;

// import uim.platform.document_ai.domain.entities.extraction_result;
// import uim.platform.document_ai.domain.ports.repositories.extraction_results;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:
class ExtractionResultRepository : TenantRepository!(ExtractionResult, ExtractionResultId), IExtractionResultRepository {
  bool existsById(TenantId tenantId, ClientId clientId, ExtractionResultId id) {
    return findByClient(tenantId, clientId).any!(r => r.id == id);
  }

  ExtractionResult findById(TenantId tenantId, ClientId clientId, ExtractionResultId id) {
    foreach (r; findByClient(tenantId, clientId)) {
      if (r.id == id)
        return r;
    }
    return ExtractionResult.init;
  }

  // #
  size_t countByClient(TenantId tenantId, ClientId clientId) {
    return findByClient(tenantId, clientId).length;
  }

  ExtractionResult[] filterByClient(ExtractionResult[] results, ClientId clientId) {
    return results.filter!(r => r.clientId == clientId).array;
  }

  ExtractionResult[] findByClient(TenantId tenantId, ClientId clientId) {
    return filterByClient(findByClient(tenantId, clientId), clientId);
  }

  void removeByClient(TenantId tenantId, ClientId clientId) {
    findByClient(tenantId, clientId).each!(r => remove(r));
  }

  bool existsByDocument(TenantId tenantId, ClientId clientId, DocumentId docId) {
    return findByClient(tenantId, clientId).any!(r => r.documentId == docId);
  }

  ExtractionResult findByDocument(TenantId tenantId, ClientId clientId, DocumentId docId) {
    if (countByClient(tenantId, clientId) == 0)
      return ExtractionResult.init;

    foreach (r; findByClient(tenantId, clientId)) {
      if (r.documentId == docId)
        return r;
    }
    return ExtractionResult.init;
  }

  size_t countBySchema(TenantId tenantId, ClientId clientId, SchemaId schemaId) {
    return findBySchema(tenantId, clientId, schemaId).length;
  }

  ExtractionResult[] filterBySchema(ExtractionResult[] results, SchemaId schemaId) {
    return results.filter!(r => r.schemaId == schemaId).array;
  }

  ExtractionResult[] findBySchema(TenantId tenantId, ClientId clientId, SchemaId schemaId) {
    return filterBySchema(findByClient(tenantId, clientId), schemaId);
  }

  void removeBySchema(TenantId tenantId, ClientId clientId, SchemaId schemaId) {
    findBySchema(tenantId, clientId, schemaId).each!(r => remove(r));
  }

}
