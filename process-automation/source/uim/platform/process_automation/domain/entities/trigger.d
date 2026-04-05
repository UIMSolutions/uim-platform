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
}

struct WebhookConfig {
    string url;
    string secret;
    string[] allowedIps;
    string authType;
}

struct Trigger {
    TriggerId id;
    ProcessId processId;
    TenantId tenantId;
    string name;
    string description;
    TriggerType type;
    TriggerStatus status;
    ScheduleConfig schedule;
    WebhookConfig webhook;
    string eventType;
    string eventSource;
    string filterExpression;
    string createdBy;
    long createdAt;
    long modifiedAt;
    long lastFiredAt;
    long fireCount;
}
