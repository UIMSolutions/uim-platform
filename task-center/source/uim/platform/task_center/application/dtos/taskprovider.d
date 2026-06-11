module uim.platform.task_center.application.dtos.taskprovider;

import uim.platform.task_center;

// mixin(ShowModule!());

@safe:
struct CreateTaskProviderRequest {
    TenantId tenantId; // This is needed to identify the tenant to which the task provider belongs, which is important for multi-tenancy support and ensuring that the provider is created in the correct context.
    TaskProviderId providerId; // This is needed to ensure idempotency of the request. The client can generate a UUID and pass it here. If a task provider with the same ID already exists, the service can return the existing provider instead of creating a new one.
    
    string name; // The name of the task provider. This is a required field, as it provides a reference to the provider and is often used in provider lists and notifications.
    string description; // A description of the task provider. This is optional, but it can provide additional context or information about the provider.
    string providerType; // The type of the task provider. This is optional, but it can be used to classify or group providers based on their type or functionality.
    string authType; // The authentication type used by the task provider. This is optional, but it can provide information about how to authenticate with the provider, which can be important for integration and security purposes.
    string endpointUrl; // The endpoint URL of the task provider. This is a required field, as it specifies where the provider can be accessed and is essential for integration and communication with the provider.
    string authEndpointUrl; // The authentication endpoint URL of the task provider. This is optional, but it can provide information about where to authenticate with the provider, which can be important for integration and security purposes.
    string clientId; // The client ID used for authentication with the task provider. This is optional, but it can provide information about how to authenticate with the provider, which can be important for integration and security purposes.
    UserId createdBy; // The user who is creating the task provider. This is important for auditing purposes, as it allows the system to track who created the provider.
}

struct UpdateTaskProviderRequest {
    TenantId tenantId; // This is needed to identify the tenant to which the task provider belongs, which is important for multi-tenancy support and ensuring that the provider is updated in the correct context.
    TaskProviderId providerId; // This is needed to identify which task provider to update. The client must pass the ID of the provider to be updated.
    
    string name; // The new name of the task provider. This field is optional; if the client does not want to update the name, it can be left empty or null.
    string description; // The new description of the task provider. This field is optional; if the client does not want to update the description, it can be left empty or null.
    string providerType; // The new type of the task provider. This field is optional;
    string endpointUrl; // The new endpoint URL of the task provider. This field is optional; if the client does not want to update the endpoint URL, it can be left empty or null.
    string authEndpointUrl; // The new authentication endpoint URL of the task provider. This field is optional; if the client does not want to update the authentication endpoint URL, it can be left empty or null.
    string clientId; // The new client ID used for authentication with the task provider. This field is optional; if the client does not want to update the client ID, it can be left empty or null.
    UserId updatedBy; // The user who is performing the update operation. This is important for auditing purposes, as it allows the system to track who made changes to the provider.
}