/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.infrastructure.persistence.repositories.documents;

// import uim.platform.document_ai.domain.entities.AiDocument;
// import uim.platform.document_ai.domain.ports.repositories.documents;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:
class DocumentRepository : TenantRepository!(AiDocument, DocumentId), IDocumentRepository {

  bool existsById(TenantId tenantId, ClientId clientId, DocumentId id) {
    return findByClient(tenantId, clientId).any!(d => d.id == id);
  }

  AiDocument findById(TenantId tenantId, ClientId clientId, DocumentId id) {
    foreach (d; findByClient(tenantId, clientId)) {
      if (d.id == id)
        return d;
    }
    return AiDocument.init;
  }

  size_t countByClient(TenantId tenantId, ClientId clientId) {
    return findByClient(tenantId, clientId).length;
  }

  AiDocument[] filterByClient(AiDocument[] documents, ClientId clientId) {
    return documents.filter!(d => d.clientId == clientId).array;
  }

  AiDocument[] findByClient(TenantId tenantId, ClientId clientId) {
    return filterByClient(findByClient(tenantId, clientId), clientId);
  }

  void removeByClient(TenantId tenantId, ClientId clientId) {
    findByClient(tenantId, clientId).each!(e => remove(e));
  }

  size_t countByStatus(TenantId tenantId, ClientId clientId, DocumentStatus status) {
    return findByStatus(tenantId, clientId, status).length;
  }

  AiDocument[] filterByStatus(AiDocument[] documents, ClientId clientId, DocumentStatus status) {
    return documents.filter!(d => d.clientId == clientId && d.status == status).array;
  }

  AiDocument[] findByStatus(TenantId tenantId, ClientId clientId, DocumentStatus status) {
    return filterByStatus(findByClient(tenantId, clientId), clientId, status);
  }

  void removeByStatus(TenantId tenantId, ClientId clientId, DocumentStatus status) {
    findByStatus(tenantId, clientId, status).each!(e => remove(e));
  }

  size_t countByDocumentType(TenantId tenantId, ClientId clientId, DocumentTypeId typeId) {
    return findByDocumentType(tenantId, clientId, typeId).length;
  }

  AiDocument[] filterByDocumentType(AiDocument[] documents, ClientId clientId, DocumentTypeId typeId) {
    return documents.filter!(d => d.clientId == clientId && d.documentTypeId == typeId).array;
  }

  AiDocument[] findByDocumentType(TenantId tenantId, ClientId clientId, DocumentTypeId typeId) {
    return filterByDocumentType(findByClient(tenantId, clientId), clientId, typeId);
  }

  void removeByDocumentType(TenantId tenantId, ClientId clientId, DocumentTypeId typeId) {
    findByDocumentType(tenantId, clientId, typeId).each!(e => remove(e));
  }

  size_t countByCategory(TenantId tenantId, ClientId clientId, DocumentCategory category) {
    return findByCategory(tenantId, clientId, category).length;
  }

  AiDocument[] filterByCategory(AiDocument[] documents, ClientId clientId, DocumentCategory category) {
    return documents.filter!(d => d.clientId == clientId && d.category == category).array;
  }

  AiDocument[] findByCategory(TenantId tenantId, ClientId clientId, DocumentCategory category) {
    return filterByCategory(findByClient(tenantId, clientId), clientId, category);
  }

  void removeByCategory(TenantId tenantId, ClientId clientId, DocumentCategory category) {
    findByCategory(tenantId, clientId, category).each!(e => remove(e));
  }

}
