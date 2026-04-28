/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.domain.entities.event_schema;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

struct EventSchema {
    EventSchemaId id;
    TenantId tenantId;
    string name;
    string description;
    SchemaFormat format = SchemaFormat.json;
    SchemaStatus status = SchemaStatus.draft;
    string version_;
    string schemaContent;
    string applicationDomainId;
    string shared_;
    string versionCount;
    string latestVersion;
    UserId createdBy;
    UserId modifiedBy;
    string createdAt;
    string updatedAt;

    Json eventSchemaToJson() {
        return Json.emptyObject
            .set("id", id)
            .set("tenantId", tenantId)
            .set("name", name)
            .set("description", description)
            .set("format", format.to!string)
            .set("status", status.to!string)
            .set("version", version_)
            .set("schemaContent", schemaContent)
            .set("applicationDomainId", applicationDomainId)
            .set("shared", shared_)
            .set("versionCount", versionCount)
            .set("latestVersion", latestVersion)
            .set("createdBy", createdBy)
            .set("modifiedBy", modifiedBy)
            .set("createdAt", createdAt)
            .set("updatedAt", updatedAt);
    }
}
