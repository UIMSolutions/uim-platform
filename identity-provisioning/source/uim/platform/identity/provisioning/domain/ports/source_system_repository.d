module uim.platform.xyz.domain.ports.source_system_repository;

import uim.platform.xyz.domain.types;
import uim.platform.xyz.domain.entities.source_system;

interface SourceSystemRepository
{
  SourceSystem[] findByTenant(TenantId tenantId);
  SourceSystem* findById(SourceSystemId id, TenantId tenantId);
  SourceSystem* findByName(TenantId tenantId, string name);
  SourceSystem[] findByType(TenantId tenantId, SystemType systemType);
  SourceSystem[] findByStatus(TenantId tenantId, SystemStatus status);
  void save(SourceSystem entity);
  void update(SourceSystem entity);
  void remove(SourceSystemId id, TenantId tenantId);
}
