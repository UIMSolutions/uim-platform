/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.network_asset_collaboration.domain.repositories.spare_part_repository;

import uim.platform.network_asset_collaboration;

mixin(ShowModule!());

@safe:

interface SparePartRepository {
    SparePart[] findAll();
    SparePart* findById(SparePartId id);
    SparePart[] findByTenant(TenantId tenantId);
    SparePart[] findByModel(string modelId);
    SparePart[] findByPartNumber(string partNumber);
    SparePart[] findByManufacturer(string manufacturer);
    void save(SparePart sparePart);
    void update(SparePart sparePart);
    void remove(SparePartId id);
}
