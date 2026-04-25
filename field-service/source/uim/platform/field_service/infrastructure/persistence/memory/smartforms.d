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


    Smartform[] findByTenant(TenantId tenantId) {
        return findAll().filter!(e => e.tenantId == tenantId).array;
    }

    Smartform[] findByServiceCall(ServiceCallId serviceCallId) {
        return findAll().filter!(e => e.serviceCallId == serviceCallId).array;
    }

    Smartform[] findByActivity(ActivityId activityId) {
        return findAll().filter!(e => e.activityId == activityId).array;
    }

    Smartform[] findByStatus(SmartformStatus status) {
        return findAll().filter!(e => e.status == status).array;
    }

}
