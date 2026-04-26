/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.infrastructure.persistence.memory.smartforms;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

class MemorySmartformRepository : TenantRepository!(Smartform, SmartformId), SmartformRepository {

    size_t countByServiceCall(ServiceCallId serviceCallId) {
        return findByServiceCall(serviceCallId).length;
    }
    Smartform[] filterByServiceCall(Smartform[] smartforms, ServiceCallId serviceCallId) {
        return smartforms.filter!(e => e.serviceCallId == serviceCallId).array;
    }
    Smartform[] findByServiceCall(ServiceCallId serviceCallId) {
        return findAll().filter!(e => e.serviceCallId == serviceCallId).array;
    }
    void removeByServiceCall(ServiceCallId serviceCallId) {
        findByServiceCall(serviceCallId).each!(e => remove(e.id));
    }

    size_t countByActivity(ActivityId activityId) {
        return findByActivity(activityId).length;
    }
    Smartform[] filterByActivity(Smartform[] smartforms, ActivityId activityId) {
        return smartforms.filter!(e => e.activityId == activityId).array;
    }
    Smartform[] findByActivity(ActivityId activityId) {
        return findAll().filter!(e => e.activityId == activityId).array;
    }
    void removeByActivity(ActivityId activityId) {
        findByActivity(activityId).each!(e => remove(e.id));
    }

    size_t countByStatus(SmartformStatus status) {
        return findByStatus(status).length;
    }
    Smartform[] filterByStatus(Smartform[] smartforms, SmartformStatus status) {
        return smartforms.filter!(e => e.status == status).array;
    }   
    Smartform[] findByStatus(SmartformStatus status) {
        return findAll().filter!(e => e.status == status).array;
    }
    void removeByStatus(SmartformStatus status) {
        findByStatus(status).each!(e => remove(e.id));
    }

}
