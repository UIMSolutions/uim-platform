/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.domain.ports.repositories.situation_templates;

// import uim.platform.situation_automation.domain.types;
// import uim.platform.situation_automation.domain.entities.situation_template;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:

interface SituationTemplateRepository : ITenantRepository!(SituationTemplate, SituationTemplateId) {

    size_t countByCategory(TenantId tenantId, SituationCategory category);
    SituationTemplate[] findByCategory(TenantId tenantId, SituationCategory category);
    void removeByCategory(TenantId tenantId, SituationCategory category);

    size_t countByEntityType(TenantId tenantId, string entityTypeId);
    SituationTemplate[] findByEntityType(TenantId tenantId, string entityTypeId);
    void removeByEntityType(TenantId tenantId, string entityTypeId);

}
