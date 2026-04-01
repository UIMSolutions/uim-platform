module infrastructure.persistence.memory.share_repo;

import  uim.platform.dms_application.domain.entities.share;
import  uim.platform.dms_application.domain.ports.share_repository;
import  uim.platform.dms_application.domain.types;

class InMemoryShareRepository : IShareRepository
{
  private Share[string] store;

  Share[] findByTenant(TenantId tenantId)
  {
    Share[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  Share findById(ShareId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if ((*p).tenantId == tenantId)
        return *p;
    return null;
  }

  Share[] findByDocument(DocumentId documentId, TenantId tenantId)
  {
    Share[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.documentId == documentId)
        result ~= e;
    return result;
  }

  Share[] findBySharedWith(string sharedWith, TenantId tenantId)
  {
    Share[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.sharedWith == sharedWith)
        result ~= e;
    return result;
  }

  Share[] findByStatus(ShareStatus status, TenantId tenantId)
  {
    Share[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.status == status)
        result ~= e;
    return result;
  }

  void save(Share share) { store[share.id] = share; }
  void update(Share share) { store[share.id] = share; }
  void remove(ShareId id, TenantId tenantId) { store.remove(id); }

  void removeByDocument(DocumentId documentId, TenantId tenantId)
  {
    string[] toRemove;
    foreach (k, ref e; store)
      if (e.tenantId == tenantId && e.documentId == documentId)
        toRemove ~= k;
    foreach (k; toRemove)
      store.remove(k);
  }
}
