module uim.platform.identity.provisioning.domain.ports.target_system_repository;

import uim.platform.identity.provisioning.domain.types;
import uim.platform.identity.provisioning.domain.entities.target_system;

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
