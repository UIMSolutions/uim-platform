/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.application.dto;

import uim.platform.abap_environment.domain.types;
import uim.platform.abap_environment.domain.entities.communication_arrangement : CommunicationEndpoint;
import uim.platform.abap_environment.domain.entities.service_binding : ExposedEndpoint;
import uim.platform.abap_environment.domain.entities.business_user : RoleAssignment;
import uim.platform.abap_environment.domain.entities.business_role : CatalogAssignment;
import uim.platform.abap_environment.domain.entities.transport_request : TransportTask;

// ─── System Instance DTOs ───

struct CreateSystemInstanceRequest {
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

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("subaccountId", subaccountId.value)
      .set("name", name)
      .set("description", description)
      .set("plan", plan)
      .set("region", region)
      .set("sapSystemId", sapSystemId)
      .set("adminEmail", adminEmail)
      .set("abapRuntimeSize", abapRuntimeSize)
      .set("hanaMemorySize", hanaMemorySize)
      .set("softwareVersion", softwareVersion)
      .set("stackVersion", stackVersion);
  }
}

struct UpdateSystemInstanceRequest {
  string description;
  string status; // lifecycle transition target
  ushort abapRuntimeSize;
  ushort hanaMemorySize;
  string softwareVersion;

  Json toJson() const {
    return Json.emptyObject
      .set("description", description)
      .set("status", status)
      .set("abapRuntimeSize", abapRuntimeSize)
      .set("hanaMemorySize", hanaMemorySize)
      .set("softwareVersion", softwareVersion);
  }
}

// ─── Software Component DTOs ───

struct CreateSoftwareComponentRequest {
  TenantId tenantId;
  SystemInstanceId systemInstanceId;
  string name;
  string description;
  string componentType; // "developmentPackage", "businessConfiguration", ...
  string repositoryUrl;
  string branch;
  string branchStrategy;
  string namespace;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("systemInstanceId", systemInstanceId.value)
      .set("name", name)
      .set("description", description)
      .set("componentType", componentType)
      .set("repositoryUrl", repositoryUrl)
      .set("branch", branch)
      .set("branchStrategy", branchStrategy)
      .set("namespace", namespace);
  }
}

struct CloneSoftwareComponentRequest {
  string branch;
  string commitId;

  Json toJson() const {
    return Json.emptyObject
      .set("branch", branch)
      .set("commitId", commitId);
  }
}

struct PullSoftwareComponentRequest {
  string commitId;

  Json toJson() const {
    return Json.emptyObject
      .set("commitId", commitId);
  }

}

// ─── Communication Arrangement DTOs ───

struct CreateCommunicationArrangementRequest {
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

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("systemInstanceId", systemInstanceId.value)
      .set("scenarioId", scenarioId.value)
      .set("name", name)
      .set("description", description)
      .set("direction", direction)
      .set("authMethod", authMethod)
      .set("communicationUser", communicationUser)
      .set("communicationPassword", communicationPassword)
      .set("clientId", clientId)
      .set("clientSecret", clientSecret)
      .set("tokenEndpoint", tokenEndpoint)
      .set("certificateId", certificateId)
      .set("inboundServices", inboundServices.map!(s => s.toJson()).array)
      .set("outboundServices", outboundServices.map!(s => s.toJson()).array);
  }
}

struct UpdateCommunicationArrangementRequest {
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

  Json toJson() const {
    return Json.emptyObject
      .set("description", description)
      .set("status", status)
      .set("authMethod", authMethod)
      .set("communicationUser", communicationUser)
      .set("communicationPassword", communicationPassword)
      .set("clientId", clientId)
      .set("clientSecret", clientSecret)
      .set("tokenEndpoint", tokenEndpoint)
      .set("inboundServices", inboundServices.map!(s => s.toJson()).array)
      .set("outboundServices", outboundServices.map!(s => s.toJson()).array);
  }
}

// ─── Service Binding DTOs ───

struct CreateServiceBindingRequest {
  TenantId tenantId;
  SystemInstanceId systemInstanceId;
  ServiceDefinitionId serviceDefinitionId;
  string name;
  string description;
  string bindingType; // "odataV2", "odataV4", ...
  ExposedEndpoint[] endpoints;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("systemInstanceId", systemInstanceId.value)
      .set("serviceDefinitionId", serviceDefinitionId.value)
      .set("name", name)
      .set("description", description)
      .set("bindingType", bindingType)
      .set("endpoints", endpoints.map!(e => e.toJson()).array);
  }
}

struct UpdateServiceBindingRequest {
  string description;
  string status; // "active", "inactive", "deprecated_"
  ExposedEndpoint[] endpoints;

  Json toJson() const {
    return Json.emptyObject
      .set("description", description)
      .set("status", status)
      .set("endpoints", endpoints.map!(e => e.toJson()).array);
  }
}

// ─── Business User DTOs ───

struct CreateBusinessUserRequest {
  TenantId tenantId;
  SystemInstanceId systemInstanceId;
  string username;
  string firstName;
  string lastName;
  string email;
  string[] roleIds;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("systemInstanceId", systemInstanceId.value)
      .set("username", username)
      .set("firstName", firstName)
      .set("lastName", lastName)
      .set("email", email)
      .set("roleIds", roleIds.array);
  }
}

struct UpdateBusinessUserRequest {
  string firstName;
  string lastName;
  string email;
  string status; // "active", "inactive", "locked"
  string[] roleIds;

  Json toJson() const {
    return Json.emptyObject
      .set("firstName", firstName)
      .set("lastName", lastName)
      .set("email", email)
      .set("status", status)
      .set("roleIds", roleIds.array);
  }
}

// ─── Business Role DTOs ───

struct CreateBusinessRoleRequest {
  TenantId tenantId;
  SystemInstanceId systemInstanceId;
  string name;
  string description;
  string roleType; // "unrestricted", "restricted", "custom"
  string[] restrictionTypes;
  CatalogAssignment[] assignedCatalogs;

  Json toJson() const {
    return Json.emptyObject.set("tenantId", tenantId.value)
      .set("systemInstanceId", systemInstanceId.value)
      .set("name", name)
      .set("description", description)
      .set("roleType", roleType)
      .set("restrictionTypes", restrictionTypes.array)
      .set("assignedCatalogs", assignedCatalogs.map!(c => c.toJson()).array);

  }
}

struct UpdateBusinessRoleRequest {
  string description;
  string roleType;
  string[] restrictionTypes;
  CatalogAssignment[] assignedCatalogs;
}

// ─── Transport Request DTOs ───

struct CreateTransportRequestRequest {
  TenantId tenantId;
  SystemInstanceId sourceSystemId;
  string targetSystemId;
  string description;
  string owner;
  string transportType; // "workbench", "customizing", "transportOfCopies"
}

struct AddTransportTaskRequest {
  string owner;
  string description;
  string[] objectList;
}

// ─── Application Job DTOs ───

struct CreateApplicationJobRequest {
  TenantId tenantId;
  SystemInstanceId systemInstanceId;
  string name;
  string description;
  string jobTemplateName;
  string frequency; // "once", "hourly", "daily", "weekly", "monthly"
  long scheduledAt;
  string cronExpression;
  string[string] jobParameters;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("systemInstanceId", systemInstanceId.value)
      .set("name", name)
      .set("description", description)
      .set("jobTemplateName", jobTemplateName)
      .set("frequency", frequency)
      .set("scheduledAt", scheduledAt)
      .set("cronExpression", cronExpression)
      .set("jobParameters", jobParameters);
  }
}

struct UpdateApplicationJobRequest {
  string description;
  string frequency;
  long scheduledAt;
  string cronExpression;
  bool active;
  string[string] jobParameters;

  Json toJson() const {
    return Json.emptyObject
      .set("description", description)
      .set("frequency", frequency)
      .set("scheduledAt", scheduledAt)
      .set("cronExpression", cronExpression)
      .set("active", active)
      .set("jobParameters", jobParameters);
  }
}
