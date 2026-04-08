/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.application.usecases.manage.correction_requests;

import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class ManageCorrectionRequestsUseCase : UIMUseCase {
  private CorrectionRequestRepository repo;
  private DataSubjectRepository subjectRepo;

  this(CorrectionRequestRepository repo, DataSubjectRepository subjectRepo) {
    this.repo = repo;
    this.subjectRepo = subjectRepo;
  }

  CommandResult createRequest(CreateCorrectionRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult("", "Tenant ID is required");
    if (req.dataSubjectid.isEmpty)
      return CommandResult("", "Data subject ID is required");
    if (req.fieldName.length == 0)
      return CommandResult("", "Field name is required");

    auto subject = subjectRepo.findById(req.dataSubjectId, req.tenantId);
    if (subject is null)
      return CommandResult("", "Data subject not found");

    auto now = Clock.currStdTime();
    auto r = CorrectionRequest();
    r.id = randomUUID().toString();
    r.tenantId = req.tenantId;
    r.dataSubjectId = req.dataSubjectId;
    r.requestedBy = req.requestedBy;
    r.status = CorrectionStatus.requested;
    r.targetSystems = req.targetSystems;
    r.fieldName = req.fieldName;
    r.currentValue = req.currentValue;
    r.correctedValue = req.correctedValue;
    r.reason = req.reason;
    r.requestedAt = now;
    r.deadline = now + 30 * 24 * 60 * 60 * 10_000_000L; // 30 days

    repo.save(r);
    return CommandResult(r.id, "");
  }

  CorrectionRequest* getRequest(CorrectionRequestId id, TenantId tenantId) {
    return repo.findById(id, tenantId);
  }

  CorrectionRequest[] listRequests(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CorrectionRequest[] listByDataSubject(TenantId tenantId, DataSubjectId subjectId) {
    return repo.findByDataSubject(tenantId, subjectId);
  }

  CommandResult updateStatus(UpdateCorrectionStatusRequest req) {
    auto r = repo.findById(req.id, req.tenantId);
    if (r is null)
      return CommandResult("", "Correction request not found");

    r.status = req.status;
    if (req.status == CorrectionStatus.completed)
      r.completedAt = Clock.currStdTime();

    repo.update(*r);
    return CommandResult(r.id, "");
  }

  void deleteRequest(CorrectionRequestId id, TenantId tenantId) {
    repo.remove(id, tenantId);
  }
}
