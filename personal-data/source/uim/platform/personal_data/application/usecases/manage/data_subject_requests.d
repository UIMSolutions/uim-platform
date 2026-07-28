/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.application.usecases.manage.data_subject_requests;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class ManageDataSubjectRequestsUseCase { // TODO: UIMUseCase {
    private DataSubjectRequestRepository repo;

    this(DataSubjectRequestRepository repo) {
        this.repo = repo;
    }

    CommandResult createDataSubjectRequest(CreateDataSubjectRequestRequest r) {
        if (r.tenantId.isNull) return CommandResult(false, "", "ID is required");
        if (r.subjectId.isEmpty) return CommandResult(false, "", "Data subject ID is required");
        if (r.requestType.length == 0) return CommandResult(false, "", "Request type is required");

        DataSubjectRequest req;
        req.id = r.requestId;
        req.tenantId = r.tenantId;
        req.dataSubjectId = r.subjectId;
        req.requestType = r.requestType.toRequestType;
        req.status = RequestStatus.submitted;
        req.priority = r.priority.length > 0 ? r.priority.to!RequestPriority : RequestPriority.medium;
        req.description = r.description;
        req.applicationIds = r.applicationIds;
        req.dataCategoryIds = r.dataCategoryIds;
        req.assignedTo = r.assignedTo.value;
        req.dueDate = r.dueDate.to!string;
        req.createdBy = r.createdBy;
        req.createdAt = currentTimestamp();

        repo.save(req);
        return CommandResult(true, req.id.value, "");
    }

    DataSubjectRequest getDataSubjectRequest(TenantId tenantId, DataSubjectRequestId id) {
        return repo.findById(tenantId, id);
    }

    DataSubjectRequest[] listDataSubjectRequests(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    DataSubjectRequest[] listDataSubjectRequests(TenantId tenantId, DataSubjectId dataSubjectId) {
        return repo.findByDataSubject(tenantId, dataSubjectId);
    }

    DataSubjectRequest[] listDataSubjectRequests(TenantId tenantId, RequestStatus status) {
        return repo.findByStatus(tenantId, status);
    }

    CommandResult updateDataSubjectRequest(UpdateDataSubjectRequestRequest r) {
        auto request = repo.findById(r.tenantId, r.requestId);
        if (request.isNull)
            return CommandResult(false, "", "Data subject request not found");

        if (r.status.length > 0) {
            request.status = r.status.to!RequestStatus;
            if (request.status == RequestStatus.completed)
                request.completedAt = currentTimestamp();
        }
        if (r.assignedTo.length > 0) request.assignedTo = r.assignedTo;
        if (r.rejectionReason.length > 0) request.rejectionReason = r.rejectionReason;

        if (r.commentText.length > 0) {
            ProcessingComment c;
            c.author = r.commentAuthor;
            c.comment = r.commentText;
            c.createdAt = currentTimestamp();
            request.comments ~= c;
        }

        request.updatedBy = r.updatedBy;
        request.updatedAt = currentTimestamp();

        repo.update(request);
        return CommandResult(true, request.id.value, "");
    }

    CommandResult deleteDataSubjectRequest(TenantId tenantId, DataSubjectRequestId id) {
        auto request = repo.findById(tenantId, id);
        if (request.isNull)
            return CommandResult(false, "", "Data subject request not found");

        repo.remove(request);
        return CommandResult(true, request.id.value, "");
    }
}
///
unittest {
    mixin(ShowTest!("ManageDataSubjectRequestsUseCase"));

    void testCreateRequest() {
        auto repo = new MemoryDataSubjectRequestRepository();
        auto useCase = new ManageDataSubjectRequestsUseCase(repo);

        // Test creating a data subject request
        auto createRequest = CreateDataSubjectRequestRequest();
        createRequest.tenantId = TenantId("tenant1");
        createRequest.subjectId = "subject3";
        createRequest.requestType = "access";
        createRequest.priority = "high";
        createRequest.description = "Requesting access to personal data";
        createRequest.applicationIds = ["app1", "app2"];
        createRequest.dataCategoryIds = ["category1"];
        createRequest.assignedTo = "admin1";
        // TODO: createRequest.dueDate = currentTimestamp() + 7 * 24 * 60 * 60; // 7 days from now
        createRequest.createdBy = "user1";
        auto result = useCase.createDataSubjectRequest(createRequest);
        assert(result.success, "Failed to create data subject request");

        // Test retrieving the created request
        auto retrievedRequest = useCase.getDataSubjectRequest(createRequest.tenantId, DataSubjectRequestId(result.id));
        // assert(!retrievedRequest.isNull, "Failed to retrieve data subject request");
        // TODO: assert(retrievedRequest.dataSubjectId == createRequest.subjectId, "Data subject ID mismatch");
    }

    void testSecond() {
        auto repo = new MemoryDataSubjectRequestRepository();
        auto useCase = new ManageDataSubjectRequestsUseCase(repo);

        // Test listing data subject requests
        auto tenantId = TenantId("tenant1");
        auto listResult = useCase.listDataSubjectRequests(tenantId);
        assert(listResult.length == 0, "Expected no data subject requests initially");

        // Create a request to test listing
        auto createRequest = CreateDataSubjectRequestRequest();
        createRequest.tenantId = tenantId;
        createRequest.subjectId = "subject2";
        createRequest.requestType = "deletion";
        createRequest.priority = "medium";
        createRequest.description = "Requesting deletion of personal data";
        createRequest.applicationIds = ["app3"];
        createRequest.dataCategoryIds = ["category2"];
        createRequest.assignedTo = "admin2";
        // TODO: createRequest.dueDate = currentTimestamp() + 5 * 24 * 60 * 60; // 5 days from now
        createRequest.createdBy = "user2";
        useCase.createDataSubjectRequest(createRequest);

        // List again after creation
        listResult = useCase.listDataSubjectRequests(tenantId);
        assert(listResult.length == 1, "Expected one data subject request after creation");
    }

    void testThird() {
        auto repo = new MemoryDataSubjectRequestRepository();
        auto useCase = new ManageDataSubjectRequestsUseCase(repo);

        // Create a request to test updating
        auto createRequest = CreateDataSubjectRequestRequest();
        createRequest.tenantId = TenantId("tenant1");
        createRequest.subjectId = "subject3";
        createRequest.requestType = "rectification";
        createRequest.priority = "low";
        createRequest.description = "Requesting rectification of personal data";
        createRequest.applicationIds = ["app4"];
        createRequest.dataCategoryIds = ["category3"];
        createRequest.assignedTo = "admin3";
        // TODO: createRequest.dueDate = currentTimestamp() + 10 * 24 * 60 * 60; // 10 days from now
        createRequest.createdBy = "user3";
        auto result = useCase.createDataSubjectRequest(createRequest);
        assert(result.success, "Failed to create data subject request for update test");

        // Update the request
        auto updateRequest = UpdateDataSubjectRequestRequest();
        updateRequest.tenantId = createRequest.tenantId;
        updateRequest.requestId = DataSubjectRequestId(result.id);
        updateRequest.status = "in_progress";
        updateRequest.assignedTo = "admin4";
        updateRequest.commentAuthor = "user4";
        updateRequest.commentText = "Starting processing of the request";
        updateRequest.updatedBy = "user4";
        auto updateResult = useCase.updateDataSubjectRequest(updateRequest);
        // assert(updateResult.success, "Failed to update data subject request");

        // Retrieve and verify the update
        auto updatedRequest = useCase.getDataSubjectRequest(createRequest.tenantId, DataSubjectRequestId(result.id));
        // assert(!updatedRequest.isNull, "Failed to retrieve updated data subject request");
        // TODO: assert(updatedRequest.status == RequestStatus.in_progress, "Status update failed");
        // assert(updatedRequest.assignedTo == "admin4", "AssignedTo update failed");
    }

    void testDelete() {
        auto repo = new MemoryDataSubjectRequestRepository();
        auto useCase = new ManageDataSubjectRequestsUseCase(repo);

        // Create a request to test deletion
        auto createRequest = CreateDataSubjectRequestRequest();
        createRequest.tenantId = TenantId("tenant1");
        createRequest.subjectId = "subject4";
        createRequest.requestType = "erasure";
        createRequest.priority = "high";
        createRequest.description = "Requesting erasure of personal data";
        createRequest.applicationIds = ["app5"];
        createRequest.dataCategoryIds = ["category4"];
        createRequest.assignedTo = "admin5";
        // TODO: createRequest.dueDate = currentTimestamp() + 3 * 24 * 60 * 60; // 3 days from now
        createRequest.createdBy = "user5";
        auto result = useCase.createDataSubjectRequest(createRequest);
        assert(result.success, "Failed to create data subject request for deletion test");

        // Delete the request
        auto deleteResult = useCase.deleteDataSubjectRequest(createRequest.tenantId, DataSubjectRequestId(result.id));
        // assert(deleteResult.success, "Failed to delete data subject request");

        // Verify deletion
        // auto deletedRequest = useCase.getDataSubjectRequest(createRequest.tenantId, DataSubjectRequestId(result.id));
        // assert(deletedRequest.isNull, "Data subject request was not deleted");
    }

    void testAll() {
        testCreateRequest();
        testSecond();
        testThird();
        testDelete();
    }

    testAll();
}
 