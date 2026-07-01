/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.domain.repositories.ui_components;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

interface UIComponentRepository : ITenantRepository!(UIComponent, UIComponentId) {

    size_t countByCategory(TenantId tenantId, ComponentCategory category);
    UIComponent[] findByCategory(TenantId tenantId, ComponentCategory category);
    void removeByCategory(TenantId tenantId, ComponentCategory category);

}
