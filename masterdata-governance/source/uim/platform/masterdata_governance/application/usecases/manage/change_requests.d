/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.masterdata_governance.application.usecases.manage.change_requests;

import uim.platform.masterdata_governance;

// mixin(ShowModule!());

@safe:

class ManageChangeRequestsUseCase {
    private ChangeRequestRepository repo;

    this(ChangeRequestRepository repo) {
        this.repo = repo;
    }

    ChangeRequest getChangeRequest(TenantId tenantId, ChangeRequestId id) {
        return repo.find(tenantId, id);
    }

    ChangeRequest[] listChangeRequests(TenantId tenantId) {
        return repo.find(tenantId);
    }

    ChangeRequest[] listByStatus(TenantId tenantId, ChangeRequestStatus status) {
        return repo.findByStatus(tenantId, status);
    }

    ChangeRequest[] listByBusinessPartner(TenantId tenantId, BusinessPartnerId bpId) {
        return repo.findByBusinessPartner(tenantId, bpId);
    }

    ChangeRequest[] listByRequestedBy(TenantId tenantId, UserId userId) {
        return repo.findByRequestedBy(tenantId, userId);
    }

    CommandResult createChangeRequest(ChangeRequestDTO dto) {
        ChangeRequest cr;
        cr.initEntity(dto.tenantId, dto.requestedBy);
        cr.id = dto.changeRequestId;
        cr.businessPartnerId = dto.businessPartnerId;
        cr.subject = dto.subject;
        cr.description = dto.description;
        cr.changedFields = dto.changedFields;
        cr.proposedValues = dto.proposedValues;
        cr.currentValues = dto.currentValues;
        cr.comments = dto.comments;
        cr.dueDate = dto.dueDate;
        cr.priority = dto.priority;
        cr.externalReference = dto.externalReference;
        cr.requestedBy = dto.requestedBy;
        cr.status = ChangeRequestStatus.draft;

        if (!MasterdataGovernanceValidator.isValidChangeRequest(cr))
            return CommandResult(false, "", "Invalid change request data");

        repo.save(cr);
        return CommandResult(true, cr.id.value, "");
    }

    CommandResult submitChangeRequest(TenantId tenantId, ChangeRequestId id, UserId submittedBy) {
        auto cr = repo.find(tenantId, id);
        if (cr.isNull)
            return CommandResult(false, "", "Change request not found");
        if (cr.status != ChangeRequestStatus.draft && cr.status != ChangeRequestStatus.revisionRequested)
            return CommandResult(false, "", "Change request cannot be submitted in current status");

        cr.status = ChangeRequestStatus.submitted;
        cr.requestedBy = submittedBy;
        repo.update(cr);
        return CommandResult(true, cr.id.value, "");
    }

    CommandResult approveChangeRequest(TenantId tenantId, ChangeRequestId id, UserId approvedBy, string reviewerComments) {
        auto cr = repo.find(tenantId, id);
        if (cr.isNull)
            return CommandResult(false, "", "Change request not found");
        if (cr.status != ChangeRequestStatus.submitted && cr.status != ChangeRequestStatus.inReview)
            return CommandResult(false, "", "Change request cannot be approved in current status");

        cr.status = ChangeRequestStatus.approved;
        cr.decidedBy = approvedBy;
        cr.reviewerComments = reviewerComments;
        repo.update(cr);
        return CommandResult(true, cr.id.value, "");
    }

    CommandResult rejectChangeRequest(TenantId tenantId, ChangeRequestId id, UserId rejectedBy, string reviewerComments) {
        auto cr = repo.find(tenantId, id);
        if (cr.isNull)
            return CommandResult(false, "", "Change request not found");
        if (cr.status != ChangeRequestStatus.submitted && cr.status != ChangeRequestStatus.inReview)
            return CommandResult(false, "", "Change request cannot be rejected in current status");

        cr.status = ChangeRequestStatus.rejected;
        cr.decidedBy = rejectedBy;
        cr.reviewerComments = reviewerComments;
        repo.update(cr);
        return CommandResult(true, cr.id.value, "");
    }

    CommandResult requestRevision(TenantId tenantId, ChangeRequestId id, UserId reviewedBy, string reviewerComments) {
        auto cr = repo.find(tenantId, id);
        if (cr.isNull)
            return CommandResult(false, "", "Change request not found");

        cr.status = ChangeRequestStatus.revisionRequested;
        cr.reviewedBy = reviewedBy;
        cr.reviewerComments = reviewerComments;
        repo.update(cr);
        return CommandResult(true, cr.id.value, "");
    }

    CommandResult withdrawChangeRequest(TenantId tenantId, ChangeRequestId id) {
        auto cr = repo.find(tenantId, id);
        if (cr.isNull)
            return CommandResult(false, "", "Change request not found");

        cr.status = ChangeRequestStatus.withdrawn;
        repo.update(cr);
        return CommandResult(true, cr.id.value, "");
    }

    CommandResult deleteChangeRequest(TenantId tenantId, ChangeRequestId id) {
        auto cr = repo.find(tenantId, id);
        if (cr.isNull)
            return CommandResult(false, "", "Change request not found");

        repo.remove(cr);
        return CommandResult(true, cr.id.value, "");
    }
}
