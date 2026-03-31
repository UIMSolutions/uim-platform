module uim.platform.analytics.domain.entities.widget;

import uim.platform.analytics.domain.values.common;
import uim.platform.analytics.domain.values.chart_type;
import uim.platform.analytics.domain.values.aggregation;
import uim.platform.analytics;

mixin(ShowModule!());
@safe:

/// A Widget is a single visualization component placed on a dashboard page or story section.
class Widget {
    EntityId id;
    string title;
    ChartType chartType;
    EntityId datasetId;
    WidgetBinding[] dimensions;
    WidgetBinding[] measures;
    FilterSpec[] filters;
    WidgetStyle style;
    AuditInfo audit;

    this() { }

    static Widget create(string title, ChartType chartType, string datasetId, string userId) {
        auto w = new Widget();
        w.id = EntityId.generate();
        w.title = title;
        w.chartType = chartType;
        w.datasetId = EntityId(datasetId);
        w.dimensions = [];
        w.measures = [];
        w.filters = [];
        w.style = WidgetStyle.init;
        w.audit = AuditInfo.create(userId);
        return w;
    }

    void bindDimension(string columnName) {
        dimensions ~= WidgetBinding(columnName, AggregationType.Count);
    }

    void bindMeasure(string columnName, AggregationType agg) {
        measures ~= WidgetBinding(columnName, agg);
    }

    void addFilter(string column, FilterOperator op, string[] vals) {
        filters ~= FilterSpec(column, op, vals);
    }
}

struct WidgetBinding {
    string columnName;
    AggregationType aggregation;
}

enum FilterOperator {
    Equals,
    NotEquals,
    GreaterThan,
    LessThan,
    Between,
    In,
    NotIn,
    Contains,
    IsNull,
    IsNotNull,
}

struct FilterSpec {
    string column;
    FilterOperator operator;
    string[] values;
}

struct WidgetStyle {
    int width = 6;
    int height = 4;
    int posX = 0;
    int posY = 0;
    string colorPalette = "default";
}
