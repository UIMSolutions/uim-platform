/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.domain.entities.backup_policy;

import uim.platform.redis;
mixin(ShowModule!());

@safe:

struct BackupPolicy {
    mixin TenantEntity!(BackupPolicyId);

    ServiceInstanceId instanceId;
    bool enabled;
    long intervalHours;
    long retentionDays;
    long lastBackupAt;
    long nextBackupAt;
    BackupStatus status;
    string backupLocation;
    string lastBackupId;
    string lastError;

    Json toJson() const {
        return Json.emptyObject
            .set("id",             id.value)
            .set("tenantId",       tenantId.value)
            .set("instanceId",     instanceId.value)
            .set("enabled",        enabled)
            .set("intervalHours",  intervalHours)
            .set("retentionDays",  retentionDays)
            .set("lastBackupAt",   lastBackupAt)
            .set("nextBackupAt",   nextBackupAt)
            .set("status",         status.to!string)
            .set("backupLocation", backupLocation)
            .set("lastBackupId",   lastBackupId)
            .set("lastError",      lastError)
            .set("createdAt",      createdAt)
            .set("createdBy",      createdBy.value)
            .set("updatedBy",      updatedBy.value);
    }
}
