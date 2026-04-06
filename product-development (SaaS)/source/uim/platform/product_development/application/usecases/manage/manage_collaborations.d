/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.product_development.application.usecases.manage.manage_collaborations;

import uim.platform.product_development;

mixin(ShowModule!());

@safe:

class ManageCollaborationsUseCase : UIMUseCase {
    private CollaborationRepository repo;

    this(CollaborationRepository repo) {
        this.repo = repo;
    }

    Collaboration* get_(CollaborationId id) {
        return repo.findById(id);
    }

    Collaboration[] list() {
        return repo.findAll();
    }

    Collaboration[] listByProduct(string productId) {
        return repo.findByProduct(productId);
    }

    Collaboration[] listByStatus(CollaborationStatus status) {
        return repo.findByStatus(status);
    }

    Collaboration[] listByAssignee(string assignedTo) {
        return repo.findByAssignee(assignedTo);
    }

    CommandResult create(CollaborationDTO dto) {
        Collaboration c;
        c.id = dto.id;
        c.tenantId = dto.tenantId;
        c.productId = dto.productId;
        c.title = dto.title;
        c.description = dto.description;
        c.assignedTo = dto.assignedTo;
        c.participants = dto.participants;
        c.dueDate = dto.dueDate;
        c.relatedDocumentId = dto.relatedDocumentId;
        c.relatedChangeRequestId = dto.relatedChangeRequestId;
        c.createdBy = dto.createdBy;
        if (!ProductValidator.isValidCollaboration(c))
            return CommandResult(false, "", "Invalid collaboration data");
        repo.save(c);
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(CollaborationDTO dto) {
        auto existing = repo.findById(dto.id);
        if (existing is null)
            return CommandResult(false, "", "Collaboration not found");
        if (dto.title.length > 0) existing.title = dto.title;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.assignedTo.length > 0) existing.assignedTo = dto.assignedTo;
        if (dto.resolution.length > 0) existing.resolution = dto.resolution;
        if (dto.modifiedBy.length > 0) existing.modifiedBy = dto.modifiedBy;
        repo.update(*existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(CollaborationId id) {
        auto existing = repo.findById(id);
        if (existing is null)
            return CommandResult(false, "", "Collaboration not found");
        repo.remove(id);
        return CommandResult(true, id, "");
    }
}
