/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.domain.entities.dashboard;

import uim.platform.situation_automation.domain.types;

struct DashboardMetric {
    string name;
    MetricType type;
    string field;
    string filterExpression;
}

struct DashboardWidget {
    string id;
    string name;
    string widgetType;
    DashboardMetric[] metrics;
    string[] templateIds;
    int order;
}

struct Dashboard {
    DashboardId id;
    TenantId tenantId;
    string name;
    string description;
    DashboardType type;
    DashboardWidget[] widgets;
    TimeRange defaultTimeRange;
    int refreshIntervalSeconds;
    string createdBy;
    string modifiedBy;
    long createdAt;
    long modifiedAt;
}
