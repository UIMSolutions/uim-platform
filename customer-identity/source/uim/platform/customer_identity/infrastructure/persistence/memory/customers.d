/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.infrastructure.persistence.memory.customers;

import uim.platform.customer_identity;

// mixin(ShowModule!());

@safe:

class MemoryCustomerRepository : TenantRepository!(Customer, CustomerId), CustomerRepository {

    Customer findByEmail(TenantId tenantId, string email) {
        auto items = findByTenant(tenantId).filter!(c => c.email == email).array;
        return items.length > 0 ? items[0] : Customer.init;
    }

    Customer findByPhone(TenantId tenantId, string phone) {
        auto items = findByTenant(tenantId).filter!(c => c.phone == phone).array;
        return items.length > 0 ? items[0] : Customer.init;
    }

    Customer[] findByStatus(TenantId tenantId, CustomerStatus status) {
        return findByTenant(tenantId).filter!(c => c.status == status).array;
    }

    size_t countByStatus(TenantId tenantId, CustomerStatus status) {
        return findByStatus(tenantId, status).length;
    }

    bool emailExists(TenantId tenantId, string email) {
        return findByTenant(tenantId).any!(c => c.email == email);
    }
}
