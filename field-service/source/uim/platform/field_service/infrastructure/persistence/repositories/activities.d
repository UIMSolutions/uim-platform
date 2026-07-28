/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.infrastructure.persistence.repositories.activities;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

class MemoryActivityRepository : TenantRepository!(Activity, ActivityId), ActivityRepository {


    size_t countByServiceCall(TenantId tenantId, ServiceCallId serviceCallId) {
        return findByServiceCall(tenantId, serviceCallId).length;
    }
    Activity[] filterByServiceCall(Activity[] activities, ServiceCallId serviceCallId) {
        return activities.filter!(e => e.serviceCallId == serviceCallId).array;
    }
    Activity[] findByServiceCall(TenantId tenantId, ServiceCallId serviceCallId) {
        return filterByServiceCall(findByTenant(tenantId), serviceCallId);
    }
    void removeByServiceCall(TenantId tenantId, ServiceCallId serviceCallId) {
        findByServiceCall(tenantId, serviceCallId).each!(e => remove(e));
    }

    size_t countByTechnician(TenantId tenantId, TechnicianId technicianId) {
        return findByTechnician(tenantId, technicianId).length;
    }
    Activity[] filterByTechnician(Activity[] activities, TechnicianId technicianId) {
        return activities.filter!(e => e.technicianId == technicianId).array;
    }
    Activity[] findByTechnician(TenantId tenantId, TechnicianId technicianId) {
        return filterByTechnician(findByTenant(tenantId), technicianId);
    }
    void removeByTechnician(TenantId tenantId, TechnicianId technicianId) {
        findByTechnician(tenantId, technicianId).each!(e => remove(e));
    }

    Activity[] findByStatus(TenantId tenantId, ActivityStatus status) {
        return filterByStatus(findByTenant(tenantId), status);
    }
    Activity[] filterByStatus(Activity[] activities, ActivityStatus status) {
        return activities.filter!(e => e.status == status).array;
    }
    size_t countByStatus(TenantId tenantId, ActivityStatus status) {
        return findByStatus(tenantId, status).length;
    }
    void removeByStatus(TenantId tenantId, ActivityStatus status) {
        findByStatus(tenantId, status).each!(e => remove(e)); 
    }

}
