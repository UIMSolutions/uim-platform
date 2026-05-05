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
    if (req.dataSubjectId.isEmpty)
      return CommandResult(false, "", "Data subject ID is required");

    auto subject = subjectRepo.findById(req.dataSubjectId, req.tenantId);
    if (subject.isNull)
      return CommandResult(false, "", "Data subject not found");

    auto now = Clock.currStdTime();
    auto archiveRequest = ArchiveRequest();
    archiveRequest.createEntity(req.tenantId);

    archiveRequest.dataSubjectId = req.dataSubjectId;
    archiveRequest.requestedBy = req.requestedBy;
    archiveRequest.status = ArchiveStatus.scheduled;
    archiveRequest.targetSystems = req.targetSystems;
    archiveRequest.categories = req.categories;
    archiveRequest.archiveLocation = req.archiveLocation;
    archiveRequest.reason = req.reason;
    archiveRequest.isTestMode = req.isTestMode;
    archiveRequest.scheduledAt = req.scheduledAt > 0 ? req.scheduledAt : now;

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
    auto archiveRequest = repo.findById(req.tenantId, req.id);
    if (archiveRequest.isNull)
      return CommandResult(false, "", "Archive request not found");

    archiveRequest.status = req.status;
    auto now = Clock.currStdTime();
    if (req.status == ArchiveStatus.inProgress)
      archiveRequest.startedAt = now;
    if (req.status == ArchiveStatus.completed)
      archiveRequest.completedAt = now;

    repo.update(archiveRequest);
    return CommandResult(true, archiveRequest.id.value, "");
  }

  void deleteRequest(TenantId tenantId, ArchiveRequestId requestId) {
    repo.removeById(tenantId, requestId);
  }
}
