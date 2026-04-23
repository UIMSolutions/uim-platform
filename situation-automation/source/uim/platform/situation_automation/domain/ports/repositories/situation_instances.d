/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.domain.ports.repositories.situation_instances;

// import uim.platform.situation_automation.domain.types;
// import uim.platform.situation_automation.domain.entities.situation_instance;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:

interface SituationInstanceRepository : ITenantRepository!(SituationInstance, SituationInstanceId) {

    size_t countByTemplate(SituationTemplateId templateId);
    SituationInstance[] findByTemplate(SituationTemplateId templateId);
    void removeByTemplate(SituationTemplateId templateId);

    size_t countByStatus(TenantId tenantId, InstanceStatus status);
    SituationInstance[] findByStatus(TenantId tenantId, InstanceStatus status);
    void removeByStatus(TenantId tenantId, InstanceStatus status);

    size_t countByEntity(TenantId tenantId, string entityId);
    SituationInstance[] findByEntity(TenantId tenantId, string entityId);
    void removeByEntity(TenantId tenantId, string entityId);

}
