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
    return clientId in store ? store[clientId].any!(r => r.id == id) : false;
  }

  ExtractionResult findById(TenantId tenantId, ClientId clientId, ExtractionResultId id) {
    if (clientId !in findByTenant(tenantId))
      return ExtractionResult.init;
  
    foreach (r; findByTenant(tenantId)[clientId]) {
      if (r.id == id)
        return r;
    }
    return ExtractionResult.init;
  }

  // #
  size_t countByClient(TenantId tenantId, ClientId clientId) {
    return clientId in findByTenant(tenantId) ? findByTenant(tenantId)[clientId].length : 0;
  }

  ExtractionResult[] filterByClient(ExtractionResult[] results, ClientId clientId) {
    return results.filter!(r => r.clientId == clientId).array;
  }

  ExtractionResult[] findByClient(TenantId tenantId, ClientId clientId) {
    return filterByClient(findByTenant(tenantId), clientId);
  }

  void removeByClient(TenantId tenantId, ClientId clientId) {
    findByClient(tenantId, clientId).each!(r => remove(r));
  }

  ExtractionResult findByDocument(TenantId tenantId, ClientId clientId, DocumentId docId) {
    if (clientId !in findByTenant(tenantId))
      return ExtractionResult.init;

    foreach (r; findByTenant(tenantId)[clientId]) {
      if (r.documentId == docId)
        return r;
    }
    return ExtractionResult.init;
  }

  ExtractionResult[] findBySchema(TenantId tenantId, SchemaId schemaId, ClientId clientId) {
    return clientId in findByTenant(tenantId) ? findByTenant(tenantId)[clientId].filter!(r => r.schemaId == schemaId).array : null;
  }

  void save(TenantId tenantId, ExtractionResult r) {
    findByTenant(tenantId)[r.clientId] ~= r;
  }

  void update(TenantId tenantId, ExtractionResult r) {
    if (r.clientId !in findByTenant(tenantId)) {
      return;
    }
    foreach (existing; findByTenant(tenantId)[r.clientId]) {
      if (existing.id == r.id) {
        existing = r;
        return;
      }
    }
  }

  void remove(ExtractionResultId id, ClientId clientId) {
    if (clientId in store) {
      store[clientId] = store[clientId].filter!(r => r.id != id).array;
    }
  }

  size_t countByClient(ClientId clientId) {
    return clientId in store ? store[clientId].length : 0;
  }
}
