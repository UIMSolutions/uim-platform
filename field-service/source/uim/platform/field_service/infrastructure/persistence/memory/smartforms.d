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

    size_t countByServiceCall(TenantId tenantId, ServiceCallId serviceCallId) {
        return findByServiceCall(tenantId, serviceCallId).length;
    }
    Smartform[] filterByServiceCall(Smartform[] smartforms, ServiceCallId serviceCallId) {
        return smartforms.filter!(e => e.serviceCallId == serviceCallId).array;
    }
    Smartform[] findByServiceCall(TenantId tenantId, ServiceCallId serviceCallId) {
        return findByTenant(tenantId).filter!(e => e.tenantId == tenantId && e.serviceCallId == serviceCallId).array;
    }
    void removeByServiceCall(TenantId tenantId, ServiceCallId serviceCallId) {
        findByServiceCall(tenantId, serviceCallId).each!(entity => remove(entity));
    }

    size_t countByActivity(TenantId tenantId, ActivityId activityId) {
        return findByActivity(tenantId, activityId).length;
    }
    Smartform[] filterByActivity(Smartform[] smartforms, ActivityId activityId) {
        return smartforms.filter!(e => e.activityId == activityId).array;
    }
    Smartform[] findByActivity(TenantId tenantId, ActivityId activityId) {
        return findByTenant(tenantId).filter!(e => e.tenantId == tenantId && e.activityId == activityId).array;
    }
    void removeByActivity(TenantId tenantId, ActivityId activityId) {
        findByActivity(tenantId, activityId).each!(entity => remove(entity));
    }

    size_t countByStatus(TenantId tenantId, SmartformStatus status) {
        return findByStatus(tenantId, status).length;
    }
    Smartform[] filterByStatus(Smartform[] smartforms, SmartformStatus status) {
        return smartforms.filter!(e => e.status == status).array;
    }   
    Smartform[] findByStatus(TenantId tenantId, SmartformStatus status) {
        return findByTenant(tenantId).filter!(e => e.tenantId == tenantId && e.status == status).array;
    }
    void removeByStatus(TenantId tenantId, SmartformStatus status) {
        findByStatus(tenantId, status).each!(entity => remove(entity));
    }

}
