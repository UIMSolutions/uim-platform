module uim.platform.integration_suite.infrastructure.persistence.repositories.message_queues;
import uim.platform.integration_suite;

mixin(ShowModule!());

@safe:

class MemoryMessageQueueRepository
    : TenantRepository!(MessageQueue, MessageQueueId),
      MessageQueueRepository {

  MessageQueue[] findByStatus(TenantId tenantId, QueueStatus status) {
    import std.algorithm : filter;
    import std.array : array;
    return getAll(tenantId).filter!(q => q.status == status).array;
  }
}
