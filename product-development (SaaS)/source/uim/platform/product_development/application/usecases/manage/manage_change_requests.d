/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.product_development.application.usecases.manage.manage_change_requests;

import uim.platform.product_development;

mixin(ShowModule!());

@safe:

class ManageChangeRequestsUseCase : UIMUseCase {
    private ChangeRequestRepository repo;

    this(ChangeRequestRepository repo) {
        this.repo = repo;
    }

    ChangeRequest* get_(ChangeRequestId id) {
        return repo.findById(id);
    }

    ChangeRequest[] list() {
        return repo.findAll();
    }

    ChangeRequest[] listByProduct(string productId) {
        return repo.findByProduct(productId);
    }

    ChangeRequest[] listByStatus(ChangeRequestStatus status) {
        return repo.findByStatus(status);
    }

    ChangeRequest[] listByAssignee(string assignedTo) {
        return repo.findByAssignee(assignedTo);
    }

    CommandResult create(ChangeRequestDTO dto) {
        ChangeRequest cr;
        cr.id = dto.id;
        cr.tenantId = dto.tenantId;
        cr.productId = dto.productId;
        cr.title = dto.title;
        cr.description = dto.description;
        cr.reason = dto.reason;
        cr.impact = dto.impact;
        cr.requestedBy = dto.requestedBy;
        cr.assignedTo = dto.assignedTo;
        cr.requestedDate = dto.requestedDate;
        cr.targetDate = dto.targetDate;
        cr.affectedDocuments = dto.affectedDocuments;
        cr.affectedBoms = dto.affectedBoms;
        cr.createdBy = dto.createdBy;
        if (!ProductValidator.isValidChangeRequest(cr))
            return CommandResult(false, "", "Invalid change request data");
        repo.save(cr);
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(ChangeRequestDTO dto) {
        auto existing = repo.findById(dto.id);
        if (existing is null)
            return CommandResult(false, "", "Change request not found");
        if (dto.title.length > 0) existing.title = dto.title;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.assignedTo.length > 0) existing.assignedTo = dto.assignedTo;
        if (dto.impact.length > 0) existing.impact = dto.impact;
        if (dto.targetDate.length > 0) existing.targetDate = dto.targetDate;
        if (dto.modifiedBy.length > 0) existing.modifiedBy = dto.modifiedBy;
        repo.update(*existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(ChangeRequestId id) {
        auto existing = repo.findById(id);
        if (existing is null)
            return CommandResult(false, "", "Change request not found");
        repo.remove(id);
        return CommandResult(true, id, "");
    }
}
