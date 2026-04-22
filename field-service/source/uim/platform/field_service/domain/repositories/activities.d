/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.domain.repositories.activities;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

interface ActivityRepository : ITenantRepository!(Activity, ActivityId) {

    size_t countByServiceCall(ServiceCallId serviceCallId);
    Activity[] findByServiceCall(ServiceCallId serviceCallId);
    void removeByServiceCall(ServiceCallId serviceCallId);

    size_t countByTechnician(TechnicianId technicianId);
    Activity[] findByTechnician(TechnicianId technicianId);
    void removeByTechnician(TechnicianId technicianId);

    size_t countByStatus(ActivityStatus status);
    Activity[] findByStatus(ActivityStatus status);
    void removeByStatus(ActivityStatus status);
    
}
