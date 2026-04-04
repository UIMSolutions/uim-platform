/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.application.usecases.manage.blocking_requests;

// import std.uuid;
// import std.datetime.systime : Clock;

import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy.domain.entities.blocking_request;
import uim.platform.data.privacy.domain.ports.repositories.blocking_requests;
import uim.platform.data.privacy.domain.ports.repositories.data_subjects;
import uim.platform.data.privacy.application.dto;

class ManageBlockingRequestsUseCase : UIMUseCase {
  private BlockingRequestRepository repo;
  private DataSubjectRepository subjectRepo;

  this(BlockingRequestRepository repo, DataSubjectRepository subjectRepo)
  {
    this.repo = repo;
    this.subjectRepo = subjectRepo;
  }

  CommandResult createRequest(CreateBlockingRequest req)
  {
    if (req.tenantId.length == 0)
      return CommandResult("", "Tenant ID is required");
    if (req.dataSubjectId.length == 0)
      return CommandResult("", "Data subject ID is required");

    auto subject = subjectRepo.findById(req.dataSubjectId, req.tenantId);
    if (subject is null)
      return CommandResult("", "Data subject not found");

    auto now = Clock.currStdTime();
    auto request = BlockingRequest();
    request.id = randomUUID().toString();
    request.tenantId = req.tenantId;
    request.dataSubjectId = req.dataSubjectId;
    request.requestedBy = req.requestedBy;
    request.status = BlockingStatus.requested;
    request.targetSystems = req.targetSystems;
    request.categories = req.categories;
    request.reason = req.reason;
    request.requestedAt = now;

    repo.save(request);
    return CommandResult(request.id, "");
  }

  BlockingRequest* getRequest(BlockingRequestId id, TenantId tenantId)
  {
    return repo.findById(id, tenantId);
  }

  BlockingRequest[] listRequests(TenantId tenantId)
  {
    return repo.findByTenant(tenantId);
  }

  BlockingRequest[] listByStatus(TenantId tenantId, BlockingStatus status)
  {
    return repo.findByStatus(tenantId, status);
  }

  CommandResult updateStatus(UpdateBlockingStatusRequest req)
  {
    auto request = repo.findById(req.id, req.tenantId);
    if (request is null)
      return CommandResult("", "Blocking request not found");

    request.status = req.status;
    if (req.status == BlockingStatus.active)
      request.activatedAt = Clock.currStdTime();
    if (req.status == BlockingStatus.released)
      request.releasedAt = Clock.currStdTime();

    repo.update(*request);
    return CommandResult(request.id, "");
  }

  void deleteRequest(BlockingRequestId id, TenantId tenantId)
  {
    repo.remove(id, tenantId);
  }
}
