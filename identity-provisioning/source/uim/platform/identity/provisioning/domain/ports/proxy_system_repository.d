module domain.ports.proxy_system_repository;

import domain.types;
import domain.entities.proxy_system;

interface ProxySystemRepository
{
  ProxySystem[] findByTenant(TenantId tenantId);
  ProxySystem* findById(ProxySystemId id, TenantId tenantId);
  ProxySystem* findByName(TenantId tenantId, string name);
  ProxySystem[] findBySource(SourceSystemId sourceId, TenantId tenantId);
  ProxySystem[] findByTarget(TargetSystemId targetId, TenantId tenantId);
  void save(ProxySystem entity);
  void update(ProxySystem entity);
  void remove(ProxySystemId id, TenantId tenantId);
}
