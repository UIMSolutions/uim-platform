module infrastructure.persistence.memory.document_repo;

import uim.platform.dms_application.domain.entities.document;
import uim.platform.dms_application.domain.ports.document_repository;
import uim.platform.dms_application.domain.types;

class InMemoryDocumentRepository : IDocumentRepository {
  private Document[string] store;

  Document[] findByTenant(TenantId tenantId) {
    Document[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  Document findById(DocumentId id, TenantId tenantId) {
    if (auto p = id in store)
      if ((*p).tenantId == tenantId)
        return *p;
    return null;
  }

  Document[] findByRepository(RepositoryId repositoryId, TenantId tenantId) {
    Document[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.repositoryId == repositoryId)
        result ~= e;
    return result;
  }

  Document[] findByFolder(FolderId folderId, TenantId tenantId) {
    Document[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.folderId == folderId)
        result ~= e;
    return result;
  }

  Document[] findByStatus(DocumentStatus status, TenantId tenantId) {
    Document[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.status == status)
        result ~= e;
    return result;
  }

  Document[] findByName(string name, TenantId tenantId) {
    import std.algorithm : canFind;
    import std.uni : toLower;

    Document[] result;
    auto lowerName = name.toLower();
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.name.toLower().canFind(lowerName))
        result ~= e;
    return result;
  }

  long countByRepository(RepositoryId repositoryId, TenantId tenantId) {
    long count;
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.repositoryId == repositoryId)
        ++count;
    return count;
  }

  long countByFolder(FolderId folderId, TenantId tenantId) {
    long count;
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.folderId == folderId)
        ++count;
    return count;
  }

  void save(Document doc) {
    store[doc.id] = doc;
  }

  void update(Document doc) {
    store[doc.id] = doc;
  }

  void remove(DocumentId id, TenantId tenantId) {
    store.remove(id);
  }

  void removeByFolder(FolderId folderId, TenantId tenantId) {
    string[] toRemove;
    foreach (k, ref e; store)
      if (e.tenantId == tenantId && e.folderId == folderId)
        toRemove ~= k;
    foreach (k; toRemove)
      store.remove(k);
  }
}
