/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.domain.ports.usecases.transport_queues;

import uim.platform.content_agent;

mixin(ShowModule!());

@safe:

/// Interface for managing transport queues in the content agent domain.
interface IManageTransportQueuesUseCase { 

  UsecaseResult createQueue(CreateQueueRequest req);
  UsecaseResult updateQueue(UpdateQueueRequest req);
  UsecaseResult deleteQueue(TenantId tenantId, TransportQueueId id);
  TransportQueue getQueue(TenantId tenantId, TransportQueueId id);
  TransportQueue[] listQueues(TenantId tenantId);
  TransportQueue getDefaultQueue(TenantId tenantId);

}
