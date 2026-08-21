/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.infrastructure.persistence.repositories.document_types;

// import uim.platform.document_ai.domain.entities.document_type;
// import uim.platform.document_ai.domain.ports.repositories.document_types;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:
class DocumentTypeRepository : TenantRepository!(DocumentType, DocumentTypeId), IDocumentTypeRepository {

  DocumentType findById(TenantId tenantId, ClientId clientId, DocumentTypeId id) {
    foreach(c; filterByClient(findByTenant(tenantId), clientId)) {
      if (c.id == id)
        return c;
    }
    return null;
  }

  size_t countByClient(TenantId tenantId, ClientId clientId) {
    return findByClient(tenantId, clientId).length;
  }

  DocumentType[] filterByClient(DocumentType[] types, ClientId clientId) {
    return types.filter!(dt => dt.clientId == clientId).array;
  }
  
  DocumentType[] findByClient(TenantId tenantId, ClientId clientId) {
    return filterByClient(findByTenant(tenantId), clientId).array;
  }

  void removeByClient(TenantId tenantId, ClientId clientId) {
    findByClient(tenantId, clientId).each!(e => remove(e));
  }

  size_t countByCategory(TenantId tenantId, ClientId clientId, DocumentCategory category) {
    return findByCategory(tenantId, clientId, category).length;
  }

  DocumentType[] filterByCategory(DocumentType[] types, DocumentCategory category) {
    return types.filter!(dt => dt.category == category).array;
  }
  
  DocumentType[] findByCategory(TenantId tenantId, ClientId clientId, DocumentCategory category) {
    return filterByCategory(findByClient(tenantId, clientId), category).array;
  }

  void removeByCategory(TenantId tenantId, ClientId clientId, DocumentCategory category) {
    findByCategory(tenantId, clientId, category).each!(e => remove(e));
  }

}
