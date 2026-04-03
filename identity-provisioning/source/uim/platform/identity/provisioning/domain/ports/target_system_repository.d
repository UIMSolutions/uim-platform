module uim.platform.xyz.domain.ports.target_system_repository;

import uim.platform.xyz.domain.types;
import uim.platform.xyz.domain.entities.target_system;

interface TargetSystemRepository
{
  TargetSystem[] findByTenant(TenantId tenantId);
  TargetSystem* findById(TargetSystemId id, TenantId tenantId);
  TargetSystem* findByName(TenantId tenantId, string name);
  TargetSystem[] findByType(TenantId tenantId, SystemType systemType);
  TargetSystem[] findByStatus(TenantId tenantId, SystemStatus status);
  void save(TargetSystem entity);
  void update(TargetSystem entity);
  void remove(TargetSystemId id, TenantId tenantId);
}
