module  uim.platform.dms_application.domain.ports.folder_repository;

import  uim.platform.dms_application.domain.entities.folder;
import  uim.platform.dms_application.domain.types;

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
