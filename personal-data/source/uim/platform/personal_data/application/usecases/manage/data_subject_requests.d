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

    CommandResult create(CreateDataSubjectRequestRequest r) {
        if (r.id.isEmpty) return CommandResult(false, "", "ID is required");
        if (r.dataSubjectId.isEmpty) return CommandResult(false, "", "Data subject ID is required");
        if (r.requestType.length == 0) return CommandResult(false, "", "Request type is required");

        import std.conv : to;

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
        return CommandResult(true, req.id, "");
    }

    DataSubjectRequest getById(DataSubjectRequestId id) {
        return repo.findById(id);
    }

    DataSubjectRequest[] list(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    DataSubjectRequest[] listByDataSubject(DataSubjectId dataSubjectId) {
        return repo.findByDataSubject(dataSubjectId);
    }

    DataSubjectRequest[] listByStatus(RequestStatus status) {
        return repo.findByStatus(status);
    }

    CommandResult update(UpdateDataSubjectRequestRequest r) {
        auto existing = repo.findById(r.id);
        if (existing.id.isEmpty)
            return CommandResult(false, "", "Request not found");

        import std.conv : to;

        if (r.status.length > 0) {
            existing.status = r.status.to!RequestStatus;
            if (existing.status == RequestStatus.completed)
                existing.completedAt = clockTime();
        }
        if (r.assignedTo.length > 0) existing.assignedTo = r.assignedTo;
        if (r.rejectionReason.length > 0) existing.rejectionReason = r.rejectionReason;

        if (r.commentText.length > 0) {
            ProcessingComment c;
            c.author = r.commentAuthor;
            c.comment = r.commentText;
            c.createdAt = clockTime();
            existing.comments ~= c;
        }

        existing.modifiedBy = r.modifiedBy;
        existing.modifiedAt = clockTime();

        repo.update(existing);
        return CommandResult(true, existing.id, "");
    }

    CommandResult remove(DataSubjectRequestId id) {
        auto existing = repo.findById(id);
        if (existing.id.isEmpty)
            return CommandResult(false, "", "Request not found");
        repo.remove(id);
        return CommandResult(true, id.toString, "");
    }
}
