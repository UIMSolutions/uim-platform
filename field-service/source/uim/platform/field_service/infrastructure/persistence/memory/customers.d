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

    Customer[] findAll() { return store; }

    Customer* findById(CustomerId id) {
        foreach (ref e; store)
            if (e.id == id) return &e;
        return null;
    }

    Customer[] findByTenant(TenantId tenantId) {
        Customer[] result;
        foreach (ref e; store)
            if (e.tenantId == tenantId) result ~= e;
        return result;
    }

    Customer[] findByType(CustomerType customerType) {
        Customer[] result;
        foreach (ref e; store)
            if (e.customerType == customerType) result ~= e;
        return result;
    }

    Customer[] findByStatus(CustomerStatus status) {
        Customer[] result;
        foreach (ref e; store)
            if (e.status == status) result ~= e;
        return result;
    }

    void save(Customer customer) { store ~= customer; }

    void update(Customer customer) {
        foreach (ref e; store)
            if (e.id == customer.id) { e = customer; return; }
    }

    void remove(CustomerId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
