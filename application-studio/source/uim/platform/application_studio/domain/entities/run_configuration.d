/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.domain.entities.run_configuration;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

struct RunConfiguration {
    RunConfigurationId id;
    TenantId tenantId;
    ProjectId projectId;
    string name;
    string description;
    RunMode mode = RunMode.run;
    RunStatus status = RunStatus.idle;
    string entryPoint;
    string arguments;
    string environmentVars;
    string port;
    string debugPort;
    string lastRunAt;
    string createdAt;
    string modifiedAt;
    string createdBy;
    string modifiedBy;

    Json runConfigurationToJson() {
        return Json.emptyObject
            .set("id", id)
            .set("tenantId", tenantId)
            .set("projectId", projectId)
            .set("name", name)
            .set("description", description)
            .set("mode", mode.to!string)
            .set("status", status.to!string)
            .set("entryPoint", entryPoint)
            .set("arguments", arguments)
            .set("environmentVars", environmentVars)
            .set("port", port)
            .set("debugPort", debugPort)
            .set("lastRunAt", lastRunAt)
            .set("createdAt", createdAt)
            .set("modifiedAt", modifiedAt)
            .set("createdBy", createdBy)
            .set("modifiedBy", modifiedBy);
    }
}
