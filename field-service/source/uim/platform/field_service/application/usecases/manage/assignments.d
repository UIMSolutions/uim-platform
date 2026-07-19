/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.application.usecases.manage.assignments;

import uim.platform.field_service;
mixin(ShowModule!());

@safe:

class ManageAssignmentsUseCase { // TODO: UIMUseCase {
    private AssignmentRepository repo;

    this(AssignmentRepository repo) {
        this.repo = repo;
    }

    Assignment getAssignment(TenantId tenantId, AssignmentId id) {
        return repo.findById(tenantId, id);
    }

    Assignment[] listAssignments(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Assignment[] listAssignments(TenantId tenantId, ActivityId activityId) {
        return repo.findByActivity(tenantId, activityId);
    }

    Assignment[] listAssignments(TenantId tenantId, TechnicianId technicianId) {
        return repo.findByTechnician(tenantId, technicianId);
    }

    CommandResult createAssignment(AssignmentDTO dto) {
        auto assignment = Assignment(dto.tenantId, dto.assignmentId, dto.createdBy);
        assignment.activityId = dto.activityId;
        assignment.technicianId = dto.technicianId;
        assignment.assignedDate = dto.assignedDate;
        assignment.schedulingPolicy = dto.schedulingPolicy;
        assignment.matchScore = dto.matchScore;
        assignment.notes = dto.notes;
        if (!FieldServiceValidator.isValidAssignment(assignment))
            return CommandResult(false, "", "Invalid assignment data");

        repo.save(assignment);
        return CommandResult(true, assignment.id.value, "");
    }

    CommandResult updateAssignment(AssignmentDTO dto) {
        auto assignment = repo.findById(dto.tenantId, dto.assignmentId);
        if (assignment.isNull)
            return CommandResult(false, "", "Assignment not found");
        if (dto.acceptedDate.length > 0) assignment.acceptedDate = dto.acceptedDate;
        if (dto.startedDate.length > 0) assignment.startedDate = dto.startedDate;
        if (dto.completedDate.length > 0) assignment.completedDate = dto.completedDate;
        if (dto.travelDistance.length > 0) assignment.travelDistance = dto.travelDistance;
        if (dto.notes.length > 0) assignment.notes = dto.notes;
        if (!dto.updatedBy.isNull) assignment.updatedBy = dto.updatedBy;
        repo.update(assignment);
        return CommandResult(true, assignment.id.value, "");
    }

    CommandResult deleteAssignment(TenantId tenantId, AssignmentId id) {
        auto assignment = repo.findById(tenantId, id);
        if (assignment.isNull)
            return CommandResult(false, "", "Assignment not found");

        repo.remove(assignment);
        return CommandResult(true, assignment.id.value, "");
    }
}
