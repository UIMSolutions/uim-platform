/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.domain.repositories.customer_repository;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

interface CustomerRepository : ITenantRepository{

    size_t countByType(CustomerType customerType);
    Customer[] findByType(CustomerType customerType);
    void removeByType(CustomerType customerType);

    size_t countByStatus(CustomerStatus status);
    Customer[] findByStatus(CustomerStatus status);
    void removeByStatus(CustomerStatus status);
    
}
