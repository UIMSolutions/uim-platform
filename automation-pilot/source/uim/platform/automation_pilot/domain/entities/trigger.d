/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.domain.entities.trigger;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

struct Trigger {
    TriggerId id;
    TenantId tenantId;
    CommandId commandId;
    string name;
    string description;
    TriggerType triggerType = TriggerType.event;
    TriggerStatus status = TriggerStatus.active;
    string eventType;
    string eventSource;
    string filterExpression;
    string inputMapping;
    string webhookUrl;
    string lastTriggeredAt;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;

    Json triggerToJson() {
        return Json.emptyObject
            .set("id", id)
            .set("tenantId", tenantId)
            .set("commandId", commandId)
            .set("name", name)
            .set("description", description)
            .set("triggerType", triggerType.to!string)
            .set("status", status.to!string)
            .set("eventType", eventType)
            .set("eventSource", eventSource)
            .set("filterExpression", filterExpression)
            .set("inputMapping", inputMapping)
            .set("webhookUrl", webhookUrl)
            .set("lastTriggeredAt", lastTriggeredAt)
            .set("createdBy", createdBy)
            .set("modifiedBy", modifiedBy)
            .set("createdAt", createdAt)
            .set("modifiedAt", modifiedAt);
    }
}
