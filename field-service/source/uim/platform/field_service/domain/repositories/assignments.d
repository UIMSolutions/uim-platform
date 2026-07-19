/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.domain.repositories.assignments;

import uim.platform.field_service;
mixin(ShowModule!());

@safe:

interface AssignmentRepository : ITenantRepository!(Assignment, AssignmentId) {

    size_t countByActivity(TenantId tenantId, ActivityId activityId);
    Assignment[] findByActivity(TenantId tenantId, ActivityId activityId);
    void removeByActivity(TenantId tenantId, ActivityId activityId);

    size_t countByTechnician(TenantId tenantId, TechnicianId technicianId);
    Assignment[] findByTechnician(TenantId tenantId, TechnicianId technicianId);
    void removeByTechnician(TenantId tenantId, TechnicianId technicianId);

    size_t countByStatus(TenantId tenantId, AssignmentStatus status);
    Assignment[] findByStatus(TenantId tenantId, AssignmentStatus status);
    void removeByStatus(TenantId tenantId, AssignmentStatus status);

}
