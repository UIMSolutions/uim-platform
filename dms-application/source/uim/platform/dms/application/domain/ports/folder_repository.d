module uim.platform.dms.application.domain.ports.folder_repository;

// import uim.platform.dms.application.domain.entities.folder;
// import uim.platform.dms.application.domain.types;
import uim.platform.dms.application;
mixin(ShowModule!());
@safe:
interface IFolderRepository {
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
