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

    size_t countByCategory(ComponentCategory category) {
        return findByCategory(category).length;
    }

    UIComponent[] findByCategory(ComponentCategory category) {
        return findAll.filter!(e => e.category == category).array;
    }

    void removeByCategory(ComponentCategory category) {
        findByCategory(category).each!(e => remove(e));
    }

}
