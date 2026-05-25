/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.snowflake.application.dto;

mixin(ShowModule!());

@safe:

// --- SnowflakeAccount ---
struct CreateAccountRequest {
  string tenantId;
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
  string tenantId;
  string id;
  string name;
  string status;
  string[string] metadata;
}

// --- ZerocopyConnector ---
struct CreateConnectorRequest {
  string tenantId;
  string id;
  string accountId;
  string name;
  string invitationLink;
  string bdcTenantId;
  string description;
  string[string] metadata;
}
struct UpdateConnectorRequest {
  string tenantId;
  string id;
  string name;
  string status;
  string description;
  string[string] metadata;
}
struct EnrollConnectorRequest {
  string tenantId;
  string connectorId;
  string bdcTenantId;
}

// --- SnowflakeWarehouse ---
struct CreateWarehouseRequest {
  string tenantId;
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
  string tenantId;
  string id;
  string size;
  string status;
  int    autoSuspend;
  bool   autoResume;
  string comment;
}

// --- SnowflakeDatabase ---
struct CreateDatabaseRequest {
  string tenantId;
  string id;
  string accountId;
  string name;
  int    retentionDays;
  string comment;
  string[string] metadata;
}
struct UpdateDatabaseRequest {
  string tenantId;
  string id;
  int    retentionDays;
  string status;
  string comment;
}

// --- DataProductShare ---
struct CreateShareRequest {
  string tenantId;
  string id;
  string accountId;
  string connectorId;
  string dataProductId;
  string shareName;
  string comment;
  string[string] metadata;
}
struct UpdateShareRequest {
  string tenantId;
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
  string tenantId;
  string id;
  string email;
  string firstName;
  string lastName;
  string role;
  string externalUserId;
}
struct UpdateTenantUserRequest {
  string tenantId;
  string id;
  string firstName;
  string lastName;
  string role;
  bool   active;
}

// --- ProvisioningRequest ---
struct CreateProvisioningRequest {
  string tenantId;
  string id;
  string requestedBy;
  string accountName;
  string region;
  string adminEmail;
  string adminFirstName;
  string adminLastName;
  string[string] metadata;
}
struct UpdateProvisioningStatusRequest {
  string tenantId;
  string id;
  string status;
  string resultAccountId;
  string errorMessage;
}
