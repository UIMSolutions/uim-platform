/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.domain.repositories.activities;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

interface ActivityRepository : ITentRepository!(Activity, ActivityId) {

    size_t countByServiceCall(TenantId tenantId, ServiceCallId serviceCallId);
    Activity[] findByServiceCall(TenantId tenantId, ServiceCallId serviceCallId);
    void removeByServiceCall(TenantId tenantId, ServiceCallId serviceCallId);

    size_t countByTechnician(TenantId tenantId, TechnicianId technicianId);
    Activity[] findByTechnician(TenantId tenantId, TechnicianId technicianId);
    void removeByTechnician(TenantId tenantId, TechnicianId technicianId);

    size_t countByStatus(TenantId tenantId, ActivityStatus status);
    Activity[] findByStatus(TenantId tenantId, ActivityStatus status);
    void removeByStatus(TenantId tenantId, ActivityStatus status);
    
}
