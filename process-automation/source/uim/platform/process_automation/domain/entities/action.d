/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.domain.entities.action;

import uim.platform.process_automation;

// mixin(ShowModule!());

@safe:

struct ActionParameter {
    string name;
    string type;
    bool required;
    string defaultValue;
    string description;

    Json toJson() const {
        return Json.emptyObject
            .set("name", name)
            .set("type", type)
            .set("required", required)
            .set("defaultValue", defaultValue)
            .set("description", description);
    }
}

struct ActionHeader {
    string name;
    string value;

    Json toJson() const {
        return Json.emptyObject
            .set("name", name)
            .set("value", value);
    }
}

struct Action {
    mixin TenantEntity!(ActionId);

    ProjectId projectId;
    string name;
    string description;
    ActionStatus status;
    ActionType type;
    HttpMethod method;
    string baseUrl;
    string path;
    ActionHeader[] headers;
    ActionParameter[] inputParameters;
    ActionParameter[] outputParameters;
    string authType;
    string destinationName;
    string version_;

    Json toJson() const {
        return entityToJson
            .set("projectId", projectId.value)
            .set("name", name)
            .set("description", description)
            .set("status", status.to!string)
            .set("type", type.to!string)
            .set("method", method.to!string)
            .set("baseUrl", baseUrl)
            .set("path", path)
            .set("headers", headers.map!(h => h.toJson()).array.toJson)
            .set("inputParameters", inputParameters.map!(p => p.toJson()).array.toJson)
            .set("outputParameters", outputParameters.map!(p => p.toJson()).array.toJson)
            .set("authType", authType)
            .set("destinationName", destinationName)
            .set("version_", version_);
    }
}
