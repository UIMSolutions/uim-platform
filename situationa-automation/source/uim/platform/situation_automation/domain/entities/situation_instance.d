/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.domain.entities.situation_instance;

import uim.platform.situation_automation.domain.types;

struct ResolutionInfo {
    ResolutionType type;
    string resolvedBy;
    string actionId;
    string ruleId;
    string outcome;
    long resolvedAt;
}

struct SituationInstance {
    SituationInstanceId id;
    SituationTemplateId templateId;
    TenantId tenantId;
    string description;
    InstanceStatus status;
    SituationSeverity severity;
    string entityId;
    string entityTypeId;
    string[][] contextData;
    ResolutionInfo resolution;
    string assignedTo;
    string sourceSystem;
    string sourceInstanceId;
    int retryCount;
    long detectedAt;
    long dueAt;
    long modifiedAt;
}
