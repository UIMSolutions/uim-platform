/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.ports.usecases.manage_queue_subscriptions;

import uim.platform.events;

mixin(ShowModule!());

@safe:

interface IManageQueueSubscriptions {
  QueueSubscription[] listQueueSubscriptions(TenantId tenantId);
  QueueSubscription getQueueSubscription(TenantId tenantId, QueueSubscriptionId id);
  QueueSubscription createQueueSubscription(CreateQueueSubscriptionRequest request);
  QueueSubscription updateQueueSubscription(UpdateQueueSubscriptionRequest request);
  /// Stops routing into the queue.
  void deleteQueueSubscription(TenantId tenantId, QueueSubscriptionId id);
}
