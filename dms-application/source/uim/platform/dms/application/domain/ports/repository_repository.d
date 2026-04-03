module uim.platform.dms.application.domain.ports.repository_repository;

// import uim.platform.dms.application.domain.entities.repository;
// import uim.platform.dms.application.domain.types;

import uim.platform.dms.application;

mixin(ShowModule!());
@safe:
interface IRepositoryRepository
{
  Repository[] findByTenant(TenantId tenantId);
  Repository findById(RepositoryId id, TenantId tenantId);
  Repository findByName(string name, TenantId tenantId);
  Repository[] findByStatus(RepositoryStatus status, TenantId tenantId);
  void save(Repository repo);
  void update(Repository repo);
  void remove(RepositoryId id, TenantId tenantId);
}
