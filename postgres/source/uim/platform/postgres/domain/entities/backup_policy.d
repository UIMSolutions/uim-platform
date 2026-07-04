/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.domain.entities.backup_policy;

import uim.platform.postgres;

mixin(ShowModule!());

@safe:

struct BackupPolicy {
    mixin TenantEntity!(BackupPolicyId);

    ServiceInstanceId instanceId;
    long   retentionPeriod; // days
    string backupWindow;    // e.g. "04:00-05:00"
    long   lastBackupAt;
    long   nextBackupAt;
    BackupStatus status;
    string backupLocation;
    string lastError;

    Json toJson() const {
        return Json.emptyObject
            .set("id",              id.value)
            .set("tenantId",        tenantId.value)
            .set("instanceId",      instanceId.value)
            .set("retentionPeriod", retentionPeriod)
            .set("backupWindow",    backupWindow)
            .set("lastBackupAt",    lastBackupAt)
            .set("nextBackupAt",    nextBackupAt)
            .set("status",          status.to!string)
            .set("backupLocation",  backupLocation)
            .set("lastError",       lastError)
            .set("createdAt",       createdAt)
            .set("createdBy",       createdBy.value)
            .set("updatedBy",       updatedBy.value);
    }
}
