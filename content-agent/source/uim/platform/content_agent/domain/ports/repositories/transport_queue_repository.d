module uim.platform.content_agent.domain.ports.transport_queue_repository;

import uim.platform.content_agent.domain.entities.transport_queue;
import uim.platform.content_agent.domain.types;

/// Port: outgoing - transport queue persistence.
interface TransportQueueRepository
{
  TransportQueue findById(TransportQueueId id);
  TransportQueue[] findByTenant(TenantId tenantId);
  TransportQueue findDefault(TenantId tenantId);
  TransportQueue findByName(TenantId tenantId, string name);
  void save(TransportQueue queue);
  void update(TransportQueue queue);
  void remove(TransportQueueId id);
}
