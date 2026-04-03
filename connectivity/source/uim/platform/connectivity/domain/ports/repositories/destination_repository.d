module uim.platform.connectivity.domain.ports.destination_repository;

import uim.platform.connectivity.domain.entities.destination;
import uim.platform.connectivity.domain.types;

/// Port: outgoing - destination persistence.
interface DestinationRepository
{
  Destination findById(DestinationId id);
  Destination findByName(TenantId tenantId, string name);
  Destination[] findByTenant(TenantId tenantId);
  Destination[] findByProxyType(TenantId tenantId, ProxyType proxyType);
  void save(Destination dest);
  void update(Destination dest);
  void remove(DestinationId id);
}
