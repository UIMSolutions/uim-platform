/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.network_asset_collaboration.domain.repositories.indicator_repository;

import uim.platform.network_asset_collaboration;

mixin(ShowModule!());

@safe:

interface IndicatorRepository {
    Indicator[] findAll();
    Indicator* findById(IndicatorId id);
    Indicator[] findByTenant(TenantId tenantId);
    Indicator[] findByEquipment(string equipmentId);
    Indicator[] findByType(IndicatorType indicatorType);
    Indicator[] findByStatus(IndicatorStatus status);
    void save(Indicator indicator);
    void remove(IndicatorId id);
}
