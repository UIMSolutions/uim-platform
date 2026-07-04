/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.domain.repositories.customers;

import uim.platform.customer_identity;

mixin(ShowModule!());

@safe:

interface CustomerRepository : ITenantRepository!(Customer, CustomerId) {
    Customer findByEmail(TenantId tenantId, string email);
    Customer findByPhone(TenantId tenantId, string phone);
    Customer[] findByStatus(TenantId tenantId, CustomerStatus status);
    size_t countByStatus(TenantId tenantId, CustomerStatus status);
    bool emailExists(TenantId tenantId, string email);
}
