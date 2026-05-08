/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.domain.entities.visibility;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:

struct VisibilityMetric {
    string id;
    string name;
    MetricType type;
    string sourceField;
    string unit;
    double warningThreshold;
    double criticalThreshold;

    Json toJson() const {
        return Json.emptyObject
            .set("id", id)
            .set("name", name)
            .set("type", type.toString())
            .set("sourceField", sourceField)
            .set("unit", unit)
            .set("warningThreshold", warningThreshold)
            .set("criticalThreshold", criticalThreshold);
    }
}

struct VisibilityFilter {
    string field;
    string operator;
    string value;

    Json toJson() const {
        return Json.emptyObject
            .set("field", field)
            .set("operator", operator)
            .set("value", value);
    }
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
            .set("status", status.to!string())
            .set("dashboardType", dashboardType.to!string())
            .set("processIds", processIds.map!(p => p.value).array.toJson)
            .set("metrics", metrics.map!(m => m.toJson()).array.toJson)
            .set("filters", filters.map!(f => f.toJson()).array.toJson)
            .set("refreshIntervalSeconds", refreshIntervalSeconds);

        return j;
    }
}
