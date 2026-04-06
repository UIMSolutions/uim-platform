/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.domain.entities.activity;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

struct Activity {
    ActivityId id;
    TenantId tenantId;
    ServiceCallId serviceCallId;
    TechnicianId technicianId;
    string subject;
    string description;
    ActivityType activityType = ActivityType.serviceTask;
    ActivityStatus status = ActivityStatus.draft;
    string plannedStart;
    string plannedEnd;
    string actualStart;
    string actualEnd;
    string travelTime;
    string workTime;
    string address;
    string latitude;
    string longitude;
    string notes;
    string feedbackCode;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}
