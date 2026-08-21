/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.infrastructure.persistence.repositories.enrichment_data;

// import uim.platform.document_ai.domain.entities.enrichment_data;
// import uim.platform.document_ai.domain.ports.repositories.enrichment_datas;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:
class EnrichmentDataRepository : TenantRepository!(EnrichmentData, EnrichmentDataId), IEnrichmentDataRepository {

  bool existsById(TenantId tenantId, ClientId clientId, EnrichmentDataId id) {
    return findByClient(tenantId, clientId) ? store[clientId].any!(ed => ed.id == id) : false;
  }

  EnrichmentData findById(TenantId tenantId, ClientId clientId, EnrichmentDataId id) {
    foreach (enrichmentData; findByClient(tenantId, clientId)) {
      if (enrichmentData.id == id)
        return enrichmentData;
    }
    return EnrichmentData.init;
  }

  size_t countByClient(TenantId tenantId, ClientId clientId) {
    return findByClient(tenantId, clientId).length;
  }

  EnrichmentData[] filterByClient(EnrichmentData[] enrichmentDatas, ClientId clientId) {
    return enrichmentDatas.filter!(ed => ed.clientId == clientId).array;
  }

  EnrichmentData[] findByClient(TenantId tenantId, ClientId clientId) {
    return filterByClient(findByTenant(tenantId), clientId);
  }

  void removeByClient(TenantId tenantId, ClientId clientId) {
    findByClient(tenantId, clientId).each!(ed => remove(ed));
  }

  size_t countByDocumentType(TenantId tenantId, ClientId clientId, DocumentTypeId typeId) {
    return findByDocumentType(tenantId, clientId, typeId).length;
  }

  EnrichmentData[] filterByDocumentType(EnrichmentData[] enrichmentDatas, DocumentTypeId typeId) {
    return enrichmentDatas.filter!(ed => ed.documentTypeId == typeId).array;
  }

  EnrichmentData[] findByDocumentType(TenantId tenantId, ClientId clientId, DocumentTypeId typeId) {
    return filterByDocumentType(findByClient(tenantId, clientId), typeId);
  }

  void removeByDocumentType(TenantId tenantId, ClientId clientId, DocumentTypeId typeId) {
    findByDocumentType(tenantId, clientId, typeId).each!(ed => remove(ed));
  }

  size_t countBySubtype(TenantId tenantId, ClientId clientId, string subtype) {
    return findBySubtype(tenantId, clientId, subtype).length;
  }

  EnrichmentData[] filterBySubtype(EnrichmentData[] enrichmentDatas, string subtype) {
    return enrichmentDatas.filter!(ed => ed.subtype == subtype).array;
  }

  EnrichmentData[] findBySubtype(TenantId tenantId, ClientId clientId, string subtype) {
    return filterBySubtype(findByClient(tenantId, clientId), subtype);
  }

  void removeBySubtype(TenantId tenantId, ClientId clientId, string subtype) {
    findBySubtype(tenantId, clientId, subtype).each!(ed => remove(ed));
  }

}
