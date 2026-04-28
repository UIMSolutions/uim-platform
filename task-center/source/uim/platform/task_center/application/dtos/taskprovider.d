module uim.platform.task_center.application.dtos.taskprovider;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:
struct CreateTaskProviderRequest {
    TenantId tenantId;
    string id;
    string name;
    string description;
    string providerType;
    string authType;
    string endpointUrl;
    string authEndpointUrl;
    string clientId;
    string createdBy;
}

struct UpdateTaskProviderRequest {
    TenantId tenantId;
    string id;
    string name;
    string description;
    string endpointUrl;
    string authEndpointUrl;
    string clientId;
    string modifiedBy;
}