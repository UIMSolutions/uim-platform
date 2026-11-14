/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.domain.services.topic_router;

import uim.platform.events;

mixin(ShowModule!());

@safe:

/// Queues that receive an event: the distinct queues of all active
/// subscriptions whose pattern matches the topic (subscription order).
QueueId[] routeTopic(const QueueSubscription[] subscriptions, string topic) {
  QueueId[] targets;
  foreach (s; subscriptions)
    if (s.isActive && topicMatches(s.topicPattern, topic) && !targets.canFind(s.queueId))
      targets ~= s.queueId;
  return targets;
}

///
unittest {
  QueueSubscription a, b, c, d;
  a.queueId = QueueId("q1");
  a.topicPattern = "acme/sales/orders/*";
  b.queueId = QueueId("q2");
  b.topicPattern = "acme/sales/#";
  c.queueId = QueueId("q1");
  c.topicPattern = "acme/#";
  d.queueId = QueueId("q3");
  d.topicPattern = "acme/sales/orders/created";
  d.status = QueueSubscriptionStatus.inactive;
  assert(routeTopic([a, b, c, d], "acme/sales/orders/created") == [QueueId("q1"), QueueId("q2")]);
  assert(routeTopic([a, d], "other/x") == []);
}
