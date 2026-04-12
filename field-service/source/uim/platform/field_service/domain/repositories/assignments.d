/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.domain.repositories.assignment_repository;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

interface AssignmentRepository {
    Assignment[] findAll();
    Assignment* findById(AssignmentId id);
    Assignment[] findByTenant(TenantId tenantId);
    Assignment[] findByActivity(ActivityId activityId);
    Assignment[] findByTechnician(TechnicianId technicianId);
    Assignment[] findByStatus(AssignmentStatus status);
    void save(Assignment assignment);
    void update(Assignment assignment);
    void remove(AssignmentId id);
}
