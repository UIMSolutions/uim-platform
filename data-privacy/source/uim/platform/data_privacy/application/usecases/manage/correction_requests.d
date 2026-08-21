/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_privacy.application.usecases.manage.correction_requests;

import uim.platform.data_privacy;

mixin(ShowModule!());

@safe:
class ManageCorrectionRequestsUseCase {
  protected ICorrectionRequestRepository crRepo;
  private IDataSubjectRepository dsRepo;

  this(ICorrectionRequestRepository crRepo, IDataSubjectRepository dsRepo) {
    this.crRepo = crRepo;
    this.dsRepo = dsRepo;
  }

  UsecaseResult createRequest(CreateCorrectionRequest req) {
    if (req.tenantId.isEmpty)
      return UsecaseResult(false, "", "Tenant ID is required");
    if (req.subjectId.isEmpty)
      return UsecaseResult(false, "", "Data subject ID is required");
    // if (req.fieldname.isEmpty)
      // return UsecaseResult(false, "", "Field name is required");
// 
    auto subject = dsRepo.findById(req.tenantId, req.subjectId);
    if (subject.isNull)
      return UsecaseResult(false, "", "Data subject not found");

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
    return UsecaseResult(true,request.id.value, "");
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

  UsecaseResult updateStatus(UpdateCorrectionStatusRequest req) {
    auto correctionRequest = crRepo.findById(req.tenantId, req.requestId);
    if (correctionRequest.isNull)
      return UsecaseResult(false, "", "Correction request not found");

    correctionRequest.status = req.status.toCorrectionStatus;
    if (correctionRequest.status == CorrectionStatus.completed)
      correctionRequest.completedAt = currentTimestamp();

    crRepo.update(correctionRequest);
    return UsecaseResult(true, correctionRequest.id.value, "");
  }

  UsecaseResult deleteRequest(TenantId tenantId, CorrectionRequestId id) {
    auto entity = crRepo.findById(tenantId, id);
    if (entity.isNull)
      return UsecaseResult(false, "", "Correction request not found");

    crRepo.remove(entity);
    return UsecaseResult(true, entity.id.value, "");
  }
}
