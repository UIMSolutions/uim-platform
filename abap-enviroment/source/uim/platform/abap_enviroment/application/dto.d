module uim.platform.abap_enviroment.application.dto;

import uim.platform.abap_enviroment.domain.types;
import uim.platform.abap_enviroment.domain.entities.communication_arrangement : CommunicationEndpoint;
import uim.platform.abap_enviroment.domain.entities.service_binding : ExposedEndpoint;
import uim.platform.abap_enviroment.domain.entities.business_user : RoleAssignment;
import uim.platform.abap_enviroment.domain.entities.business_role : CatalogAssignment;
import uim.platform.abap_enviroment.domain.entities.transport_request : TransportTask;

/// --- Command result ---

struct CommandResult
{
  string id;
  string error;

  bool isSuccess() const
  {
    return error.length == 0;
  }
}

// ─── System Instance DTOs ───

struct CreateSystemInstanceRequest
{
  TenantId tenantId;
  SubaccountId subaccountId;
  string name;
  string description;
  string plan; // "standard", "free_", "development", "test", "production"
  string region;
  string sapSystemId; // 3-char SID
  string adminEmail;
  ushort abapRuntimeSize;
  ushort hanaMemorySize;
  string softwareVersion;
  string stackVersion;
}

struct UpdateSystemInstanceRequest
{
  string description;
  string status; // lifecycle transition target
  ushort abapRuntimeSize;
  ushort hanaMemorySize;
  string softwareVersion;
}

// ─── Software Component DTOs ───

struct CreateSoftwareComponentRequest
{
  TenantId tenantId;
  SystemInstanceId systemInstanceId;
  string name;
  string description;
  string componentType; // "developmentPackage", "businessConfiguration", ...
  string repositoryUrl;
  string branch;
  string branchStrategy;
  string namespace;
}

struct CloneSoftwareComponentRequest
{
  string branch;
  string commitId;
}

struct PullSoftwareComponentRequest
{
  string commitId;
}

// ─── Communication Arrangement DTOs ───

struct CreateCommunicationArrangementRequest
{
  TenantId tenantId;
  SystemInstanceId systemInstanceId;
  CommunicationScenarioId scenarioId;
  string name;
  string description;
  string direction; // "inbound", "outbound"
  string authMethod; // "basicAuthentication", ...
  string communicationUser;
  string communicationPassword;
  string clientId;
  string clientSecret;
  string tokenEndpoint;
  string certificateId;
  CommunicationEndpoint[] inboundServices;
  CommunicationEndpoint[] outboundServices;
}

struct UpdateCommunicationArrangementRequest
{
  string description;
  string status; // "active", "inactive"
  string authMethod;
  string communicationUser;
  string communicationPassword;
  string clientId;
  string clientSecret;
  string tokenEndpoint;
  CommunicationEndpoint[] inboundServices;
  CommunicationEndpoint[] outboundServices;
}

// ─── Service Binding DTOs ───

struct CreateServiceBindingRequest
{
  TenantId tenantId;
  SystemInstanceId systemInstanceId;
  ServiceDefinitionId serviceDefinitionId;
  string name;
  string description;
  string bindingType; // "odataV2", "odataV4", ...
  ExposedEndpoint[] endpoints;
}

struct UpdateServiceBindingRequest
{
  string description;
  string status; // "active", "inactive", "deprecated_"
  ExposedEndpoint[] endpoints;
}

// ─── Business User DTOs ───

struct CreateBusinessUserRequest
{
  TenantId tenantId;
  SystemInstanceId systemInstanceId;
  string username;
  string firstName;
  string lastName;
  string email;
  string[] roleIds;
}

struct UpdateBusinessUserRequest
{
  string firstName;
  string lastName;
  string email;
  string status; // "active", "inactive", "locked"
  string[] roleIds;
}

// ─── Business Role DTOs ───

struct CreateBusinessRoleRequest
{
  TenantId tenantId;
  SystemInstanceId systemInstanceId;
  string name;
  string description;
  string roleType; // "unrestricted", "restricted", "custom"
  string[] restrictionTypes;
  CatalogAssignment[] assignedCatalogs;
}

struct UpdateBusinessRoleRequest
{
  string description;
  string roleType;
  string[] restrictionTypes;
  CatalogAssignment[] assignedCatalogs;
}

// ─── Transport Request DTOs ───

struct CreateTransportRequestRequest
{
  TenantId tenantId;
  SystemInstanceId sourceSystemId;
  string targetSystemId;
  string description;
  string owner;
  string transportType; // "workbench", "customizing", "transportOfCopies"
}

struct AddTransportTaskRequest
{
  string owner;
  string description;
  string[] objectList;
}

// ─── Application Job DTOs ───

struct CreateApplicationJobRequest
{
  TenantId tenantId;
  SystemInstanceId systemInstanceId;
  string name;
  string description;
  string jobTemplateName;
  string frequency; // "once", "hourly", "daily", "weekly", "monthly"
  long scheduledAt;
  string cronExpression;
  string[string] jobParameters;
}

struct UpdateApplicationJobRequest
{
  string description;
  string frequency;
  long scheduledAt;
  string cronExpression;
  bool active;
  string[string] jobParameters;
}
