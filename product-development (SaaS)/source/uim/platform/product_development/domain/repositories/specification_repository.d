/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.product_development.domain.repositories.specification_repository;

import uim.platform.product_development;

mixin(ShowModule!());

@safe:

interface SpecificationRepository {
    Specification[] findAll();
    Specification* findById(SpecificationId id);
    Specification[] findByTenant(TenantId tenantId);
    Specification[] findByProduct(string productId);
    Specification[] findByType(SpecificationType specType);
    void save(Specification spec);
    void update(Specification spec);
    void remove(SpecificationId id);
}
