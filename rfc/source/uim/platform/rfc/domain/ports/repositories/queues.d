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
    RfcQueueEntry   findById(string tenantId, string id);
    RfcQueueEntry[] findByQueue(string tenantId, QueueName queueName);
    RfcQueueEntry[] findByTid(string tenantId, TidValue tid);
    RfcQueueEntry[] findPending(string tenantId, QueueName queueName);
    bool            save(RfcQueueEntry entry);
    bool            update(RfcQueueEntry entry);
    bool            remove(string tenantId, string id);
    size_t          countByQueue(string tenantId, QueueName queueName);
}
