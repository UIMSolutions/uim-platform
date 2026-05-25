module uim.platform.integration_suite.domain.ports.repositories.message_queues;
import uim.platform.integration_suite;
@safe:
interface MessageQueueRepository : ITenantRepository!(MessageQueue, MessageQueueId) {
  MessageQueue[] findByStatus(TenantId tenantId, QueueStatus status);
}
