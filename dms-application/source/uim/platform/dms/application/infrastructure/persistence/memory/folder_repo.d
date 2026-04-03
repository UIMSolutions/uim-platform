module uim.platform.dms.application.infrastructure.persistence.memory.folder_repo;

// import uim.platform.dms.application.domain.entities.folder;
// import uim.platform.dms.application.domain.ports.folder_repository;
// import uim.platform.dms.application.domain.types;

import uim.platform.dms.application;
mixin(ShowModule!());
@safe:
class MemoryFolderRepository : IFolderRepository {
  private Folder[string] store;

  Folder[] findByTenant(TenantId tenantId) {
    Folder[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  Folder findById(FolderId id, TenantId tenantId) {
    if (auto p = id in store)
      if ((*p).tenantId == tenantId)
        return *p;
    return null;
  }

  Folder[] findByRepository(RepositoryId repositoryId, TenantId tenantId) {
    Folder[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.repositoryId == repositoryId)
        result ~= e;
    return result;
  }

  Folder[] findByParent(FolderId parentFolderId, TenantId tenantId) {
    Folder[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.parentFolderId == parentFolderId)
        result ~= e;
    return result;
  }

  Folder findByPath(string path, RepositoryId repositoryId, TenantId tenantId) {
    foreach (ref e; store)
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

  void remove(FolderId id, TenantId tenantId) {
    store.remove(id);
  }

  void removeByRepository(RepositoryId repositoryId, TenantId tenantId) {
    string[] toRemove;
    foreach (k, ref e; store)
      if (e.tenantId == tenantId && e.repositoryId == repositoryId)
        toRemove ~= k;
    foreach (k; toRemove)
      store.remove(k);
  }
}
