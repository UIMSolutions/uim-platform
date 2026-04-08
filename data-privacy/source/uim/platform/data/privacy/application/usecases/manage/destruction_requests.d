/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.application.usecases.manage.destruction_requests;

import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class ManageDestructionRequestsUseCase : UIMUseCase {
  private DestructionRequestRepository repo;
  private DataSubjectRepository subjectRepo;

  this(DestructionRequestRepository repo, DataSubjectRepository subjectRepo) {
    this.repo = repo;
    this.subjectRepo = subjectRepo;
  }

  CommandResult createRequest(CreateDestructionRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult("", "Tenant ID is required");
    if (req.dataSubjectid.isEmpty)
      return CommandResult("", "Data subject ID is required");

    auto subject = subjectRepo.findById(req.dataSubjectId, req.tenantId);
    if (subject is null)
      return CommandResult("", "Data subject not found");

    auto now = Clock.currStdTime();
    auto r = DestructionRequest();
    r.id = randomUUID().toString();
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
    return CommandResult(r.id, "");
  }

  DestructionRequest* getRequest(DestructionRequestId id, TenantId tenantId) {
    return repo.findById(id, tenantId);
  }

  DestructionRequest[] listRequests(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  DestructionRequest[] listByDataSubject(TenantId tenantId, DataSubjectId subjectId) {
    return repo.findByDataSubject(tenantId, subjectId);
  }

  CommandResult updateStatus(UpdateDestructionStatusRequest req) {
    auto r = repo.findById(req.id, req.tenantId);
    if (r is null)
      return CommandResult("", "Destruction request not found");

    r.status = req.status;
    auto now = Clock.currStdTime();
    if (req.status == DestructionStatus.inProgress)
      r.startedAt = now;
    if (req.status == DestructionStatus.completed)
      r.completedAt = now;

    repo.update(*r);
    return CommandResult(r.id, "");
  }

  void deleteRequest(DestructionRequestId id, TenantId tenantId) {
    repo.remove(id, tenantId);
  }
}
