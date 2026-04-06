/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.infrastructure.persistence.memory.situation_instances;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:
class MemorySituationInstanceRepository : SituationInstanceRepository {
    private SituationInstance[] store;

    SituationInstance findById(SituationInstanceId id) {
        foreach (ref i; store) {
            if (i.id == id)
                return i;
        }
        return SituationInstance.init;
    }

    SituationInstance[] findByTenant(TenantId tenantId) {
        return store.filter!(i => i.tenantId == tenantId).array;
    }

    SituationInstance[] findByTemplate(SituationTemplateId templateId) {
        return store.filter!(i => i.templateId == templateId).array;
    }

    SituationInstance[] findByStatus(TenantId tenantId, InstanceStatus status) {
        return store.filter!(i => i.tenantId == tenantId && i.status == status).array;
    }

    SituationInstance[] findByEntity(TenantId tenantId, string entityId) {
        return store.filter!(i => i.tenantId == tenantId && i.entityId == entityId).array;
    }

    void save(SituationInstance i) {
        store ~= i;
    }

    void update(SituationInstance i) {
        foreach (ref existing; store) {
            if (existing.id == i.id) {
                existing = i;
                return;
            }
        }
    }

    void remove(SituationInstanceId id) {
        store = store.filter!(i => i.id != id).array;
    }

    long countByTenant(TenantId tenantId) {
        return cast(long) store.filter!(i => i.tenantId == tenantId).array.length;
    }

    long countByStatus(TenantId tenantId, InstanceStatus status) {
        return cast(long) store.filter!(i => i.tenantId == tenantId && i.status == status).array.length;
    }
}
