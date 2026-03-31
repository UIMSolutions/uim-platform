module infrastructure.persistence.in_memory_document_version_repo;

import domain.entities.document_version;
import domain.ports.document_version_repository;
import domain.types;

class InMemoryDocumentVersionRepository : IDocumentVersionRepository
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

  void save(DocumentVersion ver) { store[ver.id] = ver; }
  void update(DocumentVersion ver) { store[ver.id] = ver; }
  void remove(DocumentVersionId id, TenantId tenantId) { store.remove(id); }

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
