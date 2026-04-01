module infrastructure.persistence.memory.folder_repo;

import domain.entities.folder;
import domain.ports.folder_repository;
import domain.types;

class InMemoryFolderRepository : IFolderRepository
{
  private Folder[string] store;

  Folder[] findByTenant(TenantId tenantId)
  {
    Folder[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  Folder findById(FolderId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if ((*p).tenantId == tenantId)
        return *p;
    return null;
  }

  Folder[] findByRepository(RepositoryId repositoryId, TenantId tenantId)
  {
    Folder[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.repositoryId == repositoryId)
        result ~= e;
    return result;
  }

  Folder[] findByParent(FolderId parentFolderId, TenantId tenantId)
  {
    Folder[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.parentFolderId == parentFolderId)
        result ~= e;
    return result;
  }

  Folder findByPath(string path, RepositoryId repositoryId, TenantId tenantId)
  {
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.repositoryId == repositoryId && e.path == path)
        return e;
    return null;
  }

  void save(Folder folder) { store[folder.id] = folder; }
  void update(Folder folder) { store[folder.id] = folder; }
  void remove(FolderId id, TenantId tenantId) { store.remove(id); }

  void removeByRepository(RepositoryId repositoryId, TenantId tenantId)
  {
    string[] toRemove;
    foreach (k, ref e; store)
      if (e.tenantId == tenantId && e.repositoryId == repositoryId)
        toRemove ~= k;
    foreach (k; toRemove)
      store.remove(k);
  }
}
