/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.domain.ports.repositories.folders;

// import uim.platform.dms.application.domain.entities.folder;
// import uim.platform.dms.application.domain.types;
import uim.platform.dms.application;

mixin(ShowModule!());
@safe:
interface IFolderRepository : ITenantRepository!(Folder, FolderId) {
  bool existsByPath(TenantId tenantId, RepositoryId repositoryId, string path);
  Folder findByPath(TenantId tenantId, RepositoryId repositoryId, string path);
  void removeByPath(TenantId tenantId, RepositoryId repositoryId, string path);
  
  size_t countByRepository(TenantId tenantId, RepositoryId repositoryId);
  Folder[] findByRepository(TenantId tenantId, RepositoryId repositoryId);
  void removeByRepository(TenantId tenantId, RepositoryId repositoryId);

  size_t countByParent(TenantId tenantId, FolderId parentFolderId);
  Folder[] findByParent(TenantId tenantId, FolderId parentFolderId);
  void removeByParent(TenantId tenantId, FolderId parentFolderId);
}
