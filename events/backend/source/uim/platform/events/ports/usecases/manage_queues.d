/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.ports.usecases.manage_queues;

import uim.platform.events;

mixin(ShowModule!());

@safe:

interface IManageQueues {
  EventQueue[] listQueues(TenantId tenantId);
  EventQueue getQueue(TenantId tenantId, QueueId id);
  EventQueue createQueue(CreateQueueRequest request);
  EventQueue updateQueue(UpdateQueueRequest request);
  /// Refused while webhooks exist or other queues dead-letter into it; removes subscriptions, bindings and messages.
  void deleteQueue(TenantId tenantId, QueueId id);
}
