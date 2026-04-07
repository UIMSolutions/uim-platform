/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.application.usecases.manage.transport_requests;

import uim.platform.content_agent.application.dto;
import uim.platform.content_agent.domain.entities.transport_request;
import uim.platform.content_agent.domain.entities.content_package;
import uim.platform.content_agent.domain.entities.transport_queue;
import uim.platform.content_agent.domain.entities.content_activity;
import uim.platform.content_agent.domain.ports.repositories.transport_requests;
import uim.platform.content_agent.domain.ports.repositories.content_packages;
import uim.platform.content_agent.domain.ports.repositories.transport_queues;
import uim.platform.content_agent.domain.ports.repositories.content_activitys;
import uim.platform.content_agent.domain.services.transport_validator;
import uim.platform.content_agent.domain.types;

// import std.conv : to;

/// Application service for transport request lifecycle management.
class ManageTransportRequestsUseCase : UIMUseCase {
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
    foreach (pid; req.packageIds)
    {
      auto pkg = packageRepo.findById(pid);
      if (pkg.id.length == 0)
        return CommandResult(false, "", "Package not found: " ~ pid);
      packages ~= pkg;
    }

    // Resolve queue
    TransportQueue queue;
    if (req.queueId.length > 0)
      queue = queueRepo.findById(req.queueId);
    else
      queue = queueRepo.findDefault(req.tenantId);

    // import std.uuid : randomUUID;
    auto id = randomUUID().toString();

    TransportRequest tr;
    tr.id = id;
    tr.tenantId = req.tenantId;
    tr.sourceSubaccount = req.sourceSubaccount;
    tr.targetSubaccount = req.targetSubaccount;
    tr.description = req.description;
    tr.mode = parseTransportMode(req.mode);
    tr.packageIds = req.packageIds;
    tr.queueId = queue.id;
    tr.status = TransportStatus.created;
    tr.createdBy = req.createdBy;
    tr.createdAt = clockSeconds();
    tr.updatedAt = tr.createdAt;

    // Validate transport
    auto validation = TransportValidator.validate(tr, packages, queue);
    if (!validation.valid)
    {
      string msg = "Transport validation failed: ";
      foreach (i, e; validation.errors)
      {
        if (i > 0)
          msg ~= "; ";
        msg ~= e;
      }
      return CommandResult(false, "", msg);
    }

    requestRepo.save(tr);
    recordActivity(req.tenantId, ActivityType.transportCreated, id,
        req.description, "Transport request created", req.createdBy);

    return CommandResult(true, id, "");
  }

  CommandResult releaseTransport(ReleaseTransportRequest req) {
    auto tr = requestRepo.findById(req.requestId);
    if (tr.id.length == 0)
      return CommandResult(false, "", "Transport request not found");

    if (tr.status != TransportStatus.created && tr.status != TransportStatus.readyForExport)
      return CommandResult(false, "", "Transport request is not in a releasable state");

    tr.status = TransportStatus.released;
    tr.releasedAt = clockSeconds();
    tr.updatedAt = tr.releasedAt;

    requestRepo.update(tr);
    recordActivity(req.tenantId, ActivityType.transportReleased, req.requestId,
        tr.description, "Transport released", req.releasedBy);

    return CommandResult(true, req.requestId, "");
  }

  CommandResult cancelTransport(TransportRequestId id) {
    auto tr = requestRepo.findById(id);
    if (tr.id.length == 0)
      return CommandResult(false, "", "Transport request not found");

    tr.status = TransportStatus.cancelled;
    tr.updatedAt = clockSeconds();
    requestRepo.update(tr);

    return CommandResult(true, id, "");
  }

  TransportRequest getTransportRequest(TransportRequestId id) {
    return requestRepo.findById(id);
  }

  TransportRequest[] listTransportRequests(TenantId tenantId) {
    return requestRepo.findByTenant(tenantId);
  }

  TransportRequest[] listByStatus(TenantId tenantId, string statusStr) {
    auto status = parseTransportStatus(statusStr);
    return requestRepo.findByStatus(tenantId, status);
  }

  private void recordActivity(TenantId tenantId, ActivityType actType,
      string entityId, string entityName, string desc, string by) {
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

  private static long clockSeconds() {
    // import std.datetime.systime : Clock;
    return Clock.currTime().toUnixTime();
  }

  private static TransportMode parseTransportMode(string s) {
    switch (s)
    {
    case "ctsPlus":
      return TransportMode.ctsPlus;
    case "directExport":
      return TransportMode.directExport;
    case "fileDownload":
      return TransportMode.fileDownload;
    default:
      return TransportMode.cloudTransportManagement;
    }
  }

  private static TransportStatus parseTransportStatus(string s) {
    switch (s)
    {
    case "created":
      return TransportStatus.created;
    case "readyForExport":
      return TransportStatus.readyForExport;
    case "exporting":
      return TransportStatus.exporting;
    case "exported":
      return TransportStatus.exported;
    case "inQueue":
      return TransportStatus.inQueue;
    case "importing":
      return TransportStatus.importing;
    case "imported":
      return TransportStatus.imported;
    case "released":
      return TransportStatus.released;
    case "failed":
      return TransportStatus.failed;
    case "cancelled":
      return TransportStatus.cancelled;
    default:
      return TransportStatus.created;
    }
  }
}
