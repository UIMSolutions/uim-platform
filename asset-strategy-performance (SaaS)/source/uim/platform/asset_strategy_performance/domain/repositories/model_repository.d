/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.asset_strategy_performance.domain.repositories.model_repository;

import uim.platform.asset_strategy_performance;

mixin(ShowModule!());

@safe:

interface ModelRepository {
    Model[] findAll();
    Model* findById(ModelId id);
    Model[] findByTenant(TenantId tenantId);
    Model[] findByCategory(ModelCategory category);
    Model[] findByManufacturer(string manufacturer);
    void save(Model model);
    void update(Model model);
    void remove(ModelId id);
}
