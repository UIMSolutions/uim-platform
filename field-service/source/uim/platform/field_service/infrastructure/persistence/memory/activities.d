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


    size_t countByServiceCall(ServiceCallId serviceCallId) {
        return findByServiceCall(serviceCallId).length;
    }
    Activity[] filterByServiceCall(Activity[] activities, ServiceCallId serviceCallId) {
        return activities.filter!(e => e.serviceCallId == serviceCallId).array;
    }
    Activity[] findByServiceCall(ServiceCallId serviceCallId) {
        return filterByServiceCall(findAll(), serviceCallId);
    }
    void removeByServiceCall(ServiceCallId serviceCallId) {
        findByServiceCall(serviceCallId).each!(e => remove(e));
    }

    size_t countByTechnician(TechnicianId technicianId) {
        return findByTechnician(technicianId).length;
    }
    Activity[] filterByTechnician(Activity[] activities, TechnicianId technicianId) {
        return activities.filter!(e => e.technicianId == technicianId).array;
    }
    Activity[] findByTechnician(TechnicianId technicianId) {
        return filterByTechnician(findAll(), technicianId);
    }
    void removeByTechnician(TechnicianId technicianId) {
        findByTechnician(technicianId).each!(e => remove(e));
    }

    Activity[] findByStatus(ActivityStatus status) {
        return filterByStatus(findAll(), status);
    }
    Activity[] filterByStatus(Activity[] activities, ActivityStatus status) {
        return activities.filter!(e => e.status == status).array;
    }
    size_t countByStatus(ActivityStatus status) {
        return findByStatus(status).length;
    }
    void removeByStatus(ActivityStatus status) {
        findByStatus(status).each!(e => remove(e)); 
    }

}
