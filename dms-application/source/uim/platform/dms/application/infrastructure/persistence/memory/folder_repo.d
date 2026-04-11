/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.infrastructure.persistence.memory.folder;

// import uim.platform.dms.application.domain.entities.folder;
// import uim.platform.dms.application.domain.ports.repositories.folders;
// import uim.platform.dms.application.domain.types;

import uim.platform.dms.application;

mixin(ShowModule!());
@safe:
class MemoryFolderRepository : IFolderRepository {
  private Folder[string] store;

  Folder[] findByTenant(TenantId tenantId) {
    Folder[] result;
    foreach (e; store)
      if (e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  Folder findById(FolderId tenantId, id tenantId) {
    if (auto p = id in store)
      if ((*p).tenantId == tenantId)
        return *p;
    return null;
  }

  Folder[] findByRepository(RepositoryId repositorytenantId, id tenantId) {
    Folder[] result;
    foreach (e; store)
      if (e.tenantId == tenantId && e.repositoryId == repositoryId)
        result ~= e;
    return result;
  }

  Folder[] findByParent(FolderId parentFoldertenantId, id tenantId) {
    Folder[] result;
    foreach (e; store)
      if (e.tenantId == tenantId && e.parentFolderId == parentFolderId)
        result ~= e;
    return result;
  }

  Folder findByPath(string path, RepositoryId repositorytenantId, id tenantId) {
    foreach (e; store)
      if (e.tenantId == tenantId && e.repositoryId == repositoryId && e.path == path)
        return e;
    return null;
  }

  void save(Folder folder) {
    store[folder.id] = folder;
  }

  void update(Folder folder) {
    store[folder.id] = folder;
  }

  void remove(FolderId tenantId, id tenantId) {
    store.remove(id);
  }

  void removeByRepository(RepositoryId repositorytenantId, id tenantId) {
    string[] toRemove;
    foreach (k, ref e; store)
      if (e.tenantId == tenantId && e.repositoryId == repositoryId)
        toRemove ~= k;
    foreach (k; toRemove)
      store.remove(k);
  }
}
