/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.infrastructure.persistence.memory.ui_components;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class MemoryUIComponentRepository : TenantRepository!(UIComponent, UIComponentId), UIComponentRepository {

    size_t countByCategory(TenantId tenantId, ComponentCategory category) {
        return findByCategory(tenantId, category).length;
    }

    UIComponent[] filterByCategory(UIComponent[] components, ComponentCategory category) {
        return components.filter!(e => e.category == category).array;
    }

    UIComponent[] findByCategory(TenantId tenantId, ComponentCategory category) {
        return filterByCategory(findByTenant(tenantId), category);
    }

    void removeByCategory(TenantId tenantId, ComponentCategory category) {
        findByCategory(tenantId, category).each!(e => remove(e));
    }

}
    
