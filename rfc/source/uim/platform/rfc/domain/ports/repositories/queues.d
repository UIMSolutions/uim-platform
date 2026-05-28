/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.rfc.domain.ports.repositories.queues;

import uim.platform.rfc;

mixin(ShowModule!());
@safe:

interface RfcQueueRepository {
    RfcQueueEntry   findById(TenantId tenantId, string id);
    RfcQueueEntry[] findByQueue(TenantId tenantId, QueueName queueName);
    RfcQueueEntry[] findByTid(TenantId tenantId, TidValue tid);
    RfcQueueEntry[] findPending(TenantId tenantId, QueueName queueName);
    bool            save(RfcQueueEntry entry);
    bool            update(RfcQueueEntry entry);
    bool            remove(TenantId tenantId, string id);
    size_t          countByQueue(TenantId tenantId, QueueName queueName);
}
