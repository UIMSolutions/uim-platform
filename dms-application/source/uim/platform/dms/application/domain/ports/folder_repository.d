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
interface IFolderRepository
{
  Folder[] findByTenant(TenantId tenantId);
  Folder findById(FolderId id, TenantId tenantId);
  Folder[] findByRepository(RepositoryId repositoryId, TenantId tenantId);
  Folder[] findByParent(FolderId parentFolderId, TenantId tenantId);
  Folder findByPath(string path, RepositoryId repositoryId, TenantId tenantId);
  void save(Folder folder);
  void update(Folder folder);
  void remove(FolderId id, TenantId tenantId);
  void removeByRepository(RepositoryId repositoryId, TenantId tenantId);
}
