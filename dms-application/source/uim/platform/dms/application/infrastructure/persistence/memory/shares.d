/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.infrastructure.persistence.memory.shares;

// import uim.platform.dms.application.domain.entities.share;
// import uim.platform.dms.application.domain.ports.repositories.shares;
// import uim.platform.dms.application.domain.types;

import uim.platform.dms.application;

mixin(ShowModule!());

@safe:
class MemoryShareRepository : TenantRepository!(Share, ShareId), IShareRepository {
  size_t countByDocument(TenantId tenantId, DocumentId documentId) {
    return findByDocument(tenantId, documentId).length;
  }

  Share[] findByDocument(TenantId tenantId, DocumentId documentId) {
    return findByTenant(tenantId).filter!(e => e.documentId == documentId).array;
  }

  void removeByDocument(TenantId tenantId, DocumentId documentId) {
    findByDocument(tenantId, documentId).each!(e => remove(e.id));
  }

  size_t countBySharedWith(TenantId tenantId, string sharedWith) {
    return findBySharedWith(tenantId, sharedWith).length;
  }

  Share[] findBySharedWith(TenantId tenantId, string sharedWith) {
    return findByTenant(tenantId).filter!(e => e.sharedWith == sharedWith).array;
  }

  void removeBySharedWith(TenantId tenantId, string sharedWith) {
    findBySharedWith(tenantId, sharedWith).each!(e => remove(e.id));
  }

  size_t countByStatus(TenantId tenantId, ShareStatus status) {
    return findByStatus(tenantId, status).length;
  }

  Share[] findByStatus(TenantId tenantId, ShareStatus status) {
    return findByTenant(tenantId).filter!(e => e.status == status).array;
  }

  void removeByStatus(TenantId tenantId, ShareStatus status) {
    findByStatus(tenantId, status).each!(e => remove(e));
  }
}
