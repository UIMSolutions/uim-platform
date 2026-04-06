/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.domain.entities.assignment;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

struct Assignment {
    AssignmentId id;
    TenantId tenantId;
    ActivityId activityId;
    TechnicianId technicianId;
    AssignmentStatus status = AssignmentStatus.proposed;
    string assignedDate;
    string acceptedDate;
    string startedDate;
    string completedDate;
    string travelDistance;
    string schedulingPolicy;
    string matchScore;
    string notes;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}
