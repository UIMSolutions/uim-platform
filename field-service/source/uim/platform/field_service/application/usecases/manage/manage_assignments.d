/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.application.usecases.manage.manage_assignments;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

class ManageAssignmentsUseCase : UIMUseCase {
    private AssignmentRepository repo;

    this(AssignmentRepository repo) {
        this.repo = repo;
    }

    Assignment* get_(AssignmentId id) {
        return repo.findById(id);
    }

    Assignment[] list() {
        return repo.findAll();
    }

    Assignment[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Assignment[] listByActivity(ActivityId activityId) {
        return repo.findByActivity(activityId);
    }

    Assignment[] listByTechnician(TechnicianId technicianId) {
        return repo.findByTechnician(technicianId);
    }

    CommandResult create(AssignmentDTO dto) {
        Assignment a;
        a.id = dto.id;
        a.tenantId = dto.tenantId;
        a.activityId = dto.activityId;
        a.technicianId = dto.technicianId;
        a.assignedDate = dto.assignedDate;
        a.schedulingPolicy = dto.schedulingPolicy;
        a.matchScore = dto.matchScore;
        a.notes = dto.notes;
        a.createdBy = dto.createdBy;
        if (!FieldServiceValidator.isValidAssignment(a))
            return CommandResult(false, "", "Invalid assignment data");
        repo.save(a);
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(AssignmentDTO dto) {
        auto existing = repo.findById(dto.id);
        if (existing is null)
            return CommandResult(false, "", "Assignment not found");
        if (dto.acceptedDate.length > 0) existing.acceptedDate = dto.acceptedDate;
        if (dto.startedDate.length > 0) existing.startedDate = dto.startedDate;
        if (dto.completedDate.length > 0) existing.completedDate = dto.completedDate;
        if (dto.travelDistance.length > 0) existing.travelDistance = dto.travelDistance;
        if (dto.notes.length > 0) existing.notes = dto.notes;
        if (dto.modifiedBy.length > 0) existing.modifiedBy = dto.modifiedBy;
        repo.update(*existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(AssignmentId id) {
        auto existing = repo.findById(id);
        if (existing is null)
            return CommandResult(false, "", "Assignment not found");
        repo.remove(id);
        return CommandResult(true, id, "");
    }
}
