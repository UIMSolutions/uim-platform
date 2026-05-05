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
  bool existsByPath(TenantId tenantId, RepositoryId repositoryId, string path) {
    return findByTenant(tenantId).any!(e => e.repositoryId == repositoryId && e.path == path);
  }

  Folder findByPath(TenantId tenantId, RepositoryId repositoryId, string path) {
    foreach (e; findByTenant(tenantId))
      if (e.repositoryId == repositoryId && e.path == path)
        return e;
    return Folder.init;
  }

  void removeByPath(TenantId tenantId, RepositoryId repositoryId, string path) {
    foreach (e; findByTenant(tenantId))
      if (e.repositoryId == repositoryId && e.path == path)
        remove(e.id);
  }

  size_t countByRepository(TenantId tenantId, RepositoryId repositoryId) {
    return findByRepository(tenantId, repositoryId).length;
  }

  Folder[] findByRepository(TenantId tenantId, RepositoryId repositoryId) {
    return findByTenant(tenantId).filter!(e => e.repositoryId == repositoryId).array;
  }

  void removeByRepository(TenantId tenantId, RepositoryId repositoryId) {
    findByRepository(tenantId, repositoryId).each!(e => remove(e.id));
  }

  size_t countByParent(TenantId tenantId, FolderId parentFolderId) {
    return findByParent(tenantId, parentFolderId).length;
  }

  Folder[] findByParent(TenantId tenantId, FolderId parentFolderId) {
    return findByTenant(tenantId).filter!(e => e.parentFolderId == parentFolderId).array;
  }

  void removeByParent(TenantId tenantId, FolderId parentFolderId) {
    findByParent(tenantId, parentFolderId).each!(e => remove(e.id));
  }
}
