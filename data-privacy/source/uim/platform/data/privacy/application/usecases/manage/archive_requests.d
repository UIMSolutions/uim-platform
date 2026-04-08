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
      return CommandResult("", "Tenant ID is required");
    if (req.dataSubjectId.length == 0)
      return CommandResult("", "Data subject ID is required");

    auto subject = subjectRepo.findById(req.dataSubjectId, req.tenantId);
    if (subject is null)
      return CommandResult("", "Data subject not found");

    auto now = Clock.currStdTime();
    auto r = ArchiveRequest();
    r.id = randomUUID().toString();
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

  ArchiveRequest* getRequest(ArchiveRequestId id, TenantId tenantId) {
    return repo.findById(id, tenantId);
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
      return CommandResult("", "Archive request not found");

    r.status = req.status;
    auto now = Clock.currStdTime();
    if (req.status == ArchiveStatus.inProgress)
      r.startedAt = now;
    if (req.status == ArchiveStatus.completed)
      r.completedAt = now;

    repo.update(*r);
    return CommandResult(r.id, "");
  }

  void deleteRequest(ArchiveRequestId id, TenantId tenantId) {
    repo.remove(id, tenantId);
  }
}
