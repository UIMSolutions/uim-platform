/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.domain.repositories.service_calls;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

interface ServiceCallRepository : ITenantRepository!(ServiceCall, ServiceCallId) {

    size_t countByStatus(ServiceCallStatus status);
    ServiceCall[] findByStatus(ServiceCallStatus status);
    void removeByStatus(ServiceCallStatus status);

    size_t countByPriority(ServiceCallPriority priority);
    ServiceCall[] findByPriority(ServiceCallPriority priority);
    void removeByPriority(ServiceCallPriority priority);

    size_t countByCustomer(CustomerId customerId);
    ServiceCall[] findByCustomer(CustomerId customerId);
    void removeByCustomer(CustomerId customerId);
    
}
