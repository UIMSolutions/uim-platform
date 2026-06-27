module uim.platform.integration_suite.domain.ports.repositories.topic_subscriptions;
import uim.platform.integration_suite;
@safe:
interface TopicSubscriptionRepository : ITenantRepository!(TopicSubscription, TopicSubscriptionId) {
  TopicSubscription[] findByQueue(TenantId tenantId, MessageQueueId queueId);
  TopicSubscription[] findByStatus(TenantId tenantId, SubscriptionStatus status);
}
