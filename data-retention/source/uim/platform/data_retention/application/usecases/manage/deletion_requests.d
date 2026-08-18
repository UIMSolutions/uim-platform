/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_retention.application.usecases.manage.deletion_requests;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class ManageDeletionRequestsUseCase {
    private IDeletionRequestRepository repo;

    this(IDeletionRequestRepository repo) {
        this.repo = repo;
    }

    UsecaseResult createDeletionRequest(CreateDeletionRequestRequest req) {
        if (req.subjectId.isNull)
            return UsecaseResult(false, "", "Data subject ID is required");

        DeletionRequest dr = DeletionRequest(req.tenantId, DeletionRequestId(generateId));
        dr.subjectId = req.subjectId;
        dr.groupId = req.groupId;
        dr.actionType = toDeletionActionType(req.actionType);
        dr.status = DeletionRequestStatus.pending;
        dr.reason = req.reason;
        dr.requestedBy = req.requestedBy;
        dr.requestedAt = clockSeconds();
        dr.createdAt = clockSeconds();

        repo.save(dr);
        return UsecaseResult(true, dr.id.value, "");
    }

    UsecaseResult updateDeletionRequest(UpdateDeletionRequestRequest req) {
        auto dr = repo.findById(req.tenantId, req.requestId);
        if (dr.isNull)
            return UsecaseResult(false, "", "Deletion request not found");

        if (req.status.length > 0)
            dr.status = toDeletionRequestStatus(req.status);
        if (req.errorMessage.length > 0)
            dr.errorMessage = req.errorMessage;
        if (dr.status == DeletionRequestStatus.completed)
            dr.completedAt = clockSeconds();
        dr.updatedAt = clockSeconds();

        repo.update(dr);
        return UsecaseResult(true, dr.id.value, "");
    }

    bool hasDeletionRequest(TenantId tenantId, DeletionRequestId id) {
        return repo.existsById(tenantId, id);
    }

    DeletionRequest getDeletionRequest(TenantId tenantId, DeletionRequestId id) {
        return repo.findById(tenantId, id);
    }

    DeletionRequest[] listDeletionRequests(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    DeletionRequest[] listDeletionRequestsByStatus(TenantId tenantId, DeletionRequestStatus status) {
        return repo.findByStatus(tenantId, status);
    }

    UsecaseResult deleteDeletionRequest(TenantId tenantId, DeletionRequestId id) {
        auto request = repo.findById(tenantId, id);
        if (request.isNull)
            return UsecaseResult(false, "", "Deletion request not found");

        repo.remove(request);
        return UsecaseResult(true, request.id.value, "");
    }
}
