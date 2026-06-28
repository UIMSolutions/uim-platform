/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.application.usecases.manage.destruction_requests;

import uim.platform.data.privacy;

// mixin(ShowModule!());

@safe:
class ManageDestructionRequestsUseCase { // TODO: UIMUseCase {
  private DestructionRequestRepository repo;
  private DataSubjectRepository dataSubjects;

  this(DestructionRequestRepository repo, DataSubjectRepository dataSubjects) {
    this.repo = repo;
    this.dataSubjects = dataSubjects;
  }

  CommandResult createRequest(CreateDestructionRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");
    if (req.dataSubjectId.isEmpty)
      return CommandResult(false, "", "Data subject ID is required");

    auto subject = dataSubjects.findById(req.tenantId, req.dataSubjectId);
    if (subject.isNull)
      return CommandResult(false, "", "Data subject not found");

    DestructionRequest r;
    r.initEntity(req.tenantId);

    r.dataSubjectId = req.dataSubjectId;
    r.requestedBy = req.requestedBy;
    r.status = DestructionStatus.scheduled;
    r.targetSystems = req.targetSystems;
    r.archiveRequestId = req.archiveRequestId;
    r.blockingRequestId = req.blockingRequestId;
    r.reason = req.reason;
    r.scheduledAt = req.scheduledAt > 0 ? req.scheduledAt : currentTimestamp();

    repo.save(r);
    return CommandResult(true, r.id.value, "");
  }

  DestructionRequest getRequest(TenantId tenantId, DestructionRequestId id) {
    return repo.findById(tenantId, id);
  }

  DestructionRequest[] listRequests(TenantId tenantId) {
    return repo.find(tenantId);
  }

  DestructionRequest[] listByDataSubject(TenantId tenantId, DataSubjectId subjectId) {
    return repo.findByDataSubject(tenantId, subjectId);
  }

  CommandResult updateStatus(UpdateDestructionStatusRequest req) {
    auto request = repo.findById(req.tenantId, req.requestId);
    if (request.isNull)
      return CommandResult(false, "", "Destruction request not found");

    request.status = req.status.toDestructionStatus;
    auto now = currentTimestamp();
    if (request.status == DestructionStatus.inProgress)
      request.startedAt = now;
    if (request.status == DestructionStatus.completed)
      request.completedAt = now;

    repo.update(request);
    return CommandResult(true, request.id.value, "");
  }

  CommandResult deleteRequest(TenantId tenantId, DestructionRequestId requestId) {
    auto request = repo.findById(tenantId, requestId);
    if (request.isNull)
      return CommandResult(false, "", "Destruction request not found");

    repo.remove(request);
    return CommandResult(true, request.id.value, "");
  }
}
