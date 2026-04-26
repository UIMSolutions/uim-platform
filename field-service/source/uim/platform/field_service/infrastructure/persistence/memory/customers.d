/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.infrastructure.persistence.memory.customers;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

class MemoryCustomerRepository : TenantRepository!(Customer, CustomerId), CustomerRepository {

    size_t countByType(CustomerType customerType) {
        return findByType(customerType).length;
    }

    Customer[] filterByType(Customer[] customers, CustomerType customerType) {
        return customers.filter!(e => e.customerType == customerType).array;
    }

    Customer[] findByType(CustomerType customerType) {
        return filterByType(findAll(), customerType);
    }

    void removeByType(CustomerType customerType) {
        findByType(customerType).each!(e => remove(e));
    }

    size_t countByStatus(CustomerStatus status) {
        return findByStatus(status).length;
    }

    Customer[] filterByStatus(Customer[] customers, CustomerStatus status) {
        return customers.filter!(e => e.status == status).array;
    }

    Customer[] findByStatus(CustomerStatus status) {
        return filterByStatus(findAll(), status);
    }

    void removeByStatus(CustomerStatus status) {
        findByStatus(status).each!(e => remove(e));
    }

}
