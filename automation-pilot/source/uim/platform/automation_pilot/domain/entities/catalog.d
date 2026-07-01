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
    mixin TenantEntity!(CatalogId);

    string name;
    string description;
    CatalogStatus status = CatalogStatus.active;
    CatalogType catalogType = CatalogType.custom;
    string tags;
    string version_;
    string commandCount;

    Json toJson() const {
        return entityToJson
            .set("name", name)
            .set("description", description)
            .set("status", status.to!string)
            .set("catalogType", catalogType.to!string)
            .set("tags", tags)
            .set("version", version_)
            .set("commandCount", commandCount);
    }
}
