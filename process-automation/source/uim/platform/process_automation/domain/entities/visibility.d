/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.domain.entities.visibility;

import uim.platform.process_automation.domain.types;

struct VisibilityMetric {
    string id;
    string name;
    MetricType type;
    string sourceField;
    string unit;
    double warningThreshold;
    double criticalThreshold;
}

struct VisibilityFilter {
    string field;
    string operator;
    string value;
}

struct Visibility {
    VisibilityId id;
    TenantId tenantId;
    string name;
    string description;
    VisibilityStatus status;
    DashboardType dashboardType;
    ProcessId[] processIds;
    VisibilityMetric[] metrics;
    VisibilityFilter[] filters;
    string refreshIntervalSeconds;
    string createdBy;
    string modifiedBy;
    long createdAt;
    long modifiedAt;
}
