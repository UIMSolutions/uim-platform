/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.infrastructure.persistence.memory.automation_rules;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:
class MemoryAutomationRuleRepository : TenantRepository!(AutomationRule, AutomationRuleId), AutomationRuleRepository {

    // #region ByTemplate
    size_t countByTemplate(TenantId tenantId, SituationTemplateId templateId) {
        return findByTemplate(tenantId, templateId).length;
    }
    AutomationRule[] filterByTemplate(AutomationRule[] rules, SituationTemplateId templateId) {
        return rules.filter!(r => r.templateId == templateId).array;
    }
    AutomationRule[] findByTemplate(TenantId tenantId, SituationTemplateId templateId) {
        return filterByTemplate(findByTenant(tenantId), templateId);
    }
    void removeByTemplate(TenantId tenantId, SituationTemplateId templateId) {
        findByTemplate(tenantId, templateId).each!(r => remove(r));
    }
    // #endregion ByTemplate

    // #region Active rules
    size_t countActive(TenantId tenantId) {
        return findActive(tenantId).length;
    }
    AutomationRule[] filterActive(AutomationRule[] rules) {
        return rules.filter!(r => r.enabled && r.status == RuleStatus.active).array;
    }
    AutomationRule[] findActive(TenantId tenantId) {
        return filterActive(findByTenant(tenantId));
    }
    void removeActive(TenantId tenantId) {
        findActive(tenantId).each!(r => remove(r));
    }
    // #endregion Active rules

}
