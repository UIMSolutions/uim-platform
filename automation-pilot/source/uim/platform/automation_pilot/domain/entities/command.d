/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.domain.entities.command;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

struct Command {
    mixin TenantEntity!(CommandId);

    CatalogId catalogId;
    string name;
    string description;
    CommandStatus status = CommandStatus.draft;
    CommandType commandType = CommandType.simple;
    string version_;
    string inputSchema;
    string outputSchema;
    string steps;
    string timeout;
    string retryCount;
    string tags;
    
    Json toJson() const {
        auto j = entityToJson
            .set("catalogId", catalogId)
            .set("name", name)
            .set("description", description)
            .set("status", status.to!string)
            .set("commandType", commandType.to!string)
            .set("version", version_)
            .set("inputSchema", inputSchema)
            .set("outputSchema", outputSchema)
            .set("steps", steps)
            .set("timeout", timeout)
            .set("retryCount", retryCount)
            .set("tags", tags);

        return j;
    }
}
