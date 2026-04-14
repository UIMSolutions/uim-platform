/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.application.usecases.manage.archive_requests;

import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class ManageArchiveRequestsUseCase : UIMUseCase {
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
    if (subject is null)
      return CommandResult(false, "", "Data subject not found");

    auto now = Clock.currStdTime();
    auto r = ArchiveRequest();
    r.id = randomUUID();
    r.tenantId = req.tenantId;
    r.dataSubjectId = req.dataSubjectId;
    r.requestedBy = req.requestedBy;
    r.status = ArchiveStatus.scheduled;
    r.targetSystems = req.targetSystems;
    r.categories = req.categories;
    r.archiveLocation = req.archiveLocation;
    r.reason = req.reason;
    r.isTestMode = req.isTestMode;
    r.scheduledAt = req.scheduledAt > 0 ? req.scheduledAt : now;

    repo.save(r);
    return CommandResult(r.id, "");
  }

  ArchiveRequest* getRequest(ArchiveRequestId tenantId, id tenantId) {
    return repo.findById(tenantId, id);
  }

  ArchiveRequest[] listRequests(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  ArchiveRequest[] listByDataSubject(TenantId tenantId, DataSubjectId subjectId) {
    return repo.findByDataSubject(tenantId, subjectId);
  }

  CommandResult updateStatus(UpdateArchiveStatusRequest req) {
    auto r = repo.findById(req.id, req.tenantId);
    if (r is null)
      return CommandResult(false, "", "Archive request not found");

    r.status = req.status;
    auto now = Clock.currStdTime();
    if (req.status == ArchiveStatus.inProgress)
      r.startedAt = now;
    if (req.status == ArchiveStatus.completed)
      r.completedAt = now;

    repo.update(*r);
    return CommandResult(r.id, "");
  }

  void deleteRequest(ArchiveRequestId tenantId, id tenantId) {
    repo.remove(tenantId, id);
  }
}
