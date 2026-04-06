/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.asset_strategy_performance.domain.repositories.location_repository;

import uim.platform.asset_strategy_performance;

mixin(ShowModule!());

@safe:

interface LocationRepository {
    Location[] findAll();
    Location* findById(LocationId id);
    Location[] findByTenant(TenantId tenantId);
    Location[] findByType(LocationType locationType);
    Location[] findByParent(LocationId parentId);
    void save(Location location);
    void update(Location location);
    void remove(LocationId id);
}
