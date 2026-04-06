/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.domain.ports.repositories.situation_instances;

import uim.platform.situation_automation.domain.types;
import uim.platform.situation_automation.domain.entities.situation_instance;

interface SituationInstanceRepository {
    SituationInstance findById(SituationInstanceId id);
    SituationInstance[] findByTenant(TenantId tenantId);
    SituationInstance[] findByTemplate(SituationTemplateId templateId);
    SituationInstance[] findByStatus(TenantId tenantId, InstanceStatus status);
    SituationInstance[] findByEntity(TenantId tenantId, string entityId);
    void save(SituationInstance i);
    void update(SituationInstance i);
    void remove(SituationInstanceId id);
    long countByTenant(TenantId tenantId);
    long countByStatus(TenantId tenantId, InstanceStatus status);
}
