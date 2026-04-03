module uim.platform.dms.application.infrastructure.persistence.memory.document_version_repo;

// import uim.platform.dms.application.domain.entities.document_version;
// import uim.platform.dms.application.domain.ports.document_version_repository;
// import uim.platform.dms.application.domain.types;

import uim.platform.dms.application;

mixin(ShowModule!());
@safe:

class MemoryDocumentVersionRepository : IDocumentVersionRepository
{
  private DocumentVersion[string] store;

  DocumentVersion[] findByTenant(TenantId tenantId)
  {
    DocumentVersion[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  DocumentVersion findById(DocumentVersionId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if ((*p).tenantId == tenantId)
        return *p;
    return null;
  }

  DocumentVersion[] findByDocument(DocumentId documentId, TenantId tenantId)
  {
    DocumentVersion[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.documentId == documentId)
        result ~= e;
    return result;
  }

  DocumentVersion findLatest(DocumentId documentId, TenantId tenantId)
  {
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.documentId == documentId && e.status == VersionStatus.current)
        return e;
    return null;
  }

  long countByDocument(DocumentId documentId, TenantId tenantId)
  {
    long count;
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.documentId == documentId)
        ++count;
    return count;
  }

  void save(DocumentVersion ver)
  {
    store[ver.id] = ver;
  }

  void update(DocumentVersion ver)
  {
    store[ver.id] = ver;
  }

  void remove(DocumentVersionId id, TenantId tenantId)
  {
    store.remove(id);
  }

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
