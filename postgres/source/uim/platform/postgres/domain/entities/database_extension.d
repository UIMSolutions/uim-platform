/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.domain.entities.database_extension;

import uim.platform.postgres;
mixin(ShowModule!());

@safe:

struct DatabaseExtension {
    mixin TenantEntity!(DatabaseExtensionId);

    ServiceInstanceId instanceId;
    string extensionName;
    string extensionVersion;
    ExtensionStatus status;
    string schema_;     // D keyword avoidance

    Json toJson() const {
        return Json.emptyObject
            .set("id",               id.value)
            .set("tenantId",         tenantId.value)
            .set("instanceId",       instanceId.value)
            .set("extensionName",    extensionName)
            .set("extensionVersion", extensionVersion)
            .set("status",           status.to!string)
            .set("schema",           schema_)
            .set("createdAt",        createdAt)
            .set("createdBy",        createdBy.value)
            .set("updatedBy",        updatedBy.value);
    }
}
