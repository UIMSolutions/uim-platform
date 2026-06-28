/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.application.usecases.manage.data_subject_requests;

import uim.platform.personal_data;

// mixin(ShowModule!());

@safe:

class ManageDataSubjectRequestsUseCase { // TODO: UIMUseCase {
    private DataSubjectRequestRepository repo;

    this(DataSubjectRequestRepository repo) {
        this.repo = repo;
    }

    CommandResult createDataSubjectRequest(CreateDataSubjectRequestRequest r) {
        if (r.isNull) return CommandResult(false, "", "ID is required");
        if (r.dataSubjectId.isEmpty) return CommandResult(false, "", "Data subject ID is required");
        if (r.requestType.length == 0) return CommandResult(false, "", "Request type is required");

        

        DataSubjectRequest req;
        req.id = r.id;
        req.tenantId = r.tenantId;
        req.dataSubjectId = r.dataSubjectId;
        req.requestType = r.requestType.to!RequestType;
        req.status = RequestStatus.submitted;
        req.priority = r.priority.length > 0 ? r.priority.to!RequestPriority : RequestPriority.medium;
        req.description = r.description;
        req.applicationIds = r.applicationIds;
        req.dataCategoryIds = r.dataCategoryIds;
        req.assignedTo = r.assignedTo;
        req.dueDate = r.dueDate;
        req.createdBy = r.createdBy;
        req.createdAt = clockTime();

        repo.save(req);
        return CommandResult(true, req.id.value, "");
    }

    DataSubjectRequest getDataSubjectRequest(TenantId tenantId, DataSubjectRequestId id) {
        return repo.findById(tenantId, id);
    }

    DataSubjectRequest[] listDataSubjectRequests(TenantId tenantId) {
        return repo.find(tenantId);
    }

    DataSubjectRequest[] listDataSubjectRequestsByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId) {
        return repo.findByDataSubject(tenantId, dataSubjectId);
    }

    DataSubjectRequest[] listDataSubjectRequestsByStatus(TenantId tenantId, RequestStatus status) {
        return repo.findByStatus(tenantId, status);
    }

    CommandResult updateDataSubjectRequest(UpdateDataSubjectRequestRequest r) {
        auto request = repo.findById(r.id);
        if (request.isNull)
            return CommandResult(false, "", "Data subject request not found");

        

        if (r.status.length > 0) {
            request.status = r.status.to!RequestStatus;
            if (request.status == RequestStatus.completed)
                request.completedAt = clockTime();
        }
        if (r.assignedTo.length > 0) request.assignedTo = r.assignedTo;
        if (r.rejectionReason.length > 0) request.rejectionReason = r.rejectionReason;

        if (r.commentText.length > 0) {
            ProcessingComment c;
            c.author = r.commentAuthor;
            c.comment = r.commentText;
            c.createdAt = clockTime();
            request.comments ~= c;
        }

        request.updatedBy = r.updatedBy;
        request.updatedAt = clockTime();

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
