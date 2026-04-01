module domain.ports.folder_repository;

import domain.entities.folder;
import domain.types;

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
