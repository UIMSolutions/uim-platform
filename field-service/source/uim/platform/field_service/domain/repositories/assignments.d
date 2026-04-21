/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.domain.repositories.assignment_repository;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

interface AssignmentRepository : ITenantRepository!(Assignment, AssignmentId) {

    size_t countByActivity(ActivityId activityId);
    Assignment[] findByActivity(ActivityId activityId);
    void removeByActivity(ActivityId activityId);

    size_t countByTechnician(TechnicianId technicianId);
    Assignment[] findByTechnician(TechnicianId technicianId);
    void removeByTechnician(TechnicianId technicianId);

    size_t countByStatus(AssignmentStatus status);
    Assignment[] findByStatus(AssignmentStatus status);
    void removeByStatus(AssignmentStatus status);

}
