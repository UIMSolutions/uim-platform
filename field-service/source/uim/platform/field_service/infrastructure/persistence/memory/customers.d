/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.infrastructure.persistence.memory.customers;

import uim.platform.field_service;

// mixin(ShowModule!());

@safe:

class MemoryCustomerRepository : TenantRepository!(Customer, CustomerId), CustomerRepository {

    size_t countByType(TenantId tenantId, CustomerType customerType) {
        return findByType(tenantId, customerType).length;
    }

    Customer[] filterByType(Customer[] customers, CustomerType customerType) {
        return customers.filter!(e => e.customerType == customerType).array;
    }

    Customer[] findByType(TenantId tenantId, CustomerType customerType) {
        return filterByType(findByTenant(tenantId), customerType);
    }

    void removeByType(TenantId tenantId, CustomerType customerType) {
        findByType(tenantId, customerType).each!(e => remove(e));
    }

    size_t countByStatus(TenantId tenantId, CustomerStatus status) {
        return findByStatus(tenantId, status).length;
    }

    Customer[] filterByStatus(Customer[] customers, CustomerStatus status) {
        return customers.filter!(e => e.status == status).array;
    }

    Customer[] findByStatus(TenantId tenantId, CustomerStatus status) {
        return filterByStatus(findByTenant(tenantId), status);
    }

    void removeByStatus(TenantId tenantId, CustomerStatus status) {
        findByStatus(tenantId, status).each!(e => remove(e));
    }

}
