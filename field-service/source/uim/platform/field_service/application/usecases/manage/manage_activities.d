/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.application.usecases.manage.manage.activities;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

class ManageActivitiesUseCase : UIMUseCase {
    private ActivityRepository repo;

    this(ActivityRepository repo) {
        this.repo = repo;
    }

    Activity* get_(ActivityId id) {
        return repo.findById(id);
    }

    Activity[] list() {
        return repo.findAll();
    }

    Activity[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Activity[] listByServiceCall(ServiceCallId serviceCallId) {
        return repo.findByServiceCall(serviceCallId);
    }

    Activity[] listByTechnician(TechnicianId technicianId) {
        return repo.findByTechnician(technicianId);
    }

    CommandResult create(ActivityDTO dto) {
        Activity a;
        a.id = dto.id;
        a.tenantId = dto.tenantId;
        a.serviceCallId = dto.serviceCallId;
        a.technicianId = dto.technicianId;
        a.subject = dto.subject;
        a.description = dto.description;
        a.plannedStart = dto.plannedStart;
        a.plannedEnd = dto.plannedEnd;
        a.address = dto.address;
        a.latitude = dto.latitude;
        a.longitude = dto.longitude;
        a.notes = dto.notes;
        a.createdBy = dto.createdBy;
        if (!FieldServiceValidator.isValidActivity(a))
            return CommandResult(false, "", "Invalid activity data");
        repo.save(a);
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(ActivityDTO dto) {
        auto existing = repo.findById(dto.id);
        if (existing is null)
            return CommandResult(false, "", "Activity not found");
        if (dto.subject.length > 0) existing.subject = dto.subject;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.plannedStart.length > 0) existing.plannedStart = dto.plannedStart;
        if (dto.plannedEnd.length > 0) existing.plannedEnd = dto.plannedEnd;
        if (dto.actualStart.length > 0) existing.actualStart = dto.actualStart;
        if (dto.actualEnd.length > 0) existing.actualEnd = dto.actualEnd;
        if (dto.notes.length > 0) existing.notes = dto.notes;
        if (dto.feedbackCode.length > 0) existing.feedbackCode = dto.feedbackCode;
        if (dto.modifiedBy.length > 0) existing.modifiedBy = dto.modifiedBy;
        repo.update(*existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(ActivityId id) {
        auto existing = repo.findById(id);
        if (existing is null)
            return CommandResult(false, "", "Activity not found");
        repo.remove(id);
        return CommandResult(true, id, "");
    }
}
