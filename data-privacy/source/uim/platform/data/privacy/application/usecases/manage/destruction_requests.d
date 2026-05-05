/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.application.usecases.manage.destruction_requests;

import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class ManageDestructionRequestsUseCase { // TODO: UIMUseCase {
  private DestructionRequestRepository repo;
  private DataSubjectRepository subjectRepo;

  this(DestructionRequestRepository repo, DataSubjectRepository subjectRepo) {
    this.repo = repo;
    this.subjectRepo = subjectRepo;
  }

  CommandResult createRequest(CreateDestructionRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");
    if (req.dataSubjectId.isEmpty)
      return CommandResult(false, "", "Data subject ID is required");

    auto subject = subjectRepo.findById(req.dataSubjectId, req.tenantId);
    if (subject.isNull)
      return CommandResult(false, "", "Data subject not found");

    auto now = Clock.currStdTime();
    auto r = DestructionRequest();
    r.id = randomUUID();
    r.tenantId = req.tenantId;
    r.dataSubjectId = req.dataSubjectId;
    r.requestedBy = req.requestedBy;
    r.status = DestructionStatus.scheduled;
    r.targetSystems = req.targetSystems;
    r.archiveRequestId = req.archiveRequestId;
    r.blockingRequestId = req.blockingRequestId;
    r.reason = req.reason;
    r.scheduledAt = req.scheduledAt > 0 ? req.scheduledAt : now;

    repo.save(r);
    return CommandResult(true, r.id.value, "");
  }

  DestructionRequest getRequest(TenantId tenantId, DestructionRequestId id) {
    return repo.findById(tenantId, id);
  }

  DestructionRequest[] listRequests(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  DestructionRequest[] listByDataSubject(TenantId tenantId, DataSubjectId subjectId) {
    return repo.findByDataSubject(tenantId, subjectId);
  }

  CommandResult updateStatus(UpdateDestructionStatusRequest req) {
    auto r = repo.findById(req.tenantId, req.id);
    if (r.isNull)
      return CommandResult(false, "", "Destruction request not found");

    r.status = req.status;
    auto now = Clock.currStdTime();
    if (req.status == DestructionStatus.inProgress)
      r.startedAt = now;
    if (req.status == DestructionStatus.completed)
      r.completedAt = now;

    repo.update(r);
    return CommandResult(true, r.id.value, "");
  }

  CommandResult deleteRequest(TenantId tenantId, DestructionRequestId id) {
    auto r = repo.findById(tenantId, id);
    if (r.isNull)
      return CommandResult(false, "", "Destruction request not found");

    repo.removeById(tenantId, id);
    return CommandResult(true, id.value, "");
  }
}
