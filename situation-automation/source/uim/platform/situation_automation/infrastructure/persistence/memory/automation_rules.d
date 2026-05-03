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

    size_t countByTemplate(SituationTemplateId templateId) {
        return findByTemplate(templateId).length;
    }
    AutomationRule[] findByTemplate(SituationTemplateId templateId) {
        return findAll().filter!(r => r.templateId == templateId).array;
    }
    void removeByTemplate(SituationTemplateId templateId) {
        findByTemplate(templateId).each!(r => remove(r.id));
    }

    size_t countActive(TenantId tenantId) {
        return findActive(tenantId).length;
    }
    AutomationRule[] findActive(TenantId tenantId) {
        return findByTenant(tenantId).filter!(r => r.enabled && r.status == RuleStatus.active).array;
    }
    void removeActive(TenantId tenantId) {
        findActive(tenantId).each!(r => remove(r.id));
    }
}
