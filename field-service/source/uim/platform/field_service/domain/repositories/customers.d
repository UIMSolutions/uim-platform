/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.domain.repositories.customers;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

interface CustomerRepository : ITenantRepository!(Customer, CustomerId) {

    size_t countByType(TenantId tenantId, CustomerType customerType);
    Customer[] findByType(TenantId tenantId, CustomerType customerType);
    void removeByType(TenantId tenantId, CustomerType customerType);

    size_t countByStatus(TenantId tenantId, CustomerStatus status);
    Customer[] findByStatus(TenantId tenantId, CustomerStatus status);
    void removeByStatus(TenantId tenantId, CustomerStatus status);
    
}
