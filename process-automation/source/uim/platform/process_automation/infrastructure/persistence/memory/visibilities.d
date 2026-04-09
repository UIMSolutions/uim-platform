/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.infrastructure.persistence.memory.visibilities;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:
class MemoryVisibilityRepository : VisibilityRepository {
    private Visibility[] store;

    Visibility findById(VisibilityId id) {
        foreach (ref v; store) {
            if (v.id == id)
                return v;
        }
        return Visibility.init;
    }

    Visibility[] findByTenant(TenantId tenantId) {
        return store.filter!(v => v.tenantId == tenantId).array;
    }

    void save(Visibility v) {
        store ~= v;
    }

    void update(Visibility v) {
        foreach (ref existing; store) {
            if (existing.id == v.id) {
                existing = v;
                return;
            }
        }
    }

    void remove(VisibilityId id) {
        store = store.filter!(v => v.id != id).array;
    }

    size_t countByTenant(TenantId tenantId) {
        return cast(long) store.filter!(v => v.tenantId == tenantId).array.length;
    }
}
