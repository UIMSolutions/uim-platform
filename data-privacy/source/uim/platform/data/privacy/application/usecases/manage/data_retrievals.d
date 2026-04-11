/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.application.usecases.manage.data_retrievals;

// import std.uuid;
// import std.datetime.systime : Clock;

// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.data_retrieval_request;
// import uim.platform.data.privacy.domain.ports.repositories.data_retrieval_requests;
// import uim.platform.data.privacy.domain.ports.repositories.data_subjects;
// import uim.platform.data.privacy.domain.ports.repositories.personal_data_models;
// import uim.platform.data.privacy.application.dto;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class ManageDataRetrievalsUseCase : UIMUseCase {
  private DataRetrievalRequestRepository repo;
  private DataSubjectRepository subjectRepo;
  private PersonalDataModelRepository modelRepo;

  this(DataRetrievalRequestRepository repo, DataSubjectRepository subjectRepo,
    PersonalDataModelRepository modelRepo) {
    this.repo = repo;
    this.subjectRepo = subjectRepo;
    this.modelRepo = modelRepo;
  }

  CommandResult createRequest(CreateDataRetrievalRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");
    if (req.dataSubjectid.isEmpty)
      return CommandResult(false, "", "Data subject ID is required");

    auto subject = subjectRepo.findById(req.dataSubjectId, req.tenantId);
    if (subject is null)
      return CommandResult(false, "", "Data subject not found");

    auto now = Clock.currStdTime();
    // Deadline: 30 days from now (GDPR Art. 12(3))
    long deadline = now + (30L * 24 * 60 * 60 * 10_000_000L);

    auto request = DataRetrievalRequest();
    request.id = randomUUID();
    request.tenantId = req.tenantId;
    request.dataSubjectId = req.dataSubjectId;
    request.requestedBy = req.requestedBy;
    request.requestType = RequestType.access;
    request.status = RetrievalStatus.requested;
    request.targetSystems = req.targetSystems;
    request.categories = req.categories;
    request.reason = req.reason;
    request.requestedAt = now;
    request.deadline = deadline;

    // Simulate retrieval: count matching personal data fields
    auto models = modelRepo.findByTenant(req.tenantId);
    long fieldCount = 0;
    foreach (m; models) {
      if (req.targetSystems.length > 0) {
        bool systemMatch = false;
        foreach (s; req.targetSystems)
          if (s == m.sourceSystem) {
            systemMatch = true;
            break;
          }
        if (!systemMatch)
          continue;
      }
      fieldCount++;
    }
    request.totalFields = fieldCount;
    request.status = RetrievalStatus.completed;
    request.completedAt = Clock.currStdTime();
    request.downloadUrl = "/api/v1/data-retrievals/" ~ request.id ~ "/download";

    repo.save(request);
    return CommandResult(request.id, "");
  }

  DataRetrievalRequest* getRequest(DataRetrievalRequestId tenantId, id tenantId) {
    return repo.findById(tenantId, id);
  }

  DataRetrievalRequest[] listRequests(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  DataRetrievalRequest[] listByStatus(TenantId tenantId, RetrievalStatus status) {
    return repo.findByStatus(tenantId, status);
  }

  CommandResult updateStatus(UpdateRetrievalStatusRequest req) {
    auto request = repo.findById(req.id, req.tenantId);
    if (request is null)
      return CommandResult(false, "", "Data retrieval request not found");

    request.status = req.status;
    if (req.downloadUrl.length > 0)
      request.downloadUrl = req.downloadUrl;
    if (req.totalFields > 0)
      request.totalFields = req.totalFields;
    if (req.status == RetrievalStatus.completed)
      request.completedAt = Clock.currStdTime();

    repo.update(*request);
    return CommandResult(request.id, "");
  }

  void deleteRequest(DataRetrievalRequestId tenantId, id tenantId) {
    repo.remove(tenantId, id);
  }
}
