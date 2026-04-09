/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.infrastructure.persistence.memory.situation_templates;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:
class MemorySituationTemplateRepository : SituationTemplateRepository {
    private SituationTemplate[] store;

    SituationTemplate findById(SituationTemplateId id) {
        foreach (ref t; store) {
            if (t.id == id)
                return t;
        }
        return SituationTemplate.init;
    }

    SituationTemplate[] findByTenant(TenantId tenantId) {
        return store.filter!(t => t.tenantId == tenantId).array;
    }

    SituationTemplate[] findByCategory(TenantId tenantId, SituationCategory category) {
        return store.filter!(t => t.tenantId == tenantId && t.category == category).array;
    }

    SituationTemplate[] findByEntityType(TenantId tenantId, string entityTypeId) {
        return store.filter!(t => t.tenantId == tenantId && t.entityTypeId == entityTypeId).array;
    }

    void save(SituationTemplate t) {
        store ~= t;
    }

    void update(SituationTemplate t) {
        foreach (ref existing; store) {
            if (existing.id == t.id) {
                existing = t;
                return;
            }
        }
    }

    void remove(SituationTemplateId id) {
        store = store.filter!(t => t.id != id).array;
    }

    size_t countByTenant(TenantId tenantId) {
        return cast(long) store.filter!(t => t.tenantId == tenantId).array.length;
    }
}
