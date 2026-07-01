/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.domain.entities.logic_flow;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

struct LogicFlow {
    mixin TenantEntity!(LogicFlowId);

    ApplicationId applicationId;
    PageId pageId;
    string name;
    string description;
    FlowTrigger trigger = FlowTrigger.componentEvent;
    FlowStatus status = FlowStatus.active;
    string triggerConfig;
    string nodes;
    string connections;
    string variables;
    string errorHandler;

    Json toJson() const {
        return entityToJson
            .set("applicationId", applicationId.value)
            .set("pageId", pageId.value)
            .set("name", name)
            .set("description", description)
            .set("trigger", trigger.to!string)
            .set("status", status.to!string)
            .set("triggerConfig", triggerConfig)
            .set("nodes", nodes)
            .set("connections", connections)
            .set("variables", variables)
            .set("errorHandler", errorHandler);
    }
}
