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

    size_t countByStatus(ServiceCallStatus status) {
        return findByStatus(status).length;
    }
    ServiceCall[] filterByStatus(ServiceCall[] serviceCalls, ServiceCallStatus status) {
        return serviceCalls.filter!(e => e.status == status).array;
    }
    ServiceCall[] findByStatus(ServiceCallStatus status) {
        return filterByStatus(findAll(), status);
    }
    void removeByStatus(ServiceCallStatus status) {
        findByStatus(status).each!(entity => remove(entity));
    }

    size_t countByPriority(ServiceCallPriority priority) {
        return findByPriority(priority).length;
    }
    ServiceCall[] filterByPriority(ServiceCall[] serviceCalls, ServiceCallPriority priority) {
        return serviceCalls.filter!(e => e.priority == priority).array;
    }
    ServiceCall[] findByPriority(ServiceCallPriority priority) {
        return filterByPriority(findAll(), priority);
    }
    void removeByPriority(ServiceCallPriority priority) {
        findByPriority(priority).each!(entity => remove(entity));
    }

    size_t countByCustomer(CustomerId customerId) {
        return findByCustomer(customerId).length;
    }
    ServiceCall[] filterByCustomer(ServiceCall[] serviceCalls, CustomerId customerId) {
        return serviceCalls.filter!(e => e.customerId == customerId).array;
    }
    ServiceCall[] findByCustomer(CustomerId customerId) {
        return filterByCustomer(findAll(), customerId);
    }
    void removeByCustomer(CustomerId customerId) {
        findByCustomer(customerId).each!(entity => remove(entity));
    }

}
