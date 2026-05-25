module uim.platform.integration_suite.infrastructure.persistence.memory.topic_subscriptions;
import uim.platform.integration_suite;

mixin(ShowModule!());

@safe:

class MemoryTopicSubscriptionRepository
    : TenantRepository!(TopicSubscription, TopicSubscriptionId),
      TopicSubscriptionRepository {

  TopicSubscription[] findByQueue(TenantId tenantId, MessageQueueId queueId) {
    import std.algorithm : filter;
    import std.array : array;
    return getAll(tenantId).filter!(s => s.queueId == queueId).array;
  }

  TopicSubscription[] findByStatus(TenantId tenantId, SubscriptionStatus status) {
    import std.algorithm : filter;
    import std.array : array;
    return getAll(tenantId).filter!(s => s.status == status).array;
  }
}
