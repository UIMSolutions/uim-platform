/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.domain.repositories.service_call_repository;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

interface ServiceCallRepository {
    bool existsById(ServiceCallId id);
    ServiceCall findById(ServiceCallId id);

    ServiceCall[] findAll();
    ServiceCall[] findByTenant(TenantId tenantId);
    ServiceCall[] findByStatus(ServiceCallStatus status);
    ServiceCall[] findByPriority(ServiceCallPriority priority);
    ServiceCall[] findByCustomer(CustomerId customerId);
    
    void save(ServiceCall serviceCall);
    void update(ServiceCall serviceCall);
    void remove(ServiceCallId id);
}
