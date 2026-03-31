module uim.platform.analytics.app.dto.widget;

import std.conv : to;
import uim.platform.analytics.domain.entities.widget;
import uim.platform.analytics.domain.values.chart_type;
import uim.platform.analytics;

mixin(ShowModule!());
@safe:

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
    if (w is null)
      return WidgetResponse.init;

    return WidgetResponse(
      w.id.value,
      w.title,
      w.chartType.to!string,
      w.datasetId.value,
    );
  }
}
