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
    LogicFlowId id;
    TenantId tenantId;
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
    string createdAt;
    string modifiedAt;
    string createdBy;
    string modifiedBy;

    Json logicFlowToJson() {
        return Json.emptyObject
            .set("id", id)
            .set("tenantId", tenantId)
            .set("applicationId", applicationId)
            .set("pageId", pageId)
            .set("name", name)
            .set("description", description)
            .set("trigger", trigger.to!string)
            .set("status", status.to!string)
            .set("triggerConfig", triggerConfig)
            .set("nodes", nodes)
            .set("connections", connections)
            .set("variables", variables)
            .set("errorHandler", errorHandler)
            .set("createdAt", createdAt)
            .set("modifiedAt", modifiedAt)
            .set("createdBy", createdBy)
            .set("modifiedBy", modifiedBy);
    }
}
