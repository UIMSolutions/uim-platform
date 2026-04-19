/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.application.usecases.manage.transport_queues;

import uim.platform.content_agent.application.dto;
import uim.platform.content_agent.domain.entities.transport_queue;
import uim.platform.content_agent.domain.entities.content_activity;
import uim.platform.content_agent.domain.ports.repositories.transport_queues;
import uim.platform.content_agent.domain.ports.repositories.content_activitys;
import uim.platform.content_agent.domain.types;

// import std.conv : to;

/// Application service for transport queue configuration.
class ManageTransportQueuesUseCase { // TODO: UIMUseCase {
  private TransportQueueRepository queueRepo;
  private ContentActivityRepository activityRepo;

  this(TransportQueueRepository queueRepo, ContentActivityRepository activityRepo) {
    this.queueRepo = queueRepo;
    this.activityRepo = activityRepo;
  }

  CommandResult createQueue(CreateQueueRequest req) {
    auto existing = queueRepo.findByName(req.tenantId, req.name);
    if (existing.id.length > 0)
      return CommandResult(false, "", "Queue with name '" ~ req.name ~ "' already exists");

    if (req.name.length == 0)
      return CommandResult(false, "", "Queue name is required");

    TransportQueue queue;
    queue.id = randomUUID();
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

    return CommandResult(true, id.toString, "");
  }

  CommandResult updateQueue(TransportQueueId id, UpdateQueueRequest req) {
    auto queue = queueRepo.findById(id);
    if (queue.id.isEmpty)
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
    return CommandResult(true, id.toString, "");
  }

  CommandResult deleteQueue(TransportQueueId id) {
    auto queue = queueRepo.findById(id);
    if (queue.id.isEmpty)
      return CommandResult(false, "", "Queue not found");

    queueRepo.remove(id);
    return CommandResult(true, id.toString, "");
  }

  TransportQueue getQueue(TransportQueueId id) {
    return queueRepo.findById(id);
  }

  TransportQueue[] listQueues(TenantId tenantId) {
    return queueRepo.findByTenant(tenantId);
  }

  TransportQueue getDefaultQueue(TenantId tenantId) {
    return queueRepo.findDefault(tenantId);
  }

  private void recordActivity(TenantId tenantId, ActivityType actType,
      string entityId, string entityName, string desc, string by) {
    // import std.uuid : randomUUID;
    ContentActivity activity;
    activity.id = randomUUID();
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

  

  private static QueueType parseQueueType(string s) {
    switch (s) {
    case "ctsPlus":
      return QueueType.ctsPlus;
    case "local":
      return QueueType.local;
    default:
      return QueueType.cloudTMS;
    }
  }
}
