module uim.platform.situation_automation.application.dtos.situation_action;
import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:
struct CreateSituationActionRequest {
    TenantId tenantId;
    SituationActionId situationActionId;
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
    UserId createdBy;
}

struct UpdateSituationActionRequest {
    TenantId tenantId;
    SituationActionId situationActionId;
    string name;
    string description;
    string baseUrl;
    string path;
    string authType;
    string destinationName;
    string webhookUrl;
    string emailTemplate;
    UserId updatedBy;
}
