/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.infrastructure.persistence.memory.documents;

// import uim.platform.dms.application.domain.entities.document;
// import uim.platform.dms.application.domain.ports.repositories.documents;
// import uim.platform.dms.application.domain.types;

import uim.platform.dms.application;

mixin(ShowModule!());
@safe:

class MemoryDocumentRepository : TenantRepository!(Document, DocumentId), IDocumentRepository {

  size_t countByRepository(TenantId tenantId, RepositoryId repositoryId) {
    return findByTenant(tenantId).filter!(e => e.repositoryId == repositoryId).count;
  }

  Document[] findByRepository(TenantId tenantId, RepositoryId repositoryId) {
    return findByTenant(tenantId).filter!(e => e.repositoryId == repositoryId).array;
  }

  void removeByRepository(TenantId tenantId, RepositoryId repositoryId) {
    findByRepository(tenantId, repositoryId).each!(e => store.remove(e.id));
  }

  size_t countByFolder(TenantId tenantId, FolderId folderId) {
    return findByFolder(tenantId, folderId).count;
  }

  Document[] findByFolder(TenantId tenantId, FolderId folderId) {
    return findByFolder(tenantId, folderId).array;
  }

  void removeByFolder(TenantId tenantId, FolderId folderId) {
    findByFolder(tenantId, folderId).each!(e => store.remove(e.id));
  }

  size_t countByStatus(TenantId tenantId, DocumentStatus status) {
    return findByStatus(tenantId, status).count;
  }

  Document[] findByStatus(TenantId tenantId, DocumentStatus status) {
    return findByStatus(tenantId, status).array;
  }

  void removeByStatus(TenantId tenantId, DocumentStatus status) {
    findByStatus(tenantId, status).each!(e => store.remove(e.id));
  }

  size_t countByName(TenantId tenantId, string name) {
    return findByName(tenantId, name).count;
  }

  Document[] findByName(TenantId tenantId, string name) {
    auto lowerName = name.toLower();
    return findByTenant(tenantId).filter!(e => e.name.toLower().canFind(lowerName)).array;
  }

  void removeByName(TenantId tenantId, string name) {
    findByName(tenantId, name).each!(e => store.remove(e.id));
  }
}
