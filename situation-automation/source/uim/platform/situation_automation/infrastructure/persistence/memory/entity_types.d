/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.infrastructure.persistence.memory.entity_types;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:
class MemoryEntityTypeRepository : EntityTypeRepository {
    private EntityType[] store;

    EntityType findById(EntityTypeId id) {
        foreach (e; store) {
            if (e.id == id)
                return e;
        }
        return EntityType.init;
    }

    EntityType[] findByTenant(TenantId tenantId) {
        return store.filter!(e => e.tenantId == tenantId).array;
    }

    EntityType[] findByCategory(TenantId tenantId, EntityCategory category) {
        return store.filter!(e => e.tenantId == tenantId && e.category == category).array;
    }

    void save(EntityType e) {
        store ~= e;
    }

    void update(EntityType e) {
        foreach (existing; store) {
            if (existing.id == e.id) {
                existing = e;
                return;
            }
        }
    }

    void remove(EntityTypeId id) {
        store = store.filter!(e => e.id != id).array;
    }

    size_t countByTenant(TenantId tenantId) {
        return store.filter!(e => e.tenantId == tenantId).array.length;
    }
}
