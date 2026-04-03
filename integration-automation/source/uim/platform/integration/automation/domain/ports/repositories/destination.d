module uim.platform.integration.automation.domain.ports.repositories.destination;

import uim.platform.integration.automation.domain.types;
import uim.platform.integration.automation.domain.entities.destination;

/// Port for persisting and querying destinations.
interface DestinationRepository
{
  Destination[] findByTenant(TenantId tenantId);
  Destination* findById(DestinationId id, TenantId tenantId);
  Destination[] findBySystem(TenantId tenantId, SystemId systemId);
  Destination* findByName(TenantId tenantId, string name);
  Destination[] findEnabled(TenantId tenantId);
  void save(Destination destination);
  void update(Destination destination);
  void remove(DestinationId id, TenantId tenantId);
}
