/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.app.usecases.widgets;
// import uim.platform.analytics.domain.entities.widget;
// import uim.platform.analytics.domain.repositories.widget;
// import uim.platform.analytics.domain.values.common;
// import uim.platform.analytics.domain.values.chart_type;
// import uim.platform.analytics.app.dto.widget;


import uim.platform.analytics;

mixin(ShowModule!());
@safe:
class WidgetUseCases {
  private WidgetRepository repo;

  this(WidgetRepository repo) {
    this.repo = repo;
  }

  WidgetResponse createWidget(CreateWidgetRequest req) {
    ChartType ct;
    try {
      ct = req.chartType.to!ChartType;
    }
    catch (Exception) {
      ct = ChartType.Bar;
    }
    auto w = Widget.create(req.title, ct, req.datasetId, req.userId);
    repo.save(w);
    return WidgetResponse.fromEntity(w);
  }

  WidgetResponse getWidget(string id) {
    auto found = repo.findAll().filter!(e => e.id.value == id).array;
    return WidgetResponse.fromEntity(found.empty ? Widget.init : found[0]);
  }

  WidgetResponse[] listWidgets() {
    WidgetResponse[] result;
    foreach (w; repo.findAll())
      result ~= WidgetResponse.fromEntity(w);
    return result;
  }

  CommandResult deleteWidget(string id) {
    auto found = repo.findAll().filter!(e => e.id.value == id).array;
    if (!found.empty) repo.remove(found[0]);
    return CommandResult(true, id, "");
  }
}
