module uim.platform.analytics.app.dto.widget;

import std.conv : to;
import analytics.domain.entities.widget;
import analytics.domain.values.chart_type;

struct CreateWidgetRequest {
    string title;
    string chartType;
    string datasetId;
    string userId;
}

struct WidgetResponse {
    string id;
    string title;
    string chartType;
    string datasetId;

    static WidgetResponse fromEntity(Widget w) {
        if (w is null) return WidgetResponse.init;

        return WidgetResponse(
            w.id.value,
            w.title,
            w.chartType.to!string,
            w.datasetId.value,
        );
    }
}
