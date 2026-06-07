/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.domain.entities.configuration;

import uim.platform.postgres;

// mixin(ShowModule!());

@safe:

/// Instance-level PostgreSQL configuration.
/// auditLogLevels is a comma-separated list: "DDL,ROLE,DML"
struct Configuration {
    mixin TenantEntity!(ConfigurationId);

    ServiceInstanceId instanceId;
    string auditLogLevels;        // comma-separated: "DDL,ROLE"
    long   backupRetentionPeriod; // days
    string locale;                // e.g. "en_US"
    long   maxConnections;
    long   workMem;               // KB
    long   sharedBuffersMb;
    string maintenanceWindowDay;  // e.g. "Sunday"
    long   maintenanceWindowStartHour; // 0-23 UTC
    long   maintenanceWindowDuration;  // hours
    string activeVersion;

    Json toJson() const {
        return Json.emptyObject
            .set("id",                       id.value)
            .set("tenantId",                 tenantId.value)
            .set("instanceId",               instanceId.value)
            .set("auditLogLevels",           auditLogLevels)
            .set("backupRetentionPeriod",    backupRetentionPeriod)
            .set("locale",                   locale)
            .set("maxConnections",           maxConnections)
            .set("workMem",                  workMem)
            .set("sharedBuffersMb",          sharedBuffersMb)
            .set("maintenanceWindowDay",     maintenanceWindowDay)
            .set("maintenanceWindowStartHour", maintenanceWindowStartHour)
            .set("maintenanceWindowDuration", maintenanceWindowDuration)
            .set("activeVersion",            activeVersion)
            .set("createdAt",                createdAt)
            .set("createdBy",                createdBy.value)
            .set("updatedBy",                updatedBy.value);
    }
}
