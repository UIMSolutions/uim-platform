module application.use_cases.manage_data_retrievals;

import std.uuid;
import std.datetime.systime : Clock;

import domain.types;
import domain.entities.data_retrieval_request;
import domain.ports.data_retrieval_request_repository;
import domain.ports.data_subject_repository;
import domain.ports.personal_data_model_repository;
import application.dto;

class ManageDataRetrievalsUseCase
{
    private DataRetrievalRequestRepository repo;
    private DataSubjectRepository subjectRepo;
    private PersonalDataModelRepository modelRepo;

    this(DataRetrievalRequestRepository repo,
        DataSubjectRepository subjectRepo,
        PersonalDataModelRepository modelRepo)
    {
        this.repo = repo;
        this.subjectRepo = subjectRepo;
        this.modelRepo = modelRepo;
    }

    CommandResult createRequest(CreateDataRetrievalRequest req)
    {
        if (req.tenantId.length == 0)
            return CommandResult("", "Tenant ID is required");
        if (req.dataSubjectId.length == 0)
            return CommandResult("", "Data subject ID is required");

        auto subject = subjectRepo.findById(req.dataSubjectId, req.tenantId);
        if (subject is null)
            return CommandResult("", "Data subject not found");

        auto now = Clock.currStdTime();
        // Deadline: 30 days from now (GDPR Art. 12(3))
        long deadline = now + (30L * 24 * 60 * 60 * 10_000_000L);

        auto request = DataRetrievalRequest();
        request.id = randomUUID().toString();
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
        foreach (ref m; models)
        {
            if (req.targetSystems.length > 0)
            {
                bool systemMatch = false;
                foreach (s; req.targetSystems)
                    if (s == m.sourceSystem)
                    {
                        systemMatch = true;
                        break;
                    }
                if (!systemMatch) continue;
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

    DataRetrievalRequest* getRequest(DataRetrievalRequestId id, TenantId tenantId)
    {
        return repo.findById(id, tenantId);
    }

    DataRetrievalRequest[] listRequests(TenantId tenantId)
    {
        return repo.findByTenant(tenantId);
    }

    DataRetrievalRequest[] listByStatus(TenantId tenantId, RetrievalStatus status)
    {
        return repo.findByStatus(tenantId, status);
    }

    CommandResult updateStatus(UpdateRetrievalStatusRequest req)
    {
        auto request = repo.findById(req.id, req.tenantId);
        if (request is null)
            return CommandResult("", "Data retrieval request not found");

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

    void deleteRequest(DataRetrievalRequestId id, TenantId tenantId)
    {
        repo.remove(id, tenantId);
    }
}
