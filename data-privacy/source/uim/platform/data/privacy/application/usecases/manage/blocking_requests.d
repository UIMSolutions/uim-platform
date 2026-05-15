/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.application.usecases.manage.blocking_requests;
// import std.uuid;
// import std.datetime.systime : Clock;
// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.blocking_request;
// import uim.platform.data.privacy.domain.ports.repositories.blocking_requests;
// import uim.platform.data.privacy.domain.ports.repositories.data_subjects;
// import uim.platform.data.privacy.application.dto;

import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class ManageBlockingRequestsUseCase { // TODO: UIMUseCase {
  private BlockingRequestRepository blockingRequests;
  private DataSubjectRepository dataSubjects;

  this(BlockingRequestRepository blockingRequests, DataSubjectRepository dataSubjects) {
    this.blockingRequests = blockingRequests;
    this.dataSubjects = dataSubjects;
  }

  CommandResult createRequest(CreateBlockingRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");
    if (req.dataSubjectId.isEmpty)
      return CommandResult(false, "", "Data subject ID is required");

    auto subject = dataSubjects.findById(req.tenantId, req.dataSubjectId);
    if (subject.isNull)
      return CommandResult(false, "", "Data subject not found");

    BlockingRequest request;
    request.initEntity(req.tenantId);

    request.dataSubjectId = req.dataSubjectId;
    request.requestedBy = req.requestedBy;
    request.status = BlockingStatus.requested;
    request.targetSystems = req.targetSystems;
    request.categories = req.categories;
    request.reason = req.reason;
    request.requestedAt = currentTimestamp();

    blockingRequests.save(request);
    return CommandResult(true, request.id.value, "");
  }

  BlockingRequest getRequest(TenantId tenantId, BlockingRequestId id) {
    return blockingRequests.findById(tenantId, id);
  }

  BlockingRequest[] listRequests(TenantId tenantId) {
    return blockingRequests.findByTenant(tenantId);
  }

  BlockingRequest[] listByStatus(TenantId tenantId, BlockingStatus status) {
    return blockingRequests.findByStatus(tenantId, status);
  }

  CommandResult updateStatus(UpdateBlockingStatusRequest req) {
    auto request = blockingRequests.findById(req.tenantId, req.id);
    if (request.isNull)
      return CommandResult(false, "", "Blocking request not found");

    request.status = req.status;
    if (req.status == BlockingStatus.active)
      request.activatedAt = currentTimestamp();
    if (req.status == BlockingStatus.released)
      request.releasedAt = currentTimestamp();

    blockingRequests.update(request);
    return CommandResult(true, request.id.value, "");
  }

  CommandResult deleteRequest(TenantId tenantId, BlockingRequestId id) {
    auto request = blockingRequests.findById(tenantId, id);
    if (request.isNull)
      return CommandResult(false, "", "Blocking request not found");

    blockingRequests.remove(request);
    return CommandResult(true, request.id.value, ""); 
  }
}
