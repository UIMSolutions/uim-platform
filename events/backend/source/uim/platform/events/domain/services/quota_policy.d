/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.domain.services.quota_policy;

import uim.platform.events;

mixin(ShowModule!());

@safe:

/// Effective limits of a messaging service: explicit values win, otherwise
/// the defaults of the plan apply.
struct ServiceQuota {
  int maxConnections;
  int maxQueues;
  int maxQueueDepth;
  long maxMessageSize;
}

ServiceQuota planDefaults(MessagingServicePlan plan) pure nothrow {
  final switch (plan) {
  case MessagingServicePlan.dev:
    return ServiceQuota(10, 10, 1_000, 64 * 1024);
  case MessagingServicePlan.standard:
    return ServiceQuota(100, 100, 100_000, 1024 * 1024);
  case MessagingServicePlan.premium:
    return ServiceQuota(1_000, 1_000, 1_000_000, 10 * 1024 * 1024);
  }
}

ServiceQuota quotaOf(const MessagingService s) pure nothrow {
  auto q = planDefaults(s.plan);
  if (s.maxConnections > 0)
    q.maxConnections = s.maxConnections;
  if (s.maxQueues > 0)
    q.maxQueues = s.maxQueues;
  if (s.maxQueueDepth > 0)
    q.maxQueueDepth = s.maxQueueDepth;
  if (s.maxMessageSize > 0)
    q.maxMessageSize = s.maxMessageSize;
  return q;
}

/// Queue depth limit: the queue's own value, capped by the service quota.
int effectiveDepth(const EventQueue q, const MessagingService s) pure nothrow {
  auto limit = quotaOf(s).maxQueueDepth;
  return q.maxDepth > 0 && q.maxDepth < limit ? q.maxDepth : limit;
}

/// Message size limit: the queue's own value, capped by the service quota.
long effectiveMessageSize(const EventQueue q, const MessagingService s) pure nothrow {
  auto limit = quotaOf(s).maxMessageSize;
  return q.maxMessageSize > 0 && q.maxMessageSize < limit ? q.maxMessageSize : limit;
}

///
unittest {
  MessagingService s;
  s.plan = MessagingServicePlan.dev;
  assert(quotaOf(s).maxQueues == 10);
  s.maxQueues = 3;
  assert(quotaOf(s).maxQueues == 3);
  EventQueue q;
  assert(effectiveDepth(q, s) == 1_000);
  q.maxDepth = 5;
  assert(effectiveDepth(q, s) == 5);
  q.maxDepth = 5_000;
  assert(effectiveDepth(q, s) == 1_000);
}
