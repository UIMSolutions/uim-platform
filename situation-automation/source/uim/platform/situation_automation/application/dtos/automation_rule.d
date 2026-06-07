module uim.platform.situation_automation.application.dtos.automation_rule;
import uim.platform.situation_automation;

// mixin(ShowModule!());

@safe:
struct CreateAutomationRuleRequest {
    TenantId tenantId;
    SituationTemplateId situationTemplateId;
    AutomationRuleId automationRuleId;
    string name;
    string description;
    string priority;
    int executionOrder;
    UserId createdBy;
}

struct UpdateAutomationRuleRequest {
    TenantId tenantId;
    AutomationRuleId automationRuleId;
    string name;
    string description;
    string priority;
    int executionOrder;
    bool enabled;
    UserId updatedBy;
}