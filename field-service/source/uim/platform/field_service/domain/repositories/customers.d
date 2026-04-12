/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.domain.repositories.customer_repository;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

interface CustomerRepository {
    bool existsById(CustomerId id);
    Customer findById(CustomerId id);
    
    Customer[] findAll();
    Customer[] findByTenant(TenantId tenantId);
    Customer[] findByType(CustomerType customerType);
    Customer[] findByStatus(CustomerStatus status);
    
    void save(Customer customer);
    void update(Customer customer);
    void remove(CustomerId id);
}
