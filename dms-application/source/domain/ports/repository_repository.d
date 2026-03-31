module domain.ports.repository_repository;

import domain.entities.repository;
import domain.types;

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
