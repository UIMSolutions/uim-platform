module uim.platform.destination.domain.ports.destination_repository;

import uim.platform.destination.domain.entities.destination;
import uim.platform.destination.domain.types;

/// Port: outgoing — destination configuration persistence.
interface DestinationRepository
{
  Destination findById(DestinationId id);
  Destination findByName(TenantId tenantId, SubaccountId subaccountId, string name);
  Destination[] findByTenant(TenantId tenantId);
  Destination[] findBySubaccount(TenantId tenantId, SubaccountId subaccountId);
  Destination[] findByServiceInstance(TenantId tenantId, ServiceInstanceId instanceId);
  Destination[] findByLevel(TenantId tenantId, SubaccountId subaccountId, DestinationLevel level);
  void save(Destination dest);
  void update(Destination dest);
  void remove(DestinationId id);
}
