/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.product_development.domain.repositories.bom_repository;

import uim.platform.product_development;

mixin(ShowModule!());

@safe:

interface BillOfMaterialRepository {
    BillOfMaterial[] findAll();
    BillOfMaterial* findById(BillOfMaterialId id);
    BillOfMaterial[] findByTenant(TenantId tenantId);
    BillOfMaterial[] findByProduct(string productId);
    BillOfMaterial[] findByType(BomType bomType);
    void save(BillOfMaterial bom);
    void update(BillOfMaterial bom);
    void remove(BillOfMaterialId id);
}
