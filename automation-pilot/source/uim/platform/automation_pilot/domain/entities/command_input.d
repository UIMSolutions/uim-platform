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
    mixin TenantEntity!(CommandInputId);

    string name;
    string description;
    InputType inputType = InputType.string_;
    InputSensitivity sensitivity = InputSensitivity.normal;
    string keys;
    string values;
    string version_;
    string commandId;

    Json toJson() const {
        return entityToJson
            .set("name", name)
            .set("description", description)
            .set("inputType", inputType.to!string)
            .set("sensitivity", sensitivity.to!string)
            .set("keys", keys)
            .set("values", values)
            .set("version", version_)
            .set("commandId", commandId);
    }
}
