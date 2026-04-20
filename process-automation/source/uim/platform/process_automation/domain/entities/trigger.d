/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.domain.entities.trigger;

import uim.platform.process_automation.domain.types;

struct ScheduleConfig {
    ScheduleFrequency frequency;
    string cronExpression;
    string startDate;
    string endDate;
    string timezone;
    int repeatCount;

    Json toJson() const {
        return Json()
            .set("frequency", frequency.toString())
            .set("cronExpression", cronExpression)
            .set("startDate", startDate)
            .set("endDate", endDate)
            .set("timezone", timezone)
            .set("repeatCount", repeatCount);
    }
}

struct WebhookConfig {
    string url;
    string secret;
    string[] allowedIps;
    string authType;

    Json toJson() const {
        return Json()
            .set("url", url)
            .set("secret", secret)
            .set("allowedIps", allowedIps.array)
            .set("authType", authType);
    }
}

struct Trigger {
    mixin TenantEntity!(TriggerId);

    ProcessId processId;
    string name;
    string description;
    TriggerType type;
    TriggerStatus status;
    ScheduleConfig schedule;
    WebhookConfig webhook;
    string eventType;
    string eventSource;
    string filterExpression;
    long lastFiredAt;
    long fireCount;

    Json toJson() const {
        return entityToJson()
            .set("processId", processId.value)
            .set("name", name)
            .set("description", description)
            .set("type", type.toString())
            .set("status", status.toString())
            .set("schedule", schedule.toJson())
            .set("webhook", webhook.toJson())
            .set("eventType", eventType)
            .set("eventSource", eventSource)
            .set("filterExpression", filterExpression)
            .set("lastFiredAt", lastFiredAt)
            .set("fireCount", fireCount);
    }
}
