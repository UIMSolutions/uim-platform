/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.snowflake.domain.types;

// mixin(ShowModule!());

@safe:

/// Unique identifier for a SnowflakeAccount
struct SnowflakeAccountId { string value; mixin IdTemplate; }

/// Unique identifier for a ZerocopyConnector
struct ZerocopyConnectorId { string value; mixin IdTemplate; }

/// Unique identifier for a SnowflakeWarehouse
struct SnowflakeWarehouseId { string value; mixin IdTemplate; }

/// Unique identifier for a SnowflakeDatabase
struct SnowflakeDatabaseId { string value; mixin IdTemplate; }

/// Unique identifier for a DataProductShare
struct DataProductShareId { string value; mixin IdTemplate; }

/// Unique identifier for a SnowflakeRole
struct SnowflakeRoleId { string value; mixin IdTemplate; }

/// Unique identifier for a TenantUser
struct SnowflakeTenantUserId { string value; mixin IdTemplate; }

/// Unique identifier for a ProvisioningRequest
struct ProvisioningRequestId { string value; mixin IdTemplate; }
