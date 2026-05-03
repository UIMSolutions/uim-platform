/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.infrastructure.persistence.memory.situation_templates;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:
class MemorySituationTemplateRepository : TenantRepository!(SituationTemplate, SituationTemplateId), SituationTemplateRepository {

size_t countByCategory(TenantId tenantId, SituationCategory category) {
        return findByCategory(tenantId, category).length;
    }
    SituationTemplate[] findByCategory(TenantId tenantId, SituationCategory category) {
        return findAll().filter!(t => t.tenantId == tenantId && t.category == category).array;
    }
    void removeByCategory(TenantId tenantId, SituationCategory category) {
        findByCategory(tenantId, category).each!(t => remove(t));
    }

    size_t countByPriority(TenantId tenantId, SituationPriority priority) {
        return findByPriority(tenantId, priority).length;
    }
    SituationTemplate[] findByEntityType(TenantId tenantId, string entityTypeId) {
        return findAll().filter!(t => t.tenantId == tenantId && t.entityTypeId == entityTypeId).array;
    }
    void removeByEntityType(TenantId tenantId, string entityTypeId) {
        findByEntityType(tenantId, entityTypeId).each!(t => remove(t));
    }

}
