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

    // #region ByTemplate
    size_t countByTemplate(TenantId tenantId, SituationTemplateId templateId) {
        return findByTemplate(tenantId, templateId).length;
    }

    SituationInstance[] filterByTemplate(SituationInstance[] instances, SituationTemplateId templateId) {
        return instances.filter!(i => i.templateId == templateId).array;
    }

    SituationInstance[] findByTemplate(TenantId tenantId, SituationTemplateId templateId) {
        return filterByTemplate(findByTenant(tenantId), templateId);
    }

    void removeByTemplate(TenantId tenantId, SituationTemplateId templateId) {
        findByTemplate(tenantId, templateId).each!(i => remove(i));
    }
    // #endregion ByTemplate

    // #region ByStatus
    size_t countByStatus(TenantId tenantId, InstanceStatus status) {
        return findByStatus(tenantId, status).length;
    }

    SituationInstance[] filterByStatus(SituationInstance[] instances, InstanceStatus status) {
        return instances.filter!(i => i.status == status).array;
    }

    SituationInstance[] findByStatus(TenantId tenantId, InstanceStatus status) {
        return filterByStatus(findByTenant(tenantId), status);
    }

    void removeByStatus(TenantId tenantId, InstanceStatus status) {
        findByStatus(tenantId, status).each!(i => remove(i));
    }
    // #endregion ByStatus

    // #region ByEntity
    size_t countByEntity(TenantId tenantId, string entityId) {
        return findByEntity(tenantId, entityId).length;
    }

    SituationInstance[] filterByEntity(SituationInstance[] instances, string entityId) {
        return instances.filter!(i => i.entityId == entityId).array;
    }

    SituationInstance[] findByEntity(TenantId tenantId, string entityId) {
        return filterByEntity(findByTenant(tenantId), entityId);
    }

    void removeByEntity(TenantId tenantId, string entityId) {
        findByEntity(tenantId, entityId).each!(i => remove(i));
    }
    // #endregion ByEntity

}
