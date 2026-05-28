module uim.platform.integration_suite.application.dto;
@safe:

// --- Integration Packages ---
struct CreatePackageRequest {
  string   tenantId;
  string   id;
  string   name;
  string   version_;
  string   description;
  string   vendor;
  string   category;
  string[] tags;
  string[string] metadata;
}
struct UpdatePackageRequest {
  string   tenantId;
  string   id;
  string   name;
  string   version_;
  string   description;
  string   status;
  string   category;
  string[] tags;
  string[string] metadata;
}

// --- Integration Flows ---
struct CreateFlowRequest {
  string   tenantId;
  string   id;
  string   packageId;
  string   name;
  string   description;
  string   version_;
  string   direction;
  string   senderAdapterType;
  string   receiverAdapterType;
  string   senderEndpoint;
  string   receiverEndpoint;
  string[] steps;
  string[string] metadata;
}
struct UpdateFlowRequest {
  string   tenantId;
  string   id;
  string   name;
  string   description;
  string   version_;
  string   status;
  string[string] metadata;
}
struct DeployFlowRequest {
  TenantId tenantId;
  string id;
  string deployedBy;
}

// --- API Proxies ---
struct CreateApiProxyRequest {
  string   tenantId;
  string   id;
  string   name;
  string   description;
  string   version_;
  string   targetEndpoint;
  string   basePath;
  string[] policies;
  string[] tags;
  string[string] metadata;
}
struct UpdateApiProxyRequest {
  string   tenantId;
  string   id;
  string   name;
  string   description;
  string   status;
  string   targetEndpoint;
  string[] policies;
  string[] tags;
  string[string] metadata;
}

// --- API Products ---
struct CreateApiProductRequest {
  string   tenantId;
  string   id;
  string   name;
  string   description;
  string[] apiProxyIds;
  string[] scopes;
  string[] environments;
  string[string] metadata;
}
struct UpdateApiProductRequest {
  string   tenantId;
  string   id;
  string   name;
  string   description;
  string[] apiProxyIds;
  string   status;
  bool     isPublic;
  string[string] metadata;
}

// --- Message Queues ---
struct CreateQueueRequest {
  TenantId tenantId;
  string id;
  string name;
  string description;
  int    maxMessageSize;
  int    maxQueueSize;
  int    retentionPeriod;
  bool   deadLetterQueue;
  string deadLetterQueueName;
  string[string] metadata;
}
struct UpdateQueueRequest {
  TenantId tenantId;
  string id;
  string status;
  int    maxMessageSize;
  int    maxQueueSize;
  int    retentionPeriod;
  string[string] metadata;
}

// --- Topic Subscriptions ---
struct CreateSubscriptionRequest {
  TenantId tenantId;
  string id;
  string name;
  string queueId;
  string topicPattern;
  string protocol;
  string endpoint;
  string[string] metadata;
}
struct UpdateSubscriptionRequest {
  TenantId tenantId;
  string id;
  string status;
  string topicPattern;
  string endpoint;
  string[string] metadata;
  UserId updatedBy;
}

// --- Trading Partners ---
struct CreateTradingPartnerRequest {
  string   tenantId;
  string   id;
  string   name;
  string   description;
  string   partnerType;
  string   standard;
  string   systemId;
  string   contactEmail;
  string   contactName;
  string   country;
  string[string] metadata;
}
struct UpdateTradingPartnerRequest {
  TenantId tenantId;
  string id;
  string name;
  string contactEmail;
  string contactName;
  string standard;
  bool   active;
  string[string] metadata;
}

// --- Message Mappings ---
struct CreateMappingRequest {
  TenantId tenantId;
  string id;
  string packageId;
  string name;
  string description;
  string version_;
  string sourceStandard;
  string targetStandard;
  string sourceSchema;
  string targetSchema;
  string mappingExpression;
  string[string] metadata;
}
struct UpdateMappingRequest {
  TenantId tenantId;
  string id;
  string name;
  string description;
  string version_;
  string status;
  string mappingExpression;
  string[string] metadata;
}

// --- Integration Users ---
struct CreateIntegrationUserRequest {
  TenantId tenantId;
  string id;
  string email;
  string firstName;
  string lastName;
  string role;
  string externalUserId;
}
struct UpdateIntegrationUserRequest {
  TenantId tenantId;
  string id;
  string firstName;
  string lastName;
  string role;
  bool   active;
}
