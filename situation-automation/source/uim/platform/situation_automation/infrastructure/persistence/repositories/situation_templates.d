/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.infrastructure.persistence.repositories.situation_templates;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:
class MemorySituationTemplateRepository : TenantRepository!(SituationTemplate, SituationTemplateId), SituationTemplateRepository {

    // #region ByCategory
    size_t countByCategory(TenantId tenantId, SituationCategory category) {
        return findByCategory(tenantId, category).length;
    }

    SituationTemplate[] filterByCategory(SituationTemplate[] templates, SituationCategory category) {
        return templates.filter!(t => t.category == category).array;
    }

    SituationTemplate[] findByCategory(TenantId tenantId, SituationCategory category) {
        return filterByCategory(findByTenant(tenantId), category);
    }

    void removeByCategory(TenantId tenantId, SituationCategory category) {
        findByCategory(tenantId, category).each!(t => remove(t));
    }
    // #endregion ByCategory

    // #region ByEntityType
    size_t countByEntityType(TenantId tenantId, EntityTypeId entityTypeId) {
        return findByEntityType(tenantId, entityTypeId).length;
    }

    SituationTemplate[] filterByEntityType(SituationTemplate[] templates, EntityTypeId entityTypeId) {
        return templates.filter!(t => t.entityTypeId == entityTypeId).array;
    }

    SituationTemplate[] findByEntityType(TenantId tenantId, EntityTypeId entityTypeId) {
        return filterByEntityType(findByTenant(tenantId), entityTypeId);
    }

    void removeByEntityType(TenantId tenantId, EntityTypeId entityTypeId) {
        findByEntityType(tenantId, entityTypeId).each!(t => remove(t));
    }
    // #endregion ByEntityType
    
}
