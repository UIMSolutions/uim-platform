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

    size_t countByActivity(TenantId tenantId, ActivityId activityId) {
        return findByActivity(tenantId, activityId).length;
    }
    Assignment[] filterByActivity(Assignment[] assignments, ActivityId activityId) {
        return assignments.filter!(e => e.activityId == activityId).array;
    }
    Assignment[] findByActivity(TenantId tenantId, ActivityId activityId) {
        return filterByActivity(findByTenant(tenantId), activityId);
    }
    void removeByActivity(TenantId tenantId, ActivityId activityId) {
        findByActivity(tenantId, activityId).each!(e => remove(e));
    }

    size_t countByTechnician(TenantId tenantId, TechnicianId technicianId) {
        return findByTechnician(tenantId, technicianId).length;
    }
    Assignment[] filterByTechnician(Assignment[] assignments, TechnicianId technicianId) {
        return assignments.filter!(e => e.technicianId == technicianId).array;
    }
    Assignment[] findByTechnician(TenantId tenantId, TechnicianId technicianId) {
        return filterByTechnician(findByTenant(tenantId), technicianId);
    }
    void removeByTechnician(TenantId tenantId, TechnicianId technicianId) {
        findByTechnician(tenantId, technicianId).each!(e => remove(e));
    }

    size_t countByStatus(TenantId tenantId, AssignmentStatus status) {
        return findByStatus(tenantId, status).length;
    }
    Assignment[] filterByStatus(Assignment[] assignments, AssignmentStatus status) {
        return assignments.filter!(e => e.status == status).array;
    }
    Assignment[] findByStatus(TenantId tenantId, AssignmentStatus status) {
        return filterByStatus(findByTenant(tenantId), status);
    }
    void removeByStatus(TenantId tenantId, AssignmentStatus status) {
        findByStatus(tenantId, status).each!(e => remove(e));
    }

}
