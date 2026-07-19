/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.domain.types;
import uim.platform.auditlog;
mixin(ShowModule!());
@safe:
/// Unique identifier type aliases for type safety.
struct AuditLogId {
  mixin(IdTemplate);
}

/// Strongly-typed identifier for a Data Access Log aggregate root.
struct DataAccessLogId {
  mixin(IdTemplate);
}

/// Strongly-typed identifier for a Data Change Log aggregate root.
struct DataChangeLogId {
  mixin(IdTemplate);
}

/// Strongly-typed identifier for a Data Export Log aggregate root.
struct DataExportLogId {
  mixin(IdTemplate);
}

/// Strongly-typed identifier for a Data Import Log aggregate root.
struct DataImportLogId {
  mixin(IdTemplate);
}

/// Strongly-typed identifier for a Data Retention Log aggregate root.
struct DataRetentionLogId {
  mixin(IdTemplate);
}

/// Strongly-typed identifier for a Data Retention Policy aggregate root.
struct RetentionPolicyId {
  mixin(IdTemplate);
}

/// Strongly-typed identifier for an Audit Config aggregate root.
struct AuditConfigId {
  mixin(IdTemplate);
}

/// Strongly-typed identifier for a Config Change Log aggregate root. 
struct ConfigChangeLogId {
  mixin(IdTemplate);
}

/// Strongly-typed identifier for a Data Export Job aggregate root.
struct ExportJobId {
  mixin(IdTemplate);
}

/// Strongly-typed identifier for a Data Import Job aggregate root.
struct ImportJobId {
  mixin(IdTemplate);
}

/// Strongly-typed identifier for a Service aggregate root.
struct ServiceId {
  mixin(IdTemplate);
}

/// Strongly-typed identifier for a Security Event aggregate root.
struct SecurityEventId {
  mixin(IdTemplate);
}


