/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.application.usecases.manage.archive_requests;

import uim.platform.data.privacy;
mixin(ShowModule!());

@safe:
class ManageArchiveRequestsUseCase { // TODO: UIMUseCase {
  private ArchiveRequestRepository repo;
  private DataSubjectRepository subjectRepo;

  this(ArchiveRequestRepository repo, DataSubjectRepository subjectRepo) {
    this.repo = repo;
    this.subjectRepo = subjectRepo;
  }

  CommandResult createRequest(CreateArchiveRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");
    if (req.subjectId.isEmpty)
      return CommandResult(false, "", "Data subject ID is required");

    auto subject = subjectRepo.findById(req.tenantId, req.subjectId);
    if (subject.isNull)
      return CommandResult(false, "", "Data subject not found");

    auto now = currentTimestamp();
    auto archiveRequest = ArchiveRequest();
    archiveRequest.createEntity(req.tenantId);

    archiveRequest.dataSubjectId = req.subjectId;
    archiveRequest.requestedBy = req.requestedBy;
    archiveRequest.status = ArchiveStatus.scheduled;
    archiveRequest.targetSystems = req.targetSystems;
    archiveRequest.categories = req.categories.map!(c => toPersonalDataCategory(c)).array;
    archiveRequest.archiveLocation = req.archiveLocation;
    archiveRequest.reason = req.reason;
    archiveRequest.isTestMode = req.isTestMode;
    archiveRequest.scheduledAt = req.scheduledAt > 0 ? req.scheduledAt : archiveRequest.createdAt;

    repo.save(archiveRequest);
    return CommandResult(true, archiveRequest.id.value, "");
  }

  ArchiveRequest getRequest(TenantId tenantId, ArchiveRequestId requestId) {
    return repo.findById(tenantId, requestId);
  }

  ArchiveRequest[] listRequests(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  ArchiveRequest[] listByDataSubject(TenantId tenantId, DataSubjectId subjectId) {
    return repo.findByDataSubject(tenantId, subjectId);
  }

  CommandResult updateStatus(UpdateArchiveStatusRequest req) {
    auto archiveRequest = repo.findById(req.tenantId, req.requestId);
    if (archiveRequest.isNull)
      return CommandResult(false, "", "Archive request not found");

    archiveRequest.status = req.status.toArchiveStatus;
    auto now = currentTimestamp();
    if (archiveRequest.status == ArchiveStatus.inProgress)
      archiveRequest.startedAt = now;
    if (archiveRequest.status == ArchiveStatus.completed)
      archiveRequest.completedAt = now;

    repo.update(archiveRequest);
    return CommandResult(true, archiveRequest.id.value, "");
  }

  CommandResult deleteRequest(TenantId tenantId, ArchiveRequestId requestId) {
    auto archiveRequest = repo.findById(tenantId, requestId);
    if (archiveRequest.isNull)
      return CommandResult(false, "", "Archive request not found");

    repo.remove(archiveRequest);
    return CommandResult(true, archiveRequest.id.value, "");
  }
}
