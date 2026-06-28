/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.application.usecases.manage.activities;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

class ManageActivitiesUseCase { // TODO: UIMUseCase {
    private ActivityRepository repo;

    this(ActivityRepository repo) {
        this.repo = repo;
    }

    Activity getActivity(TenantId tenantId, ActivityId id) {
        return repo.find(tenantId, id);
    }

    Activity[] listActivities(TenantId tenantId) {
        return repo.find(tenantId);
    }

    Activity[] listActivities(TenantId tenantId, ServiceCallId serviceCallId) {
        return repo.findByServiceCall(tenantId, serviceCallId);
    }

    Activity[] listActivities(TenantId tenantId, TechnicianId technicianId) {
        return repo.findByTechnician(tenantId, technicianId);
    }

    CommandResult createActivity(ActivityDTO dto) {
        Activity activity;
        activity.id = dto.activityId;
        activity.tenantId = dto.tenantId;
        activity.serviceCallId = dto.serviceCallId;
        activity.technicianId = dto.technicianId;
        activity.subject = dto.subject;
        activity.description = dto.description;
        activity.plannedStart = dto.plannedStart;
        activity.plannedEnd = dto.plannedEnd;
        activity.address = dto.address;
        activity.latitude = dto.latitude;
        activity.longitude = dto.longitude;
        activity.notes = dto.notes;
        activity.createdBy = dto.createdBy;
        if (!FieldServiceValidator.isValidActivity(activity))
            return CommandResult(false, "", "Invalid activity data");

        repo.save(activity);
        return CommandResult(true, activity.id.value, "");
    }

    CommandResult updateActivity(ActivityDTO dto) {
        auto activity = repo.findById(dto.tenantId, dto.activityId);
        if (activity.isNull)
            return CommandResult(false, "", "Activity not found");
        if (dto.subject.length > 0) activity.subject = dto.subject;
        if (dto.description.length > 0) activity.description = dto.description;
        if (dto.plannedStart.length > 0) activity.plannedStart = dto.plannedStart;
        if (dto.plannedEnd.length > 0) activity.plannedEnd = dto.plannedEnd;
        if (dto.actualStart.length > 0) activity.actualStart = dto.actualStart;
        if (dto.actualEnd.length > 0) activity.actualEnd = dto.actualEnd;
        if (dto.notes.length > 0) activity.notes = dto.notes;
        if (dto.feedbackCode.length > 0) activity.feedbackCode = dto.feedbackCode;
        if (!dto.updatedBy.isNull) activity.updatedBy = dto.updatedBy;
        
        repo.update(activity);
        return CommandResult(true, activity.id.value, "");
    }

    CommandResult deleteActivity(TenantId tenantId, ActivityId id) {
        auto activity = repo.find(tenantId, id);
        if (activity.isNull)
            return CommandResult(false, "", "Activity not found");
            
        repo.remove(activity);
        return CommandResult(true, activity.id.value, "");
    }
}
