/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.feature_flags.domain.entities.audit_entry;

import uim.platform.feature_flags;

mixin(ShowModule!());

@safe:

/// Immutable audit log entry written on every flag management operation.
struct AuditEntry {
    AuditEntryId id;
    TenantId     tenantId;

    AuditAction  action_;
    string       entityType;  /// "FeatureFlag" | "ServiceInstance"
    string       entityId;
    string       entityName;

    /// JSON snapshot of the payload that triggered the change (sanitised)
    string       payload;

    UserId       performedBy;
    string       performedAt;  /// ISO-8601 timestamp

    bool isNull() const { return id.isNull; }
}
