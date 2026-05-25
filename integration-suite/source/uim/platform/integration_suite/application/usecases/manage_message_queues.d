module uim.platform.integration_suite.application.usecases.manage_message_queues;
import uim.platform.integration_suite;
import std.conv : to;
mixin(ShowModule!());
@safe:

class ManageMessageQueuesUseCase {
private:
  MessageQueueRepository _repo;

public:
  this(MessageQueueRepository repo) { _repo = repo; }

  CommandResult create(CreateQueueRequest req) {
    auto q = MessageQueue();
    initEntity(q, req.tenantId, req.id);
    q.name                = req.name;
    q.description         = req.description;
    q.status              = QueueStatus.active;
    q.maxMessageSize      = req.maxMessageSize;
    q.maxQueueSize        = req.maxQueueSize;
    q.retentionPeriod     = req.retentionPeriod;
    q.deadLetterQueue     = req.deadLetterQueue;
    q.deadLetterQueueName = req.deadLetterQueueName;
    q.metadata            = req.metadata;
    auto err = IntegrationValidator.validateMessageQueue(q);
    if (err !is null) return CommandResult(false, err);
    _repo.add(getTenantId(req.tenantId), q);
    return CommandResult(true, q.toJson());
  }

  CommandResult getAll(string tenantId) {
    auto items = _repo.getAll(getTenantId(tenantId));
    auto arr = Json.emptyArray;
    foreach (q; items) arr ~= q.toJson();
    return CommandResult(true, arr);
  }

  CommandResult getById(string tenantId, string id) {
    auto q = _repo.getById(getTenantId(tenantId), MessageQueueId(id));
    if (q.isNull) return CommandResult(false, "Queue not found");
    return CommandResult(true, q.toJson());
  }

  CommandResult update(UpdateQueueRequest req) {
    auto q = _repo.getById(getTenantId(req.tenantId), MessageQueueId(req.id));
    if (q.isNull) return CommandResult(false, "Queue not found");
    if (req.status.length > 0)    q.status          = req.status.to!QueueStatus;
    if (req.maxMessageSize != 0)  q.maxMessageSize   = req.maxMessageSize;
    if (req.maxQueueSize != 0)    q.maxQueueSize     = req.maxQueueSize;
    if (req.retentionPeriod != 0) q.retentionPeriod  = req.retentionPeriod;
    foreach (k, v; req.metadata)  q.metadata[k]      = v;
    _repo.update(getTenantId(req.tenantId), q);
    return CommandResult(true, q.toJson());
  }

  CommandResult remove(string tenantId, string id) {
    auto q = _repo.getById(getTenantId(tenantId), MessageQueueId(id));
    if (q.isNull) return CommandResult(false, "Queue not found");
    _repo.remove(getTenantId(tenantId), MessageQueueId(id));
    return CommandResult(true, "Queue deleted");
  }
}
