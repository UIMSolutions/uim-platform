/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.domain.entities.command_input;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

struct CommandInput {
    CommandInputId id;
    TenantId tenantId;
    string name;
    string description;
    InputType inputType = InputType.string_;
    InputSensitivity sensitivity = InputSensitivity.normal;
    string keys;
    string values;
    string version_;
    string commandId;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;

    Json commandInputToJson() {
        return Json.emptyObject
            .set("id", id)
            .set("tenantId", tenantId)
            .set("name", name)
            .set("description", description)
            .set("inputType", inputType.to!string)
            .set("sensitivity", sensitivity.to!string)
            .set("keys", keys)
            .set("values", sensitivity == InputSensitivity.secret ? "***" : values)
            .set("version", version_)
            .set("commandId", commandId)
            .set("createdBy", createdBy)
            .set("modifiedBy", modifiedBy)
            .set("createdAt", createdAt)
            .set("modifiedAt", modifiedAt);
    }
}
