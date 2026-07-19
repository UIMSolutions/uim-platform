/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.infrastructure.persistence.memory.service_calls;

import uim.platform.field_service;
mixin(ShowModule!());

@safe:

class MemoryServiceCallRepository : TenantRepository!(ServiceCall, ServiceCallId), ServiceCallRepository {

    size_t countByStatus(TenantId tenantId, ServiceCallStatus status) {
        return findByStatus(tenantId, status).length;
    }
    ServiceCall[] filterByStatus(ServiceCall[] serviceCalls, ServiceCallStatus status) {
        return serviceCalls.filter!(e => e.status == status).array;
    }
    ServiceCall[] findByStatus(TenantId tenantId, ServiceCallStatus status) {
        return filterByStatus(findByTenant(tenantId), status);
    }
    void removeByStatus(TenantId tenantId, ServiceCallStatus status) {
        findByStatus(tenantId, status).each!(entity => remove(entity));
    }

    size_t countByPriority(TenantId tenantId, ServiceCallPriority priority) {
        return findByPriority(tenantId, priority).length;
    }
    ServiceCall[] filterByPriority(ServiceCall[] serviceCalls, ServiceCallPriority priority) {
        return serviceCalls.filter!(e => e.priority == priority).array;
    }
    ServiceCall[] findByPriority(TenantId tenantId, ServiceCallPriority priority) {
        return filterByPriority(findByTenant(tenantId), priority);
    }
    void removeByPriority(TenantId tenantId, ServiceCallPriority priority) {
        findByPriority(tenantId, priority).each!(entity => remove(entity));
    }

    size_t countByCustomer(TenantId tenantId, CustomerId customerId) {
        return findByCustomer(tenantId, customerId).length;
    }
    ServiceCall[] filterByCustomer(ServiceCall[] serviceCalls, CustomerId customerId) {
        return serviceCalls.filter!(e => e.customerId == customerId).array;
    }
    ServiceCall[] findByCustomer(TenantId tenantId, CustomerId customerId) {
        return filterByCustomer(findByTenant(tenantId), customerId);
    }
    void removeByCustomer(TenantId tenantId, CustomerId customerId) {
        findByCustomer(tenantId, customerId).each!(entity => remove(entity));
    }

}
