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
class MemoryShareRepository : IShareRepository {
  private Share[string] store;

  Share[] findByTenant(TenantId tenantId) {
    Share[] result;
    foreach (e; store)
      if (e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  Share findById(ShareId tenantId, id tenantId) {
    if (auto p = id in store)
      if ((*p).tenantId == tenantId)
        return *p;
    return null;
  }

  Share[] findByDocument(DocumentId documenttenantId, id tenantId) {
    Share[] result;
    foreach (e; store)
      if (e.tenantId == tenantId && e.documentId == documentId)
        result ~= e;
    return result;
  }

  Share[] findBySharedWith(string sharedWith, TenantId tenantId) {
    Share[] result;
    foreach (e; store)
      if (e.tenantId == tenantId && e.sharedWith == sharedWith)
        result ~= e;
    return result;
  }

  Share[] findByStatus(ShareStatus status, TenantId tenantId) {
    Share[] result;
    foreach (e; store)
      if (e.tenantId == tenantId && e.status == status)
        result ~= e;
    return result;
  }

  void save(Share share) {
    store[share.id] = share;
  }

  void update(Share share) {
    store[share.id] = share;
  }

  void remove(ShareId tenantId, id tenantId) {
    store.remove(id);
  }

  void removeByDocument(DocumentId documenttenantId, id tenantId) {
    string[] toRemove;
    foreach (k, ref e; store)
      if (e.tenantId == tenantId && e.documentId == documentId)
        toRemove ~= k;
    foreach (k; toRemove)
      store.remove(k);
  }
}
