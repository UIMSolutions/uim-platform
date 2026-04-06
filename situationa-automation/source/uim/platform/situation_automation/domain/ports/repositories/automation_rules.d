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

interface AutomationRuleRepository {
    AutomationRule findById(AutomationRuleId id);
    AutomationRule[] findByTenant(TenantId tenantId);
    AutomationRule[] findByTemplate(SituationTemplateId templateId);
    AutomationRule[] findActive(TenantId tenantId);
    void save(AutomationRule r);
    void update(AutomationRule r);
    void remove(AutomationRuleId id);
    long countByTenant(TenantId tenantId);
}
