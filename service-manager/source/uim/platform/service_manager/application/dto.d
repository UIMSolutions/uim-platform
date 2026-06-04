module uim.platform.service_manager.application.dto;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

// --- Platform DTOs ---

struct CreatePlatformRequest {
    TenantId tenantId;
    PlatformId platformId;

    string name;
    string description;
    string type;
    string brokerUrl;
    string credentials;
    string region;
    string subaccountId;
}

struct UpdatePlatformRequest {
    TenantId tenantId;
    PlatformId platformId;

    string name;
    string description;
    string type;
    string brokerUrl;
    string credentials;
    string region;
}

// --- Service Broker DTOs ---

struct CreateServiceBrokerRequest {
    TenantId tenantId;
    ServiceBrokerId brokerId;

    string name;
    string description;
    string brokerUrl;
}

struct UpdateServiceBrokerRequest {
    TenantId tenantId;
    ServiceBrokerId brokerId;

    string name;
    string description;
    string brokerUrl;
}

// --- Service Offering DTOs ---

struct CreateServiceOfferingRequest {
    TenantId tenantId;
    ServiceOfferingId offeringId;
    ServiceBrokerId brokerId;

    string name;
    string description;
    string catalogName;
    string category;
    string bindable;
    string tags;
    string metadata;
}

struct UpdateServiceOfferingRequest {
    TenantId tenantId;
    ServiceOfferingId offeringId;

    string name;
    string description;
    string catalogName;
    string category;
    string tags;
    string metadata;
}

// --- Service Plan DTOs ---

struct CreateServicePlanRequest {
    TenantId tenantId;
    ServicePlanId planId;

    string name;
    string description;
    string catalogName;
    ServiceOfferingId offeringId;
    string pricing;
    string free;
    string bindable;
    int maxInstances;
    string schemas;
    string metadata;
}

struct UpdateServicePlanRequest {
    TenantId tenantId;
    ServicePlanId planId;

    string name;
    string description;
    string pricing;
    int maxInstances;
    string schemas;
    string metadata;
}

// --- Service Instance DTOs ---

struct CreateServiceInstanceRequest {
    TenantId tenantId;
    ServiceInstanceId instanceId;

    string name;
    ServicePlanId planId;
    ServiceOfferingId offeringId;
    PlatformId platformId;
    string context;
    string parameters;
    string labels;
    string shared_;
}

struct UpdateServiceInstanceRequest {
    TenantId tenantId;
    ServiceInstanceId instanceId;

    string name;
    ServicePlanId planId;
    string parameters;
    string labels;
    string shared_;
}

// --- Service Binding DTOs ---

struct CreateServiceBindingRequest {
    TenantId tenantId;
    ServiceBindingId bindingId;

    string name;
    ServiceInstanceId instanceId;
    string parameters;
    string bindResource;
    string context;
    string labels;
}

struct UpdateServiceBindingRequest {
    TenantId tenantId;
    ServiceBindingId bindingId;

    string name;
    string parameters;
    string labels;
}

// --- Operation DTOs ---

struct CreateOperationRequest {
    TenantId tenantId;
    OperationId operationId;

    string resourceId;
    string resourceType;
    string type;
    string description;
}

struct UpdateOperationRequest {
    TenantId tenantId;
    OperationId operationId;

    string status;
    string errorMessage;
}

// --- Label DTOs ---

struct CreateLabelRequest {
    TenantId tenantId;
    LabelId labelId;

    string resourceId;
    string resourceType;
    string key;
    string value;
}

struct UpdateLabelRequest {
    TenantId tenantId;
    LabelId labelId;

    string key;
    string value;
}
