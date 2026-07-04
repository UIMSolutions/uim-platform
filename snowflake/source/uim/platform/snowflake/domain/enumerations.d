/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.snowflake.domain.enumerations;

mixin(ShowModule!());

@safe:

/// Status of a provisioned SAP Snowflake account
enum AccountStatus : string {
  pending    = "pending",
  processing = "processing",
  active     = "active",
  inactive   = "inactive",
  failed     = "failed",
  suspended  = "suspended"
}

/// Status of a Zerocopy Connector
enum ConnectorStatus : string {
  pending    = "pending",
  enrolling  = "enrolling",
  active     = "active",
  error_     = "error",
  revoked    = "revoked"
}

/// Snowflake Virtual Warehouse sizes
enum WarehouseSize : string {
  xsmall   = "X-Small",
  small_   = "Small",
  medium   = "Medium",
  large_   = "Large",
  xlarge   = "X-Large",
  xxlarge  = "2X-Large",
  xxxlarge = "3X-Large",
  x4large  = "4X-Large",
  x5large  = "5X-Large",
  x6large  = "6X-Large"
}

/// Status of a Snowflake Virtual Warehouse
enum WarehouseStatus : string {
  started   = "started",
  suspended = "suspended",
  resizing  = "resizing",
  starting  = "starting",
  stopping  = "stopping"
}

/// Status of a Snowflake Database
enum DatabaseStatus : string {
  active   = "active",
  inactive = "inactive",
  dropped  = "dropped"
}

/// Status of a Data Product Share
enum ShareStatus : string {
  pending  = "pending",
  sharing  = "sharing",
  active   = "active",
  error_   = "error",
  revoked  = "revoked",
  syncing  = "syncing"
}

/// Status of a Provisioning Request
enum ProvisioningStatus : string {
  pending    = "pending",
  processing = "processing",
  completed  = "completed",
  failed     = "failed",
  cancelled  = "cancelled"
}

/// Roles of tenant users in the provisioning service
enum TenantUserRole : string {
  admin  = "admin",
  editor = "editor",
  viewer = "viewer"
}

/// Privilege types assignable to Snowflake roles
enum PrivilegeType : string {
  usage_        = "USAGE",
  select_       = "SELECT",
  insert_       = "INSERT",
  update_       = "UPDATE",
  delete_       = "DELETE",
  create_table  = "CREATE TABLE",
  create_schema = "CREATE SCHEMA",
  monitor_      = "MONITOR",
  operate_      = "OPERATE",
  modify_       = "MODIFY"
}
