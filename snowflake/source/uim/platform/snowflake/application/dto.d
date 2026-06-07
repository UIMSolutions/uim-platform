/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.snowflake.application.dto;

// mixin(ShowModule!());

@safe:

// --- SnowflakeAccount ---
struct CreateAccountRequest {
  TenantId tenantId;
  string id;
  string name;
  string region;
  string adminEmail;
  string adminFirstName;
  string adminLastName;
  string entitlementSystemId;
  string[string] metadata;
}
struct UpdateAccountRequest {
  TenantId tenantId;
  string id;
  string name;
  string status;
  string[string] metadata;
}

// --- ZerocopyConnector ---
struct CreateConnectorRequest {
  TenantId tenantId;
  string id;
  string accountId;
  string name;
  string invitationLink;
  string bdcTenantId;
  string description;
  string[string] metadata;
}
struct UpdateConnectorRequest {
  TenantId tenantId;
  string id;
  string name;
  string status;
  string description;
  string[string] metadata;
}
struct EnrollConnectorRequest {
  TenantId tenantId;
  string connectorId;
  string bdcTenantId;
}

// --- SnowflakeWarehouse ---
struct CreateWarehouseRequest {
  TenantId tenantId;
  string id;
  string accountId;
  string name;
  string size;
  int    autoSuspend;
  bool   autoResume;
  string comment;
  string[string] metadata;
}
struct UpdateWarehouseRequest {
  TenantId tenantId;
  string id;
  string size;
  string status;
  int    autoSuspend;
  bool   autoResume;
  string comment;
}

// --- SnowflakeDatabase ---
struct CreateDatabaseRequest {
  TenantId tenantId;
  string id;
  string accountId;
  string name;
  int    retentionDays;
  string comment;
  string[string] metadata;
}
struct UpdateDatabaseRequest {
  TenantId tenantId;
  string id;
  int    retentionDays;
  string status;
  string comment;
}

// --- DataProductShare ---
struct CreateShareRequest {
  TenantId tenantId;
  string id;
  string accountId;
  string connectorId;
  string dataProductId;
  string shareName;
  string comment;
  string[string] metadata;
}
struct UpdateShareRequest {
  TenantId tenantId;
  string id;
  string status;
  string comment;
}

// --- SnowflakeRole ---
struct CreateRoleRequest {
  string   tenantId;
  string   id;
  string   accountId;
  string   name;
  string   description;
  string[] privileges;
  string[string] metadata;
}
struct UpdateRoleRequest {
  string   tenantId;
  string   id;
  string   description;
  string[] privileges;
  bool     active;
}

// --- TenantUser ---
struct CreateTenantUserRequest {
  TenantId tenantId;
  string id;
  string email;
  string firstName;
  string lastName;
  string role;
  string externalUserId;
}
struct UpdateTenantUserRequest {
  TenantId tenantId;
  string id;
  string firstName;
  string lastName;
  string role;
  bool   active;
}

// --- ProvisioningRequest ---
struct CreateProvisioningRequest {
  TenantId tenantId;
  string id;
  UserId requestedBy;
  string accountName;
  string region;
  string adminEmail;
  string adminFirstName;
  string adminLastName;
  string[string] metadata;
}
struct UpdateProvisioningStatusRequest {
  TenantId tenantId;
  string id;
  string status;
  string resultAccountId;
  string errorMessage;
}
