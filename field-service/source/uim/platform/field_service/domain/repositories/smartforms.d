/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.domain.repositories.smartforms;

import uim.platform.field_service;

// mixin(ShowModule!());

@safe:

interface SmartformRepository : ITenantRepository!(Smartform, SmartformId) {

    size_t countByServiceCall(TenantId tenantId, ServiceCallId serviceCallId);
    Smartform[] findByServiceCall(TenantId tenantId, ServiceCallId serviceCallId);
    void removeByServiceCall(TenantId tenantId, ServiceCallId serviceCallId);

    size_t countByActivity(TenantId tenantId, ActivityId activityId);
    Smartform[] findByActivity(TenantId tenantId, ActivityId activityId);
    void removeByActivity(TenantId tenantId, ActivityId activityId);

    size_t countByStatus(TenantId tenantId, SmartformStatus status);
    Smartform[] findByStatus(TenantId tenantId, SmartformStatus status);
    void removeByStatus(TenantId tenantId, SmartformStatus status);
    
}
