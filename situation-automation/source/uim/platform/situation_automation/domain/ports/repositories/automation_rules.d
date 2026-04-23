/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.domain.ports.repositories.automation_rules;

// import uim.platform.situation_automation.domain.types;
// import uim.platform.situation_automation.domain.entities.automation_rule;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:

interface AutomationRuleRepository : ITenantRepository!(AutomationRule, AutomationRuleId) {
    
    size_t countByTemplate(SituationTemplateId templateId);
    AutomationRule[] findByTemplate(SituationTemplateId templateId);
    void removeByTemplate(SituationTemplateId templateId);
    
    size_t countActive(TenantId tenantId);
    AutomationRule[] findActive(TenantId tenantId);
    void removeActive(TenantId tenantId);

}
