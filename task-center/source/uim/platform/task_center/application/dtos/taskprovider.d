module uim.platform.task_center.application.dtos.taskprovider;

import uim.platform.task_center;

// mixin(ShowModule!());

@safe:
struct CreateTaskProviderRequest {
    TenantId tenantId;
    TaskProviderId taskProviderId; // This is needed to ensure idempotency of the request. The client can generate a UUID and pass it here. If a task provider with the same ID already exists, the service can return the existing provider instead of creating a new one.
    string name;
    string description;
    string providerType;
    string authType;
    string endpointUrl;
    string authEndpointUrl;
    string clientId;
    UserId createdBy;
}

struct UpdateTaskProviderRequest {
    TenantId tenantId;
    TaskProviderId taskProviderId;
    
    string name;
    string description;
    string endpointUrl;
    string authEndpointUrl;
    string clientId;
    UserId updatedBy;
}