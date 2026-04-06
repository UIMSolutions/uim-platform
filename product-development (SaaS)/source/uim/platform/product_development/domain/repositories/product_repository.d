/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.product_development.domain.repositories.product_repository;

import uim.platform.product_development;

mixin(ShowModule!());

@safe:

interface ProductRepository {
    Product[] findAll();
    Product* findById(ProductId id);
    Product[] findByTenant(TenantId tenantId);
    Product[] findByType(ProductType productType);
    Product[] findByStatus(ProductStatus status);
    Product[] findByLifecyclePhase(LifecyclePhase phase);
    void save(Product product);
    void update(Product product);
    void remove(ProductId id);
}
