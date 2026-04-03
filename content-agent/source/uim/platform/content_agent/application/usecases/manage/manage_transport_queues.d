module uim.platform.content_agent.application.usecases.manage_transport_queues;

import uim.platform.content_agent.application.dto;
import uim.platform.content_agent.domain.entities.transport_queue;
import uim.platform.content_agent.domain.entities.content_activity;
import uim.platform.content_agent.domain.ports.transport_queue_repository;
import uim.platform.content_agent.domain.ports.content_activity_repository;
import uim.platform.content_agent.domain.types;

// import std.conv : to;

/// Application service for transport queue configuration.
class ManageTransportQueuesUseCase
{
  private TransportQueueRepository queueRepo;
  private ContentActivityRepository activityRepo;

  this(TransportQueueRepository queueRepo, ContentActivityRepository activityRepo)
  {
    this.queueRepo = queueRepo;
    this.activityRepo = activityRepo;
  }

  CommandResult createQueue(CreateQueueRequest req)
  {
    auto existing = queueRepo.findByName(req.tenantId, req.name);
    if (existing.id.length > 0)
      return CommandResult(false, "", "Queue with name '" ~ req.name ~ "' already exists");

    if (req.name.length == 0)
      return CommandResult(false, "", "Queue name is required");

    // import std.uuid : randomUUID;
    auto id = randomUUID().toString();

    TransportQueue queue;
    queue.id = id;
    queue.tenantId = req.tenantId;
    queue.name = req.name;
    queue.description = req.description;
    queue.queueType = parseQueueType(req.queueType);
    queue.endpoint = req.endpoint;
    queue.authToken = req.authToken;
    queue.isDefault = req.isDefault;
    queue.createdBy = req.createdBy;
    queue.createdAt = clockSeconds();
    queue.updatedAt = queue.createdAt;

    queueRepo.save(queue);
    recordActivity(req.tenantId, ActivityType.queueConfigured, id, req.name,
        "Transport queue configured", req.createdBy);

    return CommandResult(true, id, "");
  }

  CommandResult updateQueue(TransportQueueId id, UpdateQueueRequest req)
  {
    auto queue = queueRepo.findById(id);
    if (queue.id.length == 0)
      return CommandResult(false, "", "Queue not found");

    if (req.description.length > 0)
      queue.description = req.description;
    if (req.endpoint.length > 0)
      queue.endpoint = req.endpoint;
    if (req.authToken.length > 0)
      queue.authToken = req.authToken;
    queue.isDefault = req.isDefault;
    queue.updatedAt = clockSeconds();

    queueRepo.update(queue);
    return CommandResult(true, id, "");
  }

  CommandResult deleteQueue(TransportQueueId id)
  {
    auto queue = queueRepo.findById(id);
    if (queue.id.length == 0)
      return CommandResult(false, "", "Queue not found");

    queueRepo.remove(id);
    return CommandResult(true, id, "");
  }

  TransportQueue getQueue(TransportQueueId id)
  {
    return queueRepo.findById(id);
  }

  TransportQueue[] listQueues(TenantId tenantId)
  {
    return queueRepo.findByTenant(tenantId);
  }

  TransportQueue getDefaultQueue(TenantId tenantId)
  {
    return queueRepo.findDefault(tenantId);
  }

  private void recordActivity(TenantId tenantId, ActivityType actType,
      string entityId, string entityName, string desc, string by)
  {
    // import std.uuid : randomUUID;
    ContentActivity activity;
    activity.id = randomUUID().toString();
    activity.tenantId = tenantId;
    activity.activityType = actType;
    activity.severity = ActivitySeverity.info;
    activity.entityId = entityId;
    activity.entityName = entityName;
    activity.description = desc;
    activity.performedBy = by;
    activity.timestamp = clockSeconds();
    activityRepo.save(activity);
  }

  private static long clockSeconds()
  {
    // import std.datetime.systime : Clock;
    return Clock.currTime().toUnixTime();
  }

  private static QueueType parseQueueType(string s)
  {
    switch (s)
    {
    case "ctsPlus":
      return QueueType.ctsPlus;
    case "local":
      return QueueType.local;
    default:
      return QueueType.cloudTMS;
    }
  }
}
