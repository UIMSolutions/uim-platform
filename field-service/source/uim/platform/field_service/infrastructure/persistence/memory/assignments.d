/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.infrastructure.persistence.memory.assignments;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

class MemoryAssignmentRepository : TenantRepository!(Assignment, AssignmentId), AssignmentRepository {

    size_t countByActivity(ActivityId activityId) {
        return findByActivity(activityId).length;
    }
    Assignment[] filterByActivity(Assignment[] assignments, ActivityId activityId) {
        return assignments.filter!(e => e.activityId == activityId).array;
    }
    Assignment[] findByActivity(ActivityId activityId) {
        return filterByActivity(findAll(), activityId);
    }
    void removeByActivity(ActivityId activityId) {
        findByActivity(activityId).each!(e => remove(e));
    }

    size_t countByTechnician(TechnicianId technicianId) {
        return findByTechnician(technicianId).length;
    }
    Assignment[] filterByTechnician(Assignment[] assignments, TechnicianId technicianId) {
        return assignments.filter!(e => e.technicianId == technicianId).array;
    }
    Assignment[] findByTechnician(TechnicianId technicianId) {
        return filterByTechnician(findAll(), technicianId);
    }
    void removeByTechnician(TechnicianId technicianId) {
        findByTechnician(technicianId).each!(e => remove(e));
    }

    size_t countByStatus(AssignmentStatus status) {
        return findByStatus(status).length;
    }
    Assignment[] filterByStatus(Assignment[] assignments, AssignmentStatus status) {
        return assignments.filter!(e => e.status == status).array;
    }
    Assignment[] findByStatus(AssignmentStatus status) {
        return filterByStatus(findAll(), status);
    }
    void removeByStatus(AssignmentStatus status) {
        findByStatus(status).each!(e => remove(e));
    }

}
