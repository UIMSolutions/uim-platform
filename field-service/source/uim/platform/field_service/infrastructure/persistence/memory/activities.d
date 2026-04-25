/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.infrastructure.persistence.memory.activities;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

class MemoryActivityRepository : TenantRepository!(Activity, ActivityId), ActivityRepository {

    Activity[] findByTenant(TenantId tenantId) {
        return findAll.filter!(e => e.tenantId == tenantId).array;
    }

    Activity[] findByServiceCall(ServiceCallId serviceCallId) {
        return findAll.filter!(e => e.serviceCallId == serviceCallId).array;
    }

    Activity[] findByTechnician(TechnicianId technicianId) {
        return findAll.filter!(e => e.technicianId == technicianId).array;
    }

    Activity[] findByStatus(ActivityStatus status) {
        return findAll.filter!(e => e.status == status).array;
    }

}
