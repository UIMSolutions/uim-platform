/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.infrastructure.persistence.memory.document_repo;

// import uim.platform.dms.application.domain.entities.document;
// import uim.platform.dms.application.domain.ports.repositories.documents;
// import uim.platform.dms.application.domain.types;

import uim.platform.dms.application;

mixin(ShowModule!());
@safe:

class MemoryDocumentRepository : IDocumentRepository
{
  private Document[string] store;

  Document[] findByTenant(TenantId tenantId)
  {
    Document[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  Document findById(DocumentId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if ((*p).tenantId == tenantId)
        return *p;
    return null;
  }

  Document[] findByRepository(RepositoryId repositoryId, TenantId tenantId)
  {
    Document[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.repositoryId == repositoryId)
        result ~= e;
    return result;
  }

  Document[] findByFolder(FolderId folderId, TenantId tenantId)
  {
    Document[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.folderId == folderId)
        result ~= e;
    return result;
  }

  Document[] findByStatus(DocumentStatus status, TenantId tenantId)
  {
    Document[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.status == status)
        result ~= e;
    return result;
  }

  Document[] findByName(string name, TenantId tenantId)
  {
    // import std.algorithm : canFind;
    // import std.uni : toLower;

    Document[] result;
    auto lowerName = name.toLower();
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.name.toLower().canFind(lowerName))
        result ~= e;
    return result;
  }

  long countByRepository(RepositoryId repositoryId, TenantId tenantId)
  {
    long count;
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.repositoryId == repositoryId)
        ++count;
    return count;
  }

  long countByFolder(FolderId folderId, TenantId tenantId)
  {
    long count;
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.folderId == folderId)
        ++count;
    return count;
  }

  void save(Document doc)
  {
    store[doc.id] = doc;
  }

  void update(Document doc)
  {
    store[doc.id] = doc;
  }

  void remove(DocumentId id, TenantId tenantId)
  {
    store.remove(id);
  }

  void removeByFolder(FolderId folderId, TenantId tenantId)
  {
    string[] toRemove;
    foreach (k, ref e; store)
      if (e.tenantId == tenantId && e.folderId == folderId)
        toRemove ~= k;
    foreach (k; toRemove)
      store.remove(k);
  }
}
