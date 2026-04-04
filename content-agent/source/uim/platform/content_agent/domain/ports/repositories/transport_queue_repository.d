/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.domain.ports.repositories.transport_queues;

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
