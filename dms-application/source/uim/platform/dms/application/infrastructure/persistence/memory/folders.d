/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.infrastructure.persistence.memory.folders;

// import uim.platform.dms.application.domain.entities.folder;
// import uim.platform.dms.application.domain.ports.repositories.folders;
// import uim.platform.dms.application.domain.types;

import uim.platform.dms.application;

mixin(ShowModule!());
@safe:
class MemoryFolderRepository : TenantRepository!(Folder, FolderId), IFolderRepository {
  Folder findByPath(TenantId tenantId, string path, RepositoryId repositoryId) {
    foreach (e; findByTenant(tenantId))
      if (e.repositoryId == repositoryId && e.path == path)
        return e;
    return Folder.init;
  }

  Folder[] findByRepository(TenantId tenantId, RepositoryId repositoryId) {
    return findByTenant(tenantId).filter!(e => e.repositoryId == repositoryId).array;
  }

  Folder[] findByParent(TenantId tenantId, FolderId parentFolderId) {
    return findByTenant(tenantId).filter!(e => e.parentFolderId == parentFolderId).array;
  }

  void save(Folder folder) {
    store[folder.id] = folder;
  }

  void update(Folder folder) {
    store[folder.id] = folder;
  }

  void remove(TenantId tenantId, FolderId id) {
    if (auto p = id in store)
      if ((*p).tenantId == tenantId)
        store.remove(id);
  }

  void removeByRepository(TenantId tenantId, RepositoryId repositoryId) {
    string[] toRemove;
    foreach (k, ref e; store)
      if (e.tenantId == tenantId && e.repositoryId == repositoryId)
        toRemove ~= k;
    foreach (k; toRemove)
      store.remove(k);
  }
}
