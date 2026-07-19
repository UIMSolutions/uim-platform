/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.domain.enumerations;

import uim.platform.datasphere_composer;
mixin(ShowModule!());

@safe:

/// Unification algorithm model
enum UnificationModel : string {
  deterministic = "DETERMINISTIC",
  probabilistic  = "PROBABILISTIC"
}

/// Status of a data product or data product provider
enum DataProductStatus : string {
  active   = "ACTIVE",
  inactive = "INACTIVE",
  pending  = "PENDING",
  error_   = "ERROR"
}

/// Status of a data provider
enum DataProviderStatus : string {
  active   = "ACTIVE",
  inactive = "INACTIVE",
  pending  = "PENDING"
}

/// Status of a composition run
enum CompositionRunStatus : string {
  pending   = "PENDING",
  running   = "RUNNING",
  completed = "COMPLETED",
  failed    = "FAILED",
  cancelled = "CANCELLED"
}

/// Transformation type for attribute mappings
enum TransformationType : string {
  none      = "NONE",
  toString_ = "TO_STRING",
  toNumber  = "TO_NUMBER",
  toDate    = "TO_DATE",
  trim      = "TRIM",
  upper     = "UPPER",
  lower     = "LOWER",
  append    = "APPEND",
  custom    = "CUSTOM"
}

/// Timestamp ingestion format
enum TimestampFormat : string {
  iso           = "ISO",
  unix_sec      = "UNIX_SEC",
  unix_milli    = "UNIX_MILLI",
  microsoft_json = "MICROSOFT_JSON",
  custom        = "CUSTOM"
}

/// Data quality rank (confidence level of incoming data)
enum DataQualityRank : string {
  critical = "CRITICAL",
  high     = "HIGH",
  medium   = "MEDIUM",
  low      = "LOW",
  minimal  = "MINIMAL"
}

/// Role of a tenant user
enum TenantUserRole : string {
  admin  = "ADMIN",
  editor = "EDITOR",
  viewer = "VIEWER"
}

/// Attribute data type in a schema
enum AttributeDataType : string {
  string_  = "STRING",
  number   = "NUMBER",
  integer  = "INTEGER",
  boolean_ = "BOOLEAN",
  date     = "DATE",
  datetime = "DATETIME",
  object_  = "OBJECT",
  array_   = "ARRAY"
}

/// Output data product publication status
enum OutputProductStatus : string {
  disabled = "DISABLED",
  enabling = "ENABLING",
  enabled  = "ENABLED",
  error_   = "ERROR"
}
