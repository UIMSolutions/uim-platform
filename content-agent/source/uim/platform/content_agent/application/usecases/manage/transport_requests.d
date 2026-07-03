/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.application.usecases.manage.transport_requests;


// import uim.platform.content_agent.domain.entities.transport_request;
// import uim.platform.content_agent.domain.entities.content_package;
// import uim.platform.content_agent.domain.entities.transport_queue;
// import uim.platform.content_agent.domain.entities.content_activity;
// import uim.platform.content_agent.domain.ports.repositories.transport_requests;
// import uim.platform.content_agent.domain.ports.repositories.content_packages;
// import uim.platform.content_agent.domain.ports.repositories.transport_queues;
// import uim.platform.content_agent.domain.ports.repositories.content_activitys;
// import uim.platform.content_agent.domain.services.transport_validator;

import uim.platform.content_agent;

// mixin(ShowModule!());

@safe:
/// Application service for transport request lifecycle management.
class ManageTransportRequestsUseCase { // TODO: UIMUseCase {
  private TransportRequestRepository requestRepo;
  private ContentPackageRepository packageRepo;
  private TransportQueueRepository queueRepo;
  private ContentActivityRepository activityRepo;

  this(TransportRequestRepository requestRepo, ContentPackageRepository packageRepo,
    TransportQueueRepository queueRepo, ContentActivityRepository activityRepo) {
    this.requestRepo = requestRepo;
    this.packageRepo = packageRepo;
    this.queueRepo = queueRepo;
    this.activityRepo = activityRepo;
  }

  CommandResult createTransportRequest(CreateTransportRequest req) {
    if (req.packageIds.length == 0)
      return CommandResult(false, "", "At least one package is required");

    // Resolve packages
    ContentPackage[] packages;
    foreach (pid; req.packageIds) {
      auto pkg = packageRepo.findById(req.tenantId, pid);
      if (pkg.isNull)
        return CommandResult(false, "", "Package not found: " ~ pid.value);

      packages ~= pkg;
    }

    // Resolve queue
    TransportQueue queue = req.queueId.isNull
      ? queueRepo.findDefault(req.tenantId)
      : queueRepo.findById(req.queueId);

    auto tr = TransportRequest(req.tenantId, req.requestId.isNull ? TransportRequestId(createId()) : req.requestId, req.createdBy);
    tr.sourceSubaccount = req.sourceSubaccount;
    tr.targetSubaccount = req.targetSubaccount;
    tr.description = req.description;
    tr.mode = req.mode.to!TransportMode;
    tr.packageIds = req.packageIds;
    tr.queueId = queue.id;
    tr.status = TransportStatus.created;

    // Validate transport
    auto validation = TransportValidator.validate(tr, packages, queue);
    if (!validation.valid) {
      string msg = "Transport validation failed: ";
      foreach (i, e; validation.errors) {
        if (i > 0)
          msg ~= "; ";
        msg ~= e;
      }
      return CommandResult(false, "", msg);
    }

    requestRepo.save(tr);
    recordActivity(req.tenantId, ActivityType.transportCreated, tr.id.value,
      req.description, "Transport request created", req.createdBy.value);

    return CommandResult(true, tr.id.value, "");
  }

  CommandResult releaseTransport(ReleaseTransportRequest req) {
    auto tr = requestRepo.findById(req.tenantId, req.requestId);
    if (tr.isNull)
      return CommandResult(false, "", "Transport request not found");

    if (tr.status != TransportStatus.created && tr.status != TransportStatus.readyForExport)
      return CommandResult(false, "", "Transport request is not in a releasable state");

    tr.status = TransportStatus.released;
    tr.releasedAt = currentTimestamp;
    tr.updatedAt = tr.releasedAt;

    requestRepo.update(tr);
    recordActivity(req.tenantId, ActivityType.transportReleased, tr.id.value,
      tr.description, "Transport released", req.releasedBy.value);

    return CommandResult(true, tr.id.value, "");
  }

  CommandResult cancelTransport(TenantId tenantId, TransportRequestId requestId) {
    auto tr = requestRepo.findById(tenantId, requestId);
    if (tr.isNull)
      return CommandResult(false, "", "Transport request not found");

    tr.status = TransportStatus.cancelled;
    tr.updatedAt = clockSeconds();
    requestRepo.update(tr);

    return CommandResult(true, tr.id.value, "");
  }

  TransportRequest getTransportRequest(TenantId tenantId, TransportRequestId id) {
    return requestRepo.findById(tenantId, id);
  }

  TransportRequest[] listTransportRequests(TenantId tenantId) {
    return requestRepo.findByTenant(tenantId);
  }

  TransportRequest[] listByStatus(TenantId tenantId, string statusStr) {
    auto status = statusStr.to!TransportStatus;
    return requestRepo.findByStatus(tenantId, status);
  }

  private CommandResult recordActivity(TenantId tenantId, ActivityType actType,
    string entityId, string entityName, string desc, string by) {
   
    auto activity = ContentActivity(tenantId);
    activity.activityType = actType;
    activity.severity = ActivitySeverity.info;
    activity.entityId = entityId;
    activity.entityName = entityName;
    activity.description = desc;
    activity.performedBy = by;
    activity.timestamp = activity.createdAt;

    activityRepo.save(activity);
    return CommandResult(true, activity.id.value, "");
  }

}
