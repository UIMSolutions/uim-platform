module uim.platform.integration_suite.application.dto;
@safe:

// --- Integration Packages ---
struct CreatePackageRequest {
  TenantId tenantId;
  IntegrationPackageId packageId;
  string name;
  string version_;
  string description;
  string vendor;
  string category;
  string[] tags;
  string[string] metadata;
}

struct UpdatePackageRequest {
  TenantId tenantId;
  IntegrationPackageId packageId;
  string name;
  string version_;
  string description;
  string status;
  string category;
  string[] tags;
  string[string] metadata;
}

// --- Integration Flows ---
struct CreateFlowRequest {
  TenantId tenantId;
  IntegrationFlowId id;
  IntegrationPackageId packageId;
  string name;
  string description;
  string version_;
  string direction;
  string senderAdapterType;
  string receiverAdapterType;
  string senderEndpoint;
  string receiverEndpoint;
  string[] steps;
  string[string] metadata;
}

struct UpdateFlowRequest {
  TenantId tenantId;
  IntegrationFlowId id;
  string name;
  string description;
  string version_;
  string status;
  string[string] metadata;
}

struct DeployFlowRequest {
  TenantId tenantId;
  IntegrationFlowId id;
  string deployedBy;
}

// --- API Proxies ---
struct CreateApiProxyRequest {
  TenantId tenantId;
  ApiProxyId proxyId;
  string name;
  string description;
  string version_;
  string targetEndpoint;
  string basePath;
  string[] policies;
  string[] tags;
  string[string] metadata;
}

struct UpdateApiProxyRequest {
  TenantId tenantId;
  ApiProxyId proxyId;
  string name;
  string description;
  string status;
  string targetEndpoint;
  string[] policies;
  string[] tags;
  string[string] metadata;
}

// --- API Products ---
struct CreateApiProductRequest {
  TenantId tenantId;
  ApiProductId productId;
  string name;
  string description;
  string[] apiProxyIds;
  string[] scopes;
  string[] environments;
  string[string] metadata;
}

struct UpdateApiProductRequest {
  TenantId tenantId;
  ApiProductId productId;
  string name;
  string description;
  string[] apiProxyIds;
  string status;
  bool isPublic;
  string[string] metadata;
}

// --- Message Queues ---
struct CreateQueueRequest {
  TenantId tenantId;
  MessageQueueId queueId;
  string name;
  string description;
  int maxMessageSize;
  int maxQueueSize;
  int retentionPeriod;
  bool deadLetterQueue;
  string deadLetterQueueName;
  string[string] metadata;
}

struct UpdateQueueRequest {
  TenantId tenantId;
  MessageQueueId queueId;
  string status;
  int maxMessageSize;
  int maxQueueSize;
  int retentionPeriod;
  string[string] metadata;
}

// --- Topic Subscriptions ---
struct CreateSubscriptionRequest {
  TenantId tenantId;
  TopicSubscriptionId subscriptionId;
  MessageQueueId queueId;

  string name;
  string topicPattern;
  string protocol;
  string endpoint;
  string[string] metadata;
}

struct UpdateSubscriptionRequest {
  TenantId tenantId;
  TopicSubscriptionId subscriptionId;
  string status;
  string topicPattern;
  string endpoint;
  string[string] metadata;
  UserId updatedBy;
}

// --- Trading Partners ---
struct CreateTradingPartnerRequest {
  TenantId tenantId;
  TradingPartnerId partnerId;
  string name;
  string description;
  string partnerType;
  string standard;
  string systemId;
  string contactEmail;
  string contactName;
  string country;
  string[string] metadata;
}

struct UpdateTradingPartnerRequest {
  TenantId tenantId;
  TradingPartnerId partnerId;
  string name;
  string contactEmail;
  string contactName;
  string standard;
  bool active;
  string[string] metadata;
}

// --- Message Mappings ---
struct CreateMappingRequest {
  TenantId tenantId;
  MessageMappingId mappingId;
  IntegrationPackageId packageId;
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
  MessageMappingId mappingId;
  IntegrationPackageId packageId;
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
  IntegrationUserId userId;
  string email;
  string firstName;
  string lastName;
  string role;
  string externalUserId;
}

struct UpdateIntegrationUserRequest {
  TenantId tenantId;
  IntegrationUserId userId;
  string firstName;
  string lastName;
  string role;
  bool active;
}
