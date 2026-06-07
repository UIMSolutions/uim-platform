/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.domain.enumerations;

import uim.platform.postgres;

// mixin(ShowModule!());

@safe:

enum InstanceStatus : string {
    provisioning = "provisioning",
    active       = "active",
    failed       = "failed",
    updating     = "updating",
    deleting     = "deleting",
    deleted_     = "deleted"
}

enum BindingStatus : string {
    active   = "active",
    failed   = "failed",
    deleted_ = "deleted"
}

enum PlanTier : string {
    standard = "standard",
    premium  = "premium"
}

enum Hyperscaler : string {
    aws      = "aws",
    azure    = "azure",
    gcp      = "gcp",
    alicloud = "alicloud"
}

enum PostgresVersion : string {
    v13 = "13",
    v14 = "14",
    v15 = "15",
    v16 = "16"
}

enum SslMode : string {
    disable     = "disable",
    allow       = "allow",
    prefer      = "prefer",
    require     = "require",
    verify_ca   = "verify-ca",
    verify_full = "verify-full"
}

enum BackupStatus : string {
    enabled   = "enabled",
    disabled_ = "disabled",
    running   = "running",
    failed    = "failed",
    succeeded = "succeeded"
}

enum UserStatus : string {
    active   = "active",
    inactive_ = "inactive",
    locked   = "locked"
}

enum UserRole : string {
    readonly    = "readonly",
    readwrite   = "readwrite",
    admin       = "admin",
    replication = "replication"
}

enum ExtensionStatus : string {
    enabled   = "enabled",
    disabled_ = "disabled",
    failed    = "failed"
}

enum MaintenanceStatus : string {
    scheduled    = "scheduled",
    in_progress  = "in_progress",
    completed_   = "completed",
    cancelled_   = "cancelled"
}
