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
    mixin TenantEntity!EventSchemaId;
    
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

    Json toJson() const {
        return entityToJson
            .set("name", name)
            .set("description", description)
            .set("format", format.to!string)
            .set("status", status.to!string)
            .set("version", version_)
            .set("schemaContent", schemaContent)
            .set("applicationDomainId", applicationDomainId)
            .set("shared", shared_)
            .set("versionCount", versionCount)
            .set("latestVersion", latestVersion);
    }
}
