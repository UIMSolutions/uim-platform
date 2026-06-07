/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.domain.repositories.service_calls;

import uim.platform.field_service;

// mixin(ShowModule!());

@safe:

interface ServiceCallRepository : ITenantRepository!(ServiceCall, ServiceCallId) {

    size_t countByStatus(TenantId tenantId, ServiceCallStatus status);
    ServiceCall[] findByStatus(TenantId tenantId, ServiceCallStatus status);
    void removeByStatus(TenantId tenantId, ServiceCallStatus status);

    size_t countByPriority(TenantId tenantId, ServiceCallPriority priority);
    ServiceCall[] findByPriority(TenantId tenantId, ServiceCallPriority priority);
    void removeByPriority(TenantId tenantId, ServiceCallPriority priority);

    size_t countByCustomer(TenantId tenantId, CustomerId customerId);
    ServiceCall[] findByCustomer(TenantId tenantId, CustomerId customerId);
    void removeByCustomer(TenantId tenantId, CustomerId customerId);
    
}
