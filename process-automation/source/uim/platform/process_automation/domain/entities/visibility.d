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
    mixin TenantEntity!(VisibilityId);

    string name;
    string description;
    VisibilityStatus status;
    DashboardType dashboardType;
    ProcessId[] processIds;
    VisibilityMetric[] metrics;
    VisibilityFilter[] filters;
    string refreshIntervalSeconds;

    Json toJson() const {
        auto j = entityToJson
            .set("name", name)
            .set("description", description)
            .set("status", status.toString())
            .set("dashboardType", dashboardType.toString())
            .set("processIds", processIds.map!(p => p.value).array)
            .set("metrics", metrics.map!(m => Json.init
                .set("id", m.id)
                .set("name", m.name)
                .set("type", m.type.toString())
                .set("sourceField", m.sourceField)
                .set("unit", m.unit)
                .set("warningThreshold", m.warningThreshold)
                .set("criticalThreshold", m.criticalThreshold)).array)
            .set("filters", filters.map!(f => Json.init
                .set("field", f.field)
                .set("operator", f.operator)
                .set("value", f.value)).array)
            .set("refreshIntervalSeconds", refreshIntervalSeconds);

        return j;
    }
}
