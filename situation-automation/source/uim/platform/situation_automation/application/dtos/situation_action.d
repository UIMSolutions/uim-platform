module uim.platform.situation_automation.application.dtos.situation_action;

struct CreateSituationActionRequest {
    TenantId tenantId;
    string id;
    string name;
    string description;
    string type;
    string baseUrl;
    string path;
    string method;
    string authType;
    string destinationName;
    string webhookUrl;
    string emailTemplate;
    string scriptContent;
    string createdBy;
}

struct UpdateSituationActionRequest {
    TenantId tenantId;
    string id;
    string name;
    string description;
    string baseUrl;
    string path;
    string authType;
    string destinationName;
    string webhookUrl;
    string emailTemplate;
    string modifiedBy;
}
