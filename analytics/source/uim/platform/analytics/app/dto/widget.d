/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.app.dto.widget;

// import std.conv : to;
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

  static WidgetResponse fromEntity(Widget w)
  {
    if (w is null)
      return WidgetResponse.init;

    return WidgetResponse(w.id.value, w.title, w.chartType.to!string, w.datasetId.value,);
  }
}
