/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.domain.ports.usecases.queues;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

interface IManageQueuesUseCase {

    EventQueue getQueue(TenantId tenantId, QueueId id);

    EventQueue[] listQueues(TenantId tenantId);
    
    EventQueue[] listQueues(TenantId tenantId, BrokerServiceId serviceId);
    
    UsecaseResult createQueue(QueueDTO dto);
    
    UsecaseResult updateQueue(QueueDTO dto);
    
    UsecaseResult deleteQueue(TenantId tenantId, QueueId queueId);

}
