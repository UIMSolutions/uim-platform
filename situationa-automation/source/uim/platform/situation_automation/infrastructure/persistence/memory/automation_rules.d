/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.infrastructure.persistence.memory.automation_rules;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:
class MemoryAutomationRuleRepository : AutomationRuleRepository {
    private AutomationRule[] store;

    AutomationRule findById(AutomationRuleId id) {
        foreach (ref r; store) {
            if (r.id == id)
                return r;
        }
        return AutomationRule.init;
    }

    AutomationRule[] findByTenant(TenantId tenantId) {
        return store.filter!(r => r.tenantId == tenantId).array;
    }

    AutomationRule[] findByTemplate(SituationTemplateId templateId) {
        return store.filter!(r => r.templateId == templateId).array;
    }

    AutomationRule[] findActive(TenantId tenantId) {
        return store.filter!(r => r.tenantId == tenantId && r.enabled && r.status == RuleStatus.active).array;
    }

    void save(AutomationRule r) {
        store ~= r;
    }

    void update(AutomationRule r) {
        foreach (ref existing; store) {
            if (existing.id == r.id) {
                existing = r;
                return;
            }
        }
    }

    void remove(AutomationRuleId id) {
        store = store.filter!(r => r.id != id).array;
    }

    long countByTenant(TenantId tenantId) {
        return cast(long) store.filter!(r => r.tenantId == tenantId).array.length;
    }
}
