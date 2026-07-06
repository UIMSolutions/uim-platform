/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.snowflake.domain.types;

mixin(ShowModule!());

@safe:

/// Unique identifier for a SnowflakeAccount
struct SnowflakeAccountId { mixin(IdTemplate); }

/// Unique identifier for a ZerocopyConnector
struct ZerocopyConnectorId { mixin(IdTemplate); }

/// Unique identifier for a SnowflakeWarehouse
struct SnowflakeWarehouseId { mixin(IdTemplate); }

/// Unique identifier for a SnowflakeDatabase
struct SnowflakeDatabaseId { mixin(IdTemplate); }

/// Unique identifier for a DataProductShare
struct DataProductShareId { mixin(IdTemplate); }

/// Unique identifier for a SnowflakeRole
struct SnowflakeRoleId { mixin(IdTemplate); }

/// Unique identifier for a TenantUser
struct SnowflakeTenantUserId { mixin(IdTemplate); }

/// Unique identifier for a ProvisioningRequest
struct ProvisioningRequestId { mixin(IdTemplate); }
