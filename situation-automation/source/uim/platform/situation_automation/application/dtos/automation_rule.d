module uim.platform.situation_automation.application.dtos.automation_rule;

struct CreateAutomationRuleRequest {
    TenantId tenantId;
    string templateId;
    string id;
    string name;
    string description;
    string priority;
    int executionOrder;
    string createdBy;
}

struct UpdateAutomationRuleRequest {
    TenantId tenantId;
    string id;
    string name;
    string description;
    string priority;
    int executionOrder;
    bool enabled;
    string modifiedBy;
}