/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.infrastructure.persistence.memory.customers;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

class MemoryCustomerRepository : CustomerRepository {
    private Customer[] store;

    bool existsById(CustomerId id) {
        return store.any!(e => e.id == id);
    }

    Customer[] findAll() { return store; }

    Customer[] findByTenant(TenantId tenantId) {
        return store.filter!(e => e.tenantId == tenantId).array;
    }

    Customer[] findByType(CustomerType customerType) {
        return store.filter!(e => e.customerType == customerType).array;
    }

    Customer[] findByStatus(CustomerStatus status) {
        return store.filter!(e => e.status == status).array;
    }

    void save(Customer customer) { store ~= customer; }

    void update(Customer customer) {
        foreach (e; store)
            if (e.id == customer.id) { e = customer; return; }
    }

    void remove(CustomerId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
