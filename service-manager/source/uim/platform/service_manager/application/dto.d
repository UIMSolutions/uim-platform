module uim.platform.service_manager.application.dto;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

// --- Platform DTOs ---

struct CreatePlatformRequest {
    TenantId tenantId;

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

    string name;
    string description;
    string brokerUrl;
}

struct UpdateServiceBrokerRequest {
    TenantId tenantId;

    string name;
    string description;
    string brokerUrl;
}

// --- Service Offering DTOs ---

struct CreateServiceOfferingRequest {
    TenantId tenantId;
    ServiceBrokerId serviceBrokerId;

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

    string name;
    string description;
    string catalogName;
    ServiceOfferingId serviceOfferingId;
    string pricing;
    string free;
    string bindable;
    int maxInstances;
    string schemas;
    string metadata;
}

struct UpdateServicePlanRequest {
    TenantId tenantId;
    ServicePlanId servicePlanId;
    
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

    string name;
    string planId;
    string offeringId;
    string platformId;
    string context;
    string parameters;
    string labels;
    string shared_;
}

struct UpdateServiceInstanceRequest {
    TenantId tenantId;
    ServiceInstanceId serviceInstanceId;

    string name;
    ServicePlanId servicePlanId;
    string parameters;
    string labels;
    string shared_;
}

// --- Service Binding DTOs ---

struct CreateServiceBindingRequest {
    string name;
    string instanceId;
    string parameters;
    string bindResource;
    string context;
    string labels;
}

struct UpdateServiceBindingRequest {
    string name;
    string parameters;
    string labels;
}

// --- Operation DTOs ---

struct CreateOperationRequest {
    string resourceId;
    string resourceType;
    string type;
    string description;
}

struct UpdateOperationRequest {
    string status;
    string errorMessage;
}

// --- Label DTOs ---

struct CreateLabelRequest {
    string resourceId;
    string resourceType;
    string key;
    string value;
}

struct UpdateLabelRequest {
    string key;
    string value;
}
