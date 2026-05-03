/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.infrastructure.persistence.memory.entity_types;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:
class MemoryEntityTypeRepository : TenantRepository!(EntityType, EntityTypeId), EntityTypeRepository {

    size_t countByCategory(TenantId tenantId, EntityCategory category) {
        return findByCategory(tenantId, category).length;
    }

    EntityType[] findByCategory(TenantId tenantId, EntityCategory category) {
        return findAll().filter!(e => e.tenantId == tenantId && e.category == category).array;
    }

    void removeByCategory(TenantId tenantId, EntityCategory category) {
        store = findAll().filter!(e => !(e.tenantId == tenantId && e.category == category)).array;
    }
}
