/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.domain.entities.dashboard;

// import uim.platform.situation_automation.domain.types;
import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:
struct DashboardMetric {
    string name;
    MetricType type;
    string field;
    string filterExpression;

    Json toJson() const {
        return Json.emptyObject
            .set("name", name)
            .set("type", type.toString())
            .set("field", field)
            .set("filterExpression", filterExpression);
    }
}

struct DashboardWidget {
    string id;
    string name;
    string widgetType;
    DashboardMetric[] metrics;
    string[] templateIds;
    int order;

    Json toJson() const {
        return Json.emptyObject
            .set("id", id)
            .set("name", name)
            .set("widgetType", widgetType)
            .set("metrics", metrics.map!(m => m.toJson()).array)
            .set("templateIds", templateIds.array)
            .set("order", order);
    }
}

struct Dashboard {
    mixin TenantEntity!(DashboardId);

    string name;
    string description;
    DashboardType type;
    DashboardWidget[] widgets;
    TimeRange defaultTimeRange;
    int refreshIntervalSeconds;

    Json toJson() const {
        auto j = entityToJson
            .set("name", name)
            .set("description", description)
            .set("type", type.toString())
            .set("widgets", widgets.map!(w => w.toJson()).array)
            .set("defaultTimeRange", Json.emptyObject
                    .set("startTime", defaultTimeRange.startTime)
                    .set("endTime", defaultTimeRange.endTime))
            .set("refreshIntervalSeconds", refreshIntervalSeconds);

        return j;
    }
}
