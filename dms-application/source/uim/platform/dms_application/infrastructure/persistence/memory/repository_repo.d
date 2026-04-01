module infrastructure.persistence.memory.repository_repo;

// import uim.platform.dms_application.domain.entities.repository;
// import uim.platform.dms_application.domain.ports.repository_repository;
// import uim.platform.dms_application.domain.types;

import uim.platform.dms_application;
mixin(ShowModule!());
@safe:
class MemoryRepositoryRepository : IRepositoryRepository {
  private Repository[string] store;

  Repository[] findByTenant(TenantId tenantId) {
    Repository[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  Repository findById(RepositoryId id, TenantId tenantId) {
    if (auto p = id in store)
      if ((*p).tenantId == tenantId)
        return *p;
    return null;
  }

  Repository findByName(string name, TenantId tenantId) {
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.name == name)
        return e;
    return null;
  }

  Repository[] findByStatus(RepositoryStatus status, TenantId tenantId) {
    Repository[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.status == status)
        result ~= e;
    return result;
  }

  void save(Repository repo) {
    store[repo.id] = repo;
  }

  void update(Repository repo) {
    store[repo.id] = repo;
  }

  void remove(RepositoryId id, TenantId tenantId) {
    store.remove(id);
  }
}
