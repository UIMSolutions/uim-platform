/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.product_development.domain.repositories.product_structure_repository;

import uim.platform.product_development;

mixin(ShowModule!());

@safe:

interface ProductStructureRepository {
    ProductStructure[] findAll();
    ProductStructure* findById(ProductStructureId id);
    ProductStructure[] findByTenant(TenantId tenantId);
    ProductStructure[] findByProduct(string productId);
    ProductStructure[] findByParent(string parentNodeId);
    void save(ProductStructure ps);
    void update(ProductStructure ps);
    void remove(ProductStructureId id);
}
