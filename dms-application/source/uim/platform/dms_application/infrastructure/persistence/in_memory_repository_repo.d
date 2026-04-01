module infrastructure.persistence.memory.repository_repo;

import domain.entities.repository;
import domain.ports.repository_repository;
import domain.types;

class InMemoryRepositoryRepository : IRepositoryRepository
{
  private Repository[string] store;

  Repository[] findByTenant(TenantId tenantId)
  {
    Repository[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  Repository findById(RepositoryId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if ((*p).tenantId == tenantId)
        return *p;
    return null;
  }

  Repository findByName(string name, TenantId tenantId)
  {
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.name == name)
        return e;
    return null;
  }

  Repository[] findByStatus(RepositoryStatus status, TenantId tenantId)
  {
    Repository[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.status == status)
        result ~= e;
    return result;
  }

  void save(Repository repo) { store[repo.id] = repo; }
  void update(Repository repo) { store[repo.id] = repo; }
  void remove(RepositoryId id, TenantId tenantId) { store.remove(id); }
}
