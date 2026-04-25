/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.infrastructure.persistence.memory.situation_instances;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:
class MemorySituationInstanceRepository : TenantRepository!(SituationInstance, SituationInstanceId) {

    size_t countByTemplate(SituationTemplateId templateId) {
        return findByTemplate(templateId).length;
    }

    SituationInstance[] filterByTemplate(SituationInstance[] instances, SituationTemplateId templateId) {
        return instances.filter!(i => i.templateId == templateId).array;
    }

    SituationInstance[] findByTemplate(SituationTemplateId templateId) {
        return findAll().filter!(i => i.templateId == templateId).array;
    }

    void removeByTemplate(SituationTemplateId templateId) {
        findByTemplate(templateId).removeAll;
    }

    size_t countByStatus(TenantId tenantId, InstanceStatus status) {
        return findByStatus(tenantId, status).length;
    }

    SituationInstance[] filterByStatus(SituationInstance[] instances, InstanceStatus status) {
        return instances.filter!(i => i.status == status).array;
    }

    SituationInstance[] findByStatus(TenantId tenantId, InstanceStatus status) {
        return findAll().filter!(i => i.tenantId == tenantId && i.status == status).array;
    }

    void removeByStatus(TenantId tenantId, InstanceStatus status) {
        findByStatus(tenantId, status).removeAll;
    }

    size_t countByEntity(TenantId tenantId, string entityId) {
        return findByEntity(tenantId, entityId).length;
    }

    SituationInstance[] filterByEntity(SituationInstance[] instances, TenantId tenantId, string entityId) {
        return instances.filter!(i => i.tenantId == tenantId && i.entityId == entityId).array;
    }

    SituationInstance[] findByEntity(TenantId tenantId, string entityId) {
        return findAll().filter!(i => i.tenantId == tenantId && i.entityId == entityId).array;
    }

    void removeByEntity(TenantId tenantId, string entityId) {
        findByEntity(tenantId, entityId).removeAll;
    }

}
