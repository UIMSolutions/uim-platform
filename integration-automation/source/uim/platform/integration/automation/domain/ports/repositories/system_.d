module uim.platform.xyz.domain.ports.repositories.system_;

import uim.platform.xyz.domain.types;
import uim.platform.xyz.domain.entities.system_connection;

/// Port for persisting and querying system connections.
interface SystemRepository
{
  SystemConnection[] findByTenant(TenantId tenantId);
  SystemConnection* findById(SystemId id, TenantId tenantId);
  SystemConnection[] findByType(TenantId tenantId, SystemType systemType);
  SystemConnection[] findByStatus(TenantId tenantId, ConnectionStatus status);
  void save(SystemConnection system);
  void update(SystemConnection system);
  void remove(SystemId id, TenantId tenantId);
}
