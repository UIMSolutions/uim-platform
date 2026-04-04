/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.application.dto;

import uim.platform.kyma.domain.types;

/// --- Command result ---

struct CommandResult {
  bool success;
  string id;
  string error;
}

/// --- Environment DTOs ---

struct CreateEnvironmentRequest {
  TenantId tenantId;
  SubaccountId subaccountId;
  string name;
  string description;
  string plan; // "azure", "aws", "gcp", "free", "trial"
  string region;
  int machineCount;
  string machineType;
  int autoScalerMin;
  int autoScalerMax;
  string oidcIssuerUrl;
  string oidcClientId;
  string[] oidcGroupsClaim;
  string[] oidcUsernameClaim;
  string[] administrators;
  string createdBy;
}

struct UpdateEnvironmentRequest {
  string description;
  int machineCount;
  string machineType;
  int autoScalerMin;
  int autoScalerMax;
  string oidcIssuerUrl;
  string oidcClientId;
  string[] administrators;
}

/// --- Namespace DTOs ---

struct CreateNamespaceRequest {
  KymaEnvironmentId environmentId;
  TenantId tenantId;
  string name;
  string description;
  string cpuLimit;
  string memoryLimit;
  string cpuRequest;
  string memoryRequest;
  int podLimit;
  string quotaEnforcement;
  bool istioInjection;
  string[string] labels;
  string[string] annotations;
  string createdBy;
}

struct UpdateNamespaceRequest {
  string description;
  string cpuLimit;
  string memoryLimit;
  string cpuRequest;
  string memoryRequest;
  int podLimit;
  string quotaEnforcement;
  bool istioInjection;
  string[string] labels;
  string[string] annotations;
}

/// --- Serverless Function DTOs ---

struct CreateFunctionRequest {
  NamespaceId namespaceId;
  KymaEnvironmentId environmentId;
  TenantId tenantId;
  string name;
  string description;
  string runtime; // "nodejs18", "nodejs20", "python39", "python312"
  string sourceCode;
  string handler;
  string dependencies;
  string scalingType; // "fixed", "auto"
  int minReplicas;
  int maxReplicas;
  string cpuRequest;
  string cpuLimit;
  string memoryRequest;
  string memoryLimit;
  string[string] envVars;
  string[string] labels;
  int timeoutSeconds;
  string createdBy;
}

struct UpdateFunctionRequest {
  string description;
  string sourceCode;
  string handler;
  string dependencies;
  string scalingType;
  int minReplicas;
  int maxReplicas;
  string cpuRequest;
  string cpuLimit;
  string memoryRequest;
  string memoryLimit;
  string[string] envVars;
  string[string] labels;
  int timeoutSeconds;
}

/// --- API Rule DTOs ---

struct CreateApiRuleRequest {
  NamespaceId namespaceId;
  KymaEnvironmentId environmentId;
  TenantId tenantId;
  string name;
  string description;
  string serviceName;
  int servicePort;
  string gateway;
  string host;
  ApiRuleEntryDto[] rules;
  bool tlsEnabled;
  string tlsSecretName;
  bool corsEnabled;
  string[] corsAllowOrigins;
  string[] corsAllowMethods;
  string[] corsAllowHeaders;
  string[string] labels;
  string createdBy;
}

struct UpdateApiRuleRequest {
  string description;
  string serviceName;
  int servicePort;
  string host;
  ApiRuleEntryDto[] rules;
  bool tlsEnabled;
  string tlsSecretName;
  bool corsEnabled;
  string[] corsAllowOrigins;
  string[] corsAllowMethods;
  string[] corsAllowHeaders;
  string[string] labels;
}

struct ApiRuleEntryDto {
  string path;
  string[] methods;
  string accessStrategy;
  string[] requiredScopes;
  string[] audiences;
  string[] trustedIssuers;
}

/// --- Service Instance DTOs ---

struct CreateServiceInstanceRequest {
  NamespaceId namespaceId;
  KymaEnvironmentId environmentId;
  TenantId tenantId;
  string name;
  string description;
  string serviceOfferingName;
  string servicePlanName;
  string servicePlanId;
  string externalName;
  string parametersJson;
  string[string] labels;
  string createdBy;
}

struct UpdateServiceInstanceRequest {
  string description;
  string servicePlanName;
  string servicePlanId;
  string parametersJson;
  string[string] labels;
}

/// --- Service Binding DTOs ---

struct CreateServiceBindingRequest {
  ServiceInstanceId serviceInstanceId;
  NamespaceId namespaceId;
  KymaEnvironmentId environmentId;
  TenantId tenantId;
  string name;
  string description;
  string secretName;
  string secretNamespace;
  string parametersJson;
  string[string] labels;
  string createdBy;
}

struct UpdateServiceBindingRequest {
  string description;
  string secretName;
  string parametersJson;
  string[string] labels;
}

/// --- Event Subscription DTOs ---

struct CreateEventSubscriptionRequest {
  NamespaceId namespaceId;
  KymaEnvironmentId environmentId;
  TenantId tenantId;
  string name;
  string description;
  string source;
  string[] eventTypes;
  string typeEncoding; // "exact", "prefix"
  string sinkUrl;
  string sinkServiceName;
  int sinkServicePort;
  int maxInFlightMessages;
  bool exactTypeMatching;
  string[string] filterAttributes;
  string[string] labels;
  string createdBy;
}

struct UpdateEventSubscriptionRequest {
  string description;
  string[] eventTypes;
  string sinkUrl;
  string sinkServiceName;
  int sinkServicePort;
  int maxInFlightMessages;
  bool exactTypeMatching;
  string[string] filterAttributes;
  string[string] labels;
}

/// --- Kyma Module DTOs ---

struct EnableModuleRequest {
  KymaEnvironmentId environmentId;
  TenantId tenantId;
  string name;
  string moduleType; // "istio", "serverless", "eventing", etc.
  string version_;
  string channel;
  string customResourcePolicy;
  string configurationJson;
  string enabledBy;
}

struct UpdateModuleRequest {
  string version_;
  string channel;
  string customResourcePolicy;
  string configurationJson;
}

/// --- Application DTOs ---

struct RegisterApplicationRequest {
  KymaEnvironmentId environmentId;
  TenantId tenantId;
  string name;
  string description;
  string registrationType; // "api", "events", "apiAndEvents"
  string connectorUrl;
  AppApiEntryDto[] apis;
  AppEventEntryDto[] events;
  string[] boundNamespaces;
  string[string] labels;
  string createdBy;
}

struct UpdateApplicationRequest {
  string description;
  string connectorUrl;
  AppApiEntryDto[] apis;
  AppEventEntryDto[] events;
  string[] boundNamespaces;
  string[string] labels;
}

struct AppApiEntryDto {
  string name;
  string description;
  string targetUrl;
  string specUrl;
  string authType;
}

struct AppEventEntryDto {
  string name;
  string description;
  string version_;
}
