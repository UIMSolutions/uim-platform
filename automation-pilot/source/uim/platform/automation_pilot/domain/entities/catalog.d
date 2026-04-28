/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.domain.entities.catalog;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

struct Catalog {
    CatalogId id;
    TenantId tenantId;
    string name;
    string description;
    CatalogStatus status = CatalogStatus.active;
    CatalogType catalogType = CatalogType.custom;
    string tags;
    string version_;
    string commandCount;
    UserId createdBy;
    UserId modifiedBy;
    string createdAt;
    string updatedAt;

    Json catalogToJson() {
        return Json.emptyObject
            .set("id", id)
            .set("tenantId", tenantId)
            .set("name", name)
            .set("description", description)
            .set("status", status.to!string)
            .set("catalogType", catalogType.to!string)
            .set("tags", tags)
            .set("version", version_)
            .set("commandCount", commandCount)
            .set("createdBy", createdBy)
            .set("modifiedBy", modifiedBy)
            .set("createdAt", createdAt)
            .set("updatedAt", updatedAt);
    }
}
