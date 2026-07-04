/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.application.usecases.manage.correction_requests;

import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class ManageCorrectionRequestsUseCase { // TODO: UIMUseCase {
  private CorrectionRequestRepository crRepo;
  private DataSubjectRepository dsRepo;

  this(CorrectionRequestRepository crRepo, DataSubjectRepository dsRepo) {
    this.crRepo = crRepo;
    this.dsRepo = dsRepo;
  }

  CommandResult createRequest(CreateCorrectionRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");
    if (req.subjectId.isEmpty)
      return CommandResult(false, "", "Data subject ID is required");
    if (req.fieldName.length == 0)
      return CommandResult(false, "", "Field name is required");

    auto subject = dsRepo.findById(req.tenantId, req.subjectId);
    if (subject.isNull)
      return CommandResult(false, "", "Data subject not found");

    auto request = CorrectionRequest(req.tenantId); //, req.createdBy);
    request.dataSubjectId = req.subjectId;
    request.requestedBy = req.requestedBy;
    request.status = CorrectionStatus.requested;
    request.targetSystems = req.targetSystems;
    request.fieldName = req.fieldName;
    request.currentValue = req.currentValue;
    request.correctedValue = req.correctedValue;
    request.reason = req.reason;
    request.requestedAt = request.createdAt;
    request.deadline = request.createdAt + 30 * 24 * 60 * 60 * 10_000_000L; // 30 days

    crRepo.save(request);
    return CommandResult(true,request.id.value, "");
  }

  CorrectionRequest getRequest(TenantId tenantId, CorrectionRequestId id) {
    return crRepo.findById(tenantId, id);
  }

  CorrectionRequest[] listRequests(TenantId tenantId) {
    return crRepo.findByTenant(tenantId);
  }

  CorrectionRequest[] listByDataSubject(TenantId tenantId, DataSubjectId subjectId) {
    return crRepo.findByDataSubject(tenantId, subjectId);
  }

  CommandResult updateStatus(UpdateCorrectionStatusRequest req) {
    auto correctionRequest = crRepo.findById(req.tenantId, req.requestId);
    if (correctionRequest.isNull)
      return CommandResult(false, "", "Correction request not found");

    correctionRequest.status = req.status.toCorrectionStatus;
    if (correctionRequest.status == CorrectionStatus.completed)
      correctionRequest.completedAt = currentTimestamp();

    crRepo.update(correctionRequest);
    return CommandResult(true, correctionRequest.id.value, "");
  }

  CommandResult deleteRequest(TenantId tenantId, CorrectionRequestId id) {
    auto entity = crRepo.findById(tenantId, id);
    if (entity.isNull)
      return CommandResult(false, "", "Correction request not found");

    crRepo.remove(entity);
    return CommandResult(true, entity.id.value, "");
  }
}
