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
  private CorrectionRequestRepository correctionRequests;
  private DataSubjectRepository dataSubjects;

  this(CorrectionRequestRepository correctionRequests, DataSubjectRepository dataSubjects) {
    this.correctionRequests = correctionRequests;
    this.dataSubjects = dataSubjects;
  }

  CommandResult createRequest(CreateCorrectionRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");
    if (req.dataSubjectId.isEmpty)
      return CommandResult(false, "", "Data subject ID is required");
    if (req.fieldName.length == 0)
      return CommandResult(false, "", "Field name is required");

    auto subject = dataSubjects.findById(req.tenantId, req.dataSubjectId);
    if (subject.isNull)
      return CommandResult(false, "", "Data subject not found");

    auto now = Clock.currStdTime();
    CorrectionRequest request;
    request.initEntity(req.tenantId);
    request.dataSubjectId = req.dataSubjectId;
    request.requestedBy = req.requestedBy;
    request.status = CorrectionStatus.requested;
    request.targetSystems = req.targetSystems;
    request.fieldName = req.fieldName;
    request.currentValue = req.currentValue;
    request.correctedValue = req.correctedValue;
    request.reason = req.reason;
    request.requestedAt = now;
    request.deadline = now + 30 * 24 * 60 * 60 * 10_000_000L; // 30 days

    correctionRequests.save(request);
    return CommandResult(true,request.id.value, "");
  }

  CorrectionRequest getRequest(TenantId tenantId, CorrectionRequestId id) {
    return correctionRequests.findById(tenantId, id);
  }

  CorrectionRequest[] listRequests(TenantId tenantId) {
    return correctionRequests.findByTenant(tenantId);
  }

  CorrectionRequest[] listByDataSubject(TenantId tenantId, DataSubjectId subjectId) {
    return correctionRequests.findByDataSubject(tenantId, subjectId);
  }

  CommandResult updateStatus(UpdateCorrectionStatusRequest req) {
    auto correctionRequest = correctionRequests.findById(req.tenantId, req.id);
    if (correctionRequest.isNull)
      return CommandResult(false, "", "Correction request not found");

    correctionRequest.status = req.status;
    if (req.status == CorrectionStatus.completed)
      correctionRequest.completedAt = Clock.currStdTime();

    correctionRequests.update(correctionRequest);
    return CommandResult(true, correctionRequest.id.value, "");
  }

  CommandResult deleteRequest(TenantId tenantId, CorrectionRequestId id) {
    auto entity = correctionRequests.findById(tenantId, id);
    if (entity.isNull)
      return CommandResult(false, "", "Correction request not found");

    correctionRequests.removeById(tenantId, id);
  }
}
