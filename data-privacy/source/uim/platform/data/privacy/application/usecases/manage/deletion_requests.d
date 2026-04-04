/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.application.usecases.manage.deletion_requests;

// import std.uuid;
// import std.datetime.systime : Clock;

import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy.domain.entities.deletion_request;
import uim.platform.data.privacy.domain.ports.deletion_request_repository;
import uim.platform.data.privacy.domain.ports.data_subject_repository;
import uim.platform.data.privacy.application.dto;

class ManageDeletionRequestsUseCase
{
  private DeletionRequestRepository repo;
  private DataSubjectRepository subjectRepo;

  this(DeletionRequestRepository repo, DataSubjectRepository subjectRepo)
  {
    this.repo = repo;
    this.subjectRepo = subjectRepo;
  }

  CommandResult createRequest(CreateDeletionRequest req)
  {
    if (req.tenantId.length == 0)
      return CommandResult("", "Tenant ID is required");
    if (req.dataSubjectId.length == 0)
      return CommandResult("", "Data subject ID is required");

    // Verify data subject exists
    auto subject = subjectRepo.findById(req.dataSubjectId, req.tenantId);
    if (subject is null)
      return CommandResult("", "Data subject not found");

    auto now = Clock.currStdTime();
    // Deadline: 30 days from now (GDPR Art. 12(3))
    long deadline = now + (30L * 24 * 60 * 60 * 10_000_000L);

    auto request = DeletionRequest();
    request.id = randomUUID().toString();
    request.tenantId = req.tenantId;
    request.dataSubjectId = req.dataSubjectId;
    request.requestedBy = req.requestedBy;
    request.requestType = RequestType.deletion;
    request.status = DeletionStatus.requested;
    request.targetSystems = req.targetSystems;
    request.categories = req.categories;
    request.reason = req.reason;
    request.requestedAt = now;
    request.deadline = deadline;

    repo.save(request);
    return CommandResult(request.id, "");
  }

  DeletionRequest* getRequest(DeletionRequestId id, TenantId tenantId)
  {
    return repo.findById(id, tenantId);
  }

  DeletionRequest[] listRequests(TenantId tenantId)
  {
    return repo.findByTenant(tenantId);
  }

  DeletionRequest[] listByStatus(TenantId tenantId, DeletionStatus status)
  {
    return repo.findByStatus(tenantId, status);
  }

  DeletionRequest[] listByDataSubject(TenantId tenantId, DataSubjectId subjectId)
  {
    return repo.findByDataSubject(tenantId, subjectId);
  }

  CommandResult updateStatus(UpdateDeletionStatusRequest req)
  {
    auto request = repo.findById(req.id, req.tenantId);
    if (request is null)
      return CommandResult("", "Deletion request not found");

    request.status = req.status;
    if (req.blockerReason.length > 0)
      request.blockerReason = req.blockerReason;
    if (req.status == DeletionStatus.completed)
      request.completedAt = Clock.currStdTime();

    repo.update(*request);
    return CommandResult(request.id, "");
  }

  void deleteRequest(DeletionRequestId id, TenantId tenantId)
  {
    repo.remove(id, tenantId);
  }
}
