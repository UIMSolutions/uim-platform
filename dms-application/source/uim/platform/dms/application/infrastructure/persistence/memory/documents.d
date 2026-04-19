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
    string[] toRemove = findByTenant(tenantId).filter!(e => e.repositoryId == repositoryId).map!(e => e.id).array;
    foreach (k; toRemove)
      store.remove(k);
  }

  size_t countByFolder(TenantId tenantId, FolderId folderId) {
    return findByTenant(tenantId).filter!(e => e.folderId == folderId).count;
  }

  Document[] findByFolder(TenantId tenantId, FolderId folderId) {
    return findByTenant(tenantId).filter!(e => e.folderId == folderId).array;
  }

  void removeByFolder(TenantId tenantId, FolderId folderId) {
    string[] toRemove = findByTenant(tenantId).filter!(e => e.folderId == folderId).map!(e => e.id).array;
    foreach (k; toRemove)
      store.remove(k);
  }

  size_t countByStatus(TenantId tenantId, DocumentStatus status) {
    return findByTenant(tenantId).filter!(e => e.status == status).count;
  }

  Document[] findByStatus(TenantId tenantId, DocumentStatus status) {
    return findByTenant(tenantId).filter!(e => e.status == status).array;
  }

  void removeByStatus(TenantId tenantId, DocumentStatus status) {
    string[] toRemove = findByTenant(tenantId).filter!(e => e.status == status).map!(e => e.id).array;
    foreach (k; toRemove)
      store.remove(k);
  }

  Document[] findByName(TenantId tenantId, string name) {
    auto lowerName = name.toLower();
    return findByTenant(tenantId).filter!(e => e.name.toLower().canFind(lowerName)).array;
  }

  size_t countByName(TenantId tenantId, string name) {
    return findByName(tenantId, name).count;
  }
}